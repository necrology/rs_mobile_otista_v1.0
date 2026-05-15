import 'package:equatable/equatable.dart';

class PatientIdentity extends Equatable {
  const PatientIdentity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.familyMembers,
  });

  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final List<String> familyMembers;

  @override
  List<Object?> get props => <Object?>[
    id,
    fullName,
    email,
    phoneNumber,
    familyMembers,
  ];
}
