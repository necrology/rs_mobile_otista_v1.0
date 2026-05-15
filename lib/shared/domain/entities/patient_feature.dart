import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

enum FeatureCategory {
  dataRekamMedis,
  bookingAntrian,
  pembayaranTransaksi,
  resepObat,
  konsultasiMedis,
  notifikasiPersonal,
  informasiRumahSakit,
  informasiDokter,
  informasiBiaya,
  edukasiKesehatan,
  kontakDarurat,
}

extension FeatureCategoryExtension on FeatureCategory {
  String get title {
    switch (this) {
      case FeatureCategory.dataRekamMedis:
        return 'Data & Rekam Medis';
      case FeatureCategory.bookingAntrian:
        return 'Booking & Antrian';
      case FeatureCategory.pembayaranTransaksi:
        return 'Pembayaran & Transaksi';
      case FeatureCategory.resepObat:
        return 'Resep & Obat';
      case FeatureCategory.konsultasiMedis:
        return 'Konsultasi Medis';
      case FeatureCategory.notifikasiPersonal:
        return 'Notifikasi Personal';
      case FeatureCategory.informasiRumahSakit:
        return 'Informasi Rumah Sakit';
      case FeatureCategory.informasiDokter:
        return 'Informasi Dokter';
      case FeatureCategory.informasiBiaya:
        return 'Informasi Biaya';
      case FeatureCategory.edukasiKesehatan:
        return 'Edukasi Kesehatan';
      case FeatureCategory.kontakDarurat:
        return 'Kontak Darurat';
    }
  }

  bool get requiresLogin {
    switch (this) {
      case FeatureCategory.dataRekamMedis:
      case FeatureCategory.bookingAntrian:
      case FeatureCategory.pembayaranTransaksi:
      case FeatureCategory.resepObat:
      case FeatureCategory.konsultasiMedis:
      case FeatureCategory.notifikasiPersonal:
        return true;
      case FeatureCategory.informasiRumahSakit:
      case FeatureCategory.informasiDokter:
      case FeatureCategory.informasiBiaya:
      case FeatureCategory.edukasiKesehatan:
      case FeatureCategory.kontakDarurat:
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
  });

  final String id;
  final String title;
  final String description;
  final FeatureCategory category;
  final IconData icon;
  final List<String> dummyDetails;

  bool get requiresLogin => category.requiresLogin;

  bool matches(String query) {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final String aggregateText =
        '$title $description ${category.title} ${dummyDetails.join(' ')}'
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
  ];
}
