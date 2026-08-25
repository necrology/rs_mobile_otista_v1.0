import '../../../../shared/domain/entities/patient_feature.dart';

abstract class HomeRepository {
  Future<List<PatientFeature>> fetchPatientFeatures();
}
