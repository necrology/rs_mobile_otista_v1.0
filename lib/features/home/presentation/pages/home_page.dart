import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_branding.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../shared/domain/entities/patient_feature.dart';
import '../../../api_data/presentation/pages/employee_directory_page.dart';
import '../../../api_data/presentation/pages/hospital_resource_directory_page.dart';
import '../../../api_data/presentation/pages/patient_directory_page.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../cubit/home_cubit.dart';
import '../widgets/feature_grid_tile.dart';
import '../widgets/hospital_data_card.dart';

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
                  return const Center(child: CircularProgressIndicator());
                }

                final List<PatientFeature> filteredFeatures =
                    homeState.filteredFeatureItems;
                final List<MapEntry<FeatureCategory, List<PatientFeature>>>
                groupedEntries = _groupFeatures(filteredFeatures);

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
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.small),
                              child: TextField(
                                onChanged: context
                                    .read<HomeCubit>()
                                    .updateSearchQuery,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Cari menu, layanan, atau data RS...',
                                  prefixIcon: Icon(Icons.search_rounded),
                                ),
                              ),
                            ),
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
                          title: 'Menu Layanan',
                          subtitle:
                              'Akses cepat fitur pasien, informasi dokter, dan layanan publik rumah sakit.',
                        ),
                      ),
                      if (groupedEntries.isEmpty)
                        const SliverToBoxAdapter(
                          child: _EmptyStateWidget(
                            message:
                                'Tidak ada menu yang sesuai dengan kata kunci pencarian.',
                          ),
                        ),
                      ...groupedEntries.expand((
                        MapEntry<FeatureCategory, List<PatientFeature>> entry,
                      ) {
                        final int crossAxisCount =
                            MediaQuery.sizeOf(context).width >= 430 ? 4 : 3;

                        return <Widget>[
                          SliverToBoxAdapter(
                            child: _CategoryHeader(
                              category: entry.key,
                              itemCount: entry.value.length,
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.large,
                            ),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: AppSpacing.small,
                                    crossAxisSpacing: AppSpacing.small,
                                    childAspectRatio: 0.92,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                BuildContext context,
                                int index,
                              ) {
                                final PatientFeature feature =
                                    entry.value[index];
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
                              }, childCount: entry.value.length),
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppSpacing.small),
                          ),
                        ];
                      }),
                      const SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: 'Identitas Rumah Sakit',
                          subtitle:
                              'Informasi resmi RSUD Oto Iskandar Di Nata Kabupaten Bandung.',
                        ),
                      ),
                      if (homeState.filteredHospitalDataItems.isEmpty)
                        const SliverToBoxAdapter(
                          child: _EmptyStateWidget(
                            message:
                                'Tidak ada data rumah sakit yang sesuai pencarian.',
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.large,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                final dataItem =
                                    homeState.filteredHospitalDataItems[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.small,
                                  ),
                                  child: HospitalDataCard(dataItem: dataItem),
                                );
                              },
                              childCount:
                                  homeState.filteredHospitalDataItems.length,
                            ),
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

  List<MapEntry<FeatureCategory, List<PatientFeature>>> _groupFeatures(
    List<PatientFeature> features,
  ) {
    final Map<FeatureCategory, List<PatientFeature>> grouped =
        <FeatureCategory, List<PatientFeature>>{};

    for (final PatientFeature feature in features) {
      grouped.putIfAbsent(feature.category, () => <PatientFeature>[]);
      grouped[feature.category]!.add(feature);
    }

    final List<MapEntry<FeatureCategory, List<PatientFeature>>> entries =
        grouped.entries.toList()..sort(
          (
            MapEntry<FeatureCategory, List<PatientFeature>> left,
            MapEntry<FeatureCategory, List<PatientFeature>> right,
          ) => left.key.index.compareTo(right.key.index),
        );

    return entries;
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
        return const PatientDirectoryPage();
      case 'daftar_dokter':
      case 'spesialisasi':
        return const EmployeeDirectoryPage();
      case 'poli_jadwal':
      case 'jadwal_praktik':
        return const HospitalResourceDirectoryPage.polyclinic();
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
      case FeatureCategory.notifikasiPersonal:
        return AppColors.primaryRed;
      case FeatureCategory.bookingAntrian:
      case FeatureCategory.resepObat:
      case FeatureCategory.kontakDarurat:
        return AppColors.primaryGreen;
      case FeatureCategory.konsultasiMedis:
      case FeatureCategory.informasiRumahSakit:
      case FeatureCategory.informasiDokter:
      case FeatureCategory.informasiBiaya:
      case FeatureCategory.edukasiKesehatan:
        return AppColors.primaryBlue;
    }
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    final String greetingName = authState.identity?.fullName.isNotEmpty == true
        ? authState.identity!.fullName
        : 'Guest';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.large,
        44,
        AppSpacing.large,
        AppSpacing.medium,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: const BoxConstraints(minHeight: 216),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Image.asset(AppAssets.hospitalPhoto1, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        AppColors.textPrimary.withValues(alpha: 0.78),
                        AppColors.primaryRed.withValues(alpha: 0.72),
                        AppColors.primaryBlue.withValues(alpha: 0.66),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const BrandLogo(size: 54, borderRadius: 16),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            authState.isAuthenticated
                                ? 'Akun aktif'
                                : 'Guest mode',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      'Halo, $greetingName',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      AppBranding.appName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
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
                          label: AppBranding.locationShort,
                        ),
                        _HeroPill(
                          icon: Icons.language_outlined,
                          label: 'Website resmi',
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
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
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
        AppSpacing.large,
        AppSpacing.large,
        AppSpacing.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.itemCount});

  final FeatureCategory category;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.small,
        AppSpacing.large,
        AppSpacing.small,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              category.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Chip(label: Text('$itemCount menu')),
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
