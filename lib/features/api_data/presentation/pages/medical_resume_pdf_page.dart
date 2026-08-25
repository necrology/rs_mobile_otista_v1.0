import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../auth/domain/entities/patient_identity.dart';
import '../../domain/entities/patient_medical_summary_record.dart';
import '../../domain/entities/patient_visit_record.dart';

class MedicalResumePdfPage extends StatefulWidget {
  MedicalResumePdfPage({
    super.key,
    required PatientMedicalSummaryRecord record,
    required this.identity,
  }) : registrationId = record.registrationId,
       registration = record.registration,
       title = record.title,
       subtitle = record.subtitle,
       visitDate = record.visitDate,
       polyclinic = record.polyclinic,
       doctor = record.doctor;

  MedicalResumePdfPage.fromVisit({
    super.key,
    required PatientVisitRecord visit,
    required this.identity,
  }) : registrationId = visit.registrationId,
       registration = visit.registration,
       title = visit.isInpatient ? 'Resume Rawat Inap' : visit.title,
       subtitle = visit.subtitle,
       visitDate = visit.visitDate,
       polyclinic = visit.polyclinic,
       doctor = visit.doctor;

  final PatientIdentity identity;
  final String registrationId;
  final String registration;
  final String title;
  final String subtitle;
  final String visitDate;
  final String polyclinic;
  final String doctor;

  @override
  State<MedicalResumePdfPage> createState() => _MedicalResumePdfPageState();
}

class _MedicalResumePdfPageState extends State<MedicalResumePdfPage> {
  bool _isOpeningPdf = false;

  PatientIdentity get identity => widget.identity;
  String get registrationId => widget.registrationId;
  String get registration => widget.registration;
  String get title => widget.title;
  String get subtitle => widget.subtitle;
  String get visitDate => widget.visitDate;
  String get polyclinic => widget.polyclinic;
  String get doctor => widget.doctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resume Medis PDF')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.small,
            AppSpacing.large,
            110,
          ),
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.large),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    AppColors.primaryRed.withValues(alpha: 0.92),
                    AppColors.primaryBlue.withValues(alpha: 0.72),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.medium),
                  Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    children: <Widget>[
                      _HeaderPill(
                        label: 'No. RM',
                        value: identity.medicalRecordNumber,
                      ),
                      _HeaderPill(label: 'Registrasi', value: registration),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 18,
                          color: AppColors.primaryRed,
                        ),
                        const SizedBox(width: AppSpacing.xSmall),
                        Expanded(
                          child: Text(
                            'Dokumen Resume Medis',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    _DetailLine(label: 'Tanggal', value: visitDate),
                    _DetailLine(label: 'Poli', value: polyclinic),
                    _DetailLine(label: 'Dokter', value: doctor),
                    const SizedBox(height: AppSpacing.medium),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isOpeningPdf
                                ? null
                                : () => _openPdf(download: false),
                            icon: _isOpeningPdf
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.visibility_outlined),
                            label: const Text('Lihat PDF'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isOpeningPdf
                                ? null
                                : () => _openPdf(download: true),
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Download'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPdf({required bool download}) async {
    setState(() => _isOpeningPdf = true);

    try {
      final ApiBinaryResponse response = await context
          .read<ApiClient>()
          .getBytes(
            '/mobile/patient/medical-summaries/$registrationId/pdf',
            queryParameters: <String, Object?>{if (download) 'download': '1'},
            requiresAuth: true,
          );

      final Directory directory = download
          ? await getApplicationDocumentsDirectory()
          : await getTemporaryDirectory();
      final String safeRegistrationId = registrationId.replaceAll(
        RegExp(r'[^A-Za-z0-9_-]'),
        '-',
      );
      final File file = File(
        '${directory.path}${Platform.pathSeparator}resume-medis-$safeRegistrationId.pdf',
      );
      await file.writeAsBytes(response.bytes, flush: true);

      final OpenResult openResult = await OpenFilex.open(
        file.path,
        type: 'application/pdf',
      );
      if (!mounted) {
        return;
      }

      if (openResult.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              openResult.message.trim().isEmpty
                  ? 'Tidak ditemukan aplikasi untuk membuka PDF.'
                  : openResult.message,
            ),
          ),
        );
        return;
      }

      if (download) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF disimpan di penyimpanan aplikasi.'),
          ),
        );
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF belum bisa dibuka dari perangkat ini.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOpeningPdf = false);
      }
    }
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        '$label: ${value.trim().isEmpty ? '-' : value}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final String displayValue = value.trim().isEmpty || value == '-'
        ? '-'
        : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
