import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

enum FeatureCategory {
  dataRekamMedis,
  bookingAntrian,
  pembayaranTransaksi,
  resepObat,
  informasiRumahSakit,
  informasiDokter,
  informasiBiaya,
  edukasiKesehatan,
}

extension FeatureCategoryExtension on FeatureCategory {
  String get title {
    switch (this) {
      case FeatureCategory.dataRekamMedis:
        return 'Data & Rekam Medis';
      case FeatureCategory.bookingAntrian:
        return 'Pendaftaran & Antrian';
      case FeatureCategory.pembayaranTransaksi:
        return 'Tagihan & Pembayaran';
      case FeatureCategory.resepObat:
        return 'Resep & Obat';
      case FeatureCategory.informasiRumahSakit:
        return 'Informasi Rumah Sakit';
      case FeatureCategory.informasiDokter:
        return 'Informasi Dokter';
      case FeatureCategory.informasiBiaya:
        return 'Informasi Biaya';
      case FeatureCategory.edukasiKesehatan:
        return 'Edukasi Kesehatan';
    }
  }

  bool get requiresLogin {
    switch (this) {
      case FeatureCategory.dataRekamMedis:
      case FeatureCategory.bookingAntrian:
      case FeatureCategory.pembayaranTransaksi:
      case FeatureCategory.resepObat:
        return true;
      case FeatureCategory.informasiRumahSakit:
      case FeatureCategory.informasiDokter:
      case FeatureCategory.informasiBiaya:
      case FeatureCategory.edukasiKesehatan:
        return false;
    }
  }
}

class PatientFeature extends Equatable {
  const PatientFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.dummyDetails,
    this.links = const <PatientFeatureLink>[],
  });

  final String id;
  final String title;
  final String description;
  final FeatureCategory category;
  final IconData icon;
  final List<String> dummyDetails;
  final List<PatientFeatureLink> links;

  bool get requiresLogin => category.requiresLogin;

  bool matches(String query) {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final String linkText = links
        .map((PatientFeatureLink link) => '${link.label} ${link.value}')
        .join(' ');
    final String aggregateText =
        '$title $description ${category.title} ${dummyDetails.join(' ')} $linkText'
            .toLowerCase();
    return aggregateText.contains(normalizedQuery);
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    description,
    category,
    icon,
    dummyDetails,
    links,
  ];
}

enum PatientFeatureLinkType { maps, email, phone, website }

class PatientFeatureLink extends Equatable {
  const PatientFeatureLink({
    required this.label,
    required this.value,
    required this.type,
  });

  final String label;
  final String value;
  final PatientFeatureLinkType type;

  @override
  List<Object?> get props => <Object?>[label, value, type];
}
