import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../domain/entities/hospital_data_item.dart';
import '../../domain/entities/patient_feature.dart';

class DummyData {
  const DummyData._();

  static List<PatientFeature> get patientFeatures => <PatientFeature>[
    const PatientFeature(
      id: 'profil_pasien',
      title: 'Profil Pasien',
      description: 'Identitas pasien dan data keluarga terdaftar.',
      category: FeatureCategory.dataRekamMedis,
      icon: FontAwesomeIcons.idCardClip,
      dummyDetails: <String>[
        'Nama: Rani Putri',
        'No. RM: RM-102938',
        'Keluarga terdaftar: 2 orang',
      ],
    ),
    const PatientFeature(
      id: 'riwayat_penyakit',
      title: 'Riwayat Penyakit',
      description: 'Riwayat diagnosis dan tindakan sebelumnya.',
      category: FeatureCategory.dataRekamMedis,
      icon: FontAwesomeIcons.notesMedical,
      dummyDetails: <String>['Hipertensi (2023)', 'Alergi antibiotik tertentu'],
    ),
    const PatientFeature(
      id: 'hasil_lab',
      title: 'Hasil Lab',
      description: 'Laporan pemeriksaan laboratorium digital.',
      category: FeatureCategory.dataRekamMedis,
      icon: FontAwesomeIcons.vial,
      dummyDetails: <String>['HbA1c: 6.3%', 'Kolesterol total: 190 mg/dL'],
    ),
    const PatientFeature(
      id: 'hasil_radiologi',
      title: 'Hasil Radiologi',
      description: 'Ringkasan hasil foto dan radiologi.',
      category: FeatureCategory.dataRekamMedis,
      icon: FontAwesomeIcons.xRay,
      dummyDetails: <String>[
        'X-Ray Thorax: Normal',
        'USG Abdomen: Tidak ada kelainan bermakna',
      ],
    ),
    const PatientFeature(
      id: 'riwayat_kunjungan',
      title: 'Riwayat Kunjungan',
      description: 'Catatan kunjungan rawat jalan dan inap.',
      category: FeatureCategory.dataRekamMedis,
      icon: FontAwesomeIcons.clockRotateLeft,
      dummyDetails: <String>[
        '09 Mar 2026 - Poli Penyakit Dalam',
        '13 Feb 2026 - MCU Tahunan',
      ],
    ),
    const PatientFeature(
      id: 'booking_dokter',
      title: 'Booking Dokter',
      description: 'Pendaftaran online untuk kunjungan poli.',
      category: FeatureCategory.bookingAntrian,
      icon: FontAwesomeIcons.calendarCheck,
      dummyDetails: <String>[
        'Dr. Andi Prasetyo - Senin, 09:00',
        'Status: Menunggu konfirmasi',
      ],
    ),
    const PatientFeature(
      id: 'poli_jadwal',
      title: 'Pilih Poli & Jadwal',
      description: 'Pilih spesialisasi dan jam praktik dokter.',
      category: FeatureCategory.bookingAntrian,
      icon: FontAwesomeIcons.userDoctor,
      dummyDetails: <String>[
        'Poli Jantung - Tersedia 6 slot',
        'Poli Anak - Tersedia 4 slot',
      ],
    ),
    const PatientFeature(
      id: 'nomor_antrian',
      title: 'Nomor Antrian Digital',
      description: 'Pantau nomor antrian secara real-time.',
      category: FeatureCategory.bookingAntrian,
      icon: FontAwesomeIcons.ticket,
      dummyDetails: <String>['Antrian saat ini: A-018', 'Antrian Anda: A-024'],
    ),
    const PatientFeature(
      id: 'riwayat_booking',
      title: 'Riwayat Booking',
      description: 'Daftar booking sebelumnya.',
      category: FeatureCategory.bookingAntrian,
      icon: FontAwesomeIcons.clipboardList,
      dummyDetails: <String>['08 Mar 2026 - Selesai', '22 Feb 2026 - Selesai'],
    ),
    const PatientFeature(
      id: 'pembayaran_layanan',
      title: 'Pembayaran Layanan',
      description: 'Transfer, e-wallet, BPJS, dan asuransi.',
      category: FeatureCategory.pembayaranTransaksi,
      icon: FontAwesomeIcons.wallet,
      dummyDetails: <String>[
        'Tagihan aktif: Rp435.000',
        'Metode default: Virtual Account',
      ],
    ),
    const PatientFeature(
      id: 'riwayat_transaksi',
      title: 'Riwayat Transaksi',
      description: 'Ringkasan pembayaran dan invoice pasien.',
      category: FeatureCategory.pembayaranTransaksi,
      icon: FontAwesomeIcons.receipt,
      dummyDetails: <String>['INV-39201 - Lunas', 'INV-39155 - Lunas'],
    ),
    const PatientFeature(
      id: 'tagihan_pasien',
      title: 'Tagihan Pasien',
      description: 'Monitoring tagihan rawat jalan/inap.',
      category: FeatureCategory.pembayaranTransaksi,
      icon: FontAwesomeIcons.fileInvoiceDollar,
      dummyDetails: <String>[
        'Tagihan rawat jalan: Rp220.000',
        'Tagihan farmasi: Rp215.000',
      ],
    ),
    const PatientFeature(
      id: 'klaim_bpjs',
      title: 'Klaim BPJS / Asuransi',
      description: 'Status pengajuan klaim jaminan.',
      category: FeatureCategory.pembayaranTransaksi,
      icon: FontAwesomeIcons.shieldHeart,
      dummyDetails: <String>[
        'BPJS Kelas 2 - Aktif',
        'Klaim terakhir: Diproses',
      ],
    ),
    const PatientFeature(
      id: 'e_resep',
      title: 'E-Resep Dokter',
      description: 'Daftar resep digital dari dokter.',
      category: FeatureCategory.resepObat,
      icon: FontAwesomeIcons.prescriptionBottleMedical,
      dummyDetails: <String>['Amlodipine 5mg - 1x1', 'Vitamin D - 1x1'],
    ),
    const PatientFeature(
      id: 'pembelian_obat',
      title: 'Pembelian Obat',
      description: 'Pesan obat dari resep atau pembelian mandiri.',
      category: FeatureCategory.resepObat,
      icon: FontAwesomeIcons.cartShopping,
      dummyDetails: <String>[
        'Total pesanan: 2 item',
        'Estimasi kirim: 45 menit',
      ],
    ),
    const PatientFeature(
      id: 'riwayat_obat',
      title: 'Riwayat Obat',
      description: 'Riwayat tebus resep dan pembelian.',
      category: FeatureCategory.resepObat,
      icon: FontAwesomeIcons.pills,
      dummyDetails: <String>['Jan 2026 - Antihipertensi', 'Feb 2026 - Vitamin'],
    ),
    const PatientFeature(
      id: 'tracking_obat',
      title: 'Tracking Pengiriman Obat',
      description: 'Lacak pengantaran obat ke alamat pasien.',
      category: FeatureCategory.resepObat,
      icon: FontAwesomeIcons.truckFast,
      dummyDetails: <String>['Kurir: OTW ke lokasi', 'Estimasi tiba: 18 menit'],
    ),
    const PatientFeature(
      id: 'chat_dokter',
      title: 'Chat dengan Dokter',
      description: 'Konsultasi teks untuk pertanyaan kesehatan.',
      category: FeatureCategory.konsultasiMedis,
      icon: FontAwesomeIcons.comments,
      dummyDetails: <String>[
        'Dr. Citra - Online',
        'Balasan terakhir: 2 menit lalu',
      ],
    ),
    const PatientFeature(
      id: 'video_call_dokter',
      title: 'Video Call Dokter',
      description: 'Konsultasi video tanpa datang ke RS.',
      category: FeatureCategory.konsultasiMedis,
      icon: FontAwesomeIcons.video,
      dummyDetails: <String>[
        'Slot tersedia: 3 sesi hari ini',
        'Durasi per sesi: 15 menit',
      ],
    ),
    const PatientFeature(
      id: 'riwayat_konsultasi',
      title: 'Riwayat Konsultasi',
      description: 'Catatan konsultasi chat dan video.',
      category: FeatureCategory.konsultasiMedis,
      icon: FontAwesomeIcons.clockRotateLeft,
      dummyDetails: <String>[
        '10 Mar 2026 - Chat selesai',
        '03 Mar 2026 - Video call selesai',
      ],
    ),
    const PatientFeature(
      id: 'rating_review_dokter',
      title: 'Rating & Review Dokter',
      description: 'Beri ulasan pelayanan dokter setelah konsultasi.',
      category: FeatureCategory.konsultasiMedis,
      icon: FontAwesomeIcons.starHalfStroke,
      dummyDetails: <String>[
        'Dr. Citra: 4.8/5',
        'Review terakhir dikirim 2 hari lalu',
      ],
    ),
    const PatientFeature(
      id: 'reminder_kontrol',
      title: 'Reminder Kontrol',
      description: 'Pengingat jadwal kontrol selanjutnya.',
      category: FeatureCategory.notifikasiPersonal,
      icon: FontAwesomeIcons.bell,
      dummyDetails: <String>[
        'Kontrol Jantung - 14 Apr 2026',
        'Notifikasi H-1 aktif',
      ],
    ),
    const PatientFeature(
      id: 'pengingat_obat',
      title: 'Pengingat Minum Obat',
      description: 'Alarm minum obat harian.',
      category: FeatureCategory.notifikasiPersonal,
      icon: FontAwesomeIcons.clock,
      dummyDetails: <String>[
        'Pagi 07:00 - Amlodipine',
        'Malam 20:00 - Vitamin D',
      ],
    ),
    const PatientFeature(
      id: 'notifikasi_lab',
      title: 'Notifikasi Hasil Lab',
      description: 'Info otomatis saat hasil lab terbit.',
      category: FeatureCategory.notifikasiPersonal,
      icon: FontAwesomeIcons.flask,
      dummyDetails: <String>['Hasil Hematologi siap diunduh'],
    ),
    const PatientFeature(
      id: 'profil_rs',
      title: 'Profil RS',
      description: 'Informasi umum rumah sakit.',
      category: FeatureCategory.informasiRumahSakit,
      icon: FontAwesomeIcons.hospital,
      dummyDetails: <String>[
        'RSUD Oto Iskandar Di Nata Kabupaten Bandung',
        'Layanan publik terpadu dengan dukungan kanal digital pasien',
      ],
    ),
    const PatientFeature(
      id: 'fasilitas_rs',
      title: 'Fasilitas RS',
      description: 'Daftar fasilitas layanan dan penunjang.',
      category: FeatureCategory.informasiRumahSakit,
      icon: FontAwesomeIcons.stethoscope,
      dummyDetails: <String>[
        'IGD 24 Jam, rawat jalan, rawat inap, laboratorium, radiologi',
        'Layanan penunjang dan informasi pasien terintegrasi',
      ],
    ),
    const PatientFeature(
      id: 'lokasi_peta',
      title: 'Lokasi & Peta',
      description: 'Navigasi ke lokasi rumah sakit.',
      category: FeatureCategory.informasiRumahSakit,
      icon: FontAwesomeIcons.locationDot,
      dummyDetails: <String>[
        'Jl. Gading Tutuka, RT 01 RW 01, Kp. Cincin Kolot, Kec. Soreang',
        'Kabupaten Bandung, Jawa Barat',
      ],
    ),
    const PatientFeature(
      id: 'ketersediaan_kamar',
      title: 'Cek Ketersediaan Kamar',
      description: 'Pantau kapasitas kamar rawat inap.',
      category: FeatureCategory.informasiRumahSakit,
      icon: FontAwesomeIcons.bedPulse,
      dummyDetails: <String>[
        'Informasi ketersediaan kamar ditampilkan real-time di aplikasi',
        'Cek kategori kamar sebelum kunjungan rawat inap',
      ],
    ),
    const PatientFeature(
      id: 'daftar_dokter',
      title: 'Daftar Dokter',
      description: 'Lihat dokter aktif berdasarkan poli.',
      category: FeatureCategory.informasiDokter,
      icon: FontAwesomeIcons.userDoctor,
      dummyDetails: <String>[
        'Dokter aktif ditampilkan berdasarkan poli dan jadwal praktik',
        'Informasi diperbarui mengikuti jadwal layanan RS',
      ],
    ),
    const PatientFeature(
      id: 'spesialisasi',
      title: 'Spesialisasi Dokter',
      description: 'Cari dokter sesuai kebutuhan medis.',
      category: FeatureCategory.informasiDokter,
      icon: FontAwesomeIcons.userNurse,
      dummyDetails: <String>[
        'Penyakit Dalam, Anak, Obgyn, Bedah, Saraf, dan lainnya',
      ],
    ),
    const PatientFeature(
      id: 'jadwal_praktik',
      title: 'Jadwal Praktik',
      description: 'Jadwal praktik dokter terkini.',
      category: FeatureCategory.informasiDokter,
      icon: FontAwesomeIcons.calendarDays,
      dummyDetails: <String>[
        'Jadwal praktik dokter ditampilkan per hari dan per poli',
      ],
    ),
    const PatientFeature(
      id: 'tarif_layanan',
      title: 'Tarif Layanan',
      description: 'Informasi biaya layanan utama.',
      category: FeatureCategory.informasiBiaya,
      icon: FontAwesomeIcons.moneyBill,
      dummyDetails: <String>[
        'Ringkasan biaya layanan utama tersedia untuk referensi pasien',
      ],
    ),
    const PatientFeature(
      id: 'estimasi_biaya',
      title: 'Estimasi Biaya',
      description: 'Perkiraan biaya tindakan tertentu.',
      category: FeatureCategory.informasiBiaya,
      icon: FontAwesomeIcons.calculator,
      dummyDetails: <String>[
        'Estimasi biaya tindakan membantu persiapan sebelum pelayanan',
      ],
    ),
    const PatientFeature(
      id: 'artikel_kesehatan',
      title: 'Artikel Kesehatan',
      description: 'Edukasi kesehatan terpercaya.',
      category: FeatureCategory.edukasiKesehatan,
      icon: FontAwesomeIcons.newspaper,
      dummyDetails: <String>['Tips menjaga tekanan darah stabil'],
    ),
    const PatientFeature(
      id: 'tips_medis',
      title: 'Tips Medis',
      description: 'Tips praktis gaya hidup sehat.',
      category: FeatureCategory.edukasiKesehatan,
      icon: FontAwesomeIcons.lightbulb,
      dummyDetails: <String>['Aktivitas fisik ringan 30 menit/hari'],
    ),
    const PatientFeature(
      id: 'info_penyakit',
      title: 'Informasi Penyakit',
      description: 'Ringkasan gejala, pencegahan, dan terapi.',
      category: FeatureCategory.edukasiKesehatan,
      icon: FontAwesomeIcons.bookMedical,
      dummyDetails: <String>['Edukasi diabetes tipe 2'],
    ),
    const PatientFeature(
      id: 'call_center',
      title: 'Call Center',
      description: 'Layanan bantuan pasien 24 jam.',
      category: FeatureCategory.kontakDarurat,
      icon: FontAwesomeIcons.headset,
      dummyDetails: <String>[
        'Kontak dan kanal informasi resmi tersedia pada website RS',
      ],
    ),
    const PatientFeature(
      id: 'emergency_button',
      title: 'Emergency Button',
      description: 'Tombol cepat kondisi darurat.',
      category: FeatureCategory.kontakDarurat,
      icon: FontAwesomeIcons.triangleExclamation,
      dummyDetails: <String>[
        'Gunakan saat membutuhkan petunjuk cepat menuju layanan darurat',
      ],
    ),
    const PatientFeature(
      id: 'info_ambulans',
      title: 'Informasi Ambulans',
      description: 'Informasi armada dan cakupan area.',
      category: FeatureCategory.kontakDarurat,
      icon: FontAwesomeIcons.truckMedical,
      dummyDetails: <String>[
        'Informasi ambulans dan dukungan gawat darurat mengikuti operasional RS',
      ],
    ),
  ];

  static List<HospitalDataItem>
  get hospitalDataItems => const <HospitalDataItem>[
    HospitalDataItem(
      id: 'nama_rs',
      icon: FontAwesomeIcons.hospital,
      title: 'Nama Rumah Sakit',
      value: 'RSUD Oto Iskandar Di Nata Kabupaten Bandung',
      description:
          'Rumah sakit daerah dengan layanan pasien yang terus berkembang dan terintegrasi digital.',
      keywords: <String>['nama', 'rsud', 'otista', 'rumah sakit'],
    ),
    HospitalDataItem(
      id: 'alamat_rs',
      icon: FontAwesomeIcons.locationDot,
      title: 'Alamat',
      value: 'Jl. Gading Tutuka, RT 01 RW 01, Kp. Cincin Kolot, Kec. Soreang',
      description: 'Kabupaten Bandung, Jawa Barat.',
      keywords: <String>['alamat', 'lokasi', 'soreang', 'bandung'],
    ),
    HospitalDataItem(
      id: 'website_rs',
      icon: FontAwesomeIcons.globe,
      title: 'Website Resmi',
      value: 'rsudotista.bandungkab.go.id',
      description:
          'Akses informasi layanan, pengumuman, dan pembaruan resmi rumah sakit.',
      keywords: <String>['website', 'web', 'resmi', 'informasi'],
    ),
    HospitalDataItem(
      id: 'email_rs',
      icon: FontAwesomeIcons.envelope,
      title: 'Email',
      value: 'rsudotista@bandungkab.go.id',
      description:
          'Kanal komunikasi resmi untuk kebutuhan informasi dan korespondensi.',
      keywords: <String>['email', 'kontak', 'surat', 'informasi'],
    ),
    HospitalDataItem(
      id: 'visi_misi',
      icon: FontAwesomeIcons.bullseye,
      title: 'Visi Misi',
      value: 'Amanah, Maju, Mandiri, Berdaya Saing',
      description:
          'Mewujudkan rumah sakit yang amanah, maju, mandiri, dan berdaya saing.',
      keywords: <String>['visi', 'misi', 'arah', 'tujuan'],
    ),
  ];
}
