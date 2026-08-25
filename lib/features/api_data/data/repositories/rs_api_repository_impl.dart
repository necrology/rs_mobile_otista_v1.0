import '../../domain/entities/api_collection.dart';
import '../../domain/entities/employee_record.dart';
import '../../domain/entities/patient_lab_result_record.dart';
import '../../domain/entities/patient_medical_summary_record.dart';
import '../../domain/entities/patient_prescription_record.dart';
import '../../domain/entities/patient_radiology_result_record.dart';
import '../../domain/entities/patient_record.dart';
import '../../domain/entities/patient_visit_record.dart';
import '../../domain/entities/resource_record.dart';
import '../../domain/entities/table_metadata.dart';
import '../../../booking/domain/entities/booking_queue_response.dart';
import '../../../booking/domain/entities/booking_calendar.dart';
import '../../../booking/domain/entities/booking_options.dart';
import '../../../booking/domain/entities/queue_records.dart';
import '../../domain/repositories/rs_api_repository.dart';
import '../datasources/rs_api_remote_datasource.dart';

class RsApiRepositoryImpl implements RsApiRepository {
  const RsApiRepositoryImpl({required RsApiRemoteDatasource remoteDatasource})
    : _remoteDatasource = remoteDatasource;

  final RsApiRemoteDatasource _remoteDatasource;

  @override
  Future<PatientRecord> fetchPatientById(String id) {
    return _remoteDatasource.fetchPatientById(id);
  }

  @override
  Future<PatientRecord> fetchLinkedPatientProfile() {
    return _remoteDatasource.fetchLinkedPatientProfile();
  }

  @override
  Future<ApiCollection<PatientVisitRecord>> fetchPatientVisits({int? limit}) {
    return _remoteDatasource.fetchPatientVisits(limit: limit);
  }

  @override
  Future<ApiCollection<PatientMedicalSummaryRecord>>
  fetchPatientMedicalSummaries({int? limit}) {
    return _remoteDatasource.fetchPatientMedicalSummaries(limit: limit);
  }

  @override
  Future<ApiCollection<PatientLabResultRecord>> fetchPatientLabResults({
    int? limit,
  }) {
    return _remoteDatasource.fetchPatientLabResults(limit: limit);
  }

  @override
  Future<ApiCollection<PatientRadiologyResultRecord>>
  fetchPatientRadiologyResults({int? limit}) {
    return _remoteDatasource.fetchPatientRadiologyResults(limit: limit);
  }

  @override
  Future<ApiCollection<PatientPrescriptionRecord>> fetchPatientPrescriptions({
    int? limit,
  }) {
    return _remoteDatasource.fetchPatientPrescriptions(limit: limit);
  }

  @override
  Future<BookingQueueResponse> createGeneralBooking({
    required int poliId,
    required String tanggal,
    required String bayar,
    required String jenisPasien,
    required String doctorId,
    required String queueGroup,
    required bool isJkn,
  }) {
    return _remoteDatasource.createGeneralBooking(
      poliId: poliId,
      tanggal: tanggal,
      bayar: bayar,
      jenisPasien: jenisPasien,
      doctorId: doctorId,
      queueGroup: queueGroup,
      isJkn: isJkn,
    );
  }

  @override
  Future<BookingOptionsResponse> fetchBookingOptions({required int poliId}) {
    return _remoteDatasource.fetchBookingOptions(poliId: poliId);
  }

  @override
  Future<BookingCalendarResponse> fetchBookingCalendar({
    required int year,
    required int month,
    int? poliId,
  }) {
    return _remoteDatasource.fetchBookingCalendar(
      year: year,
      month: month,
      poliId: poliId,
    );
  }

  @override
  Future<TableMetadata> fetchTableMetadata(String tableName) {
    return _remoteDatasource.fetchTableMetadata(tableName);
  }

  @override
  Future<ApiCollection<EmployeeRecord>> searchEmployees({
    required String search,
    int? limit,
    List<String>? columns,
    List<String>? searchColumns,
  }) {
    return _remoteDatasource.searchEmployees(
      search: search,
      limit: limit,
      columns: columns,
      searchColumns: searchColumns,
    );
  }

  @override
  Future<ApiCollection<ResourceRecord>> searchDoctorSchedules({
    required String search,
    int? limit,
    List<String>? columns,
  }) {
    return _remoteDatasource.searchDoctorSchedules(
      search: search,
      limit: limit,
      columns: columns,
    );
  }

  @override
  Future<ApiCollection<ResourceRecord>> searchPolyclinics({
    required String search,
    int? limit,
    List<String>? columns,
  }) {
    return _remoteDatasource.searchPolyclinics(
      search: search,
      limit: limit,
      columns: columns,
    );
  }

  @override
  Future<ApiCollection<ResourceRecord>> searchRooms({
    required String search,
    int? limit,
    List<String>? columns,
  }) {
    return _remoteDatasource.searchRooms(
      search: search,
      limit: limit,
      columns: columns,
    );
  }

  @override
  Future<ApiCollection<ResourceRecord>> searchRoomAvailabilities({
    required String search,
    int? limit,
    List<String>? columns,
  }) {
    return _remoteDatasource.searchRoomAvailabilities(
      search: search,
      limit: limit,
      columns: columns,
    );
  }

  @override
  Future<ApiCollection<QueueRegistrationRecord>> fetchQueueRegistrations({
    int limit = 50,
  }) {
    return _remoteDatasource.fetchQueueRegistrations(limit: limit);
  }

  @override
  Future<ApiCollection<LocalQueueRecord>> fetchLocalQueues({int limit = 50}) {
    return _remoteDatasource.fetchLocalQueues(limit: limit);
  }

  @override
  Future<ApiCollection<GeneralBookingRecord>> fetchMyGeneralBookings({
    String tanggal = '',
    int limit = 30,
    bool allDates = false,
  }) {
    return _remoteDatasource.fetchMyGeneralBookings(
      tanggal: tanggal,
      limit: limit,
      allDates: allDates,
    );
  }

  @override
  Future<ApiCollection<PatientRecord>> searchPatients({
    required String query,
    int? limit,
    List<String>? columns,
    List<String>? searchColumns,
    bool withTotal = false,
  }) {
    return _remoteDatasource.searchPatients(
      query: query,
      limit: limit,
      columns: columns,
      searchColumns: searchColumns,
      withTotal: withTotal,
    );
  }
}
