part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    required this.isLoading,
    required this.searchQuery,
    required this.featureItems,
    this.errorMessage,
  });

  final bool isLoading;
  final String searchQuery;
  final List<PatientFeature> featureItems;
  final String? errorMessage;

  List<PatientFeature> get filteredFeatureItems {
    if (searchQuery.trim().isEmpty) {
      return featureItems;
    }

    return featureItems
        .where((PatientFeature feature) => feature.matches(searchQuery))
        .toList();
  }

  Map<FeatureCategory, List<PatientFeature>> get groupedFeatureItems {
    final Map<FeatureCategory, List<PatientFeature>> groupedItems =
        <FeatureCategory, List<PatientFeature>>{};

    for (final PatientFeature featureItem in filteredFeatureItems) {
      groupedItems.putIfAbsent(featureItem.category, () => <PatientFeature>[]);
      groupedItems[featureItem.category]!.add(featureItem);
    }

    return groupedItems;
  }

  HomeState copyWith({
    bool? isLoading,
    String? searchQuery,
    List<PatientFeature>? featureItems,
    Object? errorMessage = _homeNoValue,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      featureItems: featureItems ?? this.featureItems,
      errorMessage: errorMessage == _homeNoValue
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    searchQuery,
    featureItems,
    errorMessage,
  ];
}

const Object _homeNoValue = Object();
