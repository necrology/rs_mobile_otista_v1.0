import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_branding.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/auth_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Akun')),
      body: AppBackground(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState authState) {
            if (!authState.isAuthenticated) {
              return _GuestProfileView(
                onLoginTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AuthPage()),
                  );
                },
                onRegisterTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AuthPage(startWithRegister: true),
                    ),
                  );
                },
              );
            }

            final identity = authState.identity!;

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.small,
                AppSpacing.large,
                110,
              ),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const BrandLogo(size: 62, borderRadius: 18),
                            const SizedBox(width: AppSpacing.medium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    identity.fullName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(identity.email),
                                  const SizedBox(height: 2),
                                  Text(identity.phoneNumber),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Wrap(
                          spacing: AppSpacing.small,
                          runSpacing: AppSpacing.small,
                          children: <Widget>[
                            _InfoChip(
                              icon: Icons.verified_user_outlined,
                              label: 'Akun aktif',
                              color: AppColors.primaryGreen,
                            ),
                            _InfoChip(
                              icon: Icons.family_restroom_outlined,
                              label:
                                  '${identity.familyMembers.length} keluarga terhubung',
                              color: AppColors.primaryBlue,
                            ),
                            _InfoChip(
                              icon: Icons.local_hospital_outlined,
                              label: AppBranding.hospitalShortName,
                              color: AppColors.primaryRed,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Keluarga Terdaftar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.small),
                ...identity.familyMembers.map(
                  (String memberName) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.small),
                    child: Card(
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.10,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.people_alt_outlined),
                        ),
                        title: Text(memberName),
                        subtitle: const Text('Terhubung ke profil pasien'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Menu Profil',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.small),
                Card(
                  child: Column(
                    children: <Widget>[
                      _ProfileMenuTile(
                        icon: Icons.settings_outlined,
                        title: 'Pengaturan Akun',
                        onTap: () => showAppSnackBar(
                          context,
                          'Halaman pengaturan masih berupa contoh tampilan.',
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileMenuTile(
                        icon: Icons.badge_outlined,
                        title: 'Identitas Rumah Sakit',
                        onTap: () =>
                            showAppSnackBar(context, AppBranding.website),
                      ),
                      const Divider(height: 1),
                      _ProfileMenuTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Bantuan & Informasi',
                        onTap: () => showAppSnackBar(
                          context,
                          'Kanal resmi: ${AppBranding.email}',
                        ),
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
                        Text(
                          'Visi Misi',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          AppBranding.visionMission,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: authState.isSubmitting
                        ? null
                        : () => context.read<AuthCubit>().signOut(),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView({
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const BrandLogo(size: 68, borderRadius: 20),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Guest Mode Aktif',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xSmall),
                Text(
                  'Login untuk membuka rekam medis, booking, pembayaran, resep, dan konsultasi dokter dengan tampilan yang lebih personal.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.large),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onLoginTap,
                    child: const Text('Login Akun'),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onRegisterTap,
                    child: const Text('Registrasi Akun Baru'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          'Akses tanpa login',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.small),
        const _GuestMenuCard(
          icon: Icons.local_hospital_outlined,
          title: 'Informasi Rumah Sakit & Dokter',
        ),
        const SizedBox(height: AppSpacing.small),
        const _GuestMenuCard(
          icon: Icons.payments_outlined,
          title: 'Tarif & Estimasi Biaya',
        ),
        const SizedBox(height: AppSpacing.small),
        const _GuestMenuCard(
          icon: Icons.contact_phone_outlined,
          title: 'Kontak Resmi',
        ),
        const SizedBox(height: AppSpacing.medium),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppBranding.hospitalLongName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  AppBranding.address,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  AppBranding.website,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GuestMenuCard extends StatelessWidget {
  const _GuestMenuCard({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon),
        ),
        title: Text(title),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: 2,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
