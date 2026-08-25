import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../auth/domain/entities/patient_identity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../profile/presentation/pages/medical_record_page.dart';
import '../../domain/entities/patient_record.dart';
import '../cubit/rs_api_cubit.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pasien')),
      body: AppBackground(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState authState) {
            final PatientIdentity? identity = authState.identity;
            final String noRm =
                identity?.medicalRecordNumber.trim().toUpperCase() ?? '';

            if (!authState.isAuthenticated || identity == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.large),
                  child: Text('Login diperlukan untuk membuka profil pasien.'),
                ),
              );
            }

            if (noRm.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.small,
                  AppSpacing.large,
                  110,
                ),
                children: <Widget>[
                  _ProfileHero(
                    title: 'No. RM Belum Terhubung',
                    subtitle:
                        'Profil pasien hanya ditampilkan setelah akun mobile terikat ke No. Rekam Medis.',
                    isLoading: false,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.large),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Hubungkan No. RM',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            'Verifikasi No. RM memakai NIK, tanggal lahir, password akun, dan OTP email.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const MedicalRecordPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.link_rounded),
                              label: const Text('Hubungkan No. RM'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return BlocBuilder<RsApiCubit, RsApiState>(
              builder: (BuildContext context, RsApiState state) {
                final PatientRecord? patient = state.selectedPatient;

                return RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.large,
                      AppSpacing.small,
                      AppSpacing.large,
                      110,
                    ),
                    children: <Widget>[
                      _ProfileHero(
                        title: identity.fullName.trim().isEmpty
                            ? 'Profil Pasien'
                            : identity.fullName,
                        subtitle: 'No. RM $noRm',
                        isLoading: state.isLoadingPatientDetail,
                      ),
                      if (state.errorMessage != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.medium),
                        _ErrorCard(message: state.errorMessage!),
                      ],
                      const SizedBox(height: AppSpacing.medium),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.medium),
                          child: patient == null
                              ? state.isLoadingPatientDetail
                                    ? const _LoadingBlock()
                                    : const _EmptyText(
                                        'Profil pasien belum tersedia.',
                                      )
                              : _ProfileFields(patient: patient),
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

  Future<void> _loadProfile() async {
    final PatientIdentity? identity = context.read<AuthCubit>().state.identity;
    if (identity == null) {
      return;
    }

    await context.read<RsApiCubit>().fetchLinkedPatientProfile(
      patientId: identity.patientId,
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.title,
    required this.subtitle,
    required this.isLoading,
  });

  final String title;
  final String subtitle;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.primaryRed.withValues(alpha: 0.92),
            AppColors.primaryBlue.withValues(alpha: 0.82),
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
                child: const Icon(
                  Icons.assignment_ind_outlined,
                  color: Colors.white,
                ),
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
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFields extends StatelessWidget {
  const _ProfileFields({required this.patient});

  final PatientRecord patient;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, String>> fields = patient.safeProfileFields;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: AppColors.primaryRed,
            ),
            const SizedBox(width: AppSpacing.xSmall),
            Expanded(
              child: Text(
                'Data Pasien Terhubung',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.small),
        ...fields.map(
          (MapEntry<String, String> field) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    field.key,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    field.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
