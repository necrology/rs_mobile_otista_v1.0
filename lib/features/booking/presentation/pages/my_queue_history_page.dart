import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../api_data/presentation/cubit/rs_api_cubit.dart';
import '../../../auth/domain/entities/patient_identity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../profile/presentation/pages/medical_record_page.dart';
import '../../domain/entities/queue_records.dart';
import 'general_queue_page.dart';

class MyQueueHistoryPage extends StatefulWidget {
  const MyQueueHistoryPage({super.key});

  @override
  State<MyQueueHistoryPage> createState() => _MyQueueHistoryPageState();
}

class _MyQueueHistoryPageState extends State<MyQueueHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  Future<void> _loadHistory() async {
    if (!mounted) {
      return;
    }

    final PatientIdentity? identity = context.read<AuthCubit>().state.identity;
    final String noRm = identity?.medicalRecordNumber.trim() ?? '';
    if (identity == null || noRm.isEmpty) {
      return;
    }

    await context.read<RsApiCubit>().fetchMyGeneralBookings(allDates: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nomor Antrian Saya')),
      body: AppBackground(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState authState) {
            final PatientIdentity? identity = authState.identity;
            final String noRm =
                identity?.medicalRecordNumber.trim().toUpperCase() ?? '';

            if (identity == null) {
              return const _QueueAccessState(
                title: 'Login diperlukan',
                message: 'Login untuk melihat history nomor antrian Anda.',
              );
            }

            if (noRm.isEmpty) {
              return _QueueAccessState(
                title: 'No. RM Belum Terhubung',
                message:
                    'History nomor antrian hanya tersedia untuk akun yang sudah terhubung ke No. Rekam Medis.',
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
                final List<GeneralBookingRecord> bookings =
                    (state.myGeneralBookings?.items ?? <GeneralBookingRecord>[])
                        .where(
                          (GeneralBookingRecord booking) =>
                              booking.noRm.trim().toUpperCase() == noRm,
                        )
                        .toList();

                return RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.large,
                      AppSpacing.medium,
                      AppSpacing.large,
                      110,
                    ),
                    children: <Widget>[
                      _QueueHistoryHeader(
                        noRm: noRm,
                        count: bookings.length,
                        isLoading: state.isLoadingMyGeneralBookings,
                        onCreateQueue: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const GeneralQueuePage(initialTabIndex: 0),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      if (state.errorMessage != null)
                        _QueueErrorCard(message: state.errorMessage!),
                      if (state.isLoadingMyGeneralBookings && bookings.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.xLarge,
                          ),
                          child: Center(
                            child: AppLoadingIndicator(
                              message: 'Memuat history antrian',
                              size: 44,
                            ),
                          ),
                        )
                      else if (bookings.isEmpty)
                        const _QueueEmptyState()
                      else
                        ...bookings.map(
                          (GeneralBookingRecord booking) =>
                              _MyQueueHistoryCard(booking: booking),
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
}

class _QueueHistoryHeader extends StatelessWidget {
  const _QueueHistoryHeader({
    required this.noRm,
    required this.count,
    required this.isLoading,
    required this.onCreateQueue,
  });

  final String noRm;
  final int count;
  final bool isLoading;
  final VoidCallback onCreateQueue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.deepTeal.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    strokeCap: StrokeCap.round,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'History Nomor Antrian',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            'Nomor antrian diambil dari registrasi mobile dan antrian poli untuk No. RM yang sedang aktif.',
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
              _HeaderPill(label: 'Total', value: '$count'),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreateQueue,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Buat Pendaftaran Baru'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyQueueHistoryCard extends StatelessWidget {
  const _MyQueueHistoryCard({required this.booking});

  final GeneralBookingRecord booking;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _statusColor(booking.colorRole);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.deepTeal.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      booking.queueNumber,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        booking.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      if (booking.subtitle.trim().isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          booking.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusBadge(label: booking.status, color: accentColor),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.xSmall,
              runSpacing: AppSpacing.xSmall,
              children: booking.displayFields
                  .take(10)
                  .map(
                    (MapEntry<String, String> field) =>
                        _InfoChip(label: field.key, value: field.value),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(ColorRole role) {
    switch (role) {
      case ColorRole.blue:
        return AppColors.primaryBlue;
      case ColorRole.green:
        return AppColors.primaryGreen;
      case ColorRole.red:
        return AppColors.primaryRed;
      case ColorRole.orange:
        return AppColors.warning;
    }
  }
}

class _QueueEmptyState extends StatelessWidget {
  const _QueueEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.confirmation_number_outlined,
            size: 42,
            color: AppColors.primaryTeal,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Belum ada nomor antrian',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            'History akan muncul setelah pendaftaran umum dibuat dari aplikasi.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _QueueAccessState extends StatelessWidget {
  const _QueueAccessState({
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.large),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.link_off_rounded, color: AppColors.warning),
              const SizedBox(height: AppSpacing.medium),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xSmall),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
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
          ),
        ),
      ],
    );
  }
}

class _QueueErrorCard extends StatelessWidget {
  const _QueueErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Container(
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
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
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
