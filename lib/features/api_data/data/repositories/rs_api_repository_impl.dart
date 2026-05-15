import '../../domain/entities/api_collection.dart';
import '../../domain/entities/employee_record.dart';
import '../../domain/entities/patient_record.dart';
import '../../domain/entities/resource_record.dart';
import '../../domain/entities/table_metadata.dart';
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
  Future<TableMetadata> fetchTableMetadata(String tableName) {
    return _remoteDatasource.fetchTableMetadata(tableName);
  }

  @override
  Future<ApiCollection<EmployeeRecord>> searchEmployees({
    required String search,
    List<String>? searchColumns,
  }) {
    return _remoteDatasource.searchEmployees(
      search: search,
      searchColumns: searchColumns,
    );
  }

  @override
  Future<ApiCollection<ResourceRecord>> searchPolyclinics({
    required String search,
    int? limit,
  }) {
    return _remoteDatasource.searchPolyclinics(search: search, limit: limit);
  }

  @override
  Future<ApiCollection<ResourceRecord>> searchRooms({
    required String search,
    int? limit,
  }) {
    return _remoteDatasource.searchRooms(search: search, limit: limit);
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
