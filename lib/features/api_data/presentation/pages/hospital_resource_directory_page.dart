import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../booking/domain/entities/booking_options.dart';
import '../../domain/entities/api_collection.dart';
import '../../domain/entities/resource_record.dart';
import 'api_record_detail_page.dart';
import '../cubit/rs_api_cubit.dart';

enum HospitalResourceType { polyclinic, room }

class HospitalResourceDirectoryPage extends StatefulWidget {
  const HospitalResourceDirectoryPage.polyclinic({super.key})
    : type = HospitalResourceType.polyclinic;

  const HospitalResourceDirectoryPage.room({super.key})
    : type = HospitalResourceType.room;

  final HospitalResourceType type;

  @override
  State<HospitalResourceDirectoryPage> createState() =>
      _HospitalResourceDirectoryPageState();
}

class _HospitalResourceDirectoryPageState
    extends State<HospitalResourceDirectoryPage> {
  late final TextEditingController _searchController;

  _ResourceCopy get _copy => _ResourceCopy.forType(widget.type);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_copy.appBarTitle)),
      body: AppBackground(
        child: BlocBuilder<RsApiCubit, RsApiState>(
          builder: (BuildContext context, RsApiState state) {
            final ApiCollection<ResourceRecord>? collection =
                widget.type == HospitalResourceType.polyclinic
                ? state.polyclinics
                : state.rooms;
            final List<ResourceRecord> records =
                collection?.items ?? <ResourceRecord>[];
            final bool isLoading =
                widget.type == HospitalResourceType.polyclinic
                ? state.isLoadingPolyclinics
                : state.isLoadingRooms;
            final bool isRoom = widget.type == HospitalResourceType.room;
            final bool hasResourceError =
                state.errorMessage != null && records.isEmpty;
            final int activeRoomCount = records.where(_isActiveRoom).length;
            final List<_RoomQuota> visibleRoomQuotas = isRoom
                ? records.map(_RoomQuota.fromRecord).toList()
                : const <_RoomQuota>[];

            return RefreshIndicator(
              onRefresh: () => _search(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.small,
                  AppSpacing.large,
                  110,
                ),
                children: <Widget>[
                  _ResourceHeader(
                    copy: _copy,
                    count: records.length,
                    total: collection?.total,
                    activeRoomCount: isRoom ? activeRoomCount : null,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      child: _SearchBar(
                        controller: _searchController,
                        isLoading: isLoading,
                        label: _copy.searchLabel,
                        onSearch: _search,
                      ),
                    ),
                  ),
                  if (hasResourceError) ...<Widget>[
                    const SizedBox(height: AppSpacing.medium),
                    _ErrorCard(message: state.errorMessage!),
                  ],
                  if (isRoom && records.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.medium),
                    _RoomSummaryCard(
                      visibleCount: records.length,
                      activeCount: activeRoomCount,
                      totalQuota: _sumQuota(
                        visibleRoomQuotas,
                        (_RoomQuota quota) => quota.total,
                      ),
                      filledQuota: _sumQuota(
                        visibleRoomQuotas,
                        (_RoomQuota quota) => quota.filled,
                      ),
                    ),
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
                              (ResourceRecord record) => _ResourceTile(
                                record: record,
                                copy: _copy,
                                isRoom: isRoom,
                                roomQuota: isRoom
                                    ? _RoomQuota.fromRecord(record)
                                    : null,
                              ),
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

  Future<void> _search() {
    FocusScope.of(context).unfocus();
    final RsApiCubit cubit = context.read<RsApiCubit>();
    final String query = _searchController.text;

    switch (widget.type) {
      case HospitalResourceType.polyclinic:
        return cubit.searchPolyclinics(query);
      case HospitalResourceType.room:
        return cubit.searchRooms(query);
    }
  }

  bool _isActiveRoom(ResourceRecord record) {
    if (record.data.containsKey('jumlah_bed')) {
      return record.intValue(const <String>['jumlah_bed']) > 0;
    }

    final String hidden = record.value(const <String>['hidden']).toUpperCase();
    final String deletedAt = record.value(const <String>['deleted_at']);
    return hidden != 'Y' && (deletedAt == '-' || deletedAt.trim().isEmpty);
  }

  int _sumQuota(
    List<_RoomQuota> quotas,
    int Function(_RoomQuota quota) selector,
  ) {
    return quotas.fold<int>(
      0,
      (int total, _RoomQuota quota) => total + selector(quota),
    );
  }
}

class _RoomQuota {
  const _RoomQuota({
    this.total = 0,
    this.online = 0,
    this.filled = 0,
    this.renovation = 0,
  });

  factory _RoomQuota.fromRecord(ResourceRecord record) {
    return _RoomQuota(
      total: record.intValue(const <String>['jumlah_bed', 'total_bed']),
      online: record.intValue(const <String>['jumlah_kamar']),
      filled: record.intValue(const <String>['terisi', 'filled']),
      renovation: record.intValue(const <String>['renovasi']),
    );
  }

  final int total;
  final int online;
  final int filled;
  final int renovation;

  int get remaining {
    final int unavailable = filled + renovation;
    return total > unavailable ? total - unavailable : 0;
  }

  _RoomQuota add({
    required int total,
    required int online,
    required int filled,
    required int renovation,
  }) {
    return _RoomQuota(
      total: this.total + total,
      online: this.online + online,
      filled: this.filled + filled,
      renovation: this.renovation + renovation,
    );
  }

  String get summary {
    if (total <= 0 && online <= 0 && filled <= 0 && renovation <= 0) {
      return 'Bed belum tersedia';
    }

    return 'Bed $total | Terisi $filled | Kosong $remaining';
  }

  List<MapEntry<String, String>> get fields {
    return <MapEntry<String, String>>[
      MapEntry<String, String>('Jumlah Bed', total.toString()),
      MapEntry<String, String>('Jumlah Kamar', online.toString()),
      MapEntry<String, String>('Terisi', filled.toString()),
      if (renovation > 0)
        MapEntry<String, String>('Renovasi', renovation.toString()),
      MapEntry<String, String>('Bed Kosong', remaining.toString()),
    ];
  }
}

class _ResourceCopy {
  const _ResourceCopy({
    required this.appBarTitle,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.sectionTitle,
    required this.searchLabel,
    required this.emptyText,
    required this.icon,
    required this.sectionIcon,
    required this.accentColor,
    required this.priorityKeys,
  });

  final String appBarTitle;
  final String heroTitle;
  final String heroSubtitle;
  final String sectionTitle;
  final String searchLabel;
  final String emptyText;
  final IconData icon;
  final IconData sectionIcon;
  final Color accentColor;
  final List<String> priorityKeys;

  static _ResourceCopy forType(HospitalResourceType type) {
    switch (type) {
      case HospitalResourceType.polyclinic:
        return const _ResourceCopy(
          appBarTitle: 'Poli & Jadwal',
          heroTitle: 'Pilihan Poli dan Jadwal Praktik',
          heroSubtitle:
              'Lihat daftar poli, kode ruangan, hari praktik, jam layanan, kuota, dan status layanan.',
          sectionTitle: 'Daftar Poli',
          searchLabel: 'Cari poli atau kode ruangan',
          emptyText: 'Tidak ada poli yang cocok.',
          icon: Icons.event_available_outlined,
          sectionIcon: Icons.local_hospital_outlined,
          accentColor: AppColors.primaryGreen,
          priorityKeys: <String>[
            'nama',
            'kode_ruangan',
            'kelas',
            'lantai',
            'buka',
            'tutup',
            'kuota',
            'kuota_online',
            'terisi',
          ],
        );
      case HospitalResourceType.room:
        return const _ResourceCopy(
          appBarTitle: 'Ketersediaan Kamar',
          heroTitle: 'Kamar Rawat Inap',
          heroSubtitle:
              'Lihat total bed, bed terisi, dan bed kosong per kelompok kelas rawat inap.',
          sectionTitle: 'Ketersediaan Bed per Kelas',
          searchLabel: 'Cari kode, kelas, atau ruangan',
          emptyText: 'Tidak ada data bed yang cocok.',
          icon: Icons.bed_outlined,
          sectionIcon: Icons.meeting_room_outlined,
          accentColor: AppColors.primaryBlue,
          priorityKeys: <String>[
            'general_code',
            'kelas',
            'ruangan',
            'jumlah_kamar',
            'jumlah_bed',
            'terisi',
            'kosong',
            'keterangan',
          ],
        );
    }
  }
}

class _ResourceHeader extends StatelessWidget {
  const _ResourceHeader({
    required this.copy,
    required this.count,
    required this.total,
    required this.activeRoomCount,
    required this.isLoading,
  });

  final _ResourceCopy copy;
  final int count;
  final int? total;
  final int? activeRoomCount;
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
            AppColors.primaryRed.withValues(alpha: 0.74),
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
                child: Icon(copy.icon, color: Colors.white),
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
              _HeaderPill(label: 'Tampil', value: '$count'),
              _HeaderPill(label: 'Total', value: total?.toString() ?? '-'),
              if (activeRoomCount != null)
                _HeaderPill(label: 'Aktif', value: '$activeRoomCount'),
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

class _RoomSummaryCard extends StatelessWidget {
  const _RoomSummaryCard({
    required this.visibleCount,
    required this.activeCount,
    required this.totalQuota,
    required this.filledQuota,
  });

  final int visibleCount;
  final int activeCount;
  final int totalQuota;
  final int filledQuota;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _SummaryMetric(
                icon: Icons.bed_outlined,
                label: 'Tampil',
                value: '$visibleCount',
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: _SummaryMetric(
                icon: Icons.check_circle_outline_rounded,
                label: 'Grup Aktif',
                value: '$activeCount',
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: _SummaryMetric(
                icon: Icons.storage_outlined,
                label: 'Total Bed',
                value: '$totalQuota',
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: _SummaryMetric(
                icon: Icons.groups_2_outlined,
                label: 'Bed Kosong',
                value:
                    '${totalQuota > filledQuota ? totalQuota - filledQuota : 0}',
                color: AppColors.primaryTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.small),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(height: AppSpacing.small),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
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
    required this.label,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isLoading;
  final String label;
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
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.search_rounded),
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

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.record,
    required this.copy,
    required this.isRoom,
    required this.roomQuota,
  });

  final ResourceRecord record;
  final _ResourceCopy copy;
  final bool isRoom;
  final _RoomQuota? roomQuota;

  @override
  Widget build(BuildContext context) {
    final String subtitle = _subtitle;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ApiRecordDetailPage(
                appBarTitle: 'Detail ${copy.appBarTitle}',
                title: record.name,
                subtitle: subtitle,
                icon: copy.sectionIcon,
                accentColor: copy.accentColor,
                fields: isRoom
                    ? record
                          .displayFields(
                            limit: 40,
                            priorityKeys: copy.priorityKeys,
                          )
                          .followedBy(
                            roomQuota?.fields ??
                                const <MapEntry<String, String>>[],
                          )
                          .toList()
                    : _polyclinicDetailFields,
                badges: isRoom
                    ? <Widget>[_RoomStatusBadge(record: record, onAccent: true)]
                    : <Widget>[
                        _PolyclinicStatusBadge(
                          status: _practiceStatus,
                          onAccent: true,
                        ),
                      ],
                extraSections: isRoom
                    ? const <Widget>[]
                    : <Widget>[
                        _PolyclinicBookingOptionsSection(
                          poliId: int.tryParse(record.id) ?? 0,
                          accentColor: copy.accentColor,
                        ),
                      ],
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
                  color: copy.accentColor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  copy.sectionIcon,
                  color: copy.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      record.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (isRoom) ...<Widget>[
                      const SizedBox(height: AppSpacing.xSmall),
                      Wrap(
                        spacing: AppSpacing.xSmall,
                        runSpacing: AppSpacing.xSmall,
                        children: <Widget>[
                          _RoomStatusBadge(record: record),
                          _RoomQuotaBadge(roomQuota: roomQuota),
                        ],
                      ),
                    ] else ...<Widget>[
                      const SizedBox(height: AppSpacing.xSmall),
                      Wrap(
                        spacing: AppSpacing.xSmall,
                        runSpacing: AppSpacing.xSmall,
                        children: <Widget>[
                          _PolyclinicStatusBadge(status: _practiceStatus),
                          _InfoBadge(
                            icon: Icons.schedule_outlined,
                            label: _serviceHours,
                            color: AppColors.primaryBlue,
                          ),
                          _InfoBadge(
                            icon: Icons.calendar_month_outlined,
                            label: _practiceDays,
                            color: AppColors.primaryGreen,
                          ),
                          _InfoBadge(
                            icon: Icons.groups_2_outlined,
                            label: _quotaSummary,
                            color: AppColors.primaryRed,
                          ),
                        ],
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

  String get _subtitle {
    if (isRoom) {
      return <String>[
            record.value(const <String>['general_code', 'kode'], fallback: ''),
            roomQuota?.summary ?? '',
          ]
          .where((String value) {
            final String normalizedValue = value.trim();
            return normalizedValue.isNotEmpty && normalizedValue != '-';
          })
          .join(' - ');
    }

    final String kodeRuangan = record.value(const <String>[
      'kode_ruangan',
      'kode',
    ], fallback: '');
    final String kelas = record.value(const <String>['kelas'], fallback: '');

    return <String>[
      kodeRuangan,
      kelas,
      _serviceHours,
    ].where((String value) => value.trim().isNotEmpty).join(' - ');
  }

  List<MapEntry<String, String>> get _polyclinicDetailFields {
    final List<MapEntry<String, String>> fields = <MapEntry<String, String>>[];

    void add(String label, String value) {
      final String normalizedValue = value.trim();
      if (normalizedValue.isEmpty ||
          normalizedValue == '-' ||
          normalizedValue == '0000-00-00') {
        return;
      }
      fields.add(MapEntry<String, String>(label, normalizedValue));
    }

    add('Nama Poli', record.name);
    add('Kode Ruangan', record.value(const <String>['kode_ruangan', 'kode']));
    add('Kelas', record.value(const <String>['kelas']));
    add('Kelompok', record.value(const <String>['kelompok']));
    add('Lantai', record.value(const <String>['lantai']));
    add('Jam Layanan', _serviceHours);
    add('Hari Praktik', _practiceDays);
    add('Kuota Poli', _quota.toString());
    add('Kuota Online', _onlineQuota.toString());
    add('Terisi', _filledQuota.toString());
    add('Sisa Kuota', _remainingQuota.toString());
    add('Status Praktik', _practiceStatus);
    add('Status Layanan', _serviceStatus);
    add('Kode BPJS', record.value(const <String>['bpjs']));
    add('Kode Inhealth', record.value(const <String>['inhealth']));
    add('Keterangan', record.value(const <String>['description']));

    return fields;
  }

  String get _serviceHours {
    final String start = _clean(record.value(const <String>['buka']));
    final String end = _clean(record.value(const <String>['tutup']));

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

  String get _practiceDays {
    const List<MapEntry<String, String>> dayKeys = <MapEntry<String, String>>[
      MapEntry<String, String>('monday', 'Senin'),
      MapEntry<String, String>('tuesday', 'Selasa'),
      MapEntry<String, String>('wednesday', 'Rabu'),
      MapEntry<String, String>('thursday', 'Kamis'),
      MapEntry<String, String>('friday', 'Jumat'),
      MapEntry<String, String>('saturday', 'Sabtu'),
      MapEntry<String, String>('sunday', 'Minggu'),
    ];

    final List<String> activeDays = <String>[];
    for (final MapEntry<String, String> day in dayKeys) {
      final int value = record.intValue(<String>[day.key]);
      if (value <= 0) {
        continue;
      }
      activeDays.add(value > 1 ? '${day.value} ($value)' : day.value);
    }

    return activeDays.isEmpty ? 'Hari belum tersedia' : activeDays.join(', ');
  }

  int get _quota => record.intValue(const <String>['kuota']);

  int get _onlineQuota => record.intValue(const <String>['kuota_online']);

  int get _filledQuota => record.intValue(const <String>['terisi']);

  int get _remainingQuota {
    final int remaining = _quota - _filledQuota;
    return remaining > 0 ? remaining : 0;
  }

  String get _quotaSummary {
    if (_quota <= 0 && _onlineQuota <= 0 && _filledQuota <= 0) {
      return 'Kuota belum tersedia';
    }

    return 'Kuota $_quota | Terisi $_filledQuota | Sisa $_remainingQuota';
  }

  String get _practiceStatus {
    final String value = record.value(const <String>['praktik']).toUpperCase();
    if (value == 'Y' || value == '1' || value == 'TRUE') {
      return 'Praktik tersedia';
    }
    if (value == 'T' || value == 'N' || value == '0' || value == 'FALSE') {
      return 'Praktik belum tersedia';
    }
    return 'Status praktik belum tersedia';
  }

  String get _serviceStatus {
    final String flag = record.value(const <String>['flag']).toUpperCase();
    if (flag == 'Y' || flag == '1' || flag == 'TRUE') {
      return 'Layanan aktif';
    }
    if (flag == 'N' || flag == 'T' || flag == '0' || flag == 'FALSE') {
      return 'Layanan nonaktif';
    }
    return 'Mengikuti pengaturan rumah sakit';
  }

  String _clean(String value) {
    final String normalizedValue = value.trim();
    if (normalizedValue.isEmpty ||
        normalizedValue == '-' ||
        normalizedValue == '00:00:00') {
      return '';
    }
    return normalizedValue.replaceAllMapped(
      RegExp(r'(?<!\d)(\d{2}):(\d{2}):(\d{2})(?!\d)'),
      (Match match) => '${match[1]}:${match[2]}',
    );
  }
}

class _PolyclinicBookingOptionsSection extends StatefulWidget {
  const _PolyclinicBookingOptionsSection({
    required this.poliId,
    required this.accentColor,
  });

  final int poliId;
  final Color accentColor;

  @override
  State<_PolyclinicBookingOptionsSection> createState() =>
      _PolyclinicBookingOptionsSectionState();
}

class _PolyclinicBookingOptionsSectionState
    extends State<_PolyclinicBookingOptionsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.poliId <= 0) {
        return;
      }
      context.read<RsApiCubit>().fetchBookingOptions(poliId: widget.poliId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.poliId <= 0) {
      return _ScheduleInfoCard(
        accentColor: widget.accentColor,
        message: 'Detail jadwal dokter belum dapat dimuat.',
      );
    }

    return BlocBuilder<RsApiCubit, RsApiState>(
      builder: (BuildContext context, RsApiState state) {
        final BookingOptionsResponse? options =
            state.bookingOptions?.poli.id == widget.poliId.toString()
            ? state.bookingOptions
            : null;

        if (state.isLoadingBookingOptions && options == null) {
          return _ScheduleInfoCard(
            accentColor: widget.accentColor,
            message: 'Memuat daftar dokter dan jadwal...',
            isLoading: true,
          );
        }

        if (options == null) {
          return _ScheduleInfoCard(
            accentColor: widget.accentColor,
            message: state.errorMessage ?? 'Jadwal dokter belum tersedia.',
          );
        }

        final List<BookingScheduleOption> poliSchedules = options.poli.schedules
            .where(
              (BookingScheduleOption schedule) =>
                  schedule.source.toLowerCase() == 'polis',
            )
            .toList();
        final List<_DoctorScheduleGroup> doctorGroups = _doctorScheduleGroups(
          options.poli,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.event_note_outlined,
                      size: 18,
                      color: widget.accentColor,
                    ),
                    const SizedBox(width: AppSpacing.xSmall),
                    Expanded(
                      child: Text(
                        'Dokter dan Jadwal',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Jadwal Poli',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xSmall),
                if (poliSchedules.isEmpty)
                  Text(
                    'Jadwal poli belum tersedia.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  _ScheduleWrap(
                    schedules: poliSchedules,
                    accentColor: AppColors.primaryGreen,
                  ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Daftar Dokter',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xSmall),
                if (doctorGroups.isEmpty)
                  Text(
                    'Belum ada dokter yang terhubung dengan poli ini.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ...doctorGroups.map(
                    (_DoctorScheduleGroup group) => _DoctorScheduleTile(
                      group: group,
                      poliName: options.poli.name,
                      accentColor: widget.accentColor,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_DoctorScheduleGroup> _doctorScheduleGroups(BookingPoliOption poli) {
    final Map<String, _DoctorScheduleGroup> groups =
        <String, _DoctorScheduleGroup>{};

    for (final BookingScheduleOption schedule in poli.schedules) {
      final bool isDoctorSchedule =
          schedule.source.toLowerCase() == 'jadwaldokters' ||
          schedule.doctorName.trim().isNotEmpty;
      if (!isDoctorSchedule) {
        continue;
      }

      final String key = _doctorScheduleKey(
        doctorId: schedule.doctorId,
        doctorName: schedule.doctorName,
      );
      final _DoctorScheduleGroup current =
          groups[key] ??
          _DoctorScheduleGroup(
            fallbackName: schedule.doctorName.trim().isNotEmpty
                ? schedule.doctorName
                : 'Dokter belum terhubung',
            doctorId: schedule.doctorId,
            schedules: <BookingScheduleOption>[],
          );
      current.schedules.add(schedule);
      groups[key] = current;
    }

    for (final BookingDoctorOption doctor in poli.doctors) {
      final String key = _doctorScheduleKey(
        doctorId: doctor.id,
        doctorName: doctor.name,
      );
      final _DoctorScheduleGroup? current = groups[key];
      if (current == null) {
        groups[key] = _DoctorScheduleGroup(
          fallbackName: doctor.displayName,
          doctorId: doctor.id,
          doctor: doctor,
          schedules: doctor.schedules.toList(),
        );
        continue;
      }

      current.doctor = doctor;
      if (current.schedules.isEmpty && doctor.schedules.isNotEmpty) {
        current.schedules.addAll(doctor.schedules);
      }
    }

    final List<_DoctorScheduleGroup> ordered = groups.values.toList()
      ..sort(
        (_DoctorScheduleGroup a, _DoctorScheduleGroup b) =>
            a.name.compareTo(b.name),
      );
    return ordered;
  }

  String _doctorScheduleKey({
    required String doctorId,
    required String doctorName,
  }) {
    final String cleanId = doctorId.trim();
    if (cleanId.isNotEmpty && cleanId != '-' && cleanId != '0') {
      return 'id:$cleanId';
    }
    return 'name:${doctorName.trim().toLowerCase()}';
  }
}

class _DoctorScheduleGroup {
  _DoctorScheduleGroup({
    required this.fallbackName,
    required this.doctorId,
    required this.schedules,
    this.doctor,
  });

  final String fallbackName;
  final String doctorId;
  final List<BookingScheduleOption> schedules;
  BookingDoctorOption? doctor;

  String get name {
    final String value = doctor?.displayName ?? fallbackName;
    return value.trim().isEmpty ? 'Dokter belum terhubung' : value;
  }

  List<MapEntry<String, String>> detailFields({required String poliName}) {
    final List<MapEntry<String, String>> fields = <MapEntry<String, String>>[];

    void add(String label, String value) {
      final String normalizedValue = value.trim();
      if (normalizedValue.isEmpty ||
          normalizedValue == '-' ||
          normalizedValue == 'null') {
        return;
      }
      fields.add(MapEntry<String, String>(label, normalizedValue));
    }

    final BookingDoctorOption? selectedDoctor = doctor;
    add('Nama Dokter', selectedDoctor?.name ?? fallbackName);
    add('ID Dokter', selectedDoctor?.id ?? doctorId);
    add('Kode Antrian', selectedDoctor?.queueCode ?? '');
    add('Poli', poliName);

    if (selectedDoctor != null) {
      add(
        'Jabatan',
        _doctorFieldValue(selectedDoctor.data, const <String>['jabatan']),
      );
      add(
        'Poli ID',
        _doctorFieldValue(selectedDoctor.data, const <String>['poli_id']),
      );
      add(
        'Tipe Poli',
        _doctorFieldValue(selectedDoctor.data, const <String>['poli_type']),
      );
      add(
        'Kuota Poli',
        _doctorFieldValue(selectedDoctor.data, const <String>['kuota_poli']),
      );
      add(
        'Status Dokter',
        _doctorFieldValue(selectedDoctor.data, const <String>['is_dokter']),
      );

      for (final MapEntry<String, dynamic> entry
          in selectedDoctor.data.entries) {
        if (_knownDoctorDetailKeys.contains(entry.key)) {
          continue;
        }
        final String value = entry.value?.toString().trim() ?? '';
        if (value.isEmpty || value == '-' || value == 'null') {
          continue;
        }
        add(_humanizeDoctorKey(entry.key), value);
      }
    }

    if (schedules.isNotEmpty) {
      add('Jumlah Jadwal', schedules.length.toString());
    }

    return fields;
  }
}

const Set<String> _knownDoctorDetailKeys = <String>{
  'id',
  'nama',
  'kode_antrian',
  'general_code',
  'kode_bpjs',
  'jabatan',
  'poli_id',
  'poli_type',
  'kuota_poli',
  'is_dokter',
};

String _doctorFieldValue(Map<String, dynamic> data, List<String> keys) {
  for (final String key in keys) {
    final String value = data[key]?.toString().trim() ?? '';
    if (value.isNotEmpty && value != '-' && value != 'null') {
      return value;
    }
  }
  return '';
}

String _humanizeDoctorKey(String key) {
  return key
      .trim()
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .map(
        (String part) => part.length == 1
            ? part.toUpperCase()
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

class _ScheduleInfoCard extends StatelessWidget {
  const _ScheduleInfoCard({
    required this.accentColor,
    required this.message,
    this.isLoading = false,
  });

  final Color accentColor;
  final String message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: <Widget>[
            if (isLoading)
              SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: accentColor,
                ),
              )
            else
              Icon(Icons.event_note_outlined, color: accentColor, size: 20),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorDetailSchedulesSection extends StatelessWidget {
  const _DoctorDetailSchedulesSection({
    required this.schedules,
    required this.accentColor,
  });

  final List<BookingScheduleOption> schedules;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.event_available_outlined,
                  size: 18,
                  color: accentColor,
                ),
                const SizedBox(width: AppSpacing.xSmall),
                Expanded(
                  child: Text(
                    'Jadwal Praktik',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            if (schedules.isEmpty)
              Text(
                'Jadwal dokter belum tersedia.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              _ScheduleWrap(schedules: schedules, accentColor: accentColor),
          ],
        ),
      ),
    );
  }
}

class _DoctorScheduleTile extends StatelessWidget {
  const _DoctorScheduleTile({
    required this.group,
    required this.poliName,
    required this.accentColor,
  });

  final _DoctorScheduleGroup group;
  final String poliName;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openDetail(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.small),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accentColor.withValues(alpha: 0.16)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.badge_outlined, size: 18, color: accentColor),
              const SizedBox(width: AppSpacing.xSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    if (group.schedules.isEmpty)
                      Text(
                        'Jadwal dokter belum tersedia.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      _ScheduleWrap(
                        schedules: group.schedules,
                        accentColor: accentColor,
                        compact: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xSmall),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: accentColor.withValues(alpha: 0.80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ApiRecordDetailPage(
          appBarTitle: 'Detail Dokter',
          title: group.name,
          subtitle: poliName,
          icon: Icons.medical_services_outlined,
          accentColor: accentColor,
          fields: group.detailFields(poliName: poliName),
          extraSections: <Widget>[
            _DoctorDetailSchedulesSection(
              schedules: group.schedules,
              accentColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleWrap extends StatelessWidget {
  const _ScheduleWrap({
    required this.schedules,
    required this.accentColor,
    this.compact = false,
  });

  final List<BookingScheduleOption> schedules;
  final Color accentColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xSmall,
      runSpacing: AppSpacing.xSmall,
      children: schedules
          .map(
            (BookingScheduleOption schedule) => _ScheduleChip(
              schedule: schedule,
              accentColor: accentColor,
              compact: compact,
            ),
          )
          .toList(),
    );
  }
}

class _ScheduleChip extends StatelessWidget {
  const _ScheduleChip({
    required this.schedule,
    required this.accentColor,
    required this.compact,
  });

  final BookingScheduleOption schedule;
  final Color accentColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final String label = schedule.displayLabel.trim().isNotEmpty
        ? schedule.displayLabel
        : 'Jadwal belum tersedia';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RoomStatusBadge extends StatelessWidget {
  const _RoomStatusBadge({required this.record, this.onAccent = false});

  final ResourceRecord record;
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    final String availability = record.value(const <String>[
      'keterangan',
    ], fallback: '');
    final String hidden = record.value(const <String>['hidden']).toUpperCase();
    final String deletedAt = record.value(const <String>['deleted_at']);
    final bool isActive =
        hidden != 'Y' && (deletedAt == '-' || deletedAt.trim().isEmpty);
    final bool hasAvailability = availability.trim().isNotEmpty;
    final String label = hasAvailability
        ? availability
        : isActive
        ? 'Kamar aktif'
        : 'Kamar nonaktif';
    final bool isAvailable = label.toLowerCase().contains('tersedia');
    final Color color = hasAvailability
        ? isAvailable
              ? AppColors.primaryGreen
              : AppColors.warning
        : isActive
        ? AppColors.primaryGreen
        : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: onAccent
            ? Colors.white.withValues(alpha: 0.16)
            : color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: onAccent ? Colors.white : color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PolyclinicStatusBadge extends StatelessWidget {
  const _PolyclinicStatusBadge({required this.status, this.onAccent = false});

  final String status;
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = status == 'Praktik tersedia';
    final Color color = isAvailable
        ? AppColors.primaryGreen
        : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: onAccent
            ? Colors.white.withValues(alpha: 0.16)
            : color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: onAccent ? Colors.white : color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
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

class _RoomQuotaBadge extends StatelessWidget {
  const _RoomQuotaBadge({required this.roomQuota});

  final _RoomQuota? roomQuota;

  @override
  Widget build(BuildContext context) {
    final _RoomQuota? quota = roomQuota;
    final bool hasQuota = quota != null && quota.total > 0;
    final Color color = hasQuota ? AppColors.primaryBlue : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        quota?.summary ?? 'Kuota belum tersedia',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
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
