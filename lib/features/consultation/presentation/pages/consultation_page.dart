import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../shared/domain/entities/patient_feature.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../../../home/presentation/widgets/feature_tile_card.dart';

class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konsultasi')),
      body: AppBackground(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (BuildContext context, HomeState homeState) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (BuildContext context, AuthState authState) {
                final List<PatientFeature> consultationFeatures = homeState
                    .featureItems
                    .where(
                      (PatientFeature feature) =>
                          feature.category == FeatureCategory.konsultasiMedis ||
                          feature.category ==
                              FeatureCategory.notifikasiPersonal,
                    )
                    .toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.large,
                    AppSpacing.small,
                    AppSpacing.large,
                    110,
                  ),
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: Image.asset(
                              AppAssets.hospitalPhoto4,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    AppColors.primaryBlue.withValues(
                                      alpha: 0.84,
                                    ),
                                    AppColors.primaryRed.withValues(
                                      alpha: 0.66,
                                    ),
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
                                Text(
                                  'Konsultasi Cepat dengan Dokter',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: AppSpacing.small),
                                Text(
                                  authState.isAuthenticated
                                      ? 'Chat aktif dengan dokter dan jadwal video call berikutnya tersedia di sini.'
                                      : 'Akses chat, video call, dan notifikasi personal tersedia setelah login.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.92,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    ...consultationFeatures.map(
                      (PatientFeature feature) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.small,
                        ),
                        child: FeatureTileCard(
                          feature: feature,
                          isLocked:
                              feature.requiresLogin &&
                              !authState.isAuthenticated,
                          onTap: () => _onFeatureTap(
                            context,
                            feature,
                            authState.isAuthenticated,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderSoft),
                      ),
                      child: Text(
                        'Reminder medis, hasil lab, dan jadwal kontrol bisa dipantau lebih rapi dari tab ini agar pasien tidak terlewat tindak lanjut.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _onFeatureTap(
    BuildContext context,
    PatientFeature feature,
    bool isAuthenticated,
  ) async {
    if (feature.requiresLogin && !isAuthenticated) {
      await _showLoginSheet(context);
      return;
    }

    await showModalBottomSheet<void>(
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
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              ...feature.dummyDetails.map(
                (String detail) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: Text('- $detail'),
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

  Future<void> _showLoginSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext dialogContext) {
        final double bottomInset = MediaQuery.viewPaddingOf(
          dialogContext,
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
              Text(
                'Login diperlukan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              const Text(
                'Fitur konsultasi medis dan notifikasi personal memerlukan akun pasien.',
              ),
              const SizedBox(height: AppSpacing.large),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const AuthPage()),
                    );
                  },
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Nanti'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
