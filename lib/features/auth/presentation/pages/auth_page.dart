import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_branding.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../cubit/auth_cubit.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({this.startWithRegister = false, super.key});

  final bool startWithRegister;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPhoneController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthCubit authCubit = context.read<AuthCubit>();
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return DefaultTabController(
      initialIndex: widget.startWithRegister ? 1 : 0,
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: AppBackground(
          child: SafeArea(
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (BuildContext context, AuthState state) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.large,
                    AppSpacing.medium,
                    AppSpacing.large,
                    AppSpacing.large + keyboardInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _AuthTopBar(canPop: Navigator.of(context).canPop()),
                      const SizedBox(height: AppSpacing.small),
                      const _AuthHeroHeader(),
                      const SizedBox(height: AppSpacing.medium),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.medium),
                          child: Column(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: TabBar(
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  indicator: BoxDecoration(
                                    color: AppColors.primaryRed,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  labelColor: Colors.white,
                                  unselectedLabelColor: AppColors.textSecondary,
                                  tabs: const <Widget>[
                                    Tab(text: 'Login'),
                                    Tab(text: 'Registrasi'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              SizedBox(
                                height: 430,
                                child: TabBarView(
                                  children: <Widget>[
                                    _AuthFormLayout(
                                      title: 'Masuk ke akun pasien',
                                      subtitle:
                                          'Gunakan email dan password untuk membuka layanan personal Anda.',
                                      buttonLabel: 'Masuk',
                                      footerText:
                                          'Guest mode tetap bisa melihat informasi rumah sakit tanpa login.',
                                      isLoading: state.isSubmitting,
                                      children: <Widget>[
                                        TextField(
                                          controller: _loginEmailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                            hintText: 'nama@email.com',
                                            prefixIcon: Icon(
                                              Icons.mail_outline_rounded,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppSpacing.medium,
                                        ),
                                        TextField(
                                          controller: _loginPasswordController,
                                          obscureText: true,
                                          textInputAction: TextInputAction.done,
                                          decoration: const InputDecoration(
                                            labelText: 'Password',
                                            hintText:
                                                'Masukkan password akun pasien',
                                            prefixIcon: Icon(
                                              Icons.lock_outline_rounded,
                                            ),
                                          ),
                                        ),
                                      ],
                                      onSubmit: () async {
                                        final String email =
                                            _loginEmailController.text.trim();
                                        final String password =
                                            _loginPasswordController.text
                                                .trim();

                                        if (email.isEmpty || password.isEmpty) {
                                          showAppSnackBar(
                                            context,
                                            'Email dan password wajib diisi.',
                                          );
                                          return;
                                        }

                                        final bool isSuccess = await authCubit
                                            .signIn(
                                              email: email,
                                              password: password,
                                            );

                                        if (!context.mounted) {
                                          return;
                                        }

                                        if (isSuccess) {
                                          if (Navigator.of(context).canPop()) {
                                            Navigator.of(context).pop();
                                          }
                                        } else {
                                          showAppSnackBar(
                                            context,
                                            'Login belum berhasil. Silakan coba lagi.',
                                          );
                                        }
                                      },
                                    ),
                                    _AuthFormLayout(
                                      title: 'Buat akun pasien baru',
                                      subtitle:
                                          'Isi data dasar terlebih dahulu. Tampilan dibuat lebih ringkas agar cepat diisi.',
                                      buttonLabel: 'Daftar Sekarang',
                                      footerText:
                                          'Setelah registrasi, Anda bisa mulai booking, konsultasi, dan melihat data personal.',
                                      isLoading: state.isSubmitting,
                                      children: <Widget>[
                                        TextField(
                                          controller: _registerNameController,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            labelText: 'Nama lengkap',
                                            hintText:
                                                'Masukkan nama sesuai identitas',
                                            prefixIcon: Icon(
                                              Icons.person_outline_rounded,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppSpacing.medium,
                                        ),
                                        TextField(
                                          controller: _registerEmailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                            hintText: 'nama@email.com',
                                            prefixIcon: Icon(
                                              Icons.mail_outline_rounded,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppSpacing.medium,
                                        ),
                                        TextField(
                                          controller: _registerPhoneController,
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            labelText: 'Nomor telepon',
                                            hintText: '08xxxxxxxxxx',
                                            prefixIcon: Icon(
                                              Icons.phone_outlined,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppSpacing.medium,
                                        ),
                                        TextField(
                                          controller:
                                              _registerPasswordController,
                                          obscureText: true,
                                          textInputAction: TextInputAction.done,
                                          decoration: const InputDecoration(
                                            labelText: 'Password',
                                            hintText:
                                                'Minimal mudah Anda ingat',
                                            prefixIcon: Icon(
                                              Icons.lock_outline_rounded,
                                            ),
                                          ),
                                        ),
                                      ],
                                      onSubmit: () async {
                                        final String fullName =
                                            _registerNameController.text.trim();
                                        final String email =
                                            _registerEmailController.text
                                                .trim();
                                        final String phone =
                                            _registerPhoneController.text
                                                .trim();
                                        final String password =
                                            _registerPasswordController.text
                                                .trim();

                                        if (fullName.isEmpty ||
                                            email.isEmpty ||
                                            phone.isEmpty ||
                                            password.isEmpty) {
                                          showAppSnackBar(
                                            context,
                                            'Semua kolom registrasi wajib diisi.',
                                          );
                                          return;
                                        }

                                        final bool isSuccess = await authCubit
                                            .register(
                                              fullName: fullName,
                                              email: email,
                                              phoneNumber: phone,
                                              password: password,
                                            );

                                        if (!context.mounted) {
                                          return;
                                        }

                                        if (isSuccess) {
                                          if (Navigator.of(context).canPop()) {
                                            Navigator.of(context).pop();
                                          }
                                        } else {
                                          showAppSnackBar(
                                            context,
                                            'Registrasi belum berhasil. Silakan coba lagi.',
                                          );
                                        }
                                      },
                                    ),
                                  ],
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
        ),
      ),
    );
  }
}

class _AuthTopBar extends StatelessWidget {
  const _AuthTopBar({required this.canPop});

  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (canPop)
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          )
        else
          const SizedBox(width: 48),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Akun Pasien',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                AppBranding.appName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthHeroHeader extends StatelessWidget {
  const _AuthHeroHeader();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Image.asset(AppAssets.hospitalPhoto3, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      AppColors.textPrimary.withValues(alpha: 0.82),
                      AppColors.primaryRed.withValues(alpha: 0.74),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const BrandLogo(size: 64, borderRadius: 18),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppBranding.appName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppBranding.hospitalLongName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          AppBranding.tagline,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthFormLayout extends StatelessWidget {
  const _AuthFormLayout({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.children,
    required this.onSubmit,
    required this.isLoading,
    required this.footerText,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final List<Widget> children;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String footerText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.large),
        ...children,
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            footerText,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(buttonLabel),
          ),
        ),
      ],
    );
  }
}
