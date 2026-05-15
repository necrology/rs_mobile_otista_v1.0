import '../../../../shared/domain/entities/hospital_data_item.dart';
import '../../../../shared/domain/entities/patient_feature.dart';

abstract class HomeRepository {
  Future<List<PatientFeature>> fetchPatientFeatures();

  Future<List<HospitalDataItem>> fetchHospitalDataItems();
}
