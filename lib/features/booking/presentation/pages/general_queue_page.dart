import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format_utils.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../api_data/domain/entities/resource_record.dart';
import '../../../api_data/presentation/cubit/rs_api_cubit.dart';
import '../../../auth/domain/entities/patient_identity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../profile/presentation/pages/medical_record_page.dart';
import '../../domain/entities/booking_calendar.dart';
import '../../domain/entities/booking_options.dart';
import '../../domain/entities/booking_queue_response.dart';
import '../../domain/entities/queue_records.dart';

class GeneralQueuePage extends StatefulWidget {
  const GeneralQueuePage({super.key, this.initialTabIndex = 1});

  final int initialTabIndex;

  @override
  State<GeneralQueuePage> createState() => _GeneralQueuePageState();
}

class _GeneralQueuePageState extends State<GeneralQueuePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: _normalizedInitialTabIndex,
  );
  late DateTime _selectedDate = DateTime.now();

  String _selectedPoliId = '';
  String _selectedDoctorId = '';
  int get _normalizedInitialTabIndex {
    if (widget.initialTabIndex < 0) {
      return 0;
    }
    if (widget.initialTabIndex > 1) {
      return 1;
    }
    return widget.initialTabIndex;
  }

  String get _selectedDateValue {
    final String month = _selectedDate.month.toString().padLeft(2, '0');
    final String day = _selectedDate.day.toString().padLeft(2, '0');
    return '${_selectedDate.year}-$month-$day';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) {
      return;
    }

    final RsApiCubit cubit = context.read<RsApiCubit>();
    final PatientIdentity? identity = context.read<AuthCubit>().state.identity;
    final List<Future<void>> requests = <Future<void>>[
      cubit.searchPolyclinics(''),
    ];

    if (identity != null && identity.medicalRecordNumber.trim().isNotEmpty) {
      requests.add(cubit.fetchMyGeneralBookings(allDates: true));
    }

    await Future.wait(requests);
  }

  Future<void> _loadBookingOptions(String poliId) async {
    final int parsedPoliId = int.tryParse(poliId) ?? 0;
    if (parsedPoliId <= 0 || !mounted) {
      return;
    }

    await context.read<RsApiCubit>().fetchBookingOptions(poliId: parsedPoliId);
  }

  Future<BookingCalendarResponse?> _loadBookingCalendar({
    DateTime? month,
  }) async {
    if (!mounted) {
      return null;
    }

    final DateTime targetMonth = month ?? _selectedDate;
    final int parsedPoliId = int.tryParse(_selectedPoliId) ?? 0;

    return context.read<RsApiCubit>().fetchBookingCalendar(
      year: targetMonth.year,
      month: targetMonth.month,
      poliId: parsedPoliId > 0 ? parsedPoliId : null,
    );
  }

  Future<void> _pickDate({bool allowClosedDates = false}) async {
    final DateTime initialDate = _dateOnly(_selectedDate);
    final BookingCalendarResponse? initialCalendar = await _loadBookingCalendar(
      month: initialDate,
    );
    if (!mounted) {
      return;
    }

    final DateTime? selected = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (BuildContext sheetContext) {
        return _BookingCalendarSheet(
          initialDate: initialDate,
          initialCalendar: initialCalendar,
          allowClosedDates: allowClosedDates,
          loadCalendar: _loadBookingCalendar,
        );
      },
    );
    if (selected == null || !mounted) {
      return;
    }

    setState(() => _selectedDate = _dateOnly(selected));
    await _loadData();
  }

  Future<void> _submitBooking(
    List<ResourceRecord> polyclinics,
    BookingOptionsResponse? bookingOptions,
  ) async {
    final PatientIdentity? identity = context.read<AuthCubit>().state.identity;
    final String noRm = identity?.medicalRecordNumber.trim() ?? '';
    final int poliId = int.tryParse(_selectedPoliId) ?? 0;

    if (identity == null || noRm.isEmpty) {
      showAppSnackBar(
        context,
        'Antrian umum hanya bisa dibuat setelah No. RM terhubung.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    if (poliId <= 0) {
      showAppSnackBar(
        context,
        'Pilih poli tujuan terlebih dahulu.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final List<BookingDoctorOption> doctors =
        bookingOptions?.poli.doctors ?? <BookingDoctorOption>[];
    if (doctors.isNotEmpty && _selectedDoctorId.trim().isEmpty) {
      showAppSnackBar(
        context,
        'Pilih dokter tujuan terlebih dahulu.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final BookingCalendarDay? selectedCalendarDay = _calendarDayFor(
      _selectedDate,
      context.read<RsApiCubit>().state.bookingCalendar,
    );
    if (selectedCalendarDay != null && !selectedCalendarDay.isOpen) {
      showAppSnackBar(
        context,
        'Tanggal tidak tersedia: ${selectedCalendarDay.displayReason}',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final ResourceRecord selectedPoli = polyclinics.firstWhere(
      (ResourceRecord record) => record.id == _selectedPoliId,
      orElse: () => ResourceRecord(data: <String, dynamic>{'id': poliId}),
    );

    final BookingQueueResponse? result = await context
        .read<RsApiCubit>()
        .createGeneralBooking(
          poliId: poliId,
          tanggal: _selectedDateValue,
          doctorId: _selectedDoctorId,
          queueGroup:
              bookingOptions?.poli.queueGroup ??
              selectedPoli.value(const <String>[
                'kelompok',
                'kode_ruangan',
                'nama',
              ], fallback: ''),
        );

    if (!mounted || result == null) {
      return;
    }

    final String queueNumber = result.displayQueueNumber;
    showAppSnackBar(
      context,
      result.existing
          ? 'Antrian sudah ada: $queueNumber'
          : 'Antrian berhasil dibuat: $queueNumber',
      backgroundColor: AppColors.primaryGreen,
    );

    await _loadData();
    if (mounted) {
      _tabController.animateTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Antrian Umum')),
      body: AppBackground(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState authState) {
            final PatientIdentity? identity = authState.identity;
            final String noRm =
                identity?.medicalRecordNumber.trim().toUpperCase() ?? '';

            return BlocBuilder<RsApiCubit, RsApiState>(
              builder: (BuildContext context, RsApiState state) {
                final List<ResourceRecord> polyclinics =
                    state.polyclinics?.items ?? <ResourceRecord>[];
                final List<GeneralBookingRecord> myBookings =
                    state.myGeneralBookings?.items ?? <GeneralBookingRecord>[];
                final BookingOptionsResponse? bookingOptions =
                    state.bookingOptions?.poli.id == _selectedPoliId
                    ? state.bookingOptions
                    : null;
                final BookingCalendarDay? selectedCalendarDay = _calendarDayFor(
                  _selectedDate,
                  state.bookingCalendar,
                );

                if (_selectedPoliId.isEmpty &&
                    polyclinics.isNotEmpty &&
                    identity != null &&
                    noRm.isNotEmpty) {
                  _selectedPoliId = polyclinics.first.id;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _loadBookingOptions(_selectedPoliId);
                      _loadBookingCalendar();
                    }
                  });
                }

                final bool doctorStillAvailable =
                    _selectedDoctorId.isEmpty ||
                    (bookingOptions?.poli.doctors.any(
                          (BookingDoctorOption doctor) =>
                              doctor.id == _selectedDoctorId,
                        ) ??
                        false);
                if (!doctorStillAvailable) {
                  _selectedDoctorId = '';
                }

                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.large,
                        AppSpacing.small,
                        AppSpacing.large,
                        AppSpacing.small,
                      ),
                      child: Column(
                        children: <Widget>[
                          _QueueHero(
                            noRm: noRm,
                            selectedDate: _selectedDate,
                            myQueueCount: myBookings.length,
                            isLoading:
                                state.isLoadingMyGeneralBookings ||
                                state.isCreatingGeneralBooking,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          _QueueTabs(controller: _tabController),
                        ],
                      ),
                    ),
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.large,
                        ),
                        child: _ErrorCard(message: state.errorMessage!),
                      ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          _CreateQueueTab(
                            identity: identity,
                            noRm: noRm,
                            selectedDate: _selectedDate,
                            selectedPoliId: _selectedPoliId,
                            selectedDoctorId: _selectedDoctorId,
                            selectedCalendarDay: selectedCalendarDay,
                            polyclinics: polyclinics,
                            bookingOptions: bookingOptions,
                            isLoadingPolyclinics: state.isLoadingPolyclinics,
                            isLoadingBookingOptions:
                                state.isLoadingBookingOptions,
                            isLoadingBookingCalendar:
                                state.isLoadingBookingCalendar,
                            isSubmitting: state.isCreatingGeneralBooking,
                            onPickDate: () => _pickDate(),
                            onPoliChanged: (String value) {
                              setState(() {
                                _selectedPoliId = value;
                                _selectedDoctorId = '';
                              });
                              _loadBookingOptions(value);
                              _loadBookingCalendar();
                            },
                            onDoctorChanged: (String value) {
                              setState(() => _selectedDoctorId = value);
                            },
                            onSubmit: () =>
                                _submitBooking(polyclinics, bookingOptions),
                          ),
                          _BookingListTab(
                            title: 'Nomor Antrian Saya',
                            emptyMessage:
                                'Belum ada history antrian umum dari akun ini.',
                            bookings: myBookings,
                            isLoading: state.isLoadingMyGeneralBookings,
                            onRefresh: _loadData,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _QueueHero extends StatelessWidget {
  const _QueueHero({
    required this.noRm,
    required this.selectedDate,
    required this.myQueueCount,
    required this.isLoading,
  });

  final String noRm;
  final DateTime selectedDate;
  final int myQueueCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.confirmation_number,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const _LightLoadingDot()
              else
                const Icon(Icons.local_hospital_outlined, color: Colors.white),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Pendaftaran Antrian Umum',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            'Buat nomor antrian untuk pasien yang sudah punya No. RM, lalu pantau daftar booking hari ini.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: <Widget>[
              _HeaderPill(label: 'No. RM', value: noRm.isEmpty ? '-' : noRm),
              _HeaderPill(
                label: 'Tanggal',
                value: DateFormatUtils.formatDateTime(selectedDate),
              ),
              _HeaderPill(label: 'Saya', value: '$myQueueCount'),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueTabs extends StatelessWidget {
  const _QueueTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return Row(
            children: <Widget>[
              _QueueTabButton(
                icon: Icons.add_circle_outline,
                label: 'Buat',
                selected: controller.index == 0,
                onTap: () => controller.animateTo(0),
              ),
              _QueueTabButton(
                icon: Icons.confirmation_number_outlined,
                label: 'Saya',
                selected: controller.index == 1,
                onTap: () => controller.animateTo(1),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LightLoadingDot extends StatelessWidget {
  const _LightLoadingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: const CircularProgressIndicator(
        strokeWidth: 2.4,
        strokeCap: StrokeCap.round,
        color: Colors.white,
      ),
    );
  }
}

class _QueueTabButton extends StatelessWidget {
  const _QueueTabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? AppColors.primaryTeal
        : AppColors.textSecondary;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: AppColors.deepTeal.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateQueueTab extends StatelessWidget {
  const _CreateQueueTab({
    required this.identity,
    required this.noRm,
    required this.selectedDate,
    required this.selectedPoliId,
    required this.selectedDoctorId,
    required this.selectedCalendarDay,
    required this.polyclinics,
    required this.bookingOptions,
    required this.isLoadingPolyclinics,
    required this.isLoadingBookingOptions,
    required this.isLoadingBookingCalendar,
    required this.isSubmitting,
    required this.onPickDate,
    required this.onPoliChanged,
    required this.onDoctorChanged,
    required this.onSubmit,
  });

  final PatientIdentity? identity;
  final String noRm;
  final DateTime selectedDate;
  final String selectedPoliId;
  final String selectedDoctorId;
  final BookingCalendarDay? selectedCalendarDay;
  final List<ResourceRecord> polyclinics;
  final BookingOptionsResponse? bookingOptions;
  final bool isLoadingPolyclinics;
  final bool isLoadingBookingOptions;
  final bool isLoadingBookingCalendar;
  final bool isSubmitting;
  final VoidCallback onPickDate;
  final ValueChanged<String> onPoliChanged;
  final ValueChanged<String> onDoctorChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    if (identity == null) {
      return _AccessState(
        title: 'Login diperlukan',
        message: 'Silakan login untuk membuat antrian umum dari aplikasi.',
        buttonLabel: null,
        onPressed: null,
      );
    }

    if (noRm.isEmpty) {
      return _AccessState(
        title: 'No. RM Belum Terhubung',
        message:
            'Antrian umum hanya bisa dibuat oleh akun yang sudah terhubung ke No. Rekam Medis.',
        buttonLabel: 'Hubungkan No. RM',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const MedicalRecordPage()),
          );
        },
      );
    }

    ResourceRecord? selectedPoli;
    for (final ResourceRecord record in polyclinics) {
      if (record.id == selectedPoliId) {
        selectedPoli = record;
        break;
      }
    }
    final List<BookingDoctorOption> doctors =
        bookingOptions?.poli.doctors ?? <BookingDoctorOption>[];
    final bool isDateClosed =
        selectedCalendarDay != null && !selectedCalendarDay!.isOpen;
    final bool isActionDisabled =
        isSubmitting ||
        isLoadingBookingOptions ||
        isLoadingBookingCalendar ||
        isDateClosed;

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          AppSpacing.small,
          AppSpacing.large,
          156,
        ),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.assignment_add,
                        size: 20,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: AppSpacing.xSmall),
                      Expanded(
                        child: Text(
                          'Form Antrian Umum',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  _ReadonlyField(
                    icon: Icons.badge_outlined,
                    label: 'No. RM',
                    value: noRm,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  _DateField(
                    selectedDate: selectedDate,
                    onTap: onPickDate,
                    calendarDay: selectedCalendarDay,
                    isLoadingCalendar: isLoadingBookingCalendar,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  DropdownButtonFormField<String>(
                    initialValue:
                        polyclinics.any(
                          (ResourceRecord record) =>
                              record.id == selectedPoliId,
                        )
                        ? selectedPoliId
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Poli Tujuan',
                      prefixIcon: Icon(Icons.local_hospital_outlined),
                    ),
                    items: polyclinics
                        .map(
                          (ResourceRecord record) => DropdownMenuItem<String>(
                            value: record.id,
                            child: Text(
                              record.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: isSubmitting
                        ? null
                        : (String? value) {
                            if (value != null) {
                              onPoliChanged(value);
                            }
                          },
                  ),
                  if (isLoadingPolyclinics) ...<Widget>[
                    const SizedBox(height: AppSpacing.small),
                    const _SoftLinearLoader(),
                  ],
                  const SizedBox(height: AppSpacing.small),
                  _QueueAvailabilityPanel(
                    selectedPoli: selectedPoli,
                    bookingOptions: bookingOptions,
                    isLoading: isLoadingBookingOptions,
                  ),
                  if (doctors.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.small),
                    DropdownButtonFormField<String>(
                      initialValue:
                          doctors.any(
                            (BookingDoctorOption doctor) =>
                                doctor.id == selectedDoctorId,
                          )
                          ? selectedDoctorId
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Dokter',
                        prefixIcon: Icon(Icons.medical_services_outlined),
                      ),
                      items: doctors
                          .map(
                            (BookingDoctorOption doctor) =>
                                DropdownMenuItem<String>(
                                  value: doctor.id,
                                  child: Text(
                                    doctor.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                          )
                          .toList(),
                      onChanged: isSubmitting
                          ? null
                          : (String? value) {
                              if (value != null) {
                                onDoctorChanged(value);
                              }
                            },
                    ),
                  ] else if (isLoadingBookingOptions) ...<Widget>[
                    const SizedBox(height: AppSpacing.small),
                    const _SoftLinearLoader(),
                  ],
                  const SizedBox(height: AppSpacing.medium),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isSubmitting || isLoadingBookingOptions
                          ? null
                          : isActionDisabled
                          ? null
                          : onSubmit,
                      icon:
                          isSubmitting ||
                              isLoadingBookingOptions ||
                              isLoadingBookingCalendar
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.confirmation_number_outlined),
                      label: Text(
                        isLoadingBookingCalendar
                            ? 'Memeriksa Tanggal...'
                            : isLoadingBookingOptions
                            ? 'Memuat Jadwal...'
                            : isSubmitting
                            ? 'Membuat Antrian...'
                            : isDateClosed
                            ? 'Tanggal Tutup'
                            : 'Buat Antrian',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          const _InfoBox(
            title: 'Ketentuan',
            message:
                'Antrian ini untuk pasien umum yang sudah memiliki No. RM. Untuk BPJS, gunakan Mobile JKN agar tidak terjadi booking ganda.',
          ),
        ],
      ),
    );
  }
}

class _BookingListTab extends StatelessWidget {
  const _BookingListTab({
    required this.title,
    required this.emptyMessage,
    required this.bookings,
    required this.isLoading,
    required this.onRefresh,
  });

  final String title;
  final String emptyMessage;
  final List<GeneralBookingRecord> bookings;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          AppSpacing.small,
          AppSpacing.large,
          156,
        ),
        children: <Widget>[
          _BookingListContent(
            title: title,
            emptyMessage: emptyMessage,
            bookings: bookings,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

class _BookingListContent extends StatelessWidget {
  const _BookingListContent({
    required this.title,
    required this.emptyMessage,
    required this.bookings,
    required this.isLoading,
  });

  final String title;
  final String emptyMessage;
  final List<GeneralBookingRecord> bookings;
  final bool isLoading;

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
                const Icon(
                  Icons.format_list_bulleted,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: AppSpacing.xSmall),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isLoading) const AppLoadingIndicator(size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            if (isLoading && bookings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.large),
                child: Center(
                  child: AppLoadingIndicator(
                    message: 'Memuat nomor antrian',
                    size: 42,
                  ),
                ),
              )
            else if (bookings.isEmpty)
              _EmptyText(emptyMessage)
            else
              ...bookings.map(
                (GeneralBookingRecord booking) =>
                    _BookingCard(booking: booking),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final GeneralBookingRecord booking;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _statusColor(booking.colorRole);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.confirmation_number, color: accentColor),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        booking.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      if (booking.subtitle.trim().isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          booking.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusBadge(label: booking.status, color: accentColor),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.xSmall,
              runSpacing: AppSpacing.xSmall,
              children: booking.displayFields
                  .take(8)
                  .map(
                    (MapEntry<String, String> field) =>
                        _InfoChip(label: field.key, value: field.value),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(ColorRole role) {
    switch (role) {
      case ColorRole.blue:
        return AppColors.primaryBlue;
      case ColorRole.green:
        return AppColors.primaryGreen;
      case ColorRole.red:
        return AppColors.primaryRed;
      case ColorRole.orange:
        return AppColors.warning;
    }
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.selectedDate,
    required this.onTap,
    this.calendarDay,
    this.isLoadingCalendar = false,
  });

  final DateTime selectedDate;
  final VoidCallback onTap;
  final BookingCalendarDay? calendarDay;
  final bool isLoadingCalendar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Tanggal Periksa',
              prefixIcon: Icon(Icons.event_outlined),
              suffixIcon: Icon(Icons.expand_more_rounded),
            ),
            child: Text(DateFormatUtils.formatDateTime(selectedDate)),
          ),
          if (isLoadingCalendar || calendarDay != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xSmall),
            _DateStatusChip(
              calendarDay: calendarDay,
              isLoading: isLoadingCalendar,
            ),
          ],
        ],
      ),
    );
  }
}

class _DateStatusChip extends StatelessWidget {
  const _DateStatusChip({required this.calendarDay, required this.isLoading});

  final BookingCalendarDay? calendarDay;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Row(
        children: <Widget>[
          AppLoadingIndicator(size: 16),
          SizedBox(width: AppSpacing.xSmall),
          Text('Memeriksa kalender pendaftaran...'),
        ],
      );
    }

    final BookingCalendarDay? day = calendarDay;
    if (day == null) {
      return const SizedBox.shrink();
    }

    final Color color = day.isOpen
        ? AppColors.primaryGreen
        : day.isLeave
        ? AppColors.primaryBlue
        : AppColors.warning;
    final IconData icon = day.isOpen
        ? Icons.event_available_outlined
        : Icons.event_busy_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              day.isOpen ? 'Tanggal tersedia' : 'Tutup: ${day.displayReason}',
              maxLines: 2,
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

class _BookingCalendarSheet extends StatefulWidget {
  const _BookingCalendarSheet({
    required this.initialDate,
    required this.initialCalendar,
    required this.allowClosedDates,
    required this.loadCalendar,
  });

  final DateTime initialDate;
  final BookingCalendarResponse? initialCalendar;
  final bool allowClosedDates;
  final Future<BookingCalendarResponse?> Function({DateTime? month})
  loadCalendar;

  @override
  State<_BookingCalendarSheet> createState() => _BookingCalendarSheetState();
}

class _BookingCalendarSheetState extends State<_BookingCalendarSheet> {
  late DateTime _visibleMonth = _monthOnly(widget.initialDate);
  BookingCalendarResponse? _calendar;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calendar = _calendarForMonth(widget.initialCalendar, _visibleMonth);
    if (_calendar == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadMonth(_visibleMonth);
        }
      });
    }
  }

  Future<void> _loadMonth(DateTime month) async {
    final DateTime normalizedMonth = _monthOnly(month);
    setState(() {
      _visibleMonth = normalizedMonth;
      _calendar = null;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final BookingCalendarResponse? calendar = await widget.loadCalendar(
        month: month,
      );
      if (!mounted) {
        return;
      }
      final BookingCalendarResponse? validCalendar = _calendarForMonth(
        calendar,
        normalizedMonth,
      );
      setState(() {
        _calendar = validCalendar;
        _isLoading = false;
        _errorMessage = validCalendar == null
            ? 'Kalender libur bulan ini belum berhasil dimuat.'
            : null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kalender libur bulan ini belum berhasil dimuat.';
      });
    }
  }

  void _selectDate(DateTime date, BookingCalendarDay? day) {
    final bool isClosed = day != null
        ? !day.isOpen
        : date.weekday == DateTime.sunday;
    if (!widget.allowClosedDates && isClosed) {
      showAppSnackBar(
        context,
        'Tanggal tidak tersedia: ${day?.displayReason ?? 'Hari Minggu'}',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    Navigator.of(context).pop(_dateOnly(date));
  }

  Future<void> _pickMonthYear() async {
    final DateTime? selectedMonth = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return _MonthYearPickerDialog(initialMonth: _visibleMonth);
      },
    );

    if (selectedMonth == null || !mounted) {
      return;
    }

    await _loadMonth(selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.medium,
        right: AppSpacing.medium,
        top: AppSpacing.small,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.medium,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSoft,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Pilih Tanggal Registrasi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _loadMonth(
                  DateTime(_visibleMonth.year, _visibleMonth.month - 1),
                ),
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Bulan sebelumnya',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _loadMonth(
                  DateTime(_visibleMonth.year, _visibleMonth.month + 1),
                ),
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Bulan berikutnya',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: _pickMonthYear,
                icon: const Icon(Icons.calendar_month_outlined, size: 20),
                tooltip: 'Pilih bulan dan tahun',
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _monthTitle(_visibleMonth),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_isLoading) const AppLoadingIndicator(size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          const _CalendarLegend(),
          const SizedBox(height: AppSpacing.small),
          if (_errorMessage != null)
            _ErrorCard(message: _errorMessage!)
          else
            _CalendarGrid(
              visibleMonth: _visibleMonth,
              selectedDate: widget.initialDate,
              calendar: _calendar,
              allowClosedDates: widget.allowClosedDates,
              isLoading: _isLoading,
              onSelected: _selectDate,
            ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.xSmall,
      runSpacing: AppSpacing.xSmall,
      children: <Widget>[
        _CalendarLegendItem(label: 'Libur', color: AppColors.primaryRed),
        _CalendarLegendItem(
          label: 'Cuti Bersama',
          color: AppColors.primaryBlue,
        ),
        _CalendarLegendItem(label: 'Minggu', color: AppColors.warning),
      ],
    );
  }
}

class _MonthYearPickerDialog extends StatefulWidget {
  const _MonthYearPickerDialog({required this.initialMonth});

  final DateTime initialMonth;

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _month = widget.initialMonth.month;
  late final TextEditingController _yearController = TextEditingController(
    text: widget.initialMonth.year.toString(),
  );

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _submit() {
    final int? year = int.tryParse(_yearController.text.trim());
    if (year == null || year < 1900 || year > 2200) {
      showAppSnackBar(
        context,
        'Tahun harus di antara 1900-2200.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    Navigator.of(context).pop(DateTime(year, _month));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Bulan'),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      content: Row(
        children: <Widget>[
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: _month,
              decoration: const InputDecoration(labelText: 'Bulan'),
              items: List<DropdownMenuItem<int>>.generate(
                12,
                (int index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text(_monthName(index + 1)),
                ),
              ),
              onChanged: (int? value) {
                if (value != null) {
                  setState(() => _month = value);
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          SizedBox(
            width: 92,
            child: TextFormField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tahun'),
              onFieldSubmitted: (_) => _submit(),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Pilih')),
      ],
    );
  }
}

class _CalendarLegendItem extends StatelessWidget {
  const _CalendarLegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.visibleMonth,
    required this.selectedDate,
    required this.calendar,
    required this.allowClosedDates,
    required this.isLoading,
    required this.onSelected,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final BookingCalendarResponse? calendar;
  final bool allowClosedDates;
  final bool isLoading;
  final void Function(DateTime date, BookingCalendarDay? day) onSelected;

  @override
  Widget build(BuildContext context) {
    final DateTime firstOfMonth = _monthOnly(visibleMonth);
    final int daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;
    final int leadingBlanks = firstOfMonth.weekday - 1;
    final int totalCells = leadingBlanks + daysInMonth;
    final int rowCount = (totalCells / 7).ceil();
    final int itemCount = rowCount * 7;

    return Column(
      children: <Widget>[
        Row(
          children: const <Widget>[
            _WeekdayLabel('Sen'),
            _WeekdayLabel('Sel'),
            _WeekdayLabel('Rab'),
            _WeekdayLabel('Kam'),
            _WeekdayLabel('Jum'),
            _WeekdayLabel('Sab'),
            _WeekdayLabel('Min'),
          ],
        ),
        const SizedBox(height: AppSpacing.xSmall),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (BuildContext context, int index) {
            final int dayNumber = index - leadingBlanks + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final DateTime date = DateTime(
              visibleMonth.year,
              visibleMonth.month,
              dayNumber,
            );
            final BookingCalendarDay? day = calendar?.dayFor(date);
            final bool closed = day != null
                ? !day.isOpen
                : date.weekday == DateTime.sunday;
            final bool selected = _isSameDate(date, selectedDate);
            final bool disabled = !allowClosedDates && closed;

            return _CalendarDayTile(
              date: date,
              day: day,
              selected: selected,
              disabled: disabled,
              isLoading: isLoading,
              onTap: disabled ? null : () => onSelected(date, day),
            );
          },
        ),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CalendarDayTile extends StatelessWidget {
  const _CalendarDayTile({
    required this.date,
    required this.day,
    required this.selected,
    required this.disabled,
    required this.isLoading,
    required this.onTap,
  });

  final DateTime date;
  final BookingCalendarDay? day;
  final bool selected;
  final bool disabled;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isHoliday = day?.isHoliday ?? false;
    final bool isLeave = day?.isLeave ?? false;
    final bool isSundayClosed = day != null
        ? day!.isSunday && !day!.hasSundaySchedule
        : date.weekday == DateTime.sunday;
    final String badge = isHoliday
        ? 'Libur'
        : isLeave
        ? 'Cuti Bersama'
        : isSundayClosed
        ? 'Minggu'
        : '';
    final bool isMarked = badge.isNotEmpty;
    final Color accent = _accentColor(
      isHoliday: isHoliday,
      isLeave: isLeave,
      isSundayClosed: isSundayClosed,
    );
    final Color textColor = disabled
        ? AppColors.textSecondary.withValues(alpha: 0.45)
        : selected
        ? Colors.white
        : AppColors.textPrimary;
    final Color backgroundColor = selected
        ? AppColors.primaryTeal
        : disabled
        ? accent.withValues(alpha: isMarked ? 0.08 : 0.03)
        : isMarked
        ? accent.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.64);
    final Color borderColor = selected
        ? AppColors.primaryTeal
        : isMarked
        ? accent.withValues(alpha: disabled ? 0.16 : 0.28)
        : AppColors.borderSoft.withValues(alpha: 0.55);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${date.day}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            if (badge.isNotEmpty)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  badge,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? Colors.white : accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Color _accentColor({
    required bool isHoliday,
    required bool isLeave,
    required bool isSundayClosed,
  }) {
    if (isHoliday) {
      return AppColors.primaryRed;
    }
    if (isLeave) {
      return AppColors.primaryBlue;
    }
    if (isSundayClosed) {
      return AppColors.warning;
    }
    return AppColors.borderSoft;
  }
}

class _QueueAvailabilityPanel extends StatelessWidget {
  const _QueueAvailabilityPanel({
    required this.selectedPoli,
    required this.bookingOptions,
    required this.isLoading,
  });

  final ResourceRecord? selectedPoli;
  final BookingOptionsResponse? bookingOptions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final BookingPoliOption? poli = bookingOptions?.poli;
    final String schedule = _scheduleLabel(poli, selectedPoli);
    final int quota =
        poli?.quota ?? selectedPoli?.intValue(const <String>['kuota']) ?? 0;
    final int onlineQuota =
        poli?.onlineQuota ??
        selectedPoli?.intValue(const <String>['kuota_online']) ??
        0;
    final int filled =
        poli?.filled ?? selectedPoli?.intValue(const <String>['terisi']) ?? 0;
    final int baseQuota = onlineQuota > 0 ? onlineQuota : quota;
    final int remaining = baseQuota > 0
        ? (baseQuota - filled < 0 ? 0 : baseQuota - filled)
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: isLoading && bookingOptions == null
          ? const _SoftLinearLoader()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.event_available_outlined,
                      size: 18,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: AppSpacing.xSmall),
                    Expanded(
                      child: Text(
                        'Jadwal dan Kuota',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.small),
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: <Widget>[
                    _MetricPill(
                      label: 'Jadwal',
                      value: schedule.isEmpty ? '-' : schedule,
                    ),
                    _MetricPill(label: 'Kuota', value: '$baseQuota'),
                    _MetricPill(label: 'Terisi', value: '$filled'),
                    _MetricPill(label: 'Sisa', value: '$remaining'),
                  ],
                ),
              ],
            ),
    );
  }

  String _scheduleLabel(BookingPoliOption? poli, ResourceRecord? fallbackPoli) {
    final String optionSchedule = poli?.scheduleLabel.trim() ?? '';
    if (optionSchedule.isNotEmpty) {
      return optionSchedule;
    }

    final String practice =
        fallbackPoli?.value(const <String>['praktik'], fallback: '') ?? '';
    final String open =
        fallbackPoli?.value(const <String>['buka'], fallback: '') ?? '';
    final String close =
        fallbackPoli?.value(const <String>['tutup'], fallback: '') ?? '';
    return <String>[
      if (practice.trim().isNotEmpty && practice != '-') practice,
      if (open.trim().isNotEmpty || close.trim().isNotEmpty)
        '$open - $close'.replaceAll(RegExp(r'(^\s*-\s*|\s*-\s*$)'), ''),
    ].where((String value) => value.trim().isNotEmpty).join(' | ');
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SoftLinearLoader extends StatelessWidget {
  const _SoftLinearLoader();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 6,
        backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.10),
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
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

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline, color: AppColors.primaryBlue),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessState extends StatelessWidget {
  const _AccessState({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.small,
        AppSpacing.large,
        156,
      ),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.link_off_rounded, color: AppColors.warning),
                const SizedBox(height: AppSpacing.medium),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xSmall),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                if (buttonLabel != null && onPressed != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.medium),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onPressed,
                      icon: const Icon(Icons.link_rounded),
                      label: Text(buttonLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
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

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

BookingCalendarDay? _calendarDayFor(
  DateTime date,
  BookingCalendarResponse? calendar,
) {
  final BookingCalendarResponse? validCalendar = _calendarForMonth(
    calendar,
    date,
  );
  if (validCalendar == null) {
    return null;
  }

  return validCalendar.dayFor(date);
}

BookingCalendarResponse? _calendarForMonth(
  BookingCalendarResponse? calendar,
  DateTime month,
) {
  if (calendar == null ||
      calendar.year != month.year ||
      calendar.month != month.month) {
    return null;
  }

  return calendar;
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime _monthOnly(DateTime date) {
  return DateTime(date.year, date.month);
}

bool _isSameDate(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _monthTitle(DateTime date) {
  return '${_monthName(date.month)} ${date.year}';
}

String _monthName(int month) {
  const List<String> months = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  if (month < 1 || month > months.length) {
    return '-';
  }

  return months[month - 1];
}
