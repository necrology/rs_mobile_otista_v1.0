import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../domain/entities/employee_record.dart';
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
    _searchController = TextEditingController(text: 'dokter');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RsApiCubit>().searchEmployees(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokter & Pegawai')),
      body: AppBackground(
        child: BlocBuilder<RsApiCubit, RsApiState>(
          builder: (BuildContext context, RsApiState state) {
            final List<EmployeeRecord> employees =
                state.employees?.items ?? <EmployeeRecord>[];

            return RefreshIndicator(
              onRefresh: () => context.read<RsApiCubit>().searchEmployees(
                _searchController.text,
              ),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.small,
                  AppSpacing.large,
                  110,
                ),
                children: <Widget>[
                  _EmployeeHeader(
                    itemCount: employees.length,
                    isLoading: state.isLoadingEmployees,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      child: _SearchBar(
                        controller: _searchController,
                        isLoading: state.isLoadingEmployees,
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
                                Icons.medical_services_outlined,
                                size: 18,
                                color: AppColors.primaryBlue,
                              ),
                              const SizedBox(width: AppSpacing.xSmall),
                              Expanded(
                                child: Text(
                                  'Daftar Dokter & Pegawai',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.small),
                          if (state.isLoadingEmployees && employees.isEmpty)
                            const _LoadingBlock()
                          else if (employees.isEmpty)
                            const _EmptyText('Tidak ada data yang cocok.')
                          else
                            ...employees.map(
                              (EmployeeRecord employee) =>
                                  _EmployeeRecordTile(employee: employee),
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
}

class _EmployeeHeader extends StatelessWidget {
  const _EmployeeHeader({required this.itemCount, required this.isLoading});

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
                  Icons.local_hospital_outlined,
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
            'Direktori Dokter dan Pegawai',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            'Cari tenaga medis berdasarkan nama atau jabatan untuk melihat informasi layanan.',
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
              '$itemCount data tampil',
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
  const _SearchBar({required this.controller, required this.isLoading});

  final TextEditingController controller;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 330;
        final Widget field = TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(context),
          decoration: const InputDecoration(
            labelText: 'Nama atau jabatan',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        );
        final Widget button = FilledButton(
          onPressed: isLoading ? null : () => _search(context),
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

  void _search(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<RsApiCubit>().searchEmployees(controller.text);
  }
}

class _EmployeeRecordTile extends StatelessWidget {
  const _EmployeeRecordTile({required this.employee});

  final EmployeeRecord employee;

  @override
  Widget build(BuildContext context) {
    final String subtitle = employee.jabatan == '-'
        ? employee.unit
        : employee.jabatan;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ApiRecordDetailPage(
                appBarTitle: 'Detail Dokter & Pegawai',
                title: employee.nama,
                subtitle: subtitle,
                icon: Icons.medical_services_outlined,
                accentColor: AppColors.primaryBlue,
                fields: employee.displayFields,
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
                      employee.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
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
