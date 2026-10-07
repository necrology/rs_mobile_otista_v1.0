import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hapus Akun')),
      body: AppBackground(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState authState) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.medium,
                AppSpacing.large,
                40,
              ),
              children: <Widget>[
                Card(
                  color: AppColors.danger.withValues(alpha: 0.07),
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.large),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.danger,
                            ),
                            SizedBox(width: AppSpacing.small),
                            Expanded(
                              child: Text(
                                'Penghapusan akun bersifat permanen',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.medium),
                        Text(
                          'Identitas akun, hubungan akun dengan No. RM, kredensial, OTP, dan seluruh sesi login akan dihapus atau dianonimkan.',
                        ),
                        SizedBox(height: AppSpacing.small),
                        Text(
                          'Rekam medis, hasil pemeriksaan, resep, pendaftaran, antrean, dan catatan pelayanan rumah sakit tidak ikut dihapus karena dikelola sebagai dokumen pelayanan kesehatan.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _otpSent
                              ? 'Konfirmasi OTP Penghapusan'
                              : 'Verifikasi Password',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          _otpSent
                              ? 'Masukkan OTP enam digit yang dikirim ke email akun. OTP berlaku selama lima menit.'
                              : 'Masukkan password akun untuk meminta OTP penghapusan.',
                        ),
                        const SizedBox(height: AppSpacing.large),
                        if (!_otpSent)
                          TextField(
                            key: const Key('account-deletion-password'),
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            enabled: !authState.isSubmitting,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Password akun',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                tooltip: _showPassword
                                    ? 'Sembunyikan password'
                                    : 'Tampilkan password',
                                onPressed: () => setState(() {
                                  _showPassword = !_showPassword;
                                }),
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            onSubmitted: (_) => _requestOtp(),
                          )
                        else
                          TextField(
                            key: const Key('account-deletion-otp'),
                            controller: _otpController,
                            enabled: !authState.isSubmitting,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'OTP Email',
                              hintText: '6 digit',
                              prefixIcon: Icon(Icons.mark_email_read_outlined),
                            ),
                            onSubmitted: (_) => _confirmDeletion(),
                          ),
                        const SizedBox(height: AppSpacing.large),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            key: Key(
                              _otpSent
                                  ? 'confirm-account-deletion'
                                  : 'request-account-deletion-otp',
                            ),
                            onPressed: authState.isSubmitting
                                ? null
                                : _otpSent
                                ? _confirmDeletion
                                : _requestOtp,
                            style: FilledButton.styleFrom(
                              backgroundColor: _otpSent
                                  ? AppColors.danger
                                  : null,
                            ),
                            icon: authState.isSubmitting
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _otpSent
                                        ? Icons.delete_forever_rounded
                                        : Icons.mail_outline_rounded,
                                  ),
                            label: Text(
                              _otpSent
                                  ? 'Hapus Akun Permanen'
                                  : 'Kirim OTP Penghapusan',
                            ),
                          ),
                        ),
                        if (_otpSent) ...<Widget>[
                          const SizedBox(height: AppSpacing.small),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: authState.isSubmitting
                                  ? null
                                  : () {
                                      setState(() {
                                        _otpSent = false;
                                        _otpController.clear();
                                      });
                                    },
                              child: const Text('Gunakan password kembali'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _requestOtp() async {
    final String password = _passwordController.text;
    if (password.isEmpty) {
      showAppSnackBar(context, 'Password akun wajib diisi.');
      return;
    }

    final AuthCubit authCubit = context.read<AuthCubit>();
    final bool success = await authCubit.requestAccountDeletion(
      password: password,
    );
    if (!mounted) {
      return;
    }
    if (!success) {
      showAppSnackBar(
        context,
        authCubit.state.errorMessage ?? 'Permintaan penghapusan akun gagal.',
      );
      return;
    }

    _passwordController.clear();
    setState(() => _otpSent = true);
    showAppSnackBar(context, 'OTP penghapusan dikirim ke email akun.');
  }

  Future<void> _confirmDeletion() async {
    final String otp = _otpController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      showAppSnackBar(context, 'OTP harus terdiri dari 6 digit angka.');
      return;
    }

    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Hapus akun permanen?'),
              content: const Text(
                'Akun tidak dapat dipulihkan setelah dihapus. Rekam medis rumah sakit tetap disimpan sesuai ketentuan pelayanan kesehatan.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Ya, Hapus Akun'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed || !mounted) {
      return;
    }

    final AuthCubit authCubit = context.read<AuthCubit>();
    final bool success = await authCubit.confirmAccountDeletion(otp: otp);
    if (!mounted) {
      return;
    }
    if (!success) {
      showAppSnackBar(
        context,
        authCubit.state.errorMessage ?? 'Penghapusan akun gagal.',
      );
      return;
    }

    Navigator.of(context).pop(true);
  }
}
