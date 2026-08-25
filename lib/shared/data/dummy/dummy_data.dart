import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/constants/app_branding.dart';
import '../../domain/entities/patient_feature.dart';

class DummyData {
  const DummyData._();

  static List<PatientFeature> get patientFeatures => <PatientFeature>[
    const PatientFeature(
      id: 'profil_pasien',
      title: 'Profil Pasien',
      description: 'Identitas pasien dari rekam medis rumah sakit.',
      category: FeatureCategory.dataRekamMedis,
      icon: FontAwesomeIcons.idCardClip,
      dummyDetails: <String>[
        'Data pasien mengikuti identitas pada sistem rekam medis.',
        'Akun mobile terhubung ke pasien melalui No. RM yang sudah diverifikasi.',
      ],
    ),
    const PatientFeature(
      id: 'riwayat_kunjungan',
      title: 'Riwayat Kunjungan',
      description: 'Catatan kunjungan rawat jalan, IGD, dan rawat inap.',
      category: FeatureCategory.dataRekamMedis,
      icon: FontAwesomeIcons.clockRotateLeft,
      dummyDetails: <String>[
        'Riwayat ditampilkan berdasarkan data registrasi pasien.',
        'Akses riwayat mengikuti pasien yang sudah terikat ke akun mobile.',
      ],
    ),
    const PatientFeature(
      id: 'riwayat_penyakit',
      title: 'Diagnosis & Tindakan',
      description: 'Ringkasan diagnosis, ICD, dan tindakan pasien.',
      category: FeatureCategory.dataRekamMedis,
      icon: FontAwesomeIcons.notesMedical,
      dummyDetails: <String>[
        'Diagnosis mengikuti resume pasien yang terhubung ke registrasi.',
        'Tindakan ditampilkan dari ringkasan pelayanan yang sudah tercatat.',
      ],
    ),
    const PatientFeature(
      id: 'hasil_lab',
      title: 'Hasil Lab',
      description: 'Hasil pemeriksaan laboratorium dan rincian nilainya.',
      category: FeatureCategory.dataRekamMedis,
      icon: FontAwesomeIcons.vial,
      dummyDetails: <String>[
        'Data mengikuti relasi order_lab, hasillabs, rincian_hasillabs, dan master pemeriksaan laboratorium.',
        'Hasil hanya dibuka untuk akun yang No. RM-nya sudah terverifikasi.',
      ],
    ),
    const PatientFeature(
      id: 'hasil_radiologi',
      title: 'Hasil Radiologi',
      description: 'Hasil pemeriksaan, resume, dan ekspertise radiologi.',
      category: FeatureCategory.dataRekamMedis,
      icon: FontAwesomeIcons.xRay,
      dummyDetails: <String>[
        'Data mengikuti relasi order_radiologi, hasilradiologis, detailradiologis, dan radiologi_ekspertises.',
        'Akses hasil dibatasi untuk pasien yang terhubung ke akun mobile.',
      ],
    ),
    const PatientFeature(
      id: 'resep_obat',
      title: 'Resep & Obat',
      description: 'Riwayat resep farmasi dan rincian obat pasien.',
      category: FeatureCategory.resepObat,
      icon: FontAwesomeIcons.pills,
      dummyDetails: <String>[
        'Data mengikuti relasi penjualans, penjualandetails, masterobats, registrasis, dan pasiens.',
        'Resep hanya ditampilkan untuk akun yang No. RM-nya sudah terverifikasi.',
      ],
    ),
    const PatientFeature(
      id: 'booking_dokter',
      title: 'Pendaftaran Poli',
      description: 'Registrasi umum pasien untuk kunjungan poli.',
      category: FeatureCategory.bookingAntrian,
      icon: FontAwesomeIcons.calendarCheck,
      dummyDetails: <String>[
        'Pendaftaran memakai jalur umum mobile, bukan nomor JKN atau task id.',
        'Nomor antrian dibuat setelah data registrasi valid.',
      ],
    ),
    const PatientFeature(
      id: 'poli_jadwal',
      title: 'Poli & Jadwal',
      description: 'Lihat poli, hari praktik, jam layanan, dan kuota.',
      category: FeatureCategory.bookingAntrian,
      icon: FontAwesomeIcons.userDoctor,
      dummyDetails: <String>[
        'Data poli menampilkan kode ruangan, hari praktik, jam buka-tutup, status praktik, dan kuota.',
        'Jadwal dokter ditampilkan dari tabel jadwaldokters dan disandingkan dengan data poli.',
      ],
    ),
    const PatientFeature(
      id: 'nomor_antrian',
      title: 'Nomor Antrian',
      description: 'Pantau nomor antrian dari pendaftaran umum.',
      category: FeatureCategory.bookingAntrian,
      icon: FontAwesomeIcons.ticket,
      dummyDetails: <String>[
        'Nomor antrian mengikuti data registrasi dan antrian poli.',
        'Status antrian dibaca dari sistem antrian rumah sakit.',
      ],
    ),
    const PatientFeature(
      id: 'profil_rs',
      title: 'Profil RS',
      description: 'Informasi umum RSUD Oto Iskandar Di Nata.',
      category: FeatureCategory.informasiRumahSakit,
      icon: FontAwesomeIcons.hospital,
      dummyDetails: <String>[
        AppBranding.hospitalLongName,
        'Rumah sakit daerah di ${AppBranding.locationShort} dengan layanan IGD, rawat jalan, dan rawat inap.',
      ],
      links: <PatientFeatureLink>[
        PatientFeatureLink(
          label: 'Website Resmi',
          value: AppBranding.website,
          type: PatientFeatureLinkType.website,
        ),
        PatientFeatureLink(
          label: 'Soreang (Maps)',
          value: AppBranding.mapsUrl,
          type: PatientFeatureLinkType.maps,
        ),
      ],
    ),
    const PatientFeature(
      id: 'visi_misi_rs',
      title: 'Visi Misi RS',
      description: 'Arah layanan dan nilai utama rumah sakit.',
      category: FeatureCategory.informasiRumahSakit,
      icon: FontAwesomeIcons.bullseye,
      dummyDetails: <String>[
        AppBranding.visionMission,
        AppBranding.missionFocus,
        AppBranding.organizationCulture,
      ],
    ),
    const PatientFeature(
      id: 'jam_layanan_rs',
      title: 'Jam Layanan RS',
      description: 'Jam operasional layanan rumah sakit.',
      category: FeatureCategory.informasiRumahSakit,
      icon: FontAwesomeIcons.clock,
      dummyDetails: <String>[
        AppBranding.serviceHours,
        'Jam layanan dapat berubah mengikuti pengumuman resmi rumah sakit.',
      ],
      links: <PatientFeatureLink>[
        PatientFeatureLink(
          label: 'Website Resmi',
          value: AppBranding.website,
          type: PatientFeatureLinkType.website,
        ),
      ],
    ),
    const PatientFeature(
      id: 'alamat_rs',
      title: 'Alamat RS',
      description: 'Lokasi resmi rumah sakit.',
      category: FeatureCategory.informasiRumahSakit,
      icon: FontAwesomeIcons.locationDot,
      dummyDetails: <String>[
        AppBranding.address,
        'Lokasi layanan berada di wilayah ${AppBranding.locationShort}.',
      ],
      links: <PatientFeatureLink>[
        PatientFeatureLink(
          label: 'Soreang (Maps)',
          value: AppBranding.mapsUrl,
          type: PatientFeatureLinkType.maps,
        ),
      ],
    ),
    const PatientFeature(
      id: 'kontak_rs',
      title: 'Kontak RS',
      description: 'Kanal informasi resmi rumah sakit.',
      category: FeatureCategory.informasiRumahSakit,
      icon: FontAwesomeIcons.envelope,
      dummyDetails: <String>[
        'Website: ${AppBranding.website}',
        'Email: ${AppBranding.email}',
        'Telepon: ${AppBranding.phoneDisplay}',
        'WhatsApp: ${AppBranding.whatsappDisplay}',
      ],
      links: <PatientFeatureLink>[
        PatientFeatureLink(
          label: 'Website Resmi',
          value: AppBranding.website,
          type: PatientFeatureLinkType.website,
        ),
        PatientFeatureLink(
          label: 'Email RS',
          value: AppBranding.email,
          type: PatientFeatureLinkType.email,
        ),
        PatientFeatureLink(
          label: 'Telepon RS',
          value: AppBranding.phoneDial,
          type: PatientFeatureLinkType.phone,
        ),
        PatientFeatureLink(
          label: 'WhatsApp RS',
          value: AppBranding.whatsappUrl,
          type: PatientFeatureLinkType.website,
        ),
      ],
    ),
    const PatientFeature(
      id: 'fasilitas_rs',
      title: 'Fasilitas RS',
      description: 'Ringkasan fasilitas layanan rumah sakit.',
      category: FeatureCategory.informasiRumahSakit,
      icon: FontAwesomeIcons.stethoscope,
      dummyDetails: <String>[
        'Layanan utama mencakup IGD, Instalasi Rawat Jalan dan Khusus, serta Instalasi Rawat Inap.',
        'Sarana meliputi ruang tunggu, meja layanan, tempat ibadah, toilet, ruang laktasi, kursi roda, jalur evakuasi, CCTV, dan fasilitas pendukung lain.',
      ],
    ),
    const PatientFeature(
      id: 'ketersediaan_kamar',
      title: 'Ketersediaan Kamar',
      description: 'Pantau data kamar rawat inap yang aktif.',
      category: FeatureCategory.informasiRumahSakit,
      icon: FontAwesomeIcons.bedPulse,
      dummyDetails: <String>[
        'Data kamar mengikuti master kamar dan pengaturan ketersediaan kamar.',
        'Status kamar dapat berubah mengikuti operasional rawat inap.',
      ],
    ),
  ];
}
