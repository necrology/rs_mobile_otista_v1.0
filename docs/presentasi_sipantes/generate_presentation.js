const fs = require('fs');
const path = require('path');
const pptxgen = require(path.join(process.env.TEMP, 'sipantes-presentation-deps', 'node_modules', 'pptxgenjs'));

const ROOT = path.resolve(__dirname, '..', '..');
const ASSET = path.join(ROOT, 'docs', 'presentation_assets');
const OUT = __dirname;

const C = {
  ink: '123B38', deep: '0B4A45', teal: '3EB3A8', teal2: '8FD8D1',
  green: '149B5A', blue: '3C6FB6', gold: 'F0A51A', red: 'D23131',
  paper: 'F6F4EE', white: 'FFFFFF', muted: '607874', line: 'D8E1DE',
  softTeal: 'E7F5F2', softBlue: 'EAF0F8', softGold: 'FFF3DD', softRed: 'FBE8E8'
};

const img = name => path.join(ASSET, name);
const logo = path.join(ROOT, 'assets', 'images', 'otista', 'rsud_full_logo_trimmed.png');
const pemkab = path.join(ROOT, 'assets', 'images', 'otista', 'pemkab_logo.jpg');

const slides = [
  {
    type: 'cover',
    kicker: 'PRESENTASI PRODUK • BUILD EMULATOR',
    title: 'SIPANTES',
    subtitle: 'Sistem Pendaftaran Terintegrasi\nRSUD Oto Iskandar Di Nata',
    summary: 'Panduan lengkap seluruh fitur aplikasi mobile',
    meta: 'Versi 1.0 • Snapshot 5 Oktober 2026',
    image: img('01_beranda.png')
  },
  {
    title: 'SIPANTES dalam satu pandangan',
    kicker: 'TUJUAN APLIKASI',
    summary: 'Satu pintu digital untuk informasi rumah sakit, identitas pasien, layanan medis personal, pendaftaran poli, dan pemantauan antrian.',
    cards: [
      ['Informasi publik', 'Poli, dokter, jadwal, kamar, profil RS, jam layanan, alamat, kontak, dan fasilitas.'],
      ['Akun pasien', 'Registrasi, login dua langkah dengan OTP, reset password, sesi tersimpan aman, dan logout.'],
      ['Data personal', 'Profil pasien, kunjungan, diagnosis/tindakan, laboratorium, radiologi, resep, serta resume PDF.'],
      ['Pendaftaran', 'Booking umum berbasis No. RM; jalur BPJS diarahkan ke Mobile JKN untuk mencegah booking ganda.']
    ],
    callout: 'Nilai utama: pengguna dapat melihat layanan publik tanpa login, lalu membuka data personal setelah akun dan No. RM terverifikasi.'
  },
  {
    title: 'Model akses: tiga tingkat',
    kicker: 'HAK AKSES & PRASYARAT',
    cards: [
      ['1 — Tamu', 'Beranda, pencarian menu, Poli & Jadwal, informasi RS, alamat/Maps, website, kontak, dan ketersediaan kamar.'],
      ['2 — Akun aktif', 'Profil akun, kebijakan privasi, logout, penghapusan akun, serta proses untuk menghubungkan No. RM.'],
      ['3 — No. RM terhubung', 'Seluruh layanan medis personal, booking umum, serta history nomor antrian untuk pasien yang aktif.']
    ],
    bullets: [
      'Fitur yang membutuhkan login menampilkan lembar “Fitur ini memerlukan login”.',
      'Fitur medis dan booking memeriksa No. RM; jika kosong, pengguna diarahkan ke “Hubungkan No. RM”.',
      'Data personal selalu dibatasi ke identitas pasien yang terkait dengan sesi akun.'
    ]
  },
  {
    title: 'Navigasi utama aplikasi',
    kicker: '5 AKSI DI BOTTOM NAVIGATION',
    cards: [
      ['Beranda', 'Pusat pintasan seluruh layanan dan kolom pencarian.'],
      ['Booking', 'Antrian Umum: tab Buat dan tab Saya.'],
      ['Antrian', 'Aksi tengah untuk memilih Registrasi Umum atau Antrian BPJS.'],
      ['Poli & Jadwal', 'Direktori publik poli, jadwal praktik, kuota, dan dokter.'],
      ['Profil', 'Status akun, No. RM, privasi, penghapusan akun, dan logout.']
    ],
    callout: 'Halaman memakai IndexedStack: posisi setiap tab tetap dipertahankan ketika pengguna berpindah menu.'
  },
  {
    title: 'Beranda & pencarian layanan',
    kicker: 'PUSAT AKSES FITUR',
    summary: 'Beranda menampilkan status akun, sapaan pengguna, tautan cepat, kolom pencarian, dan 16 pintasan layanan.',
    bullets: [
      'Tautan “Soreang (Maps)” membuka aplikasi peta; “Website Resmi” membuka situs rumah sakit.',
      'Kolom “Cari menu atau layanan pasien…” mencari judul, deskripsi, kategori, rincian, dan tautan.',
      'Tarik ke bawah untuk memuat ulang; tersedia empty state dan tombol Muat Ulang jika terjadi error.',
      'Ikon kunci digunakan ketika fitur personal dibuka oleh pengguna yang belum login.'
    ],
    image: img('01_beranda.png')
  },
  {
    title: 'Login, registrasi, dan lupa password',
    kicker: 'AUTENTIKASI BERBASIS OTP EMAIL',
    cards: [
      ['Login', 'Masukkan email atau No. RM yang sudah terhubung + password → kirim OTP → verifikasi OTP 6 digit. OTP berlaku 5 menit.'],
      ['Registrasi', 'Nama lengkap, email, telepon, dan password 8–72 karakter berisi huruf serta angka → OTP email → aktivasi akun.'],
      ['Lupa password', 'Masukkan email → terima OTP reset → masukkan OTP dan password baru → kembali login.']
    ],
    bullets: [
      'Pesan permintaan tidak mengungkapkan apakah email terdaftar; pengguna diminta memeriksa Inbox/Spam.',
      'Jika akun sudah terdaftar saat registrasi, dialog menawarkan Login atau Lupa Password.',
      'Sesi memakai Bearer access/refresh token dan dimuat kembali saat aplikasi dibuka.'
    ]
  },
  {
    title: 'Hubungkan atau ubah No. Rekam Medis',
    kicker: 'JEMBATAN AKUN MOBILE KE DATA PASIEN',
    summary: 'Pengaitan No. RM membuka seluruh data medis personal dan proses booking umum.',
    bullets: [
      'Isi No. RM, NIK 16 digit, tanggal lahir, dan password akun.',
      'Sistem meminta verifikasi awal lalu mengirim OTP ke email akun.',
      'Masukkan OTP email dan pilih “Verifikasi No. RM”.',
      'Alur yang sama digunakan untuk mengganti No. RM yang sudah terhubung.',
      'Validasi mencegah kolom kosong, NIK tidak 16 digit, dan OTP kosong.'
    ],
    image: img('06_hubungkan_rm.png'),
    callout: 'No. RM bukan sekadar kolom profil: ia menjadi pembatas akses data dan identitas pasien aktif.'
  },
  {
    title: 'Enam layanan medis personal',
    kicker: 'TERSEDIA SETELAH NO. RM TERVERIFIKASI',
    cards: [
      ['Profil Pasien', 'Identitas aman dari rekam medis rumah sakit.'],
      ['Riwayat Kunjungan', 'Rawat jalan, IGD, dan rawat inap.'],
      ['Diagnosis & Tindakan', 'Resume medis, ICD, tindakan, dan catatan.'],
      ['Hasil Lab', 'Order, hasil, rincian nilai, satuan, dan referensi.'],
      ['Hasil Radiologi', 'Pemeriksaan, resume, status, dan ekspertise.'],
      ['Resep & Obat', 'Riwayat farmasi dan rincian obat.']
    ],
    callout: 'Semua halaman menangani tiga keadaan: belum login, No. RM belum terhubung, dan data kosong/error/loading.'
  },
  {
    title: 'Profil Pasien',
    kicker: 'IDENTITAS DARI SISTEM REKAM MEDIS',
    summary: 'Menampilkan pasien yang terhubung ke akun, bukan data pasien lain.',
    bullets: [
      'Header menampilkan nama pasien dan No. RM aktif.',
      'Bidang aman meliputi NIK, jenis kelamin, tanggal lahir, telepon, email, alamat, golongan darah, agama, dan status perkawinan—jika tersedia.',
      'Pengguna tanpa No. RM mendapat penjelasan serta tombol “Hubungkan No. RM”.',
      'Data dimuat dari profil pasien terautentikasi dan mendukung refresh.'
    ],
    callout: 'Prinsip privasi: halaman hanya menggunakan endpoint profil pasien yang terkait dengan sesi login.'
  },
  {
    title: 'Riwayat Kunjungan',
    kicker: 'JEJAK REGISTRASI PASIEN',
    bullets: [
      'Menggabungkan kunjungan rawat jalan, IGD, dan rawat inap dari registrasi pasien.',
      'Setiap kartu dapat menampilkan nomor registrasi/antrian, tanggal, poli, dokter, jenis pasien, pembayaran, dan status.',
      'Kunjungan rawat inap menambahkan kelas, ruang, bed, dan tanggal mulai rawat jika tersedia.',
      'Membuka detail kunjungan serta menyediakan akses ke Resume Medis PDF.',
      'Maksimal 50 data terbaru dimuat pada permintaan halaman.'
    ],
    cards: [
      ['Status mudah dipindai', 'Badge membedakan rawat inap, nomor antrian, dan status pelayanan.'],
      ['Empty state', 'Pesan khusus tampil ketika belum ada riwayat untuk No. RM tersebut.']
    ]
  },
  {
    title: 'Diagnosis, tindakan & Resume Medis PDF',
    kicker: 'RINGKASAN PELAYANAN KLINIS',
    bullets: [
      'Diagnosis & Tindakan menampilkan tanggal kunjungan, poli, dokter, diagnosis/ICD, tindakan, dan catatan klinis yang tersedia.',
      'Setiap ringkasan dapat dibuka ke halaman detail dengan bidang yang lebih lengkap.',
      'Resume Medis PDF memperlihatkan No. RM, registrasi, tanggal, poli, dan dokter sebelum dokumen dibuka.',
      'Tombol “Lihat PDF” membuka dokumen melalui aplikasi PDF perangkat.',
      'Tombol “Download” menyimpan berkas bernama resume-medis-[registrasi].pdf di penyimpanan aplikasi.'
    ],
    callout: 'Dokumen PDF berasal dari ringkasan medis untuk registrasi terkait dan tetap mengikuti otorisasi akun pasien.'
  },
  {
    title: 'Hasil Laboratorium',
    kicker: 'HASIL PEMERIKSAAN & NILAI RUJUKAN',
    bullets: [
      'Daftar menampilkan nomor laboratorium, kunjungan, poli/dokter, tanggal pemeriksaan, dan jumlah rincian.',
      'Detail dapat memuat bagian/kategori, nama pemeriksaan, hasil teks atau angka, satuan, serta nilai referensi rendah–tinggi.',
      'Informasi tambahan: waktu mulai/selesai, sampel, penanggung jawab, kesan, saran, diagnosis, dan pesan hasil bila tersedia.',
      'Data disaring berdasarkan No. RM yang terhubung; tersedia loading, error, refresh, dan kondisi kosong.'
    ],
    cards: [
      ['Ringkas di daftar', 'Nomor lab dan jumlah rincian membantu pengguna memilih pemeriksaan.'],
      ['Detail terstruktur', 'Hasil dan rentang referensi disajikan per item pemeriksaan.']
    ]
  },
  {
    title: 'Hasil Radiologi',
    kicker: 'PEMERIKSAAN, RESUME & EKSPERTISE',
    bullets: [
      'Daftar menampilkan jenis pemeriksaan, tanggal kunjungan, poli/dokter, status, dan nomor dokumen.',
      'Status dinormalisasi agar mudah dibaca, termasuk penanda “Selesai” bila hasil sudah tersedia.',
      'Detail mencakup catatan klinis, ringkasan hasil, ekspertise, tipe order, waktu pemeriksaan, dan waktu hasil.',
      'Akses dibatasi pada pasien aktif; data kosong tidak menampilkan rekam medis pasien lain.'
    ],
    callout: 'Sumber data menggabungkan order radiologi, hasil, detail resume, dan ekspertise yang terkait pasien.'
  },
  {
    title: 'Resep & Obat',
    kicker: 'RIWAYAT FARMASI PASIEN',
    bullets: [
      'Daftar resep menampilkan nomor resep, kunjungan, poli/dokter, tanggal, status, dan jumlah obat.',
      'Rincian obat dapat berisi nama/kode obat, jumlah, satuan, dosis, cara pakai, informasi tambahan, dan catatan.',
      'Penanda racikan dan kronis ditampilkan bila tersedia dari sumber data.',
      'Halaman detail menyatukan informasi resep dan setiap item obat dalam tampilan yang mudah dipindai.'
    ],
    cards: [
      ['Sumber', 'Penjualan farmasi dan rincian obat yang terhubung ke registrasi pasien.'],
      ['Proteksi', 'Login + No. RM terverifikasi menjadi syarat sebelum data diambil.']
    ]
  },
  {
    title: 'Booking / Antrian Umum',
    kicker: 'MEMBUAT PENDAFTARAN POLI',
    summary: 'Jalur umum hanya untuk akun yang sudah memiliki No. RM terhubung.',
    bullets: [
      'Tab “Buat”: No. RM terisi otomatis dan tidak dapat diedit.',
      'Pilih tanggal pemeriksaan dari kalender layanan, lalu pilih poli tujuan.',
      'Aplikasi memuat ketersediaan jadwal/kuota dan daftar dokter untuk poli tersebut.',
      'Jika dokter tersedia, dokter wajib dipilih sebelum “Buat Antrian”.',
      'Tanggal tutup, poli kosong, atau dokter belum dipilih akan menghentikan submit dengan pesan yang jelas.'
    ],
    image: img('08_form_booking.png')
  },
  {
    title: 'Kalender, kuota & history booking',
    kicker: 'KONTROL SEBELUM DAN SESUDAH SUBMIT',
    bullets: [
      'Kalender bulanan menandai tanggal buka/tutup beserta alasan; pengguna dapat berpindah bulan dan tahun.',
      'Panel poli menampilkan kelompok antrian, kuota, kuota online, terisi, dan sisa bila tersedia.',
      'Submit mengirim tanggal, poli, dokter, kelompok antrian, jenis pasien Umum, dan metode bayar Umum.',
      'Respons “existing” ditangani sebagai antrian yang sudah ada—mencegah pengguna mengira perlu mengirim ulang.',
      'Setelah berhasil, aplikasi berpindah ke tab “Saya” dan memuat ulang history semua tanggal.'
    ],
    image: img('02_booking.png'),
    callout: 'Tab “Saya” menampilkan nomor antrian, status, tanggal, poli, dokter, dan bidang registrasi lain yang tersedia.'
  },
  {
    title: 'Pusat pilihan antrian',
    kicker: 'SATU TOMBOL, DUA JALUR',
    cards: [
      ['Registrasi Umum', 'Membuka halaman Antrian Umum di aplikasi untuk pendaftaran poli dengan No. RM.'],
      ['Antrian BPJS', 'Membuka Mobile JKN; bila belum terpasang, diarahkan ke Play Store.']
    ],
    bullets: [
      'Pemisahan jalur mencegah booking BPJS dibuat melalui proses umum.',
      'Jika Mobile JKN/Play Store tidak bisa dibuka, aplikasi menampilkan notifikasi kegagalan.',
      'Ketentuan pada form kembali mengingatkan pengguna agar tidak membuat booking ganda.'
    ],
    image: img('03_pilih_antrian.png')
  },
  {
    title: 'Poli, dokter & jadwal praktik',
    kicker: 'DIREKTORI PUBLIK TANPA LOGIN',
    bullets: [
      'Pencarian berdasarkan nama poli atau kode ruangan; header menunjukkan jumlah tampil dan total.',
      'Kartu poli menampilkan kode/ruangan, jam layanan, hari praktik, status praktik, kuota, terisi, dan sisa.',
      'Detail poli memuat status layanan, kode BPJS/Inhealth, kelas, kelompok, lantai, dan keterangan.',
      'Bagian “Dokter dan Jadwal” menggabungkan jadwal poli dengan daftar dokter terkait.',
      'Detail dokter dapat menampilkan nama, kode antrian, jabatan, poli, kuota, status, serta seluruh jadwal praktik.'
    ],
    image: img('04_poli_jadwal.png'),
    callout: 'Snapshot emulator menampilkan 49 poli; jumlah ini dinamis mengikuti data server.'
  },
  {
    title: 'Ketersediaan Kamar Rawat Inap',
    kicker: 'INFORMASI BED PUBLIK',
    bullets: [
      'Pencarian berdasarkan kode, kelas, atau ruangan.',
      'Data dikelompokkan per kelas rawat inap dan hanya kelompok aktif yang dihitung.',
      'Ringkasan menampilkan grup aktif, total bed, bed terisi, bed kosong, dan renovasi bila ada.',
      'Detail memperlihatkan kode umum, kelas, ruangan, jumlah kamar, jumlah bed, status aktif, dan keterangan.',
      'Angka bersifat operasional dan dapat berubah mengikuti kondisi rawat inap.'
    ],
    cards: [
      ['Sumber utama', 'Endpoint mobile ketersediaan kamar.'],
      ['Fallback data', 'Pengaturan ketersediaan kamar rumah sakit bila diperlukan.']
    ]
  },
  {
    title: 'Informasi RS — profil, visi, dan jam layanan',
    kicker: 'KONTEN PUBLIK DI BERANDA',
    cards: [
      ['Profil RS', 'RSUD Oto Iskandar Di Nata Kabupaten Bandung; layanan utama mencakup IGD, rawat jalan, dan rawat inap.'],
      ['Visi & misi', 'Mendukung Bandung BEDAS menuju Indonesia Emas; fokus pada peningkatan kualitas pelayanan kesehatan.'],
      ['Budaya MANTAP', 'Melayani, Akuntabel, Nyaman, Terdepan, Amanah, Profesional.'],
      ['Jam layanan', 'Rawat jalan/poliklinik Senin–Sabtu 08.00–14.00 WIB; IGD dan pendaftaran rawat inap 24 jam.']
    ],
    callout: 'Konten ini disajikan melalui lembar informasi ringkas dan dapat ditutup tanpa meninggalkan aplikasi.'
  },
  {
    title: 'Informasi RS — alamat, kontak & fasilitas',
    kicker: 'TAUTAN KE KANAL RESMI',
    cards: [
      ['Alamat RS', 'Jl. Raya Gading Tutuka, Desa Cingcin, Kec. Soreang, Kab. Bandung, Jawa Barat — tombol membuka Maps.'],
      ['Kontak RS', 'Website, email rsudotista@bandungkab.go.id, telepon (022) 5891355, dan WhatsApp 0811-965-1010.'],
      ['Fasilitas RS', 'IGD, rawat jalan/khusus, rawat inap, ruang tunggu, meja layanan, tempat ibadah, toilet, ruang laktasi, kursi roda, evakuasi, CCTV, dan pendukung lain.']
    ],
    bullets: [
      'Tautan dibuka dengan aplikasi eksternal yang sesuai: browser, Maps, email, telepon, atau WhatsApp.',
      'Jika aplikasi eksternal gagal dibuka, SIPANTES menampilkan pesan kegagalan.'
    ]
  },
  {
    title: 'Profil & pengelolaan akun',
    kicker: 'KENDALI IDENTITAS PENGGUNA',
    cards: [
      ['Status akun', 'Nama, email, telepon, status “Akun aktif”, dan status No. RM.'],
      ['No. RM', 'Menu berubah menjadi “Hubungkan No. RM” atau “Ubah No. RM”.'],
      ['Privasi', 'Membuka kebijakan privasi resmi melalui browser eksternal.'],
      ['Logout', 'Meminta konfirmasi; sesi perangkat dibersihkan dan layanan personal harus login kembali.']
    ],
    bullets: [
      'Mode tamu menyediakan tombol Login Akun dan Registrasi Akun Baru.',
      'Mode tamu juga menampilkan akses informasi Dokter & Poli, Tarif Layanan, Kamar, Privasi, serta Penghapusan Akun.'
    ],
    callout: 'Deck ini tidak menampilkan screenshot profil akun agar email dan nomor telepon pengguna uji tidak ikut tersebar.'
  },
  {
    title: 'Penghapusan akun',
    kicker: 'ALUR PERMANEN DENGAN VERIFIKASI BERLAPIS',
    bullets: [
      'Masukkan password akun untuk meminta OTP penghapusan.',
      'Masukkan OTP email 6 digit yang berlaku 5 menit.',
      'Dialog terakhir meminta konfirmasi “Ya, Hapus Akun”.',
      'Yang dihapus/dianonimkan: identitas akun mobile, hubungan No. RM, kredensial, OTP, dan semua sesi login.',
      'Yang tidak dihapus: rekam medis, hasil pemeriksaan, resep, pendaftaran, antrian, dan catatan pelayanan kesehatan.'
    ],
    image: img('07_hapus_akun.png'),
    callout: 'Tersedia juga halaman penghapusan akun publik melalui situs resmi untuk pengguna yang tidak sedang login.'
  },
  {
    title: 'Keandalan pengalaman pengguna',
    kicker: 'STATE, VALIDASI & PEMULIHAN',
    cards: [
      ['Loading', 'Indikator khusus saat memuat layanan, jadwal, kalender, history, atau membuat antrian.'],
      ['Error', 'Pesan server/jaringan ditampilkan dengan aksi Muat Ulang atau refresh bila relevan.'],
      ['Empty state', 'Pesan yang spesifik untuk kunjungan, hasil, resep, antrian, poli, dan kamar tanpa data.'],
      ['Session expired', 'API menyiarkan sesi berakhir; token dibersihkan dan pengguna perlu login ulang.'],
      ['Validasi', 'OTP 6 digit, NIK 16 digit, password 8–72 karakter, tanggal buka, poli, serta dokter.'],
      ['Refresh', 'Pull-to-refresh digunakan pada beranda, layanan personal, direktori, dan history.']
    ]
  },
  {
    title: 'Tiga perjalanan pengguna utama',
    kicker: 'ALUR END-TO-END',
    cards: [
      ['A — Pengunjung publik', 'Buka aplikasi → cari Poli & Jadwal / Kamar / informasi RS → buka Maps, website, atau kontak resmi.'],
      ['B — Pasien baru', 'Registrasi + OTP → login + OTP → hubungkan No. RM + OTP → buka layanan medis personal.'],
      ['C — Booking umum', 'Login → No. RM terhubung → pilih tanggal → poli → dokter → Buat Antrian → lihat tab Saya/history.']
    ],
    callout: 'Untuk pasien BPJS: tombol Antrian → Antrian BPJS → lanjutkan proses di Mobile JKN.'
  },
  {
    type: 'matrix',
    title: 'Matriks kelengkapan fitur',
    kicker: '16 PINTASAN BERANDA + FITUR AKUN',
    columns: [
      [
        ['Profil Pasien', 'Login + No. RM'], ['Riwayat Kunjungan', 'Login + No. RM'],
        ['Diagnosis & Tindakan', 'Login + No. RM'], ['Hasil Lab', 'Login + No. RM'],
        ['Hasil Radiologi', 'Login + No. RM'], ['Resep & Obat', 'Login + No. RM'],
        ['Poli & Jadwal', 'Publik'], ['Nomor Antrian', 'Login + No. RM']
      ],
      [
        ['Profil RS', 'Publik'], ['Visi Misi RS', 'Publik'], ['Jam Layanan RS', 'Publik'],
        ['Alamat RS', 'Publik'], ['Kontak RS', 'Publik'], ['Fasilitas RS', 'Publik'],
        ['Ketersediaan Kamar', 'Publik'], ['Pendaftaran Poli', 'Tab Booking / Antrian Umum']
      ]
    ],
    bullets: [
      'Fitur akun tambahan: login, registrasi, lupa password, klaim/ubah No. RM, privasi, logout, dan hapus akun.',
      'Fitur integrasi tambahan: Antrian BPJS → Mobile JKN dan Resume Medis PDF.'
    ]
  },
  {
    title: 'Catatan status implementasi saat ini',
    kicker: 'TRANSPARANSI BUILD YANG DIPRESENTASIKAN',
    cards: [
      ['Tarif Layanan', 'Muncul sebagai kartu pada mode tamu, tetapi belum memiliki aksi/halaman data khusus pada source saat ini.'],
      ['Tagihan & pembayaran', 'Disebut pada teks promosi login, namun tidak ada pintasan/halaman transaksi aktif dalam build ini.'],
      ['Pendaftaran Poli', 'Tidak ditampilkan sebagai grid tersendiri; fungsinya tersedia melalui tab Booking dan pilihan Registrasi Umum.'],
      ['Data dinamis', 'Jadwal, kuota, kamar, dan antrian mengikuti API dan dapat berubah dari snapshot emulator.']
    ],
    callout: 'Penandaan ini memastikan presentasi membedakan fitur operasional, pintasan alternatif, dan elemen yang masih informasional.'
  },
  {
    type: 'closing',
    title: 'SIPANTES',
    subtitle: 'Informasi publik yang mudah diakses.\nLayanan pasien yang aman dan personal.',
    summary: 'RSUD Oto Iskandar Di Nata Kabupaten Bandung',
    bullets: [
      'Website: rsudotista.bandungkab.go.id',
      'Email: rsudotista@bandungkab.go.id',
      'Telepon: (022) 5891355 • WhatsApp: 0811-965-1010'
    ]
  }
];

const pptx = new pptxgen();
pptx.layout = 'LAYOUT_WIDE';
pptx.author = 'RSUD Oto Iskandar Di Nata';
pptx.subject = 'Presentasi lengkap fitur aplikasi SIPANTES';
pptx.title = 'SIPANTES — Presentasi Fitur Lengkap';
pptx.company = 'RSUD Oto Iskandar Di Nata Kabupaten Bandung';
pptx.lang = 'id-ID';
pptx.theme = {
  headFontFace: 'Aptos Display', bodyFontFace: 'Aptos', lang: 'id-ID'
};
pptx.defineSlideMaster({
  title: 'MASTER',
  background: { color: C.paper },
  objects: [
    { rect: { x: 0, y: 0, w: 0.16, h: 7.5, fill: { color: C.teal }, line: { color: C.teal } } },
    { line: { x: 0.55, y: 7.12, w: 12.2, h: 0, line: { color: C.line, width: 0.7 } } },
    { text: { text: 'SIPANTES • RSUD OTISTA', options: { x: 0.58, y: 7.16, w: 4.0, h: 0.16, fontFace: 'Aptos', fontSize: 7.5, color: C.muted, bold: true, margin: 0 } } },
  ],
  slideNumber: { x: 12.35, y: 7.12, w: 0.38, h: 0.2, color: C.muted, fontSize: 8, align: 'right', margin: 0 }
});

function addTitle(slide, s) {
  slide.addText(s.kicker || 'FITUR SIPANTES', { x: 0.62, y: 0.42, w: 6.6, h: 0.22, fontSize: 9, bold: true, color: C.teal, charSpacing: 1.6, margin: 0 });
  slide.addText(s.title, { x: 0.62, y: 0.73, w: 11.9, h: 0.48, fontSize: 26, bold: true, color: C.deep, margin: 0, breakLine: false, fit: 'shrink' });
  slide.addShape(pptx.ShapeType.line, { x: 0.62, y: 1.35, w: 1.05, h: 0, line: { color: C.gold, width: 4, beginArrowType: 'none', endArrowType: 'none' } });
}

function addPhone(slide, imagePath, x=10.05, y=1.18, h=5.78) {
  const w = h * 1440 / 3120;
  slide.addShape(pptx.ShapeType.roundRect, { x: x-0.07, y: y-0.07, w: w+0.14, h: h+0.14, rectRadius: 0.12, fill: { color: '172D2B' }, line: { color: '172D2B' }, shadow: { type: 'outer', color: '6A7775', blur: 2, angle: 45, distance: 2, opacity: 0.22 } });
  slide.addImage({ path: imagePath, x, y, w, h });
}

function addSummary(slide, text, hasImage=false) {
  const w = hasImage ? 8.65 : 11.85;
  slide.addText(text, { x: 0.68, y: 1.62, w, h: 0.62, fontSize: 16.5, color: C.ink, bold: false, breakLine: false, margin: 0.03, valign: 'mid', fit: 'shrink' });
}

function addBullets(slide, bullets, x, y, w, h, fontSize=15.2) {
  if (!bullets || !bullets.length) return;
  const runs = [];
  bullets.forEach((b, i) => {
    runs.push({ text: b, options: { bullet: { indent: fontSize }, hanging: 3, breakLine: i < bullets.length - 1 } });
  });
  slide.addText(runs, { x, y, w, h, fontSize, color: C.ink, margin: 0.08, breakLine: false, paraSpaceAfterPt: 7, valign: 'top', fit: 'shrink', lineSpacingMultiple: 0.95 });
}

function addCards(slide, cards, x, y, w, h) {
  if (!cards || !cards.length) return;
  const cols = cards.length <= 3 ? cards.length : (cards.length === 5 ? 5 : 2);
  const rows = Math.ceil(cards.length / cols);
  const gapX = 0.16, gapY = 0.15;
  const cw = (w - gapX * (cols - 1)) / cols;
  const ch = (h - gapY * (rows - 1)) / rows;
  cards.forEach((card, i) => {
    const col = i % cols, row = Math.floor(i / cols);
    const cx = x + col * (cw + gapX), cy = y + row * (ch + gapY);
    slide.addShape(pptx.ShapeType.roundRect, { x: cx, y: cy, w: cw, h: ch, rectRadius: 0.08, fill: { color: i % 3 === 0 ? C.softTeal : i % 3 === 1 ? C.white : C.softBlue, transparency: 0 }, line: { color: C.line, width: 0.8 }, shadow: { type: 'outer', color: '9DA9A7', blur: 1, angle: 45, distance: 1, opacity: 0.10 } });
    slide.addText(card[0], { x: cx+0.16, y: cy+0.13, w: cw-0.32, h: 0.28, fontSize: cards.length === 5 ? 13.5 : 15, bold: true, color: C.deep, margin: 0, fit: 'shrink' });
    slide.addText(card[1], { x: cx+0.16, y: cy+0.48, w: cw-0.32, h: ch-0.58, fontSize: cards.length === 5 ? 11.5 : 12.3, color: C.ink, margin: 0, valign: 'top', fit: 'shrink', breakLine: false });
  });
}

function addCallout(slide, text, hasImage=false) {
  if (!text) return;
  const w = hasImage ? 8.75 : 11.85;
  slide.addShape(pptx.ShapeType.roundRect, { x: 0.65, y: 6.36, w, h: 0.56, rectRadius: 0.05, fill: { color: C.softGold }, line: { color: 'E5CB8E', width: 0.8 } });
  slide.addText(text, { x: 0.86, y: 6.48, w: w-0.4, h: 0.28, fontSize: 10.8, color: C.ink, bold: true, margin: 0, valign: 'mid', fit: 'shrink' });
}

function renderCover(s) {
  const slide = pptx.addSlide();
  slide.background = { color: C.deep };
  slide.addShape(pptx.ShapeType.rect, { x: 0, y: 0, w: 13.333, h: 7.5, fill: { color: C.deep }, line: { color: C.deep } });
  slide.addShape(pptx.ShapeType.arc, { x: -1.6, y: 4.3, w: 7.0, h: 4.5, adjustPoint: 0.25, rotate: 330, fill: { color: C.teal, transparency: 60 }, line: { color: C.teal, transparency: 100 } });
  slide.addImage({ path: logo, x: 0.72, y: 0.52, w: 2.2, h: 0.82, transparency: 0 });
  slide.addImage({ path: pemkab, x: 3.05, y: 0.54, w: 0.55, h: 0.72 });
  slide.addText(s.kicker, { x: 0.75, y: 1.72, w: 6.9, h: 0.25, fontSize: 10, bold: true, color: C.teal2, charSpacing: 1.8, margin: 0 });
  slide.addText(s.title, { x: 0.72, y: 2.14, w: 6.1, h: 0.8, fontSize: 42, bold: true, color: C.white, margin: 0 });
  slide.addText(s.subtitle, { x: 0.76, y: 3.02, w: 6.1, h: 1.02, fontSize: 23, bold: true, color: C.white, margin: 0, breakLine: false, fit: 'shrink' });
  slide.addText(s.summary, { x: 0.76, y: 4.28, w: 5.9, h: 0.45, fontSize: 16, color: 'D7ECE8', margin: 0 });
  slide.addShape(pptx.ShapeType.roundRect, { x: 0.76, y: 5.25, w: 3.6, h: 0.48, rectRadius: 0.06, fill: { color: C.white, transparency: 88 }, line: { color: C.white, transparency: 80 } });
  slide.addText(s.meta, { x: 0.98, y: 5.39, w: 3.15, h: 0.16, fontSize: 10.5, color: C.white, bold: true, margin: 0, align: 'center' });
  addPhone(slide, s.image, 9.18, 0.56, 6.2);
}

function renderClosing(s) {
  const slide = pptx.addSlide();
  slide.background = { color: C.deep };
  slide.addShape(pptx.ShapeType.rect, { x: 0, y: 0, w: 13.333, h: 7.5, fill: { color: C.deep }, line: { color: C.deep } });
  slide.addImage({ path: logo, x: 5.45, y: 0.72, w: 2.45, h: 0.92 });
  slide.addText(s.title, { x: 2.0, y: 2.0, w: 9.33, h: 0.78, fontSize: 44, bold: true, color: C.white, align: 'center', margin: 0 });
  slide.addText(s.subtitle, { x: 2.0, y: 2.95, w: 9.33, h: 1.15, fontSize: 25, bold: true, color: C.teal2, align: 'center', margin: 0, fit: 'shrink' });
  slide.addText(s.summary, { x: 2.2, y: 4.35, w: 8.93, h: 0.35, fontSize: 16, color: C.white, align: 'center', margin: 0 });
  slide.addText(s.bullets.join('\n'), { x: 3.0, y: 5.06, w: 7.33, h: 0.85, fontSize: 13, color: 'D8ECE9', align: 'center', margin: 0.02, breakLine: false, fit: 'shrink' });
  slide.addText('TERIMA KASIH', { x: 4.6, y: 6.48, w: 4.13, h: 0.25, fontSize: 11, bold: true, color: C.gold, charSpacing: 2.2, align: 'center', margin: 0 });
}

function renderMatrix(s) {
  const slide = pptx.addSlide('MASTER'); addTitle(slide, s);
  s.columns.forEach((col, ci) => {
    const x = 0.68 + ci * 6.05;
    col.forEach((row, ri) => {
      const y = 1.62 + ri * 0.55;
      slide.addShape(pptx.ShapeType.roundRect, { x, y, w: 5.78, h: 0.43, rectRadius: 0.04, fill: { color: ri % 2 ? C.white : C.softTeal }, line: { color: C.line, width: 0.5 } });
      slide.addText(row[0], { x: x+0.13, y: y+0.11, w: 3.25, h: 0.16, fontSize: 10.2, bold: true, color: C.deep, margin: 0, fit: 'shrink' });
      slide.addText(row[1], { x: x+3.38, y: y+0.11, w: 2.22, h: 0.16, fontSize: 9.2, color: C.muted, align: 'right', margin: 0, fit: 'shrink' });
    });
  });
  addBullets(slide, s.bullets, 0.78, 6.12, 11.75, 0.78, 10.6);
}

function renderStandard(s) {
  const slide = pptx.addSlide('MASTER'); addTitle(slide, s);
  const hasImage = Boolean(s.image);
  if (hasImage) addPhone(slide, s.image);
  const contentW = hasImage ? 8.78 : 11.85;
  let top = 1.57;
  if (s.summary) { addSummary(slide, s.summary, hasImage); top = 2.32; }
  if (s.cards && s.cards.length) {
    let cardH;
    if (s.bullets && s.bullets.length) cardH = 2.5;
    else cardH = s.callout ? 3.95 : 4.7;
    addCards(slide, s.cards, 0.68, top, contentW, cardH);
    top += cardH + 0.22;
  }
  if (s.bullets && s.bullets.length) {
    const bottom = s.callout ? 6.18 : 6.88;
    addBullets(slide, s.bullets, 0.72, top, contentW-0.05, Math.max(0.65, bottom-top), hasImage ? 13.2 : 14.7);
  }
  addCallout(slide, s.callout, hasImage);
}

for (const s of slides) {
  if (s.type === 'cover') renderCover(s);
  else if (s.type === 'closing') renderClosing(s);
  else if (s.type === 'matrix') renderMatrix(s);
  else renderStandard(s);
}

function esc(s='') { return String(s).replace(/[&<>"']/g, ch => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[ch])); }
function fileUrl(p) { return 'file:///' + p.replace(/\\/g, '/').replace(/ /g, '%20'); }
function htmlSlide(s, index) {
  if (s.type === 'cover') return `<section class="slide cover"><div class="coverCopy"><img class="brand" src="${fileUrl(logo)}"><div class="kicker">${esc(s.kicker)}</div><h1>${esc(s.title)}</h1><h2>${esc(s.subtitle).replace(/\n/g,'<br>')}</h2><p class="lead">${esc(s.summary)}</p><div class="pill">${esc(s.meta)}</div></div><div class="phone"><img src="${fileUrl(s.image)}"></div></section>`;
  if (s.type === 'closing') return `<section class="slide closing"><img class="brand" src="${fileUrl(logo)}"><h1>${esc(s.title)}</h1><h2>${esc(s.subtitle).replace(/\n/g,'<br>')}</h2><p>${esc(s.summary)}</p><div class="contact">${s.bullets.map(esc).join('<br>')}</div><div class="thanks">TERIMA KASIH</div></section>`;
  const hasImage = Boolean(s.image);
  const cards = s.cards ? `<div class="cards n${s.cards.length}">${s.cards.map(c=>`<div class="card"><h3>${esc(c[0])}</h3><p>${esc(c[1])}</p></div>`).join('')}</div>` : '';
  const bullets = s.bullets ? `<ul>${s.bullets.map(b=>`<li>${esc(b)}</li>`).join('')}</ul>` : '';
  const matrix = s.type === 'matrix' ? `<div class="matrix">${s.columns.map(col=>`<div>${col.map(r=>`<div class="mrow"><b>${esc(r[0])}</b><span>${esc(r[1])}</span></div>`).join('')}</div>`).join('')}</div>` : '';
  return `<section class="slide"><header><div class="kicker">${esc(s.kicker||'FITUR SIPANTES')}</div><h1>${esc(s.title)}</h1><i></i></header><main class="${hasImage?'withImage':''}"><div class="content">${s.summary?`<p class="summary">${esc(s.summary)}</p>`:''}${matrix||cards}${bullets}${s.callout?`<div class="callout">${esc(s.callout)}</div>`:''}</div>${hasImage?`<div class="phone"><img src="${fileUrl(s.image)}"></div>`:''}</main><footer>SIPANTES • RSUD OTISTA <span>${index+1}</span></footer></section>`;
}

const css = `
@page { size: 13.333in 7.5in; margin: 0; }
* { box-sizing: border-box; } html,body { margin:0; padding:0; background:#ddd; font-family:Arial,sans-serif; color:#${C.ink}; }
.slide { width:13.333in; height:7.5in; page-break-after:always; overflow:hidden; position:relative; background:#${C.paper}; padding:.42in .6in .32in .68in; }
.slide:before { content:""; position:absolute; left:0; top:0; width:.16in; height:100%; background:#${C.teal}; }
header .kicker,.kicker { font-size:9pt; letter-spacing:1.6px; font-weight:800; color:#${C.teal}; }
header h1 { margin:.09in 0 .11in; font-size:26pt; color:#${C.deep}; line-height:1.05; } header i { display:block; width:1.05in; border-top:4px solid #${C.gold}; }
main { height:5.55in; padding-top:.22in; } main.withImage { display:grid; grid-template-columns:8.8in 2.72in; gap:.48in; }
.content { min-width:0; } .summary { font-size:16pt; margin:0 0 .18in; line-height:1.25; }
ul { margin:.14in 0 0 .25in; padding:0; font-size:14.2pt; line-height:1.27; } li { margin-bottom:.1in; padding-left:.04in; }
.cards { display:grid; grid-template-columns:repeat(2,1fr); gap:.15in; margin-top:.04in; }
.cards.n3 { grid-template-columns:repeat(3,1fr); } .cards.n5 { grid-template-columns:repeat(5,1fr); }
.card { background:white; border:1px solid #${C.line}; border-radius:.11in; padding:.15in .17in; min-height:1.05in; box-shadow:0 2px 7px rgba(20,70,65,.08); }
.card:nth-child(3n+1){background:#${C.softTeal}} .card:nth-child(3n){background:#${C.softBlue}}
.card h3 { margin:0 0 .08in; color:#${C.deep}; font-size:14pt; } .card p { margin:0; font-size:11.6pt; line-height:1.25; }
.callout { position:absolute; left:.68in; bottom:.58in; width:11.86in; min-height:.48in; padding:.12in .2in; background:#${C.softGold}; border:1px solid #e5cb8e; border-radius:.08in; font-size:10.5pt; font-weight:700; }
.withImage .callout { width:8.75in; }
.phone { background:#172d2b; padding:.07in; border-radius:.17in; box-shadow:0 5px 18px rgba(0,0,0,.19); align-self:start; justify-self:center; }
.phone img { display:block; width:2.66in; height:5.76in; object-fit:fill; border-radius:.1in; }
footer { position:absolute; bottom:.15in; left:.58in; right:.6in; border-top:1px solid #${C.line}; padding-top:.05in; font-size:7.5pt; font-weight:700; color:#${C.muted}; }
footer span { float:right; }
.matrix { display:grid; grid-template-columns:1fr 1fr; gap:.25in; margin-top:.04in; }
.mrow { display:flex; justify-content:space-between; padding:.085in .13in; border:1px solid #${C.line}; border-radius:.06in; margin-bottom:.07in; font-size:10pt; background:white; }
.mrow:nth-child(odd){background:#${C.softTeal}} .mrow span { color:#${C.muted}; text-align:right; }
.cover { padding:0; background:#${C.deep}; color:white; display:grid; grid-template-columns:8.25in 5.08in; }
.cover:before,.closing:before { display:none; } .coverCopy { padding:.52in .72in; position:relative; }
.brand { width:2.3in; max-height:.95in; object-fit:contain; object-position:left center; }
.cover .kicker { margin-top:.55in; color:#${C.teal2}; } .cover h1 { font-size:44pt; margin:.18in 0 .05in; }
.cover h2 { font-size:25pt; line-height:1.16; margin:.08in 0 .3in; } .cover .lead { font-size:16pt; color:#d7ece8; }
.pill { display:inline-block; margin-top:.28in; padding:.12in .2in; border-radius:.25in; background:rgba(255,255,255,.12); font-size:10.5pt; font-weight:700; }
.cover .phone { margin-top:.52in; }
.closing { background:#${C.deep}; color:white; text-align:center; padding:.7in 1in; }
.closing .brand { object-position:center; width:2.5in; } .closing h1 { font-size:46pt; margin:.38in 0 .12in; }
.closing h2 { color:#${C.teal2}; font-size:27pt; line-height:1.2; margin:.08in 0 .38in; }
.closing p { font-size:16pt; } .contact { margin-top:.35in; font-size:13pt; line-height:1.55; color:#d8ece9; }
.thanks { margin-top:.52in; color:#${C.gold}; letter-spacing:3px; font-size:11pt; font-weight:800; }
`;
const previewScript = `<script>const n=Number(new URLSearchParams(location.search).get('slide'));if(n>0){document.querySelectorAll('.slide').forEach((el,i)=>el.style.display=i===n-1?'':'none');document.body.style.background='#ddd';}</script>`;
const html = `<!doctype html><html><head><meta charset="utf-8"><title>SIPANTES — Presentasi Fitur Lengkap</title><style>${css}</style></head><body>${slides.map(htmlSlide).join('\n')}${previewScript}</body></html>`;

fs.mkdirSync(OUT, { recursive: true });
fs.writeFileSync(path.join(OUT, 'Presentasi_SIPANTES_Fitur_Lengkap.html'), html, 'utf8');
pptx.writeFile({ fileName: path.join(OUT, 'Presentasi_SIPANTES_Fitur_Lengkap.pptx') });
console.log(`Generated ${slides.length} slides.`);
