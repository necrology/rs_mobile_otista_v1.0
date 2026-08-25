import 'package:equatable/equatable.dart';

class PatientIdentity extends Equatable {
  const PatientIdentity({
    required this.id,
    required this.patientId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.medicalRecordNumber,
    required this.familyMembers,
  });

  final String id;
  final String patientId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String medicalRecordNumber;
  final List<String> familyMembers;

  factory PatientIdentity.fromJson(Map<String, dynamic> json) {
    return PatientIdentity(
      id: json['id'] as String? ?? '',
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      medicalRecordNumber: json['medicalRecordNumber'] as String? ?? '',
      familyMembers:
          (json['familyMembers'] as List<dynamic>?)
              ?.map((dynamic value) => value.toString())
              .toList() ??
          const <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'patientId': patientId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'medicalRecordNumber': medicalRecordNumber,
      'familyMembers': familyMembers,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    patientId,
    fullName,
    email,
    phoneNumber,
    medicalRecordNumber,
    familyMembers,
  ];
}
