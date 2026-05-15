import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/domain/entities/hospital_data_item.dart';
import '../../../../shared/domain/entities/patient_feature.dart';
import '../../domain/repositories/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required HomeRepository homeRepository})
    : _homeRepository = homeRepository,
      super(
        const HomeState(
          isLoading: true,
          searchQuery: '',
          featureItems: <PatientFeature>[],
          hospitalDataItems: <HospitalDataItem>[],
        ),
      );

  final HomeRepository _homeRepository;

  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final List<dynamic> results =
          await Future.wait<dynamic>(<Future<dynamic>>[
            _homeRepository.fetchPatientFeatures(),
            _homeRepository.fetchHospitalDataItems(),
          ]);

      emit(
        state.copyWith(
          isLoading: false,
          featureItems: results[0] as List<PatientFeature>,
          hospitalDataItems: results[1] as List<HospitalDataItem>,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Data gagal dimuat. Coba lagi.',
        ),
      );
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
