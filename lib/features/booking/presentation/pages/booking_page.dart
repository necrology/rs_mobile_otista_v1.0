import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../shared/domain/entities/patient_feature.dart';
import '../../../api_data/presentation/pages/employee_directory_page.dart';
import '../../../api_data/presentation/pages/hospital_resource_directory_page.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../../../home/presentation/widgets/feature_tile_card.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking & Layanan')),
      body: AppBackground(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (BuildContext context, HomeState homeState) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (BuildContext context, AuthState authState) {
                final List<PatientFeature> bookingFeatures = homeState
                    .featureItems
                    .where(
                      (PatientFeature feature) =>
                          feature.category == FeatureCategory.bookingAntrian ||
                          feature.category ==
                              FeatureCategory.pembayaranTransaksi ||
                          feature.category == FeatureCategory.resepObat,
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
                              AppAssets.hospitalPhoto2,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    AppColors.primaryGreen.withValues(
                                      alpha: 0.86,
                                    ),
                                    AppColors.primaryBlue.withValues(
                                      alpha: 0.76,
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
                                  'Pendaftaran Online & Antrian Digital',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: AppSpacing.small),
                                Text(
                                  authState.isAuthenticated
                                      ? 'Nomor antrian Anda: A-024. Estimasi dipanggil 20 menit lagi.'
                                      : 'Login untuk mulai booking dokter, cek antrian, pembayaran, dan resep digital.',
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
                    ...bookingFeatures.map(
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

    if (feature.id == 'booking_dokter') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const EmployeeDirectoryPage()),
      );
      return;
    }

    if (feature.id == 'poli_jadwal') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const HospitalResourceDirectoryPage.polyclinic(),
        ),
      );
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
                'Login diperlukan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              const Text(
                'Booking, antrian, pembayaran, dan resep memerlukan akun pasien aktif.',
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
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
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
