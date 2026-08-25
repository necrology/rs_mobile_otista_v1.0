import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/api_collection.dart';
import '../../domain/entities/employee_record.dart';
import '../../domain/entities/patient_lab_result_record.dart';
import '../../domain/entities/patient_medical_summary_record.dart';
import '../../domain/entities/patient_prescription_record.dart';
import '../../domain/entities/patient_radiology_result_record.dart';
import '../../domain/entities/patient_record.dart';
import '../../domain/entities/patient_visit_record.dart';
import '../../domain/entities/table_metadata.dart';
import '../../../booking/domain/entities/queue_records.dart';
import '../../domain/entities/resource_record.dart';
import '../../domain/repositories/rs_api_repository.dart';
import '../../../booking/domain/entities/booking_queue_response.dart';
import '../../../booking/domain/entities/booking_calendar.dart';
import '../../../booking/domain/entities/booking_options.dart';

part 'rs_api_state.dart';

class RsApiCubit extends Cubit<RsApiState> {
  RsApiCubit({required RsApiRepository repository})
    : _repository = repository,
      super(const RsApiState());

  final RsApiRepository _repository;

  static const List<String> _patientPreviewColumns = <String>['no_rm', 'nama'];
  static const List<String> _patientSearchColumns = <String>['nama', 'no_rm'];
  static const List<String> _employeeScheduleColumns = <String>[
    'id',
    'nama',
    'jabatan',
    'kuota_poli',
    'poli_id',
    'poli_type',
    'is_dokter',
  ];
  static const List<String> _employeeSearchColumns = <String>[
    'nama',
    'jabatan',
  ];
  static const List<String> _doctorScheduleColumns = <String>[
    'id',
    'poli',
    'dokter',
    'hari',
    'jam_mulai',
    'jam_berakhir',
  ];
  static const List<String> _polyclinicScheduleColumns = <String>[
    'id',
    'nama',
    'kelas',
    'kode_ruangan',
    'kamar_id',
    'kuota',
    'kuota_online',
    'terisi',
    'buka',
    'tutup',
    'praktik',
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];
  static const List<String> _roomQuotaColumns = <String>[
    'id',
    'general_code',
    'nama',
    'kelas',
    'ruangan',
    'jumlah_kamar',
    'jumlah_bed',
    'terisi',
    'kosong',
    'rawat_inap_aktif',
    'keterangan',
  ];
  static const List<String> _roomAvailabilityColumns = <String>[
    'id',
    'kelompokkelas_id',
    'kamar_id',
    'jumlah_bed',
    'terisi',
    'renovasi',
    'keterangan',
    'updated_at',
  ];

  Future<void> loadEndpointSamples({
    required String patientQuery,
    required String patientId,
    required String employeeSearch,
  }) async {
    final String normalizedPatientQuery = _fallback(patientQuery, 'ahmad');
    final String normalizedPatientId = _fallback(patientId, '1');
    final String normalizedEmployeeSearch = _fallback(employeeSearch, 'dokter');

    emit(
      state.copyWith(
        isLoadingPatients: true,
        isLoadingPatientDetail: true,
        isLoadingEmployees: true,
        isLoadingTable: true,
        errorMessage: null,
      ),
    );

    final List<_ApiRequestResult<dynamic>> responses =
        await Future.wait<_ApiRequestResult<dynamic>>(
          <Future<_ApiRequestResult<dynamic>>>[
            _capture(
              'Pasien',
              () => _repository.searchPatients(
                query: normalizedPatientQuery,
                limit: 10,
                searchColumns: _patientSearchColumns,
              ),
            ),
            _capture(
              'Pasien ringkas',
              () => _repository.searchPatients(
                query: normalizedPatientQuery,
                columns: _patientPreviewColumns,
                searchColumns: _patientSearchColumns,
                withTotal: true,
              ),
            ),
            _capture(
              'Detail pasien',
              () => _repository.fetchPatientById(normalizedPatientId),
            ),
            _capture(
              'Pegawai',
              () => _repository.searchEmployees(
                search: normalizedEmployeeSearch,
                searchColumns: _employeeSearchColumns,
              ),
            ),
            _capture(
              'Metadata tabel',
              () => _repository.fetchTableMetadata('pasiens'),
            ),
          ],
        );

    final List<String> errors = responses
        .where((_ApiRequestResult<dynamic> response) => !response.isSuccess)
        .map((_ApiRequestResult<dynamic> response) => response.errorMessage!)
        .toList();

    emit(
      state.copyWith(
        isLoadingPatients: false,
        isLoadingPatientDetail: false,
        isLoadingEmployees: false,
        isLoadingTable: false,
        patients: responses[0].value as ApiCollection<PatientRecord>?,
        compactPatients: responses[1].value as ApiCollection<PatientRecord>?,
        selectedPatient: responses[2].value as PatientRecord?,
        employees: responses[3].value as ApiCollection<EmployeeRecord>?,
        patientTableMetadata: responses[4].value as TableMetadata?,
        lastPatientQuery: normalizedPatientQuery,
        lastPatientId: normalizedPatientId,
        lastEmployeeSearch: normalizedEmployeeSearch,
        lastUpdatedAt: DateTime.now(),
        errorMessage: errors.isEmpty ? null : errors.join('\n'),
      ),
    );
  }

  Future<_ApiRequestResult<T>> _capture<T>(
    String label,
    Future<T> Function() request,
  ) async {
    try {
      return _ApiRequestResult<T>.success(await request());
    } catch (error) {
      return _ApiRequestResult<T>.failure('$label: ${_friendlyError(error)}');
    }
  }

  Future<void> searchPatients(String query) async {
    final String normalizedQuery = _fallback(query, 'ahmad');

    emit(
      state.copyWith(
        isLoadingPatients: true,
        selectedPatient: null,
        errorMessage: null,
      ),
    );

    try {
      final List<dynamic> responses =
          await Future.wait<dynamic>(<Future<dynamic>>[
            _repository.searchPatients(
              query: normalizedQuery,
              limit: 10,
              searchColumns: _patientSearchColumns,
            ),
            _repository.searchPatients(
              query: normalizedQuery,
              columns: _patientPreviewColumns,
              searchColumns: _patientSearchColumns,
              withTotal: true,
            ),
          ]);

      emit(
        state.copyWith(
          isLoadingPatients: false,
          patients: responses[0] as ApiCollection<PatientRecord>,
          compactPatients: responses[1] as ApiCollection<PatientRecord>,
          lastPatientQuery: normalizedQuery,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingPatients: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> fetchPatientDetail(String id) async {
    final String normalizedId = _fallback(id, '1');

    emit(state.copyWith(isLoadingPatientDetail: true, errorMessage: null));

    try {
      final PatientRecord patient = await _repository.fetchPatientById(
        normalizedId,
      );

      emit(
        state.copyWith(
          isLoadingPatientDetail: false,
          selectedPatient: patient,
          lastPatientId: normalizedId,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingPatientDetail: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> fetchLinkedPatientProfile({String? patientId}) async {
    final String normalizedPatientId = patientId?.trim() ?? '';

    emit(
      state.copyWith(
        isLoadingPatientDetail: true,
        selectedPatient: null,
        patients: null,
        compactPatients: null,
        errorMessage: null,
      ),
    );

    try {
      final PatientRecord selectedPatient = await _repository
          .fetchLinkedPatientProfile();
      final ApiCollection<PatientRecord> patients =
          ApiCollection<PatientRecord>(
            items: <PatientRecord>[selectedPatient],
            total: 1,
          );

      emit(
        state.copyWith(
          isLoadingPatientDetail: false,
          selectedPatient: selectedPatient,
          patients: patients,
          lastPatientQuery: selectedPatient.noRm,
          lastPatientId: normalizedPatientId.isEmpty
              ? selectedPatient.id
              : normalizedPatientId,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingPatientDetail: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> fetchPatientVisits() async {
    emit(
      state.copyWith(
        isLoadingPatientVisits: true,
        patientVisits: null,
        errorMessage: null,
      ),
    );

    try {
      final ApiCollection<PatientVisitRecord> visits = await _repository
          .fetchPatientVisits(limit: 50);

      emit(
        state.copyWith(
          isLoadingPatientVisits: false,
          patientVisits: visits,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingPatientVisits: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> fetchPatientMedicalSummaries() async {
    emit(
      state.copyWith(
        isLoadingPatientMedicalSummaries: true,
        patientMedicalSummaries: null,
        errorMessage: null,
      ),
    );

    try {
      final ApiCollection<PatientMedicalSummaryRecord> summaries =
          await _repository.fetchPatientMedicalSummaries(limit: 50);

      emit(
        state.copyWith(
          isLoadingPatientMedicalSummaries: false,
          patientMedicalSummaries: summaries,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingPatientMedicalSummaries: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> fetchPatientLabResults() async {
    emit(
      state.copyWith(
        isLoadingPatientLabResults: true,
        patientLabResults: null,
        errorMessage: null,
      ),
    );

    try {
      final ApiCollection<PatientLabResultRecord> results = await _repository
          .fetchPatientLabResults(limit: 50);

      emit(
        state.copyWith(
          isLoadingPatientLabResults: false,
          patientLabResults: results,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingPatientLabResults: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> fetchPatientRadiologyResults() async {
    emit(
      state.copyWith(
        isLoadingPatientRadiologyResults: true,
        patientRadiologyResults: null,
        errorMessage: null,
      ),
    );

    try {
      final ApiCollection<PatientRadiologyResultRecord> results =
          await _repository.fetchPatientRadiologyResults(limit: 50);

      emit(
        state.copyWith(
          isLoadingPatientRadiologyResults: false,
          patientRadiologyResults: results,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingPatientRadiologyResults: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> fetchPatientPrescriptions() async {
    emit(
      state.copyWith(
        isLoadingPatientPrescriptions: true,
        patientPrescriptions: null,
        errorMessage: null,
      ),
    );

    try {
      final ApiCollection<PatientPrescriptionRecord> results = await _repository
          .fetchPatientPrescriptions(limit: 50);

      emit(
        state.copyWith(
          isLoadingPatientPrescriptions: false,
          patientPrescriptions: results,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingPatientPrescriptions: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> searchEmployees(String search) async {
    final String normalizedSearch = search.trim();

    emit(state.copyWith(isLoadingEmployees: true, errorMessage: null));

    try {
      final ApiCollection<EmployeeRecord> employees = await _repository
          .searchEmployees(
            search: normalizedSearch,
            limit: 80,
            columns: _employeeScheduleColumns,
            searchColumns: _employeeSearchColumns,
          );

      emit(
        state.copyWith(
          isLoadingEmployees: false,
          employees: employees,
          lastEmployeeSearch: normalizedSearch,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingEmployees: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> searchDoctorSchedules(String search) async {
    final String normalizedSearch = search.trim();

    emit(state.copyWith(isLoadingDoctorSchedules: true, errorMessage: null));

    try {
      final ApiCollection<ResourceRecord> schedules = await _repository
          .searchDoctorSchedules(
            search: normalizedSearch,
            limit: 100,
            columns: _doctorScheduleColumns,
          );

      emit(
        state.copyWith(
          isLoadingDoctorSchedules: false,
          doctorSchedules: schedules,
          lastDoctorScheduleSearch: normalizedSearch,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingDoctorSchedules: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> fetchPatientTableMetadata() async {
    emit(state.copyWith(isLoadingTable: true, errorMessage: null));

    try {
      final TableMetadata metadata = await _repository.fetchTableMetadata(
        'pasiens',
      );

      emit(
        state.copyWith(
          isLoadingTable: false,
          patientTableMetadata: metadata,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingTable: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> searchPolyclinics(String search) async {
    final String normalizedSearch = search.trim();

    emit(state.copyWith(isLoadingPolyclinics: true, errorMessage: null));

    try {
      final ApiCollection<ResourceRecord> polyclinics = await _repository
          .searchPolyclinics(
            search: normalizedSearch,
            limit: 100,
            columns: _polyclinicScheduleColumns,
          );

      emit(
        state.copyWith(
          isLoadingPolyclinics: false,
          polyclinics: polyclinics,
          lastPolyclinicSearch: normalizedSearch,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingPolyclinics: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> searchRooms(String search) async {
    final String normalizedSearch = search.trim();

    emit(state.copyWith(isLoadingRooms: true, errorMessage: null));

    try {
      final ApiCollection<ResourceRecord> rooms = await _repository.searchRooms(
        search: normalizedSearch,
        limit: 100,
        columns: _roomQuotaColumns,
      );

      emit(
        state.copyWith(
          isLoadingRooms: false,
          rooms: rooms,
          lastRoomSearch: normalizedSearch,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingRooms: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> searchRoomAvailabilities(String search) async {
    final String normalizedSearch = search.trim();

    emit(state.copyWith(isLoadingRoomAvailabilities: true, errorMessage: null));

    try {
      final ApiCollection<ResourceRecord> availabilities = await _repository
          .searchRoomAvailabilities(
            search: normalizedSearch,
            limit: 100,
            columns: _roomAvailabilityColumns,
          );

      emit(
        state.copyWith(
          isLoadingRoomAvailabilities: false,
          roomAvailabilities: availabilities,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingRoomAvailabilities: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> fetchQueueOverview() async {
    emit(
      state.copyWith(
        isLoadingQueueRegistrations: true,
        isLoadingLocalQueues: true,
        errorMessage: null,
      ),
    );

    try {
      final List<dynamic> results =
          await Future.wait<dynamic>(<Future<dynamic>>[
            _repository.fetchQueueRegistrations(limit: 80),
            _repository.fetchLocalQueues(limit: 80),
          ]);

      emit(
        state.copyWith(
          isLoadingQueueRegistrations: false,
          isLoadingLocalQueues: false,
          queueRegistrations:
              results[0] as ApiCollection<QueueRegistrationRecord>,
          localQueues: results[1] as ApiCollection<LocalQueueRecord>,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingQueueRegistrations: false,
          isLoadingLocalQueues: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> fetchMyGeneralBookings({
    String tanggal = '',
    bool allDates = false,
  }) async {
    emit(state.copyWith(isLoadingMyGeneralBookings: true, errorMessage: null));

    try {
      final ApiCollection<GeneralBookingRecord> bookings = await _repository
          .fetchMyGeneralBookings(
            tanggal: tanggal,
            limit: 30,
            allDates: allDates,
          );

      emit(
        state.copyWith(
          isLoadingMyGeneralBookings: false,
          myGeneralBookings: bookings,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingMyGeneralBookings: false,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<BookingQueueResponse?> createGeneralBooking({
    required int poliId,
    required String tanggal,
    required String doctorId,
    required String queueGroup,
  }) async {
    emit(
      state.copyWith(
        isCreatingGeneralBooking: true,
        lastCreatedBooking: null,
        errorMessage: null,
      ),
    );

    try {
      final BookingQueueResponse result = await _repository
          .createGeneralBooking(
            poliId: poliId,
            tanggal: tanggal,
            bayar: '2',
            jenisPasien: 'umum',
            doctorId: doctorId,
            queueGroup: queueGroup,
            isJkn: false,
          );

      emit(
        state.copyWith(
          isCreatingGeneralBooking: false,
          lastCreatedBooking: result,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
      return result;
    } catch (error) {
      emit(
        state.copyWith(
          isCreatingGeneralBooking: false,
          errorMessage: _friendlyError(error),
        ),
      );
      return null;
    }
  }

  Future<void> fetchBookingOptions({required int poliId}) async {
    if (poliId <= 0) {
      emit(state.copyWith(bookingOptions: null));
      return;
    }

    emit(
      state.copyWith(
        isLoadingBookingOptions: true,
        bookingOptions: null,
        errorMessage: null,
      ),
    );

    try {
      final BookingOptionsResponse options = await _repository
          .fetchBookingOptions(poliId: poliId);

      emit(
        state.copyWith(
          isLoadingBookingOptions: false,
          bookingOptions: options,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingBookingOptions: false,
          bookingOptions: null,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<BookingCalendarResponse?> fetchBookingCalendar({
    required int year,
    required int month,
    int? poliId,
  }) async {
    emit(state.copyWith(isLoadingBookingCalendar: true, errorMessage: null));

    try {
      final BookingCalendarResponse calendar = await _repository
          .fetchBookingCalendar(year: year, month: month, poliId: poliId);

      emit(
        state.copyWith(
          isLoadingBookingCalendar: false,
          bookingCalendar: calendar,
          lastUpdatedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
      return calendar;
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingBookingCalendar: false,
          errorMessage: _friendlyError(error),
        ),
      );
      return null;
    }
  }

  String _fallback(String value, String fallbackValue) {
    final String normalizedValue = value.trim();
    return normalizedValue.isEmpty ? fallbackValue : normalizedValue;
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return error.toString();
  }
}

class _ApiRequestResult<T> {
  const _ApiRequestResult._({this.value, this.errorMessage});

  factory _ApiRequestResult.success(T value) {
    return _ApiRequestResult<T>._(value: value);
  }

  factory _ApiRequestResult.failure(String message) {
    return _ApiRequestResult<T>._(errorMessage: message);
  }

  final T? value;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;
}
