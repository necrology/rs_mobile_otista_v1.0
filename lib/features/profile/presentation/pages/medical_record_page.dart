import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format_utils.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class MedicalRecordPage extends StatefulWidget {
  const MedicalRecordPage({super.key});

  @override
  State<MedicalRecordPage> createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage> {
  final TextEditingController _noRmController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _otpSent = false;

  @override
  void dispose() {
    _noRmController.dispose();
    _nikController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('No. Rekam Medis')),
      body: AppBackground(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState state) {
            if (!state.isAuthenticated) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.large),
                  child: Text('Login diperlukan untuk mengubah No. RM.'),
                ),
              );
            }

            final String currentNoRm =
                state.identity?.medicalRecordNumber.trim() ?? '';

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.small,
                AppSpacing.large,
                AppSpacing.xLarge,
              ),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.assignment_ind_outlined),
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                currentNoRm.isEmpty
                                    ? 'Belum terhubung'
                                    : 'No. RM $currentNoRm',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Verifikasi dikirim ke email akun terdaftar.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
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
                          'Klaim / Ubah No. RM',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.large),
                        TextField(
                          controller: _noRmController,
                          enabled: !_otpSent,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'No. RM',
                            hintText: 'Contoh RM000001',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        TextField(
                          controller: _nikController,
                          enabled: !_otpSent,
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'NIK',
                            hintText: '16 digit NIK',
                            prefixIcon: Icon(Icons.credit_card_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        TextField(
                          controller: _birthDateController,
                          enabled: !_otpSent,
                          readOnly: true,
                          textInputAction: TextInputAction.next,
                          onTap: _pickBirthDate,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal lahir',
                            hintText: '28-02-2010',
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        TextField(
                          controller: _passwordController,
                          enabled: !_otpSent,
                          obscureText: true,
                          textInputAction: _otpSent
                              ? TextInputAction.next
                              : TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Password akun',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        if (_otpSent) ...<Widget>[
                          const SizedBox(height: AppSpacing.medium),
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'OTP Email',
                              hintText: '6 digit dari email',
                              prefixIcon: Icon(Icons.mark_email_read_outlined),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.large),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: state.isSubmitting ? null : _submit,
                            icon: state.isSubmitting
                                ? const AppLoadingIndicator(size: 18)
                                : Icon(
                                    _otpSent
                                        ? Icons.verified_user_outlined
                                        : Icons.mail_outline_rounded,
                                  ),
                            label: Text(
                              _otpSent
                                  ? 'Verifikasi No. RM'
                                  : 'Kirim OTP Email',
                            ),
                          ),
                        ),
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

  Future<void> _pickBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selected == null || !mounted) {
      return;
    }

    _birthDateController.text = DateFormatUtils.formatDateTime(selected);
  }

  Future<void> _submit() async {
    final AuthCubit authCubit = context.read<AuthCubit>();
    final String noRm = _noRmController.text.trim();
    final String nik = _nikController.text.trim();
    final String birthDate = _birthDateController.text.trim();
    final String password = _passwordController.text.trim();
    final String otp = _otpController.text.trim();

    if (noRm.isEmpty || nik.isEmpty || birthDate.isEmpty || password.isEmpty) {
      showAppSnackBar(
        context,
        'No. RM, NIK, tanggal lahir, dan password wajib diisi.',
      );
      return;
    }

    if (nik.length != 16) {
      showAppSnackBar(context, 'NIK harus 16 digit.');
      return;
    }

    if (_otpSent && otp.isEmpty) {
      showAppSnackBar(context, 'OTP email wajib diisi.');
      return;
    }

    final bool isSuccess = _otpSent
        ? await authCubit.confirmMedicalRecordClaim(otp: otp)
        : await authCubit.requestMedicalRecordClaim(
            password: password,
            noRm: noRm,
            nik: nik,
            birthDate: birthDate,
          );

    if (!mounted) {
      return;
    }

    if (!isSuccess) {
      showAppSnackBar(
        context,
        authCubit.state.errorMessage ?? 'Verifikasi No. RM belum berhasil.',
      );
      return;
    }

    if (!_otpSent) {
      setState(() {
        _otpSent = true;
        _otpController.clear();
      });
      showAppSnackBar(context, 'OTP verifikasi No. RM sudah dikirim ke email.');
      return;
    }

    showAppSnackBar(context, 'No. RM berhasil terhubung.');
    Navigator.of(context).pop();
  }
}








