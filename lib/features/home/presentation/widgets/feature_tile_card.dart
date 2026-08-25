import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/domain/entities/patient_feature.dart';

class FeatureTileCard extends StatelessWidget {
  const FeatureTileCard({
    required this.feature,
    required this.isLocked,
    required this.onTap,
    super.key,
  });

  final PatientFeature feature;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _resolveCategoryColor(feature.category);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(feature.icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            feature.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (isLocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Login',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
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
