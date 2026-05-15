import '../../../../shared/domain/entities/hospital_data_item.dart';
import '../../../../shared/domain/entities/patient_feature.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required HomeLocalDatasource localDatasource})
    : _localDatasource = localDatasource;

  final HomeLocalDatasource _localDatasource;

  @override
  Future<List<HospitalDataItem>> fetchHospitalDataItems() {
    return _localDatasource.getHospitalDataItems();
  }

  @override
  Future<List<PatientFeature>> fetchPatientFeatures() {
    return _localDatasource.getPatientFeatures();
  }
}
