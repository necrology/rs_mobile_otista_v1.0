import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../domain/entities/resource_record.dart';
import 'api_record_detail_page.dart';
import '../cubit/rs_api_cubit.dart';

class EmployeeDirectoryPage extends StatefulWidget {
  const EmployeeDirectoryPage({super.key});

  @override
  State<EmployeeDirectoryPage> createState() => _EmployeeDirectoryPageState();
}

class _EmployeeDirectoryPageState extends State<EmployeeDirectoryPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSchedules());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Dokter')),
      body: AppBackground(
        child: BlocBuilder<RsApiCubit, RsApiState>(
          builder: (BuildContext context, RsApiState state) {
            final List<_DoctorScheduleView> schedules = _buildSchedules(state);
            final bool isLoading =
                state.isLoadingDoctorSchedules || state.isLoadingPolyclinics;

            return RefreshIndicator(
              onRefresh: _loadSchedules,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.small,
                  AppSpacing.large,
                  110,
                ),
                children: <Widget>[
                  _DoctorHeader(
                    itemCount: schedules.length,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      child: _SearchBar(
                        controller: _searchController,
                        isLoading: isLoading,
                        onSearch: _loadSchedules,
                      ),
                    ),
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
                              const Icon(
                                Icons.event_available_outlined,
                                size: 18,
                                color: AppColors.primaryBlue,
                              ),
                              const SizedBox(width: AppSpacing.xSmall),
                              Expanded(
                                child: Text(
                                  'Jadwal Praktik Dokter',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.small),
                          if (isLoading && schedules.isEmpty)
                            const _LoadingBlock()
                          else if (schedules.isEmpty)
                            const _EmptyText(
                              'Tidak ada jadwal dokter yang cocok.',
                            )
                          else
                            ...schedules.map(
                              (_DoctorScheduleView schedule) =>
                                  _DoctorScheduleTile(schedule: schedule),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _loadSchedules() async {
    FocusScope.of(context).unfocus();
    final RsApiCubit cubit = context.read<RsApiCubit>();

    await Future.wait(<Future<void>>[
      cubit.searchDoctorSchedules(_searchController.text),
      cubit.searchPolyclinics(''),
    ]);
  }

  List<_DoctorScheduleView> _buildSchedules(RsApiState state) {
    final Map<String, ResourceRecord> polyclinicByName =
        <String, ResourceRecord>{
          for (final ResourceRecord polyclinic
              in state.polyclinics?.items ?? <ResourceRecord>[])
            _normalizeJoinKey(polyclinic.name): polyclinic,
        };

    final String query = _searchController.text.trim().toLowerCase();

    final List<_DoctorScheduleView> schedules =
        (state.doctorSchedules?.items ?? <ResourceRecord>[])
            .map(
              (ResourceRecord schedule) => _DoctorScheduleView(
                schedule: schedule,
                polyclinic:
                    polyclinicByName[_normalizeJoinKey(
                      schedule.value(const <String>['poli'], fallback: ''),
                    )],
              ),
            )
            .where(
              (_DoctorScheduleView schedule) =>
                  query.isEmpty || schedule.matches(query),
            )
            .toList()
          ..sort((_DoctorScheduleView left, _DoctorScheduleView right) {
            final int byPolyclinic = left.polyclinicName.compareTo(
              right.polyclinicName,
            );
            if (byPolyclinic != 0) {
              return byPolyclinic;
            }

            return left.doctorName.compareTo(right.doctorName);
          });

    return schedules;
  }

  String _normalizeJoinKey(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }
}

class _DoctorScheduleView {
  const _DoctorScheduleView({required this.schedule, required this.polyclinic});

  final ResourceRecord schedule;
  final ResourceRecord? polyclinic;

  String get doctorName =>
      _clean(schedule.value(const <String>['dokter'], fallback: 'Dokter'));

  String get role => 'Jadwal praktik tambahan';

  String get polyclinicName {
    final String joinedName = _clean(polyclinic?.name ?? '');
    if (joinedName.isNotEmpty) {
      return joinedName;
    }

    final String schedulePolyclinic = _clean(
      schedule.value(const <String>['poli'], fallback: ''),
    );
    return schedulePolyclinic.isEmpty
        ? 'Poli belum terhubung'
        : schedulePolyclinic;
  }

  String get roomCode => _clean(
    polyclinic?.value(const <String>['kode_ruangan', 'kode'], fallback: '') ??
        '',
  );

  String get serviceTime {
    final String start = _formatTime(
      schedule.value(const <String>['jam_mulai'], fallback: ''),
    );
    final String end = _formatTime(
      schedule.value(const <String>['jam_berakhir'], fallback: ''),
    );

    if (start.isEmpty && end.isEmpty) {
      return 'Jam belum tersedia';
    }
    if (start.isEmpty) {
      return 'Sampai $end';
    }
    if (end.isEmpty) {
      return 'Mulai $start';
    }

    return '$start - $end';
  }

  String get daySummary {
    final String hari = _clean(
      schedule.value(const <String>['hari'], fallback: ''),
    );
    return hari.isEmpty ? 'Hari praktik belum tersedia' : hari;
  }

  int get doctorQuota => 0;

  int get polyclinicQuota => polyclinic?.intValue(const <String>['kuota']) ?? 0;

  int get onlineQuota =>
      polyclinic?.intValue(const <String>['kuota_online']) ?? 0;

  int get filledQuota => polyclinic?.intValue(const <String>['terisi']) ?? 0;

  int get effectiveQuota => doctorQuota > 0 ? doctorQuota : polyclinicQuota;

  int get remainingQuota => math.max(0, effectiveQuota - filledQuota);

  String get quotaSummary {
    if (effectiveQuota <= 0 && onlineQuota <= 0 && filledQuota <= 0) {
      return 'Kuota belum tersedia';
    }

    return 'Kuota $effectiveQuota | Terisi $filledQuota | Sisa $remainingQuota';
  }

  List<MapEntry<String, String>> get detailFields {
    final List<MapEntry<String, String>> fields = <MapEntry<String, String>>[];

    void add(String label, String value) {
      final String normalizedValue = _clean(value);
      if (normalizedValue.isEmpty) {
        return;
      }
      fields.add(MapEntry<String, String>(label, normalizedValue));
    }

    add('Nama Dokter', doctorName);
    add('Keterangan', role);
    add('Poli', polyclinicName);
    add('Kode Ruangan', roomCode);
    add('Jam Praktik', serviceTime);
    add('Hari Praktik', daySummary);
    if (polyclinicQuota > 0) {
      add('Kuota Poli', polyclinicQuota.toString());
    }
    if (onlineQuota > 0) {
      add('Kuota Online', onlineQuota.toString());
    }
    if (filledQuota > 0) {
      add('Terisi', filledQuota.toString());
      add('Sisa Kuota', remainingQuota.toString());
    }

    return fields;
  }

  bool matches(String query) {
    final String aggregate =
        '$doctorName $role $polyclinicName $roomCode $serviceTime $daySummary'
            .toLowerCase();
    return aggregate.contains(query);
  }

  static String _clean(String value) {
    final String normalizedValue = value.trim();
    if (normalizedValue.isEmpty || normalizedValue == '-') {
      return '';
    }

    return normalizedValue;
  }

  static String _formatTime(String value) {
    final String normalizedValue = _clean(value);
    if (normalizedValue.isEmpty) {
      return '';
    }

    final RegExpMatch? match = RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2})?$').firstMatch(normalizedValue);
    if (match == null) {
      return normalizedValue;
    }

    final int hour = int.tryParse(match.group(1) ?? '') ?? 0;
    final String minute = match.group(2) ?? '00';
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }
}

class _DoctorHeader extends StatelessWidget {
  const _DoctorHeader({required this.itemCount, required this.isLoading});

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
            AppColors.primaryBlue.withValues(alpha: 0.92),
            AppColors.primaryGreen.withValues(alpha: 0.82),
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
                  Icons.medical_services_outlined,
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
            'Jadwal Dokter',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            'Informasi publik dokter dibatasi ke jadwal praktik, poli, jam layanan, dan kuota.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Text(
              '$itemCount jadwal tampil',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.isLoading,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 330;
        final Widget field = TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onSearch(),
          decoration: const InputDecoration(
            labelText: 'Cari dokter atau poli',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        );
        final Widget button = FilledButton(
          onPressed: isLoading ? null : onSearch,
          child: isLoading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Cari'),
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

class _DoctorScheduleTile extends StatelessWidget {
  const _DoctorScheduleTile({required this.schedule});

  final _DoctorScheduleView schedule;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ApiRecordDetailPage(
                appBarTitle: 'Detail Jadwal Dokter',
                title: schedule.doctorName,
                subtitle: schedule.polyclinicName,
                icon: Icons.event_available_outlined,
                accentColor: AppColors.primaryBlue,
                fields: schedule.detailFields,
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
                  color: AppColors.primaryBlue.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      schedule.doctorName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.polyclinicName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Wrap(
                      spacing: AppSpacing.xSmall,
                      runSpacing: AppSpacing.xSmall,
                      children: <Widget>[
                        _ScheduleChip(
                          icon: Icons.schedule_outlined,
                          label: schedule.serviceTime,
                          color: AppColors.primaryBlue,
                        ),
                        _ScheduleChip(
                          icon: Icons.calendar_month_outlined,
                          label: schedule.daySummary,
                          color: AppColors.primaryGreen,
                        ),
                        _ScheduleChip(
                          icon: Icons.groups_2_outlined,
                          label: schedule.quotaSummary,
                          color: AppColors.primaryRed,
                        ),
                      ],
                    ),
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

class _ScheduleChip extends StatelessWidget {
  const _ScheduleChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
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
