import '../entities/api_collection.dart';
import '../entities/employee_record.dart';
import '../entities/patient_record.dart';
import '../entities/resource_record.dart';
import '../entities/table_metadata.dart';

abstract class RsApiRepository {
  Future<ApiCollection<PatientRecord>> searchPatients({
    required String query,
    int? limit,
    List<String>? columns,
    List<String>? searchColumns,
    bool withTotal = false,
  });

  Future<PatientRecord> fetchPatientById(String id);

  Future<ApiCollection<EmployeeRecord>> searchEmployees({
    required String search,
    List<String>? searchColumns,
  });

  Future<ApiCollection<ResourceRecord>> searchPolyclinics({
    required String search,
    int? limit,
  });

  Future<ApiCollection<ResourceRecord>> searchRooms({
    required String search,
    int? limit,
  });

  Future<TableMetadata> fetchTableMetadata(String tableName);
}
