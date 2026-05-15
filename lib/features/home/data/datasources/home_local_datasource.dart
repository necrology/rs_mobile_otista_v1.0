import '../../../../shared/data/dummy/dummy_data.dart';
import '../../../../shared/domain/entities/hospital_data_item.dart';
import '../../../../shared/domain/entities/patient_feature.dart';

class HomeLocalDatasource {
  Future<List<PatientFeature>> getPatientFeatures() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return DummyData.patientFeatures;
  }

  Future<List<HospitalDataItem>> getHospitalDataItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return DummyData.hospitalDataItems;
  }
}
