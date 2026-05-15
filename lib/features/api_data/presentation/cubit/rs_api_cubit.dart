import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/api_collection.dart';
import '../../domain/entities/employee_record.dart';
import '../../domain/entities/patient_record.dart';
import '../../domain/entities/resource_record.dart';
import '../../domain/entities/table_metadata.dart';
import '../../domain/repositories/rs_api_repository.dart';

part 'rs_api_state.dart';

class RsApiCubit extends Cubit<RsApiState> {
  RsApiCubit({required RsApiRepository repository})
    : _repository = repository,
      super(const RsApiState());

  final RsApiRepository _repository;

  static const List<String> _patientPreviewColumns = <String>['no_rm', 'nama'];
  static const List<String> _patientSearchColumns = <String>['nama', 'no_rm'];
  static const List<String> _employeeSearchColumns = <String>[
    'nama',
    'jabatan',
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

  Future<void> searchEmployees(String search) async {
    final String normalizedSearch = _fallback(search, 'dokter');

    emit(state.copyWith(isLoadingEmployees: true, errorMessage: null));

    try {
      final ApiCollection<EmployeeRecord> employees = await _repository
          .searchEmployees(
            search: normalizedSearch,
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
          .searchPolyclinics(search: normalizedSearch, limit: 20);

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
