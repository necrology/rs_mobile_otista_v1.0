import '../../domain/entities/patient_identity.dart';

class AuthLocalDatasource {
  PatientIdentity? _cachedIdentity;

  Future<PatientIdentity?> getCurrentSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _cachedIdentity;
  }

  Future<PatientIdentity> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final String normalizedName = email
        .split('@')
        .first
        .replaceAll('.', ' ')
        .trim();
    final String userName = normalizedName.isEmpty
        ? 'Pasien'
        : normalizedName
              .split(' ')
              .map(
                (String value) => value.isEmpty
                    ? value
                    : '${value[0].toUpperCase()}${value.substring(1)}',
              )
              .join(' ');

    _cachedIdentity = PatientIdentity(
      id: 'PT-0001',
      patientId: '',
      fullName: userName,
      email: email,
      phoneNumber: '0812-3456-7890',
      medicalRecordNumber: 'PT-0001',
      familyMembers: const <String>['Budi Setiawan', 'Nina Setiawan'],
    );

    return _cachedIdentity!;
  }

  Future<PatientIdentity> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    _cachedIdentity = PatientIdentity(
      id: 'PT-0002',
      patientId: '',
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      medicalRecordNumber: '',
      familyMembers: const <String>['Keluarga 1'],
    );

    return _cachedIdentity!;
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _cachedIdentity = null;
  }
}
