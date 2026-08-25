import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/mobile_jkn_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../api_data/presentation/pages/hospital_resource_directory_page.dart';
import '../../../booking/presentation/pages/general_queue_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../cubit/navigation_cubit.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    GeneralQueuePage(),
    HospitalResourceDirectoryPage.polyclinic(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (BuildContext context, int activeTabIndex) {
        return Scaffold(
          extendBody: true,
          body: IndexedStack(index: activeTabIndex, children: _pages),
          bottomNavigationBar: _SoftBottomNav(
            activeIndex: activeTabIndex,
            onTap: context.read<NavigationCubit>().changeTab,
            onQueueTap: () => _showQueueChoiceSheet(context),
          ),
        );
      },
    );
  }

  Future<void> _showQueueChoiceSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final double bottomInset = MediaQuery.viewPaddingOf(
          sheetContext,
        ).bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.medium,
            AppSpacing.large,
            AppSpacing.large + bottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pilih Jenis Antrian',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                'Gunakan jalur umum untuk aplikasi mobile ini, atau lanjutkan BPJS melalui Mobile JKN.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              _QueueChoiceTile(
                icon: Icons.local_hospital_outlined,
                title: 'Registrasi Umum',
                subtitle: 'Buka page nomor antrian untuk pendaftaran poli.',
                color: AppColors.primaryGreen,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.read<NavigationCubit>().changeTab(1);
                },
              ),
              const SizedBox(height: AppSpacing.small),
              _QueueChoiceTile(
                icon: Icons.health_and_safety_outlined,
                title: 'Antrian BPJS',
                subtitle: 'Buka Mobile JKN atau Play Store bila belum ada.',
                color: AppColors.primaryBlue,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  try {
                    await MobileJknLauncher.open();
                  } catch (_) {
                    if (!context.mounted) {
                      return;
                    }
                    showAppSnackBar(
                      context,
                      'Mobile JKN atau Play Store belum bisa dibuka.',
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SoftBottomNav extends StatelessWidget {
  const _SoftBottomNav({
    required this.activeIndex,
    required this.onTap,
    required this.onQueueTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onQueueTap;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(Icons.home_rounded, 'Beranda', pageIndex: 0),
    _NavItem(Icons.calendar_month_rounded, 'Booking', pageIndex: 1),
    _NavItem(Icons.groups_rounded, 'Antrian', isCenterAction: true),
    _NavItem(Icons.event_available_outlined, 'Poli & Jadwal', pageIndex: 2),
    _NavItem(Icons.person_rounded, 'Profil', pageIndex: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.92),
              blurRadius: 6,
              offset: const Offset(-2, -4),
            ),
            BoxShadow(
              color: AppColors.deepTeal.withValues(alpha: 0.24),
              blurRadius: 22,
              offset: const Offset(0, -6),
            ),
            BoxShadow(
              color: AppColors.deepTeal.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: List<Widget>.generate(_items.length, (int index) {
            final _NavItem item = _items[index];
            final bool selected =
                item.pageIndex != null && activeIndex == item.pageIndex;

            if (item.isCenterAction) {
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onQueueTap,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.deepTeal.withValues(alpha: 0.32),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(item.icon, color: Colors.white, size: 27),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 9.5,
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => onTap(item.pageIndex!),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 34,
                      height: 30,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryTeal
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: selected ? Colors.white : AppColors.borderSoft,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9.5,
                        color: selected
                            ? AppColors.primaryTeal
                            : AppColors.borderSoft,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _QueueChoiceTile extends StatelessWidget {
  const _QueueChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(
    this.icon,
    this.label, {
    this.pageIndex,
    this.isCenterAction = false,
  });

  final IconData icon;
  final String label;
  final int? pageIndex;
  final bool isCenterAction;
}
