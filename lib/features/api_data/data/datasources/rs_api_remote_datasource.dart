import '../../../../core/network/api_client.dart';
import '../../domain/entities/api_collection.dart';
import '../../domain/entities/employee_record.dart';
import '../../domain/entities/patient_record.dart';
import '../../domain/entities/resource_record.dart';
import '../../domain/entities/table_metadata.dart';

class RsApiRemoteDatasource {
  const RsApiRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ApiCollection<PatientRecord>> searchPatients({
    required String query,
    int? limit,
    List<String>? columns,
    List<String>? searchColumns,
    bool withTotal = false,
  }) async {
    final dynamic response = await _apiClient.get(
      '/pasiens',
      queryParameters: <String, Object?>{
        'q': query,
        'limit': limit,
        'columns': columns?.join(','),
        'search_columns': searchColumns?.join(','),
        'with_total': withTotal ? 'true' : null,
      },
    );

    return ApiCollection<PatientRecord>.fromResponse(
      response,
      PatientRecord.fromJson,
    );
  }

  Future<PatientRecord> fetchPatientById(String id) async {
    final dynamic response = await _apiClient.get('/pasiens/$id');
    return PatientRecord.fromJson(ApiResponseReader.findMap(response));
  }

  Future<ApiCollection<EmployeeRecord>> searchEmployees({
    required String search,
    List<String>? searchColumns,
  }) async {
    final dynamic response = await _apiClient.get(
      '/pegawais',
      queryParameters: <String, Object?>{
        'search': search,
        'search_columns': searchColumns?.join(','),
      },
    );

    return ApiCollection<EmployeeRecord>.fromResponse(
      response,
      EmployeeRecord.fromJson,
    );
  }

  Future<ApiCollection<ResourceRecord>> searchPolyclinics({
    required String search,
    int? limit,
  }) async {
    final dynamic response = await _apiClient.get(
      '/polis',
      queryParameters: <String, Object?>{
        'q': search,
        'limit': limit,
        'search_columns': 'nama,kode_ruangan,kelas,kelompok',
        'with_total': 'true',
      },
    );

    return ApiCollection<ResourceRecord>.fromResponse(
      response,
      ResourceRecord.fromJson,
    );
  }

  Future<ApiCollection<ResourceRecord>> searchRooms({
    required String search,
    int? limit,
  }) async {
    final dynamic response = await _apiClient.get(
      '/kamars',
      queryParameters: <String, Object?>{
        'q': search,
        'limit': limit,
        'search_columns': 'nama,kode',
        'with_total': 'true',
      },
    );

    return ApiCollection<ResourceRecord>.fromResponse(
      response,
      ResourceRecord.fromJson,
    );
  }

  Future<TableMetadata> fetchTableMetadata(String tableName) async {
    final dynamic response = await _apiClient.get('/tables/$tableName');

    return TableMetadata.fromResponse(tableName: tableName, response: response);
  }
}
