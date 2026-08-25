import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../auth/domain/entities/patient_identity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../profile/presentation/pages/medical_record_page.dart';
import '../../domain/entities/patient_lab_result_record.dart';
import '../../domain/entities/patient_medical_summary_record.dart';
import '../../domain/entities/patient_prescription_record.dart';
import '../../domain/entities/patient_radiology_result_record.dart';
import '../../domain/entities/patient_visit_record.dart';
import 'api_record_detail_page.dart';
import 'medical_resume_pdf_page.dart';
import '../cubit/rs_api_cubit.dart';

class PatientVisitHistoryPage extends StatelessWidget {
  const PatientVisitHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PatientPersonalRecordsPage(type: _PersonalRecordType.visits);
  }
}

class PatientMedicalSummaryPage extends StatelessWidget {
  const PatientMedicalSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PatientPersonalRecordsPage(
      type: _PersonalRecordType.medicalSummaries,
    );
  }
}

class PatientLaboratoryResultsPage extends StatelessWidget {
  const PatientLaboratoryResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PatientPersonalRecordsPage(
      type: _PersonalRecordType.laboratoryResults,
    );
  }
}

class PatientRadiologyResultsPage extends StatelessWidget {
  const PatientRadiologyResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PatientPersonalRecordsPage(
      type: _PersonalRecordType.radiologyResults,
    );
  }
}

class PatientPrescriptionPage extends StatelessWidget {
  const PatientPrescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PatientPersonalRecordsPage(
      type: _PersonalRecordType.prescriptions,
    );
  }
}

enum _PersonalRecordType {
  visits,
  medicalSummaries,
  laboratoryResults,
  radiologyResults,
  prescriptions,
}

class _PatientPersonalRecordsPage extends StatefulWidget {
  const _PatientPersonalRecordsPage({required this.type});

  final _PersonalRecordType type;

  @override
  State<_PatientPersonalRecordsPage> createState() =>
      _PatientPersonalRecordsPageState();
}

class _PatientPersonalRecordsPageState
    extends State<_PatientPersonalRecordsPage> {
  _PersonalRecordCopy get _copy => _PersonalRecordCopy.forType(widget.type);

  @override
  void initState() {
    super.initState();
    if (widget.type == _PersonalRecordType.medicalSummaries) {
      _debugMedicalSummaryLog('open page');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecords());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_copy.appBarTitle)),
      body: AppBackground(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState authState) {
            final PatientIdentity? identity = authState.identity;
            final String noRm =
                identity?.medicalRecordNumber.trim().toUpperCase() ?? '';

            if (!authState.isAuthenticated || identity == null) {
              return _AccessState(
                title: 'Login diperlukan',
                message:
                    '${_copy.appBarTitle} hanya tersedia untuk akun pasien yang sudah login.',
                buttonLabel: null,
                onPressed: null,
              );
            }

            if (noRm.isEmpty) {
              return _AccessState(
                title: 'No. RM Belum Terhubung',
                message:
                    '${_copy.appBarTitle} ditampilkan setelah akun mobile terikat ke No. Rekam Medis.',
                buttonLabel: 'Hubungkan No. RM',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MedicalRecordPage(),
                    ),
                  );
                },
              );
            }

            return BlocBuilder<RsApiCubit, RsApiState>(
              builder: (BuildContext context, RsApiState state) {
                final bool isLoading = widget.type == _PersonalRecordType.visits
                    ? state.isLoadingPatientVisits
                    : widget.type == _PersonalRecordType.medicalSummaries
                    ? state.isLoadingPatientMedicalSummaries
                    : widget.type == _PersonalRecordType.laboratoryResults
                    ? state.isLoadingPatientLabResults
                    : widget.type == _PersonalRecordType.radiologyResults
                    ? state.isLoadingPatientRadiologyResults
                    : state.isLoadingPatientPrescriptions;
                final List<_PersonalRecordView> records = _recordsFromState(
                  state,
                  identity,
                );

                return RefreshIndicator(
                  onRefresh: _loadRecords,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.large,
                      AppSpacing.small,
                      AppSpacing.large,
                      110,
                    ),
                    children: <Widget>[
                      _RecordsHero(
                        copy: _copy,
                        noRm: noRm,
                        itemCount: records.length,
                        isLoading: isLoading,
                      ),
                      if (state.errorMessage != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.medium),
                        _ErrorCard(message: state.errorMessage!),
                      ],
                      const SizedBox(height: AppSpacing.medium),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.medium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    _copy.sectionIcon,
                                    size: 18,
                                    color: _copy.accentColor,
                                  ),
                                  const SizedBox(width: AppSpacing.xSmall),
                                  Expanded(
                                    child: Text(
                                      _copy.sectionTitle,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.small),
                              if (isLoading && records.isEmpty)
                                const _LoadingBlock()
                              else if (records.isEmpty)
                                _EmptyText(_copy.emptyText)
                              else
                                ...records.map(
                                  (_PersonalRecordView record) =>
                                      _PersonalRecordTile(record: record),
                                ),
                            ],
                          ),
                        ),
                      ),
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

  Future<void> _loadRecords() async {
    final PatientIdentity? identity = context.read<AuthCubit>().state.identity;
    if (identity == null || identity.medicalRecordNumber.trim().isEmpty) {
      return;
    }

    final RsApiCubit cubit = context.read<RsApiCubit>();
    switch (widget.type) {
      case _PersonalRecordType.visits:
        await cubit.fetchPatientVisits();
        return;
      case _PersonalRecordType.medicalSummaries:
        final Stopwatch stopwatch = Stopwatch()..start();
        _debugMedicalSummaryLog('fetch start');
        await cubit.fetchPatientMedicalSummaries();
        stopwatch.stop();
        final RsApiState latestState = cubit.state;
        _debugMedicalSummaryLog(
          'fetch done duration=${stopwatch.elapsedMilliseconds}ms '
          'count=${latestState.patientMedicalSummaries?.items.length ?? 0} '
          'error=${latestState.errorMessage ?? '-'}',
        );
        return;
      case _PersonalRecordType.laboratoryResults:
        await cubit.fetchPatientLabResults();
        return;
      case _PersonalRecordType.radiologyResults:
        await cubit.fetchPatientRadiologyResults();
        return;
      case _PersonalRecordType.prescriptions:
        await cubit.fetchPatientPrescriptions();
        return;
    }
  }

  void _debugMedicalSummaryLog(String message) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[DiagnosisTindakan] $message');
  }

  List<_PersonalRecordView> _recordsFromState(
    RsApiState state,
    PatientIdentity identity,
  ) {
    switch (widget.type) {
      case _PersonalRecordType.visits:
        return (state.patientVisits?.items ?? <PatientVisitRecord>[])
            .map(
              (PatientVisitRecord visit) => _PersonalRecordView(
                appBarTitle: 'Resume Medis PDF',
                title: visit.title,
                subtitle: visit.subtitle,
                icon: visit.isInpatient
                    ? Icons.local_hotel_outlined
                    : Icons.picture_as_pdf_outlined,
                accentColor: AppColors.primaryBlue,
                fields: visit.displayFields,
                badges: <Widget>[
                  if (visit.isInpatient)
                    _RecordBadge(
                      label: 'Rawat Inap',
                      color: AppColors.primaryBlue,
                    ),
                  if (visit.queueNumber != '-')
                    _RecordBadge(
                      label: 'Antrian ${visit.queueNumber}',
                      color: AppColors.primaryGreen,
                    ),
                  if (visit.status != '-')
                    _RecordBadge(
                      label: visit.status,
                      color: AppColors.primaryRed,
                    ),
                ],
                detailBuilder: (_) => MedicalResumePdfPage.fromVisit(
                  visit: visit,
                  identity: identity,
                ),
              ),
            )
            .toList();
      case _PersonalRecordType.medicalSummaries:
        return (state.patientMedicalSummaries?.items ??
                <PatientMedicalSummaryRecord>[])
            .map(
              (PatientMedicalSummaryRecord summary) => _PersonalRecordView(
                appBarTitle: 'Resume Medis PDF',
                title: summary.title,
                subtitle: summary.subtitle,
                icon: Icons.picture_as_pdf_outlined,
                accentColor: AppColors.primaryRed,
                fields: summary.displayFields,
                badges: <Widget>[
                  if (summary.polyclinic != '-')
                    _RecordBadge(
                      label: summary.polyclinic,
                      color: AppColors.primaryBlue,
                    ),
                ],
                detailBuilder: (_) =>
                    MedicalResumePdfPage(record: summary, identity: identity),
              ),
            )
            .toList();
      case _PersonalRecordType.laboratoryResults:
        return (state.patientLabResults?.items ?? <PatientLabResultRecord>[])
            .map(
              (PatientLabResultRecord result) => _PersonalRecordView(
                appBarTitle: 'Detail Hasil Lab',
                title: result.title,
                subtitle: result.subtitle,
                icon: Icons.science_outlined,
                accentColor: AppColors.primaryGreen,
                fields: result.displayFields,
                badges: <Widget>[
                  if (result.noLab != '-')
                    _RecordBadge(
                      label: result.noLab,
                      color: AppColors.primaryGreen,
                    ),
                  if (result.details.isNotEmpty)
                    _RecordBadge(
                      label: '${result.details.length} rincian',
                      color: AppColors.primaryBlue,
                    ),
                ],
              ),
            )
            .toList();
      case _PersonalRecordType.radiologyResults:
        return (state.patientRadiologyResults?.items ??
                <PatientRadiologyResultRecord>[])
            .map(
              (PatientRadiologyResultRecord result) => _PersonalRecordView(
                appBarTitle: 'Detail Hasil Radiologi',
                title: result.title,
                subtitle: result.subtitle,
                icon: Icons.biotech_outlined,
                accentColor: AppColors.primaryBlue,
                fields: result.displayFields,
                badges: <Widget>[
                  if (result.statusLabel != '-')
                    _RecordBadge(
                      label: result.statusLabel,
                      color: result.statusLabel == 'Selesai'
                          ? AppColors.primaryGreen
                          : AppColors.warning,
                    ),
                  if (result.documentNumber != '-')
                    _RecordBadge(
                      label: result.documentNumber,
                      color: AppColors.primaryBlue,
                    ),
                ],
              ),
            )
            .toList();
      case _PersonalRecordType.prescriptions:
        return (state.patientPrescriptions?.items ??
                <PatientPrescriptionRecord>[])
            .map(
              (PatientPrescriptionRecord prescription) => _PersonalRecordView(
                appBarTitle: 'Detail Resep & Obat',
                title: prescription.title,
                subtitle: prescription.subtitle,
                icon: Icons.medication_liquid_outlined,
                accentColor: AppColors.primaryGreen,
                fields: prescription.displayFields,
                badges: <Widget>[
                  if (prescription.statusLabel != '-')
                    _RecordBadge(
                      label: prescription.statusLabel,
                      color: AppColors.primaryGreen,
                    ),
                  if (prescription.details.isNotEmpty)
                    _RecordBadge(
                      label: '${prescription.details.length} obat',
                      color: AppColors.primaryBlue,
                    ),
                ],
              ),
            )
            .toList();
    }
  }
}

class _PersonalRecordCopy {
  const _PersonalRecordCopy({
    required this.appBarTitle,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.sectionTitle,
    required this.emptyText,
    required this.heroIcon,
    required this.sectionIcon,
    required this.accentColor,
  });

  final String appBarTitle;
  final String heroTitle;
  final String heroSubtitle;
  final String sectionTitle;
  final String emptyText;
  final IconData heroIcon;
  final IconData sectionIcon;
  final Color accentColor;

  static _PersonalRecordCopy forType(_PersonalRecordType type) {
    switch (type) {
      case _PersonalRecordType.visits:
        return const _PersonalRecordCopy(
          appBarTitle: 'Riwayat Kunjungan',
          heroTitle: 'Riwayat Kunjungan Pasien',
          heroSubtitle:
              'Data ditarik dari registrasi pasien yang terhubung ke akun mobile.',
          sectionTitle: 'Kunjungan Terakhir',
          emptyText: 'Belum ada riwayat kunjungan untuk pasien ini.',
          heroIcon: Icons.history_rounded,
          sectionIcon: Icons.event_note_outlined,
          accentColor: AppColors.primaryBlue,
        );
      case _PersonalRecordType.medicalSummaries:
        return const _PersonalRecordCopy(
          appBarTitle: 'Diagnosis & Tindakan',
          heroTitle: 'Diagnosis & Tindakan',
          heroSubtitle:
              'Ringkasan medis ditampilkan dari resume pasien dan data ICD yang terhubung ke registrasi.',
          sectionTitle: 'Ringkasan Medis',
          emptyText: 'Belum ada diagnosis atau tindakan yang tercatat.',
          heroIcon: Icons.medical_information_outlined,
          sectionIcon: Icons.fact_check_outlined,
          accentColor: AppColors.primaryRed,
        );
      case _PersonalRecordType.laboratoryResults:
        return const _PersonalRecordCopy(
          appBarTitle: 'Hasil Lab',
          heroTitle: 'Hasil Laboratorium',
          heroSubtitle:
              'Hasil ditampilkan dari order lab, hasillabs, dan rincian pemeriksaan yang terkait ke No. RM.',
          sectionTitle: 'Pemeriksaan Laboratorium',
          emptyText: 'Belum ada hasil laboratorium untuk pasien ini.',
          heroIcon: Icons.science_outlined,
          sectionIcon: Icons.fact_check_outlined,
          accentColor: AppColors.primaryGreen,
        );
      case _PersonalRecordType.radiologyResults:
        return const _PersonalRecordCopy(
          appBarTitle: 'Hasil Radiologi',
          heroTitle: 'Hasil Radiologi',
          heroSubtitle:
              'Hasil ditampilkan dari order radiologi, hasil radiologi, detail resume, dan ekspertise terkait pasien.',
          sectionTitle: 'Pemeriksaan Radiologi',
          emptyText: 'Belum ada hasil radiologi untuk pasien ini.',
          heroIcon: Icons.biotech_outlined,
          sectionIcon: Icons.image_search_outlined,
          accentColor: AppColors.primaryBlue,
        );
      case _PersonalRecordType.prescriptions:
        return const _PersonalRecordCopy(
          appBarTitle: 'Resep & Obat',
          heroTitle: 'Resep dan Obat Pasien',
          heroSubtitle:
              'Resep ditampilkan dari penjualan farmasi dan rincian obat yang terhubung ke registrasi pasien.',
          sectionTitle: 'Daftar Resep',
          emptyText: 'Belum ada resep obat untuk pasien ini.',
          heroIcon: Icons.medication_liquid_outlined,
          sectionIcon: Icons.receipt_long_outlined,
          accentColor: AppColors.primaryGreen,
        );
    }
  }
}

class _PersonalRecordView {
  const _PersonalRecordView({
    required this.appBarTitle,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.fields,
    required this.badges,
    this.detailBuilder,
  });

  final String appBarTitle;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<MapEntry<String, String>> fields;
  final List<Widget> badges;
  final WidgetBuilder? detailBuilder;
}

class _RecordsHero extends StatelessWidget {
  const _RecordsHero({
    required this.copy,
    required this.noRm,
    required this.itemCount,
    required this.isLoading,
  });

  final _PersonalRecordCopy copy;
  final String noRm;
  final int itemCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            copy.accentColor.withValues(alpha: 0.92),
            AppColors.primaryGreen.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
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
                child: Icon(copy.heroIcon, color: Colors.white),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            copy.heroTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            copy.heroSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: <Widget>[
              _HeaderPill(label: 'No. RM', value: noRm),
              _HeaderPill(label: 'Data', value: '$itemCount'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonalRecordTile extends StatelessWidget {
  const _PersonalRecordTile({required this.record});

  final _PersonalRecordView record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder:
                  record.detailBuilder ??
                  (_) => ApiRecordDetailPage(
                    appBarTitle: record.appBarTitle,
                    title: record.title,
                    subtitle: record.subtitle,
                    icon: record.icon,
                    accentColor: record.accentColor,
                    fields: record.fields,
                    badges: record.badges,
                  ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: record.accentColor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(record.icon, color: record.accentColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      record.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (record.subtitle.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        record.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (record.badges.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.xSmall),
                      Wrap(
                        spacing: AppSpacing.xSmall,
                        runSpacing: AppSpacing.xSmall,
                        children: record.badges,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordBadge extends StatelessWidget {
  const _RecordBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color.lerp(Colors.white, color, 0.10)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
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
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AccessState extends StatelessWidget {
  const _AccessState({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                AppColors.primaryBlue.withValues(alpha: 0.78),
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
                child: const Icon(Icons.link_off_rounded, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.90),
                ),
              ),
            ],
          ),
        ),
        if (buttonLabel != null && onPressed != null) ...<Widget>[
          const SizedBox(height: AppSpacing.medium),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.link_rounded),
              label: Text(buttonLabel!),
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.large),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
