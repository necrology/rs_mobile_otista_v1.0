import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../domain/entities/patient_record.dart';
import 'api_record_detail_page.dart';
import '../cubit/rs_api_cubit.dart';

class PatientDirectoryPage extends StatefulWidget {
  const PatientDirectoryPage({super.key});

  @override
  State<PatientDirectoryPage> createState() => _PatientDirectoryPageState();
}

class _PatientDirectoryPageState extends State<PatientDirectoryPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: 'ahmad');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RsApiCubit cubit = context.read<RsApiCubit>();
      cubit.searchPatients(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Pasien')),
      body: AppBackground(
        child: BlocBuilder<RsApiCubit, RsApiState>(
          builder: (BuildContext context, RsApiState state) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<RsApiCubit>().searchPatients(
                  _searchController.text,
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.small,
                  AppSpacing.large,
                  110,
                ),
                children: <Widget>[
                  _PatientHeader(state: state),
                  const SizedBox(height: AppSpacing.medium),
                  _PatientControls(
                    searchController: _searchController,
                    state: state,
                  ),
                  if (state.errorMessage != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.medium),
                    _ErrorCard(message: state.errorMessage!),
                  ],
                  const SizedBox(height: AppSpacing.medium),
                  _PatientListCard(state: state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.state});

  final RsApiState state;

  @override
  Widget build(BuildContext context) {
    final int visibleCount = state.patients?.items.length ?? 0;
    final String totalCount = state.compactPatients?.total?.toString() ?? '-';

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
                  Icons.personal_injury_outlined,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (state.isLoadingPatients)
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
            'Pencarian dan Profil Pasien',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            'Pantau identitas pasien, nomor rekam medis, dan data registrasi dari layanan rumah sakit.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: <Widget>[
              _HeaderPill(label: 'Tampil', value: '$visibleCount'),
              _HeaderPill(label: 'Total', value: totalCount),
              const _HeaderPill(label: 'Cari', value: 'Nama / No. RM'),
            ],
          ),
        ],
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

class _PatientControls extends StatelessWidget {
  const _PatientControls({required this.searchController, required this.state});

  final TextEditingController searchController;
  final RsApiState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: <Widget>[
            _InputAction(
              controller: searchController,
              labelText: 'Nama atau No. RM',
              prefixIcon: Icons.search_rounded,
              buttonLabel: 'Cari',
              isLoading: state.isLoadingPatients,
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.read<RsApiCubit>().searchPatients(
                  searchController.text,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientListCard extends StatelessWidget {
  const _PatientListCard({required this.state});

  final RsApiState state;

  @override
  Widget build(BuildContext context) {
    final List<PatientRecord> patients =
        state.patients?.items ?? <PatientRecord>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SectionTitle(
              icon: Icons.people_alt_outlined,
              title: 'Daftar Pasien',
            ),
            const SizedBox(height: AppSpacing.small),
            if (state.isLoadingPatients && patients.isEmpty)
              const _LoadingBlock()
            else if (patients.isEmpty)
              const _EmptyText('Tidak ada pasien yang cocok.')
            else
              ...patients.map(
                (PatientRecord patient) => _PatientRecordTile(
                  patient: patient,
                  color: AppColors.primaryRed,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ApiRecordDetailPage(
                          appBarTitle: 'Detail Pasien',
                          title: patient.nama,
                          subtitle: 'No. RM ${patient.noRm}',
                          icon: Icons.assignment_ind_outlined,
                          accentColor: AppColors.primaryRed,
                          fields: patient.displayFields,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PatientRecordTile extends StatelessWidget {
  const _PatientRecordTile({
    required this.patient,
    required this.color,
    this.onTap,
  });

  final PatientRecord patient;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          patient.nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'No. RM ${patient.noRm}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.chevron_right_rounded, size: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputAction extends StatelessWidget {
  const _InputAction({
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.buttonLabel,
    required this.isLoading,
    required this.onPressed,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String buttonLabel;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 330;
        final Widget field = TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onPressed(),
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(prefixIcon),
          ),
        );
        final Widget button = FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(buttonLabel),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              field,
              const SizedBox(height: AppSpacing.xSmall),
              button,
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(child: field),
            const SizedBox(width: AppSpacing.small),
            SizedBox(width: 92, child: button),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.primaryRed),
        const SizedBox(width: AppSpacing.xSmall),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
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
