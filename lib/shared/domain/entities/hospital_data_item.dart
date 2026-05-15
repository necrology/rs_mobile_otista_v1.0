import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class HospitalDataItem extends Equatable {
  const HospitalDataItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
    required this.keywords,
  });

  final String id;
  final IconData icon;
  final String title;
  final String value;
  final String description;
  final List<String> keywords;

  bool matches(String query) {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final String aggregateText =
        '$title $value $description ${keywords.join(' ')}'.toLowerCase();
    return aggregateText.contains(normalizedQuery);
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    icon,
    title,
    value,
    description,
    keywords,
  ];
}
