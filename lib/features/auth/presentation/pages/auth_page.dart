import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_branding.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../domain/entities/registration_request_result.dart';
import '../cubit/auth_cubit.dart';

enum _ExistingAccountAction { login, forgotPassword }

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
  final TextEditingController _loginOtpController = TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPhoneController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerOtpController = TextEditingController();
  final TextEditingController _forgotIdentifierController =
      TextEditingController();
  final TextEditingController _forgotOtpController = TextEditingController();
  final TextEditingController _forgotPasswordController =
      TextEditingController();

  bool _loginOtpSent = false;
  bool _registerOtpSent = false;
  bool _resetOtpSent = false;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _loginOtpController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    _registerOtpController.dispose();
    _forgotIdentifierController.dispose();
    _forgotOtpController.dispose();
    _forgotPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthCubit authCubit = context.read<AuthCubit>();
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return DefaultTabController(
      initialIndex: widget.startWithRegister ? 1 : 0,
      length: 3,
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
                                    gradient: AppColors.brandGradient,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  labelColor: Colors.white,
                                  unselectedLabelColor: AppColors.textSecondary,
                                  tabs: const <Widget>[
                                    Tab(text: 'Login'),
                                    Tab(text: 'Registrasi'),
                                    Tab(text: 'Lupa'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              SizedBox(
                                height: 560,
                                child: TabBarView(
                                  children: <Widget>[
                                    _AuthFormLayout(
                                      title: 'Masuk ke akun pasien',
                                      subtitle:
                                          'Gunakan email akun atau No. RM yang sudah terhubung. OTP dikirim ke email terdaftar.',
                                      buttonLabel: _loginOtpSent
                                          ? 'Verifikasi OTP'
                                          : 'Kirim OTP Login',
                                      footerText:
                                          'Kode OTP berlaku 5 menit dan menjaga akun pasien tetap aman.',
                                      isLoading: state.isSubmitting,
                                      children: <Widget>[
                                        TextField(
                                          controller: _loginEmailController,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            labelText: 'Email atau No. RM',
                                            hintText: 'nama@email.com / 074502',
                                            prefixIcon: Icon(
                                              Icons.badge_outlined,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppSpacing.medium,
                                        ),
                                        TextField(
                                          controller: _loginPasswordController,
                                          obscureText: true,
                                          textInputAction: _loginOtpSent
                                              ? TextInputAction.next
                                              : TextInputAction.done,
                                          decoration: const InputDecoration(
                                            labelText: 'Password',
                                            hintText:
                                                'Masukkan password akun pasien',
                                            prefixIcon: Icon(
                                              Icons.lock_outline_rounded,
                                            ),
                                          ),
                                        ),
                                        if (_loginOtpSent) ...<Widget>[
                                          const SizedBox(
                                            height: AppSpacing.medium,
                                          ),
                                          TextField(
                                            controller: _loginOtpController,
                                            keyboardType: TextInputType.number,
                                            textInputAction:
                                                TextInputAction.done,
                                            decoration: const InputDecoration(
                                              labelText: 'Kode OTP',
                                              hintText: '6 digit dari email',
                                              prefixIcon: Icon(
                                                Icons.verified_user_outlined,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                      onSubmit: () async {
                                        final String identifier =
                                            _loginEmailController.text.trim();
                                        final String password =
                                            _loginPasswordController.text
                                                .trim();

                                        if (identifier.isEmpty ||
                                            password.isEmpty) {
                                          showAppSnackBar(
                                            context,
                                            'Email/No. RM dan password wajib diisi.',
                                          );
                                          return;
                                        }

                                        final bool isSuccess = _loginOtpSent
                                            ? await authCubit.verifyLoginOtp(
                                                identifier: identifier,
                                                otp: _loginOtpController.text
                                                    .trim(),
                                              )
                                            : await authCubit.requestLoginOtp(
                                                identifier: identifier,
                                                password: password,
                                              );

                                        if (!context.mounted) {
                                          return;
                                        }

                                        if (isSuccess) {
                                          if (!_loginOtpSent) {
                                            setState(() {
                                              _loginOtpSent = true;
                                            });
                                            showAppSnackBar(
                                              context,
                                              'Permintaan OTP login diterima. Periksa Inbox atau Spam email Anda.',
                                            );
                                          } else if (Navigator.of(
                                            context,
                                          ).canPop()) {
                                            Navigator.of(context).pop();
                                          }
                                        } else {
                                          showAppSnackBar(
                                            context,
                                            authCubit.state.errorMessage ??
                                                'Login belum berhasil. Silakan coba lagi.',
                                          );
                                        }
                                      },
                                    ),
                                    _AuthFormLayout(
                                      title: 'Buat akun pasien baru',
                                      subtitle:
                                          'Gunakan email aktif. Jika sudah memiliki akun, lanjutkan melalui Login atau Lupa Password.',
                                      buttonLabel: _registerOtpSent
                                          ? 'Verifikasi OTP'
                                          : 'Minta OTP Registrasi',
                                      footerText:
                                          'Permintaan dibuat secara aman tanpa mengungkap status akun. Periksa Inbox/Spam jika email belum pernah terdaftar.',
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
                                          textInputAction: _registerOtpSent
                                              ? TextInputAction.next
                                              : TextInputAction.done,
                                          decoration: const InputDecoration(
                                            labelText: 'Password',
                                            hintText:
                                                '8–72 karakter, huruf dan angka',
                                            prefixIcon: Icon(
                                              Icons.lock_outline_rounded,
                                            ),
                                          ),
                                        ),
                                        if (_registerOtpSent) ...<Widget>[
                                          const SizedBox(
                                            height: AppSpacing.medium,
                                          ),
                                          TextField(
                                            controller: _registerOtpController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'OTP Email',
                                              hintText:
                                                  'Kode dari email rumah sakit',
                                              prefixIcon: Icon(
                                                Icons.mark_email_read_outlined,
                                              ),
                                            ),
                                          ),
                                        ],
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

                                        if (!_isValidNewPassword(password)) {
                                          showAppSnackBar(
                                            context,
                                            'Password harus 8–72 karakter dan mengandung huruf serta angka.',
                                          );
                                          return;
                                        }

                                        final String registrationOtp =
                                            _registerOtpController.text.trim();
                                        if (_registerOtpSent &&
                                            !_isValidOtp(registrationOtp)) {
                                          showAppSnackBar(
                                            context,
                                            'OTP harus terdiri dari 6 digit angka.',
                                          );
                                          return;
                                        }

                                        if (!_registerOtpSent) {
                                          final RegistrationRequestResult?
                                          result = await authCubit.register(
                                            fullName: fullName,
                                            email: email,
                                            phoneNumber: phone,
                                          );

                                          if (!context.mounted) {
                                            return;
                                          }

                                          if (result ==
                                              RegistrationRequestResult
                                                  .otpSent) {
                                            setState(() {
                                              _registerOtpSent = true;
                                            });
                                            showAppSnackBar(
                                              context,
                                              'Permintaan OTP registrasi diterima. Periksa Inbox atau Spam email Anda.',
                                            );
                                          } else if (result ==
                                              RegistrationRequestResult
                                                  .accountAlreadyRegistered) {
                                            await _showExistingAccountDialog(
                                              context,
                                              email,
                                            );
                                          } else {
                                            showAppSnackBar(
                                              context,
                                              authCubit.state.errorMessage ??
                                                  'Registrasi belum berhasil. Silakan coba lagi.',
                                            );
                                          }
                                          return;
                                        }

                                        final bool isSuccess = await authCubit
                                            .verifyRegistrationOtp(
                                              email: email,
                                              otp: registrationOtp,
                                              password: password,
                                            );

                                        if (!context.mounted) {
                                          return;
                                        }

                                        if (isSuccess &&
                                            Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        } else if (!isSuccess) {
                                          showAppSnackBar(
                                            context,
                                            authCubit.state.errorMessage ??
                                                'Registrasi belum berhasil. Silakan coba lagi.',
                                          );
                                        }
                                      },
                                    ),
                                    _AuthFormLayout(
                                      title: 'Atur ulang password',
                                      subtitle:
                                          'Masukkan email akun. OTP reset akan dikirim ke email terdaftar.',
                                      buttonLabel: _resetOtpSent
                                          ? 'Simpan Password Baru'
                                          : 'Kirim OTP Reset',
                                      footerText:
                                          'Gunakan password baru setelah OTP berhasil diverifikasi.',
                                      isLoading: state.isSubmitting,
                                      children: <Widget>[
                                        TextField(
                                          controller:
                                              _forgotIdentifierController,
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
                                        if (_resetOtpSent) ...<Widget>[
                                          const SizedBox(
                                            height: AppSpacing.medium,
                                          ),
                                          TextField(
                                            controller: _forgotOtpController,
                                            keyboardType: TextInputType.number,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: const InputDecoration(
                                              labelText: 'OTP Reset',
                                              hintText: '6 digit dari email',
                                              prefixIcon: Icon(
                                                Icons.password_outlined,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.medium,
                                          ),
                                          TextField(
                                            controller:
                                                _forgotPasswordController,
                                            obscureText: true,
                                            textInputAction:
                                                TextInputAction.done,
                                            decoration: const InputDecoration(
                                              labelText: 'Password baru',
                                              prefixIcon: Icon(
                                                Icons.lock_reset_rounded,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                      onSubmit: () async {
                                        final String identifier =
                                            _forgotIdentifierController.text
                                                .trim();
                                        if (identifier.isEmpty) {
                                          showAppSnackBar(
                                            context,
                                            'Email wajib diisi.',
                                          );
                                          return;
                                        }

                                        if (_resetOtpSent &&
                                            (_forgotOtpController.text
                                                    .trim()
                                                    .isEmpty ||
                                                _forgotPasswordController.text
                                                    .trim()
                                                    .isEmpty)) {
                                          showAppSnackBar(
                                            context,
                                            'OTP dan password baru wajib diisi.',
                                          );
                                          return;
                                        }

                                        final String newPassword =
                                            _forgotPasswordController.text
                                                .trim();
                                        if (_resetOtpSent &&
                                            !_isValidNewPassword(newPassword)) {
                                          showAppSnackBar(
                                            context,
                                            'Password harus 8–72 karakter dan mengandung huruf serta angka.',
                                          );
                                          return;
                                        }

                                        final bool isSuccess = _resetOtpSent
                                            ? await authCubit.resetPassword(
                                                identifier: identifier,
                                                otp: _forgotOtpController.text
                                                    .trim(),
                                                password: newPassword,
                                              )
                                            : await authCubit
                                                  .requestPasswordResetOtp(
                                                    identifier: identifier,
                                                  );

                                        if (!context.mounted) {
                                          return;
                                        }

                                        if (isSuccess && !_resetOtpSent) {
                                          setState(() {
                                            _resetOtpSent = true;
                                            _forgotOtpController.clear();
                                            _forgotPasswordController.clear();
                                          });
                                          showAppSnackBar(
                                            context,
                                            'Permintaan OTP reset diterima. Jika email terdaftar, OTP akan dikirim. Periksa Inbox atau Spam.',
                                          );
                                        } else if (isSuccess) {
                                          setState(() {
                                            _resetOtpSent = false;
                                            _forgotIdentifierController.clear();
                                            _forgotOtpController.clear();
                                            _forgotPasswordController.clear();
                                          });
                                          DefaultTabController.of(
                                            context,
                                          ).animateTo(0);
                                          showAppSnackBar(
                                            context,
                                            'Password berhasil diperbarui. Silakan login.',
                                          );
                                        } else {
                                          showAppSnackBar(
                                            context,
                                            authCubit.state.errorMessage ??
                                                'Reset password belum berhasil. Silakan coba lagi.',
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

  bool _isValidNewPassword(String password) {
    return password.length >= 8 &&
        password.length <= 72 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  bool _isValidOtp(String otp) => RegExp(r'^\d{6}$').hasMatch(otp);

  Future<void> _showExistingAccountDialog(
    BuildContext pageContext,
    String email,
  ) async {
    FocusScope.of(pageContext).unfocus();
    final _ExistingAccountAction?
    action = await showDialog<_ExistingAccountAction>(
      context: pageContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Akun sudah terdaftar'),
          content: Text(
            'Email $email sudah memiliki akun. Anda ingin login atau mengatur ulang password?',
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('existing-account-cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              key: const Key('existing-account-login'),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ExistingAccountAction.login),
              child: const Text('Login'),
            ),
            FilledButton(
              key: const Key('existing-account-forgot-password'),
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_ExistingAccountAction.forgotPassword),
              child: const Text('Lupa Password'),
            ),
          ],
        );
      },
    );

    if (!mounted || !pageContext.mounted || action == null) {
      return;
    }

    setState(() {
      _registerOtpSent = false;
      _registerOtpController.clear();
      _registerPasswordController.clear();

      switch (action) {
        case _ExistingAccountAction.login:
          _loginEmailController.text = email;
          _loginPasswordController.clear();
          _loginOtpController.clear();
          _loginOtpSent = false;
          break;
        case _ExistingAccountAction.forgotPassword:
          _forgotIdentifierController.text = email;
          _forgotOtpController.clear();
          _forgotPasswordController.clear();
          _resetOtpSent = false;
          break;
      }
    });

    DefaultTabController.of(
      pageContext,
    ).animateTo(action == _ExistingAccountAction.login ? 0 : 2);
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
                      AppColors.primaryTeal.withValues(alpha: 0.84),
                      AppColors.deepTeal.withValues(alpha: 0.82),
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
                  const PartnerLogos(height: 50),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Masuk/Daftar Akun',
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.large),
          ...children,
          const SizedBox(height: AppSpacing.large),
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
      ),
    );
  }
}
