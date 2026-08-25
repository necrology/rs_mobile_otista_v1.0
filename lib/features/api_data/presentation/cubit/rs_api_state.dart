part of 'rs_api_cubit.dart';

class RsApiState extends Equatable {
  const RsApiState({
    this.isLoadingPatients = false,
    this.isLoadingPatientDetail = false,
    this.isLoadingEmployees = false,
    this.isLoadingDoctorSchedules = false,
    this.isLoadingTable = false,
    this.isLoadingPolyclinics = false,
    this.isLoadingRooms = false,
    this.isLoadingRoomAvailabilities = false,
    this.isLoadingQueueRegistrations = false,
    this.isLoadingLocalQueues = false,
    this.isLoadingPatientVisits = false,
    this.isLoadingPatientMedicalSummaries = false,
    this.isLoadingPatientLabResults = false,
    this.isLoadingPatientRadiologyResults = false,
    this.isLoadingPatientPrescriptions = false,
    this.isLoadingGeneralBookings = false,
    this.isLoadingMyGeneralBookings = false,
    this.isCreatingGeneralBooking = false,
    this.isLoadingBookingOptions = false,
    this.isLoadingBookingCalendar = false,
    this.lastPatientQuery = 'ahmad',
    this.lastPatientId = '1',
    this.lastEmployeeSearch = 'dokter',
    this.lastDoctorScheduleSearch = '',
    this.lastPolyclinicSearch = '',
    this.lastRoomSearch = '',
    this.patients,
    this.compactPatients,
    this.selectedPatient,
    this.employees,
    this.doctorSchedules,
    this.patientTableMetadata,
    this.polyclinics,
    this.rooms,
    this.roomAvailabilities,
    this.queueRegistrations,
    this.localQueues,
    this.patientVisits,
    this.patientMedicalSummaries,
    this.patientLabResults,
    this.patientRadiologyResults,
    this.patientPrescriptions,
    this.generalBookings,
    this.myGeneralBookings,
    this.lastCreatedBooking,
    this.bookingOptions,
    this.bookingCalendar,
    this.errorMessage,
    this.lastUpdatedAt,
  });

  final bool isLoadingPatients;
  final bool isLoadingPatientDetail;
  final bool isLoadingEmployees;
  final bool isLoadingDoctorSchedules;
  final bool isLoadingTable;
  final bool isLoadingPolyclinics;
  final bool isLoadingRooms;
  final bool isLoadingRoomAvailabilities;
  final bool isLoadingQueueRegistrations;
  final bool isLoadingLocalQueues;
  final bool isLoadingPatientVisits;
  final bool isLoadingPatientMedicalSummaries;
  final bool isLoadingPatientLabResults;
  final bool isLoadingPatientRadiologyResults;
  final bool isLoadingPatientPrescriptions;
  final bool isLoadingGeneralBookings;
  final bool isLoadingMyGeneralBookings;
  final bool isCreatingGeneralBooking;
  final bool isLoadingBookingOptions;
  final bool isLoadingBookingCalendar;
  final String lastPatientQuery;
  final String lastPatientId;
  final String lastEmployeeSearch;
  final String lastDoctorScheduleSearch;
  final String lastPolyclinicSearch;
  final String lastRoomSearch;
  final ApiCollection<PatientRecord>? patients;
  final ApiCollection<PatientRecord>? compactPatients;
  final PatientRecord? selectedPatient;
  final ApiCollection<EmployeeRecord>? employees;
  final ApiCollection<ResourceRecord>? doctorSchedules;
  final TableMetadata? patientTableMetadata;
  final ApiCollection<ResourceRecord>? polyclinics;
  final ApiCollection<ResourceRecord>? rooms;
  final ApiCollection<ResourceRecord>? roomAvailabilities;
  final ApiCollection<QueueRegistrationRecord>? queueRegistrations;
  final ApiCollection<LocalQueueRecord>? localQueues;
  final ApiCollection<PatientVisitRecord>? patientVisits;
  final ApiCollection<PatientMedicalSummaryRecord>? patientMedicalSummaries;
  final ApiCollection<PatientLabResultRecord>? patientLabResults;
  final ApiCollection<PatientRadiologyResultRecord>? patientRadiologyResults;
  final ApiCollection<PatientPrescriptionRecord>? patientPrescriptions;
  final ApiCollection<GeneralBookingRecord>? generalBookings;
  final ApiCollection<GeneralBookingRecord>? myGeneralBookings;
  final BookingQueueResponse? lastCreatedBooking;
  final BookingOptionsResponse? bookingOptions;
  final BookingCalendarResponse? bookingCalendar;
  final String? errorMessage;
  final DateTime? lastUpdatedAt;

  bool get isBusy =>
      isLoadingPatients ||
      isLoadingPatientDetail ||
      isLoadingEmployees ||
      isLoadingDoctorSchedules ||
      isLoadingTable ||
      isLoadingPolyclinics ||
      isLoadingRooms ||
      isLoadingRoomAvailabilities ||
      isLoadingQueueRegistrations ||
      isLoadingLocalQueues ||
      isLoadingPatientVisits ||
      isLoadingPatientMedicalSummaries ||
      isLoadingPatientLabResults ||
      isLoadingPatientRadiologyResults ||
      isLoadingPatientPrescriptions ||
      isLoadingGeneralBookings ||
      isLoadingMyGeneralBookings ||
      isCreatingGeneralBooking ||
      isLoadingBookingOptions ||
      isLoadingBookingCalendar;

  bool get hasData =>
      patients != null ||
      compactPatients != null ||
      selectedPatient != null ||
      employees != null ||
      doctorSchedules != null ||
      patientTableMetadata != null ||
      polyclinics != null ||
      rooms != null ||
      roomAvailabilities != null ||
      queueRegistrations != null ||
      localQueues != null ||
      patientVisits != null ||
      patientMedicalSummaries != null ||
      patientLabResults != null ||
      patientRadiologyResults != null ||
      patientPrescriptions != null ||
      generalBookings != null ||
      myGeneralBookings != null ||
      lastCreatedBooking != null ||
      bookingOptions != null ||
      bookingCalendar != null;

  RsApiState copyWith({
    bool? isLoadingPatients,
    bool? isLoadingPatientDetail,
    bool? isLoadingEmployees,
    bool? isLoadingDoctorSchedules,
    bool? isLoadingTable,
    bool? isLoadingPolyclinics,
    bool? isLoadingRooms,
    bool? isLoadingRoomAvailabilities,
    bool? isLoadingQueueRegistrations,
    bool? isLoadingLocalQueues,
    bool? isLoadingPatientVisits,
    bool? isLoadingPatientMedicalSummaries,
    bool? isLoadingPatientLabResults,
    bool? isLoadingPatientRadiologyResults,
    bool? isLoadingPatientPrescriptions,
    bool? isLoadingGeneralBookings,
    bool? isLoadingMyGeneralBookings,
    bool? isCreatingGeneralBooking,
    bool? isLoadingBookingOptions,
    bool? isLoadingBookingCalendar,
    String? lastPatientQuery,
    String? lastPatientId,
    String? lastEmployeeSearch,
    String? lastDoctorScheduleSearch,
    String? lastPolyclinicSearch,
    String? lastRoomSearch,
    Object? patients = _rsApiNoValue,
    Object? compactPatients = _rsApiNoValue,
    Object? selectedPatient = _rsApiNoValue,
    Object? employees = _rsApiNoValue,
    Object? doctorSchedules = _rsApiNoValue,
    Object? patientTableMetadata = _rsApiNoValue,
    Object? polyclinics = _rsApiNoValue,
    Object? rooms = _rsApiNoValue,
    Object? roomAvailabilities = _rsApiNoValue,
    Object? queueRegistrations = _rsApiNoValue,
    Object? localQueues = _rsApiNoValue,
    Object? patientVisits = _rsApiNoValue,
    Object? patientMedicalSummaries = _rsApiNoValue,
    Object? patientLabResults = _rsApiNoValue,
    Object? patientRadiologyResults = _rsApiNoValue,
    Object? patientPrescriptions = _rsApiNoValue,
    Object? generalBookings = _rsApiNoValue,
    Object? myGeneralBookings = _rsApiNoValue,
    Object? lastCreatedBooking = _rsApiNoValue,
    Object? bookingOptions = _rsApiNoValue,
    Object? bookingCalendar = _rsApiNoValue,
    Object? errorMessage = _rsApiNoValue,
    Object? lastUpdatedAt = _rsApiNoValue,
  }) {
    return RsApiState(
      isLoadingPatients: isLoadingPatients ?? this.isLoadingPatients,
      isLoadingPatientDetail:
          isLoadingPatientDetail ?? this.isLoadingPatientDetail,
      isLoadingEmployees: isLoadingEmployees ?? this.isLoadingEmployees,
      isLoadingDoctorSchedules:
          isLoadingDoctorSchedules ?? this.isLoadingDoctorSchedules,
      isLoadingTable: isLoadingTable ?? this.isLoadingTable,
      isLoadingPolyclinics: isLoadingPolyclinics ?? this.isLoadingPolyclinics,
      isLoadingRooms: isLoadingRooms ?? this.isLoadingRooms,
      isLoadingRoomAvailabilities:
          isLoadingRoomAvailabilities ?? this.isLoadingRoomAvailabilities,
      isLoadingQueueRegistrations:
          isLoadingQueueRegistrations ?? this.isLoadingQueueRegistrations,
      isLoadingLocalQueues: isLoadingLocalQueues ?? this.isLoadingLocalQueues,
      isLoadingPatientVisits:
          isLoadingPatientVisits ?? this.isLoadingPatientVisits,
      isLoadingPatientMedicalSummaries:
          isLoadingPatientMedicalSummaries ??
          this.isLoadingPatientMedicalSummaries,
      isLoadingPatientLabResults:
          isLoadingPatientLabResults ?? this.isLoadingPatientLabResults,
      isLoadingPatientRadiologyResults:
          isLoadingPatientRadiologyResults ??
          this.isLoadingPatientRadiologyResults,
      isLoadingPatientPrescriptions:
          isLoadingPatientPrescriptions ?? this.isLoadingPatientPrescriptions,
      isLoadingGeneralBookings:
          isLoadingGeneralBookings ?? this.isLoadingGeneralBookings,
      isLoadingMyGeneralBookings:
          isLoadingMyGeneralBookings ?? this.isLoadingMyGeneralBookings,
      isCreatingGeneralBooking:
          isCreatingGeneralBooking ?? this.isCreatingGeneralBooking,
      isLoadingBookingOptions:
          isLoadingBookingOptions ?? this.isLoadingBookingOptions,
      isLoadingBookingCalendar:
          isLoadingBookingCalendar ?? this.isLoadingBookingCalendar,
      lastPatientQuery: lastPatientQuery ?? this.lastPatientQuery,
      lastPatientId: lastPatientId ?? this.lastPatientId,
      lastEmployeeSearch: lastEmployeeSearch ?? this.lastEmployeeSearch,
      lastDoctorScheduleSearch:
          lastDoctorScheduleSearch ?? this.lastDoctorScheduleSearch,
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
      doctorSchedules: doctorSchedules == _rsApiNoValue
          ? this.doctorSchedules
          : doctorSchedules as ApiCollection<ResourceRecord>?,
      patientTableMetadata: patientTableMetadata == _rsApiNoValue
          ? this.patientTableMetadata
          : patientTableMetadata as TableMetadata?,
      polyclinics: polyclinics == _rsApiNoValue
          ? this.polyclinics
          : polyclinics as ApiCollection<ResourceRecord>?,
      rooms: rooms == _rsApiNoValue
          ? this.rooms
          : rooms as ApiCollection<ResourceRecord>?,
      roomAvailabilities: roomAvailabilities == _rsApiNoValue
          ? this.roomAvailabilities
          : roomAvailabilities as ApiCollection<ResourceRecord>?,
      queueRegistrations: queueRegistrations == _rsApiNoValue
          ? this.queueRegistrations
          : queueRegistrations as ApiCollection<QueueRegistrationRecord>?,
      localQueues: localQueues == _rsApiNoValue
          ? this.localQueues
          : localQueues as ApiCollection<LocalQueueRecord>?,
      patientVisits: patientVisits == _rsApiNoValue
          ? this.patientVisits
          : patientVisits as ApiCollection<PatientVisitRecord>?,
      patientMedicalSummaries: patientMedicalSummaries == _rsApiNoValue
          ? this.patientMedicalSummaries
          : patientMedicalSummaries
                as ApiCollection<PatientMedicalSummaryRecord>?,
      patientLabResults: patientLabResults == _rsApiNoValue
          ? this.patientLabResults
          : patientLabResults as ApiCollection<PatientLabResultRecord>?,
      patientRadiologyResults: patientRadiologyResults == _rsApiNoValue
          ? this.patientRadiologyResults
          : patientRadiologyResults
                as ApiCollection<PatientRadiologyResultRecord>?,
      patientPrescriptions: patientPrescriptions == _rsApiNoValue
          ? this.patientPrescriptions
          : patientPrescriptions as ApiCollection<PatientPrescriptionRecord>?,
      generalBookings: generalBookings == _rsApiNoValue
          ? this.generalBookings
          : generalBookings as ApiCollection<GeneralBookingRecord>?,
      myGeneralBookings: myGeneralBookings == _rsApiNoValue
          ? this.myGeneralBookings
          : myGeneralBookings as ApiCollection<GeneralBookingRecord>?,
      lastCreatedBooking: lastCreatedBooking == _rsApiNoValue
          ? this.lastCreatedBooking
          : lastCreatedBooking as BookingQueueResponse?,
      bookingOptions: bookingOptions == _rsApiNoValue
          ? this.bookingOptions
          : bookingOptions as BookingOptionsResponse?,
      bookingCalendar: bookingCalendar == _rsApiNoValue
          ? this.bookingCalendar
          : bookingCalendar as BookingCalendarResponse?,
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
    isLoadingDoctorSchedules,
    isLoadingTable,
    isLoadingPolyclinics,
    isLoadingRooms,
    isLoadingRoomAvailabilities,
    isLoadingQueueRegistrations,
    isLoadingLocalQueues,
    isLoadingPatientVisits,
    isLoadingPatientMedicalSummaries,
    isLoadingPatientLabResults,
    isLoadingPatientRadiologyResults,
    isLoadingPatientPrescriptions,
    isLoadingGeneralBookings,
    isLoadingMyGeneralBookings,
    isCreatingGeneralBooking,
    isLoadingBookingOptions,
    isLoadingBookingCalendar,
    lastPatientQuery,
    lastPatientId,
    lastEmployeeSearch,
    lastDoctorScheduleSearch,
    lastPolyclinicSearch,
    lastRoomSearch,
    patients,
    compactPatients,
    selectedPatient,
    employees,
    doctorSchedules,
    patientTableMetadata,
    polyclinics,
    rooms,
    roomAvailabilities,
    queueRegistrations,
    localQueues,
    patientVisits,
    patientMedicalSummaries,
    patientLabResults,
    patientRadiologyResults,
    patientPrescriptions,
    generalBookings,
    myGeneralBookings,
    lastCreatedBooking,
    bookingOptions,
    bookingCalendar,
    errorMessage,
    lastUpdatedAt,
  ];
}

const Object _rsApiNoValue = Object();
