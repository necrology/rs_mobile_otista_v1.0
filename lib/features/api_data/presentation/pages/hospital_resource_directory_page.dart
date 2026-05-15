import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
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
            final int activeRoomCount = records.where(_isActiveRoom).length;

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
                  if (state.errorMessage != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.medium),
                    _ErrorCard(message: state.errorMessage!),
                  ],
                  if (isRoom && records.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.medium),
                    _RoomSummaryCard(
                      visibleCount: records.length,
                      activeCount: activeRoomCount,
                      totalCount: collection?.total,
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
    final String hidden = record.value(const <String>['hidden']).toUpperCase();
    final String deletedAt = record.value(const <String>['deleted_at']);
    return hidden != 'Y' && (deletedAt == '-' || deletedAt.trim().isEmpty);
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
              'Lihat daftar poli, kode ruangan, lantai, kuota, dan jam layanan yang tersedia.',
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
              'Lihat data kamar rawat inap, kode kamar, kelas, dan status aktif dari sistem rumah sakit.',
          sectionTitle: 'Data Kamar Rawat Inap',
          searchLabel: 'Cari kamar atau kode',
          emptyText: 'Tidak ada kamar yang cocok.',
          icon: Icons.bed_outlined,
          sectionIcon: Icons.meeting_room_outlined,
          accentColor: AppColors.primaryBlue,
          priorityKeys: <String>['nama', 'kode'],
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
    required this.totalCount,
  });

  final int visibleCount;
  final int activeCount;
  final int? totalCount;

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
                label: 'Aktif',
                value: '$activeCount',
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: _SummaryMetric(
                icon: Icons.storage_outlined,
                label: 'Total',
                value: totalCount?.toString() ?? '-',
                color: AppColors.primaryRed,
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
  });

  final ResourceRecord record;
  final _ResourceCopy copy;
  final bool isRoom;

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
                fields: record.displayFields(
                  limit: 40,
                  priorityKeys: copy.priorityKeys,
                ),
                badges: isRoom
                    ? <Widget>[_RoomStatusBadge(record: record, onAccent: true)]
                    : const <Widget>[],
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
                      _RoomStatusBadge(record: record),
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
      return record.value(const <String>['kode'], fallback: '');
    }

    final String kodeRuangan = record.value(const <String>[
      'kode_ruangan',
      'kode',
    ], fallback: '');
    final String kelas = record.value(const <String>['kelas'], fallback: '');

    return <String>[
      kodeRuangan,
      kelas,
    ].where((String value) => value.trim().isNotEmpty).join(' - ');
  }
}

class _RoomStatusBadge extends StatelessWidget {
  const _RoomStatusBadge({required this.record, this.onAccent = false});

  final ResourceRecord record;
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    final String hidden = record.value(const <String>['hidden']).toUpperCase();
    final String deletedAt = record.value(const <String>['deleted_at']);
    final bool isActive =
        hidden != 'Y' && (deletedAt == '-' || deletedAt.trim().isEmpty);
    final Color color = isActive ? AppColors.primaryGreen : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: onAccent
            ? Colors.white.withValues(alpha: 0.16)
            : color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        isActive ? 'Kamar aktif' : 'Kamar nonaktif',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: onAccent ? Colors.white : color,
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
