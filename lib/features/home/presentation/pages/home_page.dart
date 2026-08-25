import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_branding.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../shared/domain/entities/patient_feature.dart';
import '../../../api_data/presentation/pages/hospital_resource_directory_page.dart';
import '../../../api_data/presentation/pages/patient_personal_records_page.dart';
import '../../../api_data/presentation/pages/patient_profile_page.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../../../booking/presentation/pages/my_queue_history_page.dart';
import '../cubit/home_cubit.dart';
import '../widgets/feature_grid_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (BuildContext context, HomeState homeState) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (BuildContext context, AuthState authState) {
                if (homeState.isLoading) {
                  return const Center(
                    child: AppLoadingIndicator(message: 'Memuat layanan...'),
                  );
                }

                final List<PatientFeature> filteredFeatures =
                    homeState.filteredFeatureItems;
                final List<PatientFeature> visibleFeatures = filteredFeatures
                    .where(
                      (PatientFeature feature) =>
                          feature.id != 'booking_dokter',
                    )
                    .toList();

                return RefreshIndicator(
                  onRefresh: context.read<HomeCubit>().loadInitialData,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: _HomeHero(authState: authState),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.large,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.90,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(-2, -2),
                                      ),
                                      BoxShadow(
                                        color: AppColors.deepTeal.withValues(
                                          alpha: 0.20,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    onChanged: context
                                        .read<HomeCubit>()
                                        .updateSearchQuery,
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Cari menu atau layanan pasien...',
                                      prefixIcon: Icon(Icons.search_rounded),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (homeState.errorMessage != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.large),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  AppSpacing.medium,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      homeState.errorMessage!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: AppColors.danger),
                                    ),
                                    const SizedBox(height: AppSpacing.small),
                                    OutlinedButton(
                                      onPressed: context
                                          .read<HomeCubit>()
                                          .loadInitialData,
                                      child: const Text('Muat Ulang'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: 'Menu Layanan Utama',
                          subtitle: '',
                        ),
                      ),
                      if (visibleFeatures.isEmpty)
                        const SliverToBoxAdapter(
                          child: _EmptyStateWidget(
                            message:
                                'Tidak ada menu yang sesuai dengan kata kunci pencarian.',
                          ),
                        ),
                      if (visibleFeatures.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.large,
                            10,
                            AppSpacing.large,
                            0,
                          ),
                          sliver: SliverGrid(
                            gridDelegate: _featureGridDelegate(),
                            delegate: SliverChildBuilderDelegate((
                              BuildContext context,
                              int index,
                            ) {
                              final PatientFeature feature =
                                  visibleFeatures[index];
                              return FeatureGridTile(
                                feature: feature,
                                isLocked:
                                    feature.requiresLogin &&
                                    !authState.isAuthenticated,
                                onTap: () => _handleFeatureTap(
                                  context,
                                  feature,
                                  authState.isAuthenticated,
                                ),
                              );
                            }, childCount: visibleFeatures.length),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 110)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  SliverGridDelegateWithMaxCrossAxisExtent _featureGridDelegate() {
    return const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 104,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.82,
    );
  }

  Future<void> _handleFeatureTap(
    BuildContext context,
    PatientFeature feature,
    bool isAuthenticated,
  ) async {
    if (feature.requiresLogin && !isAuthenticated) {
      await _showLoginRequiredSheet(context);
      return;
    }

    final Widget? targetPage = _resolveFeaturePage(feature);
    if (targetPage != null) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => targetPage));
      return;
    }

    await _showFeaturePreview(context, feature);
  }

  Widget? _resolveFeaturePage(PatientFeature feature) {
    switch (feature.id) {
      case 'profil_pasien':
        return const PatientProfilePage();
      case 'riwayat_kunjungan':
        return const PatientVisitHistoryPage();
      case 'riwayat_penyakit':
        return const PatientMedicalSummaryPage();
      case 'hasil_lab':
        return const PatientLaboratoryResultsPage();
      case 'hasil_radiologi':
        return const PatientRadiologyResultsPage();
      case 'resep_obat':
        return const PatientPrescriptionPage();
      case 'poli_jadwal':
        return const HospitalResourceDirectoryPage.polyclinic();
      case 'nomor_antrian':
        return const MyQueueHistoryPage();
      case 'ketersediaan_kamar':
        return const HospitalResourceDirectoryPage.room();
      default:
        return null;
    }
  }

  Future<void> _showLoginRequiredSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final double bottomInset = MediaQuery.viewPaddingOf(
          sheetContext,
        ).bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.medium,
            AppSpacing.large,
            AppSpacing.large + bottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const BrandLogo(size: 52, borderRadius: 16),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Fitur ini memerlukan login',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                'Login untuk membuka fitur medis personal seperti booking, rekam medis, resep, dan transaksi pasien.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.large),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const AuthPage()),
                    );
                  },
                  child: const Text('Login Sekarang'),
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Nanti Saja'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showFeaturePreview(
    BuildContext context,
    PatientFeature feature,
  ) {
    final Color accentColor = _resolveCategoryColor(feature.category);

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final double bottomInset = MediaQuery.viewPaddingOf(
          sheetContext,
        ).bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.medium,
            AppSpacing.large,
            AppSpacing.large + bottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.80),
                      blurRadius: 3,
                      offset: const Offset(-2, -2),
                    ),
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(feature.icon, color: accentColor, size: 20),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              ...feature.dummyDetails.map(
                (String detail) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          detail,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (feature.links.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xSmall),
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: feature.links
                      .map(
                        (PatientFeatureLink link) => ActionChip(
                          avatar: Icon(
                            _resolveFeatureLinkIcon(link.type),
                            color: accentColor,
                            size: 18,
                          ),
                          label: Text(link.label),
                          labelStyle: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.textPrimary),
                          backgroundColor: accentColor.withValues(alpha: 0.08),
                          side: BorderSide(
                            color: accentColor.withValues(alpha: 0.26),
                          ),
                          onPressed: () => _openFeatureLink(context, link),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.large),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _resolveCategoryColor(FeatureCategory category) {
    switch (category) {
      case FeatureCategory.dataRekamMedis:
      case FeatureCategory.pembayaranTransaksi:
        return AppColors.primaryRed;
      case FeatureCategory.bookingAntrian:
      case FeatureCategory.resepObat:
        return AppColors.primaryGreen;
      case FeatureCategory.informasiRumahSakit:
      case FeatureCategory.informasiDokter:
      case FeatureCategory.informasiBiaya:
      case FeatureCategory.edukasiKesehatan:
        return AppColors.primaryBlue;
    }
  }
}

Future<void> _openFeatureLink(
  BuildContext context,
  PatientFeatureLink link,
) async {
  final Uri uri = _resolveFeatureLinkUri(link);

  try {
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      showAppSnackBar(
        context,
        _resolveFeatureLinkErrorMessage(link.type),
        backgroundColor: AppColors.danger,
      );
    }
  } on Object {
    if (!context.mounted) {
      return;
    }
    showAppSnackBar(
      context,
      _resolveFeatureLinkErrorMessage(link.type),
      backgroundColor: AppColors.danger,
    );
  }
}

Uri _resolveFeatureLinkUri(PatientFeatureLink link) {
  switch (link.type) {
    case PatientFeatureLinkType.email:
      return Uri(
        scheme: 'mailto',
        path: link.value,
        queryParameters: <String, String>{
          'subject': 'Informasi ${AppBranding.hospitalShortName}',
        },
      );
    case PatientFeatureLinkType.phone:
      return Uri(scheme: 'tel', path: link.value);
    case PatientFeatureLinkType.maps:
    case PatientFeatureLinkType.website:
      return Uri.parse(link.value);
  }
}

IconData _resolveFeatureLinkIcon(PatientFeatureLinkType type) {
  switch (type) {
    case PatientFeatureLinkType.maps:
      return Icons.map_outlined;
    case PatientFeatureLinkType.email:
      return Icons.alternate_email_rounded;
    case PatientFeatureLinkType.phone:
      return Icons.call_outlined;
    case PatientFeatureLinkType.website:
      return Icons.language_rounded;
  }
}

String _resolveFeatureLinkErrorMessage(PatientFeatureLinkType type) {
  switch (type) {
    case PatientFeatureLinkType.maps:
      return 'Google Maps belum bisa dibuka.';
    case PatientFeatureLinkType.email:
      return 'Aplikasi email belum bisa dibuka.';
    case PatientFeatureLinkType.phone:
      return 'Aplikasi telepon belum bisa dibuka.';
    case PatientFeatureLinkType.website:
      return 'Website belum bisa dibuka.';
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    final String greetingName = authState.identity?.fullName.isNotEmpty == true
        ? authState.identity!.fullName
        : 'Tamu';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, AppSpacing.medium),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(42),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.70),
              blurRadius: 5,
              offset: const Offset(-2, -2),
            ),
            BoxShadow(
              color: AppColors.deepTeal.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(42),
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 250),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.hospitalPhoto1,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          AppColors.primaryTeal.withValues(alpha: 0.88),
                          AppColors.deepTeal.withValues(alpha: 0.86),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 52, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const PartnerLogos(height: 50),
                          const Spacer(),
                          _HeroActionPill(
                            icon: Icons.person_rounded,
                            label: authState.isAuthenticated
                                ? 'Akun Aktif'
                                : 'Mode Tamu',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(
                              authState.isAuthenticated
                                  ? Icons.person_rounded
                                  : Icons.person_outline_rounded,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.small),
                          Text(
                            'Halo, $greetingName',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        'Selamat datang di',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        AppBranding.appName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xSmall),
                      Text(
                        AppBranding.hospitalLongName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.90),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Wrap(
                        spacing: AppSpacing.small,
                        runSpacing: AppSpacing.small,
                        children: <Widget>[
                          _HeroPill(
                            icon: Icons.location_on_outlined,
                            label: 'Soreang (Maps)',
                            onTap: () => _openFeatureLink(
                              context,
                              const PatientFeatureLink(
                                label: 'Soreang (Maps)',
                                value: AppBranding.mapsUrl,
                                type: PatientFeatureLinkType.maps,
                              ),
                            ),
                          ),
                          _HeroPill(
                            icon: Icons.language_outlined,
                            label: 'Website Resmi',
                            onTap: () => _openFeatureLink(
                              context,
                              const PatientFeatureLink(
                                label: 'Website Resmi',
                                value: AppBranding.website,
                                type: PatientFeatureLinkType.website,
                              ),
                            ),
                          ),
                          _HeroPill(
                            icon: Icons.account_circle_outlined,
                            label: authState.isAuthenticated
                                ? 'Layanan personal aktif'
                                : 'Login untuk akses penuh',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(20);
    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: onTap == null ? 0.14 : 0.18),
        borderRadius: borderRadius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.deepTeal.withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: borderRadius, child: content),
    );
  }
}

class _HeroActionPill extends StatelessWidget {
  const _HeroActionPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.deepTeal.withValues(alpha: 0.24),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.medium,
        AppSpacing.large,
        2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (subtitle.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}
