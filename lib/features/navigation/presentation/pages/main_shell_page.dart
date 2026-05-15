import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../booking/presentation/pages/booking_page.dart';
import '../../../consultation/presentation/pages/consultation_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../cubit/navigation_cubit.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    BookingPage(),
    ConsultationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (BuildContext context, int activeTabIndex) {
        return Scaffold(
          extendBody: true,
          body: IndexedStack(index: activeTabIndex, children: _pages),
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: NavigationBar(
                  height: 66,
                  selectedIndex: activeTabIndex,
                  onDestinationSelected: context
                      .read<NavigationCubit>()
                      .changeTab,
                  destinations: const <NavigationDestination>[
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: 'Beranda',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: 'Booking',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.monitor_heart_outlined),
                      selectedIcon: Icon(Icons.monitor_heart),
                      label: 'Konsultasi',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: 'Profil',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
