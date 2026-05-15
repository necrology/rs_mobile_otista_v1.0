part of 'rs_api_cubit.dart';

class RsApiState extends Equatable {
  const RsApiState({
    this.isLoadingPatients = false,
    this.isLoadingPatientDetail = false,
    this.isLoadingEmployees = false,
    this.isLoadingTable = false,
    this.isLoadingPolyclinics = false,
    this.isLoadingRooms = false,
    this.lastPatientQuery = 'ahmad',
    this.lastPatientId = '1',
    this.lastEmployeeSearch = 'dokter',
    this.lastPolyclinicSearch = '',
    this.lastRoomSearch = '',
    this.patients,
    this.compactPatients,
    this.selectedPatient,
    this.employees,
    this.patientTableMetadata,
    this.polyclinics,
    this.rooms,
    this.errorMessage,
    this.lastUpdatedAt,
  });

  final bool isLoadingPatients;
  final bool isLoadingPatientDetail;
  final bool isLoadingEmployees;
  final bool isLoadingTable;
  final bool isLoadingPolyclinics;
  final bool isLoadingRooms;
  final String lastPatientQuery;
  final String lastPatientId;
  final String lastEmployeeSearch;
  final String lastPolyclinicSearch;
  final String lastRoomSearch;
  final ApiCollection<PatientRecord>? patients;
  final ApiCollection<PatientRecord>? compactPatients;
  final PatientRecord? selectedPatient;
  final ApiCollection<EmployeeRecord>? employees;
  final TableMetadata? patientTableMetadata;
  final ApiCollection<ResourceRecord>? polyclinics;
  final ApiCollection<ResourceRecord>? rooms;
  final String? errorMessage;
  final DateTime? lastUpdatedAt;

  bool get isBusy =>
      isLoadingPatients ||
      isLoadingPatientDetail ||
      isLoadingEmployees ||
      isLoadingTable ||
      isLoadingPolyclinics ||
      isLoadingRooms;

  bool get hasData =>
      patients != null ||
      compactPatients != null ||
      selectedPatient != null ||
      employees != null ||
      patientTableMetadata != null ||
      polyclinics != null ||
      rooms != null;

  RsApiState copyWith({
    bool? isLoadingPatients,
    bool? isLoadingPatientDetail,
    bool? isLoadingEmployees,
    bool? isLoadingTable,
    bool? isLoadingPolyclinics,
    bool? isLoadingRooms,
    String? lastPatientQuery,
    String? lastPatientId,
    String? lastEmployeeSearch,
    String? lastPolyclinicSearch,
    String? lastRoomSearch,
    Object? patients = _rsApiNoValue,
    Object? compactPatients = _rsApiNoValue,
    Object? selectedPatient = _rsApiNoValue,
    Object? employees = _rsApiNoValue,
    Object? patientTableMetadata = _rsApiNoValue,
    Object? polyclinics = _rsApiNoValue,
    Object? rooms = _rsApiNoValue,
    Object? errorMessage = _rsApiNoValue,
    Object? lastUpdatedAt = _rsApiNoValue,
  }) {
    return RsApiState(
      isLoadingPatients: isLoadingPatients ?? this.isLoadingPatients,
      isLoadingPatientDetail:
          isLoadingPatientDetail ?? this.isLoadingPatientDetail,
      isLoadingEmployees: isLoadingEmployees ?? this.isLoadingEmployees,
      isLoadingTable: isLoadingTable ?? this.isLoadingTable,
      isLoadingPolyclinics: isLoadingPolyclinics ?? this.isLoadingPolyclinics,
      isLoadingRooms: isLoadingRooms ?? this.isLoadingRooms,
      lastPatientQuery: lastPatientQuery ?? this.lastPatientQuery,
      lastPatientId: lastPatientId ?? this.lastPatientId,
      lastEmployeeSearch: lastEmployeeSearch ?? this.lastEmployeeSearch,
      lastPolyclinicSearch: lastPolyclinicSearch ?? this.lastPolyclinicSearch,
      lastRoomSearch: lastRoomSearch ?? this.lastRoomSearch,
      patients: patients == _rsApiNoValue
          ? this.patients
          : patients as ApiCollection<PatientRecord>?,
      compactPatients: compactPatients == _rsApiNoValue
          ? this.compactPatients
          : compactPatients as ApiCollection<PatientRecord>?,
      selectedPatient: selectedPatient == _rsApiNoValue
          ? this.selectedPatient
          : selectedPatient as PatientRecord?,
      employees: employees == _rsApiNoValue
          ? this.employees
          : employees as ApiCollection<EmployeeRecord>?,
      patientTableMetadata: patientTableMetadata == _rsApiNoValue
          ? this.patientTableMetadata
          : patientTableMetadata as TableMetadata?,
      polyclinics: polyclinics == _rsApiNoValue
          ? this.polyclinics
          : polyclinics as ApiCollection<ResourceRecord>?,
      rooms: rooms == _rsApiNoValue
          ? this.rooms
          : rooms as ApiCollection<ResourceRecord>?,
      errorMessage: errorMessage == _rsApiNoValue
          ? this.errorMessage
          : errorMessage as String?,
      lastUpdatedAt: lastUpdatedAt == _rsApiNoValue
          ? this.lastUpdatedAt
          : lastUpdatedAt as DateTime?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoadingPatients,
    isLoadingPatientDetail,
    isLoadingEmployees,
    isLoadingTable,
    isLoadingPolyclinics,
    isLoadingRooms,
    lastPatientQuery,
    lastPatientId,
    lastEmployeeSearch,
    lastPolyclinicSearch,
    lastRoomSearch,
    patients,
    compactPatients,
    selectedPatient,
    employees,
    patientTableMetadata,
    polyclinics,
    rooms,
    errorMessage,
    lastUpdatedAt,
  ];
}

const Object _rsApiNoValue = Object();
