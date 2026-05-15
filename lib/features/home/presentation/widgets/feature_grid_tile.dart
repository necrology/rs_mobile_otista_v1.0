import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/domain/entities/patient_feature.dart';

class FeatureGridTile extends StatelessWidget {
  const FeatureGridTile({
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
          padding: const EdgeInsets.all(AppSpacing.small),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(feature.icon, color: accentColor, size: 16),
                  ),
                  if (isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 12,
                        color: AppColors.warning,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                feature.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_outward_rounded,
                  size: 14,
                  color: accentColor,
                ),
              ),
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
