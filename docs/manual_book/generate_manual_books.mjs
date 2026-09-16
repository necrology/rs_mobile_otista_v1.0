import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import {
  AlignmentType, Document, HeadingLevel, ImageRun, Packer, PageBreak,
  Paragraph, Table, TableCell, TableRow, TextRun, WidthType,
} from 'docx';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..', '..');
const output = here;
const green = '155C55';
const teal = '43AFA5';
const gray = '435552';
const screenshots = path.join(here, 'screenshots');
const date = '10 September 2026';

const p = (text = '', options = {}) => new Paragraph({
  spacing: { after: options.after ?? 120, line: 276 },
  alignment: options.center ? AlignmentType.CENTER : AlignmentType.LEFT,
  children: [new TextRun({ text, bold: options.bold, italics: options.italics, color: options.color, size: options.size })],
});
const heading = (text, level = HeadingLevel.HEADING_1) => new Paragraph({
  text, heading: level, spacing: { before: 260, after: 130 },
  shading: level === HeadingLevel.HEADING_1 ? { fill: 'EAF6F4' } : undefined,
});
const bullets = (items) => items.map((text) => new Paragraph({ text, bullet: { level: 0 }, spacing: { after: 65, line: 260 } }));
const numbered = (items) => items.map((text, index) => p(`${index + 1}. ${text}`));
const note = (text) => new Table({ width: { size: 100, type: WidthType.PERCENTAGE }, rows: [new TableRow({ children: [new TableCell({ shading: { fill: 'EAF6F4' }, margins: { top: 110, bottom: 110, left: 130, right: 130 }, children: [p(text, { bold: true, color: green, after: 0 })] })] })] });
const table = (headers, rows) => new Table({ width: { size: 100, type: WidthType.PERCENTAGE }, rows: [
  new TableRow({ children: headers.map((x) => new TableCell({ shading: { fill: 'CBEAE6' }, children: [p(x, { bold: true, after: 0 })] })) }),
  ...rows.map((row) => new TableRow({ children: row.map((x) => new TableCell({ children: [p(x, { after: 0 })] })) })),
] });
const cover = (title, subtitle, code) => [
  new Paragraph({ spacing: { before: 2100, after: 250 }, alignment: AlignmentType.CENTER, children: [new TextRun({ text: title, bold: true, color: green, size: 42 })] }),
  p('SIPANTES', { center: true, bold: true, color: teal, size: 34, after: 180 }),
  p(subtitle, { center: true, color: gray, size: 25 }),
  p('RSUD Oto Iskandar Di Nata Kabupaten Bandung', { center: true, bold: true, size: 22, after: 500 }),
  p(`${code}  |  Versi 1.0  |  ${date}`, { center: true, bold: true, size: 20 }),
  p('Klasifikasi: Internal — dokumen ini tidak memuat password, OTP, token, NIK, atau data klinis pasien.', { center: true, italics: true, color: gray, size: 18, after: 700 }),
  new Paragraph({ children: [new PageBreak()] }),
];
const control = (audience, scope) => [
  heading('Pengendalian Dokumen'),
  table(['Atribut', 'Keterangan'], [
    ['Nama aplikasi', 'SIPANTES — Sistem Pendaftaran Terintegrasi RSUD Oto Iskandar Di Nata'],
    ['Sasaran', audience], ['Ruang lingkup', scope], ['Versi aplikasi', '1.0.0+3'],
    ['Platform', 'Android / Flutter'], ['Penyusun', 'Tim pengembangan SIPANTES'],
    ['Status', 'Dokumen operasional internal'], ['Tanggal', date],
  ]),
  heading('Riwayat Revisi', HeadingLevel.HEADING_2),
  table(['Versi', 'Tanggal', 'Uraian'], [['1.0', date, 'Penyusunan awal berdasarkan source code, konfigurasi aplikasi, dan verifikasi tampilan emulator.']]),
];
const image = (name, caption) => {
  const data = fs.readFileSync(path.join(screenshots, name));
  return [new Paragraph({ alignment: AlignmentType.CENTER, children: [new ImageRun({ data, transformation: { width: 230, height: 499 }, type: 'png' })] }), p(`Gambar — ${caption}`, { center: true, italics: true, color: gray, size: 18 })];
};

const userChildren = [
  ...cover('MANUAL BOOK PENGGUNA', 'Panduan penggunaan aplikasi layanan pasien', 'MB-SIPANTES-USER-001'),
  ...control('Pasien, keluarga pasien, dan petugas front office yang mendampingi pengguna.', 'Akses informasi rumah sakit, akun, keterhubungan No. RM, booking, antrian, dan data layanan personal.'),
  heading('1. Tujuan dan Ketentuan Penggunaan'),
  p('SIPANTES membantu pengguna memperoleh informasi layanan RSUD Oto Iskandar Di Nata, mengelola akun, menghubungkan rekam medis, melihat layanan personal, serta membuat booking pendaftaran umum. Aplikasi membutuhkan koneksi internet untuk data yang diperbarui dari layanan rumah sakit.'),
  ...bullets(['Gunakan alamat email aktif karena beberapa proses menggunakan OTP email.', 'Jangan membagikan password, OTP, NIK, No. RM, atau tangkapan layar data medis kepada pihak lain.', 'Informasi jadwal, kuota, kamar, dan antrean dapat berubah; konfirmasi kepada rumah sakit apabila terdapat perbedaan.', 'SIPANTES tidak menggantikan pemeriksaan, instruksi dokter, maupun prosedur layanan rumah sakit.']),
  heading('2. Persyaratan'),
  table(['Kebutuhan', 'Penjelasan'], [['Perangkat', 'Ponsel Android yang mendukung aplikasi.'], ['Koneksi', 'Internet aktif dan stabil.'], ['Email', 'Email yang dapat menerima OTP.'], ['Akun', 'Diperlukan untuk fitur personal, booking, serta rekam medis.'], ['Data klaim No. RM', 'No. RM, NIK 16 digit, tanggal lahir, dan password akun.']]),
  heading('3. Mengenal Beranda'),
  p('Beranda menampilkan identitas aplikasi, sapaan akun, kolom pencarian, dan pintasan layanan. Menu navigasi bawah terdiri dari Beranda, Booking, Antrian, Poli & Jadwal, serta Profil.'),
  ...image('01_beranda.png', 'Beranda pada sesi akun aktif (data akun uji ditampilkan hanya untuk verifikasi).'),
  heading('4. Akses Informasi Tanpa Login'),
  p('Pengguna dapat membuka informasi publik tanpa masuk akun. Gunakan Beranda atau tab Poli & Jadwal untuk mencari poli, dokter, jadwal layanan, serta ketersediaan kamar. Gunakan kolom Cari dan tekan tombol Cari bila tersedia.'),
  ...numbered(['Pilih tab Poli & Jadwal.', 'Masukkan nama poli/dokter atau kata kunci pada kolom pencarian.', 'Tekan Cari, lalu pilih hasil yang relevan untuk melihat rincian jadwal/kuota.', 'Untuk kamar, buka pintasan Ketersediaan Kamar dari Beranda dan lakukan pencarian yang sama.']),
  ...image('03_poli_jadwal.png', 'Halaman Poli & Jadwal untuk pencarian layanan publik.'),
  heading('5. Registrasi Akun Baru'),
  p('Registrasi digunakan oleh pengguna yang belum memiliki akun SIPANTES. Password dibuat setelah OTP registrasi berhasil diverifikasi.'),
  ...numbered(['Buka Profil, kemudian pilih Registrasi Akun Baru; atau pilih Login lalu tab Registrasi.', 'Isi nama lengkap, email, dan nomor telepon dengan benar.', 'Kirim permintaan OTP dan cek email.', 'Masukkan OTP pada aplikasi untuk memperoleh tiket registrasi.', 'Buat password 8–72 karakter yang memuat huruf dan angka.', 'Selesaikan proses. Saat berhasil, akun dan sesi login akan aktif.']),
  note('OTP bersifat rahasia dan memiliki masa berlaku. Jika email tidak diterima, periksa folder spam, pastikan alamat email benar, lalu ulangi permintaan sesuai kebutuhan.'),
  heading('6. Login dan Lupa Password'),
  ...numbered(['Pada halaman autentikasi, pilih tab Login.', 'Masukkan identifier (email atau No. RM) dan password.', 'Kirim OTP login, lalu masukkan OTP dari email.', 'Setelah verifikasi, aplikasi mengaktifkan sesi akun.', 'Untuk lupa password, buka tab Lupa, masukkan identifier, OTP, lalu password baru.']),
  p('Apabila sesi berakhir atau aplikasi meminta login ulang, lakukan login kembali. Jangan memasukkan OTP yang sudah kedaluwarsa.'),
  heading('7. Menghubungkan atau Mengubah No. RM'),
  p('Hubungan No. RM diperlukan untuk membuka data layanan medis personal. Proses ini memverifikasi kecocokan identitas pasien dan akun melalui OTP email.'),
  ...numbered(['Buka Profil.', 'Pilih Hubungkan No. RM atau Ubah No. RM.', 'Isi No. RM, NIK 16 digit, tanggal lahir, dan password akun.', 'Tekan Kirim OTP Email.', 'Masukkan OTP enam digit yang diterima email, lalu pilih Verifikasi No. RM.', 'Tunggu notifikasi berhasil dan kembali ke halaman Profil.']),
  note('Masukkan data persis seperti data yang tercatat di rumah sakit. Bila verifikasi gagal, jangan menebak data; hubungi petugas pendaftaran untuk koreksi data sumber.'),
  heading('8. Layanan Personal dan Rekam Medis'),
  p('Setelah akun serta No. RM terhubung, pengguna dapat mengakses profil pasien, riwayat kunjungan, diagnosis/tindakan, hasil laboratorium, hasil radiologi, resep/obat, dan ringkasan medis yang tersedia. Pilih menu dari Beranda dan tunggu data dimuat.'),
  ...bullets(['Gunakan hanya untuk informasi diri sendiri atau pasien yang sah diwakili.', 'Resume medis dapat menyediakan opsi Lihat PDF atau Download. File disimpan pada penyimpanan aplikasi dan dibuka menggunakan aplikasi pembaca PDF pada perangkat.', 'Bila data kosong, itu tidak selalu berarti data hilang; bisa berarti belum ada data yang tersedia untuk akun/rekam medis tertaut.']),
  heading('9. Booking Pendaftaran Umum'),
  p('Tab Booking menampilkan formulir booking dan riwayat booking milik akun. Sebelum mengirim booking, pastikan No. RM telah terhubung dan layanan/poli yang dipilih sesuai.'),
  ...numbered(['Pilih tab Booking.', 'Pada tab Buat, tentukan tanggal kunjungan melalui kalender.', 'Pilih poli dan dokter yang tersedia.', 'Tinjau panel Jadwal dan Kuota, termasuk jumlah kuota dan sisa.', 'Pilih informasi pembayaran/jenis pasien sesuai pilihan yang tersedia.', 'Kirim booking dan simpan nomor/kode booking yang ditampilkan.', 'Buka tab Saya untuk memeriksa riwayat booking milik akun.']),
  ...image('02_booking.png', 'Halaman booking dan riwayat booking akun.'),
  note('Jangan mengirim booking berulang ketika jaringan lambat. Tunggu hasil permintaan terlebih dahulu, kemudian periksa tab Saya untuk memastikan status booking.'),
  heading('10. Memilih Jenis Antrian'),
  p('Tombol Antrian di tengah navigasi menampilkan dua jalur. Registrasi Umum membuka halaman nomor antrian/booking SIPANTES. Antrian BPJS akan membuka aplikasi Mobile JKN; apabila belum terpasang, perangkat dapat diarahkan ke Play Store.'),
  ...image('05_pilih_antrian.png', 'Halaman ketersediaan kamar sebagai salah satu informasi publik.'),
  heading('11. Profil, Privasi, Logout, dan Hapus Akun'),
  p('Tab Profil menunjukkan status akun dan status keterhubungan No. RM. Dari halaman ini pengguna dapat menghubungkan No. RM, membuka Kebijakan Privasi, menghapus akun, atau logout.'),
  ...image('04_profil.png', 'Halaman penghapusan akun dengan informasi konsekuensi penghapusan.'),
  ...numbered(['Logout: pilih Logout dan setujui konfirmasi. Sesi lokal dibersihkan; layanan personal akan meminta login ulang.', 'Hapus akun: pilih Hapus Akun, masukkan password untuk meminta OTP, masukkan OTP enam digit, lalu setujui konfirmasi permanen.']),
  note('Penghapusan akun menghapus/menanonimkan identitas akun, hubungan akun–No. RM, kredensial, OTP, dan sesi login. Rekam medis serta catatan pelayanan rumah sakit tidak ikut dihapus karena merupakan dokumen pelayanan kesehatan.'),
  heading('12. Penanganan Kendala'),
  table(['Kendala', 'Tindakan pengguna'], [['OTP tidak diterima', 'Periksa spam, koneksi, dan email terdaftar; minta OTP baru setelah menunggu.'], ['Gagal memuat data', 'Periksa koneksi, tutup-buka aplikasi, lalu coba lagi.'], ['Sesi habis', 'Login ulang menggunakan password dan OTP.'], ['No. RM gagal terhubung', 'Pastikan No. RM/NIK/tanggal lahir benar; hubungi pendaftaran bila tetap gagal.'], ['Booking belum terlihat', 'Jangan ulangi langsung; buka tab Saya atau hubungi rumah sakit dengan kode booking bila tersedia.'], ['Mobile JKN tidak terbuka', 'Pasang/perbarui Mobile JKN atau gunakan jalur registrasi umum.']]),
  heading('13. Kontak dan Penutup'),
  p('Informasi resmi RSUD Oto Iskandar Di Nata Kabupaten Bandung tersedia di https://rsudotista.bandungkab.go.id/. Untuk pertanyaan terkait pelayanan atau data pasien, gunakan kanal resmi rumah sakit dan jangan mengirimkan kredensial/OTP melalui kanal tidak resmi.'),
];

const techChildren = [
  ...cover('MANUAL BOOK TEKNIS', 'Panduan operasi, konfigurasi, keamanan, dan pemeliharaan aplikasi', 'MB-SIPANTES-TECH-001'),
  ...control('Administrator aplikasi, developer Flutter, QA, DevOps, dan petugas teknis yang berwenang.', 'Build Android, konfigurasi endpoint, autentikasi Bearer, struktur source, pengujian, diagnosis, serta rilis.'),
  heading('1. Ikhtisar Sistem'),
  p('SIPANTES adalah aplikasi Flutter Android dengan package id.rsudotista.sipantes. Aplikasi menerapkan pemisahan feature, repository, datasource, entity, dan state management menggunakan flutter_bloc. Data diperoleh dari REST API melalui ApiClient.'),
  table(['Komponen', 'Implementasi'], [['UI', 'Flutter Material, tema dan komponen bersama pada lib/core.'], ['State', 'flutter_bloc: AuthCubit, HomeCubit, RsApiCubit, NavigationCubit.'], ['HTTP', 'package http melalui ApiClient; timeout 20 detik.'], ['Sesi', 'flutter_secure_storage menyimpan identity dan token pair.'], ['File', 'path_provider dan open_filex untuk PDF resume medis.'], ['Backend default', 'https://api-mobile.rsudotista.my.id/api/v1']]),
  heading('2. Struktur Proyek'),
  table(['Lokasi', 'Tanggung jawab'], [['lib/main.dart dan lib/app.dart', 'Bootstrap aplikasi, dependency injection repository/datasource, MultiBlocProvider.'], ['lib/core/config/api_config.dart', 'Pemilihan base URL dan dart-define environment.'], ['lib/core/network/api_client.dart', 'HTTP, Bearer, refresh, retry, timeout, dan error handling.'], ['lib/features/auth', 'Login OTP, registrasi, reset password, klaim No. RM, hapus akun.'], ['lib/features/api_data', 'Profil, riwayat, hasil medis, resep, sumber daya rumah sakit.'], ['lib/features/booking', 'Kalender, opsi booking, pembuatan booking, dan booking milik pengguna.'], ['android/app', 'Manifest, signing, package, serta konfigurasi Android.'], ['test', 'Unit, contract, dan widget test.']]),
  heading('3. Konfigurasi Environment dan Build'),
  p('Default development, production, dan emulator Android menggunakan endpoint HTTPS yang sama. Konfigurasi dapat diubah melalui dart-define tanpa mengubah source.'),
  table(['Parameter', 'Fungsi'], [['APP_ENV', 'dev (default) atau prod.'], ['API_BASE_URL', 'Override umum base URL.'], ['DEV_API_BASE_URL', 'Override khusus APP_ENV=dev.'], ['PROD_API_BASE_URL', 'Override khusus APP_ENV=prod.']]),
  ...numbered(['Jalankan flutter pub get.', 'Jalankan flutter analyze dan flutter test sebelum build.', 'Untuk debug default: flutter run.', 'Untuk API lokal emulator: flutter run --dart-define=APP_ENV=dev --dart-define=DEV_API_BASE_URL=http://10.0.2.2:8080/api/v1 (sesuaikan host/port).', 'Untuk APK rilis: flutter build apk --release --dart-define=APP_ENV=prod.']),
  note('Release membutuhkan android/key.properties dan keystore yang valid. Jangan menyimpan key.properties, keystore produksi, password, OTP, atau token dalam repository.'),
  heading('4. Arsitektur Autentikasi dan Sesi'),
  p('Alur registrasi: POST /auth/register → POST /auth/verify-otp-new-user → POST /auth/set-password. Alur login: POST /auth/login → POST /auth/verify-otp. Respons sukses menyediakan identity, access token, refresh token, dan metadata kedaluwarsa.'),
  ...bullets(['Endpoint terproteksi menerima Authorization: Bearer <access_token>.', 'Pasangan token disimpan atomik pada key auth_token_pair_v1; identitas pada auth_identity.', 'Token akses yang hampir kedaluwarsa diperbarui proaktif melalui POST /auth/refresh.', 'HTTP 401 pada request terproteksi memicu satu refresh dan maksimum satu pengulangan request.', 'Refresh bersifat single-flight agar request paralel tidak menggunakan refresh token yang sudah dirotasi.', 'Refresh 401 menghapus sesi; gangguan jaringan/503 saat refresh tidak langsung menghapus token.', 'Logout membersihkan sesi lokal meskipun panggilan API logout gagal.']),
  heading('5. Endpoint Fungsional'),
  table(['Domain', 'Endpoint utama', 'Akses'], [['Auth', '/auth/register, /auth/login, /auth/verify-otp, /auth/refresh, /auth/logout', 'Campuran; logout/refresh sesuai sesi.'], ['Akun', '/auth/me, /auth/medical-record/request, /confirm, /account-deletion/*', 'Bearer.'], ['Data pasien', '/mobile/patient/profile, visits, medical-summaries, laboratory-results, radiology-results, prescriptions', 'Bearer.'], ['Resume PDF', '/mobile/patient/medical-summaries/{registration_id}/pdf', 'Bearer; respons biner.'], ['Booking', '/mobile/booking/calendar, options/{poliId}, general, general/mine', 'Buat/mine: Bearer.'], ['Data publik', '/polis, /jadwaldokters, /mobile/hospital/room-availabilities', 'Publik.']]),
  note('Jangan mengirim email, No. RM, atau identifier sebagai sumber otorisasi pada endpoint personal. Kepemilikan data harus ditentukan backend berdasarkan principal Bearer.'),
  heading('6. Keamanan Android dan Data'),
  ...bullets(['Manifest utama menggunakan android:allowBackup="false" dan android:usesCleartextTraffic="false".', 'Permission media/storage eksplisit dihapus dari manifest utama; aplikasi hanya menggunakan penyimpanan aplikasi untuk PDF.', 'Token tidak boleh masuk URL, log, analytics, exception yang dikirim keluar, screenshot, atau artefak UAT.', 'Klaim No. RM membutuhkan password, No. RM, NIK, tanggal lahir, dan OTP. Perlakukan seluruhnya sebagai data sensitif.', 'Penghapusan akun memerlukan password, OTP enam digit, serta konfirmasi pengguna.']),
  heading('7. Operasi Data dan Perilaku UI'),
  table(['Fitur', 'Operasi teknis'], [['Beranda', 'HomeCubit memuat data lokal/pintasan; navigasi pada IndexedStack.'], ['Poli & kamar', 'RsApiCubit mencari resource dan menampilkan hasil/kosong/error.'], ['Booking', 'Memuat kalender, opsi poli, lalu POST booking general dengan poli_id, tanggal, bayar, jenis_pasien, dokter_id, queue_group, is_jkn.'], ['Riwayat booking', 'GET /mobile/booking/general/mine dengan Bearer.'], ['Resume PDF', 'getBytes, simpan ke temporary/documents directory, buka melalui open_filex.'], ['BPJS', 'MobileJknLauncher membuka package app.bpjs.mobile atau fallback Play Store.']]),
  heading('8. Pengujian dan Kriteria Rilis'),
  ...numbered(['flutter analyze harus selesai tanpa issue.', 'flutter test harus lulus.', 'Uji mode tamu: informasi publik, poli, jadwal, kamar, dan privasi.', 'Uji autentikasi menggunakan akun uji berizin: registrasi, OTP, set password, login, reset password, logout.', 'Uji klaim No. RM dan data personal hanya dengan data uji/izin yang sesuai.', 'Uji booking termasuk kuota, tanggal libur/cuti, sukses, dan pencegahan duplikasi.', 'Uji refresh: access token kedaluwarsa, 401, refresh gagal, dan pemulihan jaringan.', 'Bangun APK release, periksa signing, instal pada perangkat/emulator bersih, dan lakukan smoke test.']),
  heading('9. Diagnosis Insiden'),
  table(['Gejala', 'Pemeriksaan dan tindakan'], [['INSTALL_FAILED_INSUFFICIENT_STORAGE', 'Storage emulator penuh. Wipe Data/hapus aplikasi lain, lalu flutter clean; flutter pub get; flutter run.'], ['401 pada data personal', 'Periksa status token/refresh dan login ulang; jangan memaksa identifier ke endpoint personal.'], ['Timeout/API tidak terhubung', 'Periksa base URL dart-define, DNS/jaringan, health endpoint, dan status backend.'], ['Kalender gagal', 'Periksa respons GET /mobile/booking/calendar serta konfigurasi hari libur/migrasi backend.'], ['PDF tidak terbuka', 'Periksa content-type, ruang penyimpanan aplikasi, dan aplikasi pembaca PDF perangkat.'], ['OTP gagal', 'Periksa layanan email/backend, masa berlaku OTP, serta jam perangkat.']]),
  heading('10. Prosedur Rilis dan Rollback'),
  ...numbered(['Pastikan branch/commit yang disetujui dan hasil test terdokumentasi.', 'Pasang keystore produksi melalui secret/CI, bukan repository.', 'Build APK/AAB dengan APP_ENV=prod dan endpoint produksi resmi.', 'Verifikasi package id, versionCode, versionName, signing certificate, dan manifest release.', 'Distribusikan ke kanal internal/produksi sesuai persetujuan.', 'Monitor health API, error autentikasi, booking, dan crash setelah rilis.', 'Untuk rollback, hentikan distribusi versi bermasalah, aktifkan versi sebelumnya yang ditandatangani, dan catat insiden.']),
  heading('11. Bukti Tampilan Emulator'),
  p('Screenshot berikut diambil dari emulator yang terhubung pada saat penyusunan. Tampilan menggunakan akun uji; dokumen tidak menyalin OTP, token, NIK, atau data medis klinis.'),
  ...image('01_beranda.png', 'Beranda.'), ...image('02_booking.png', 'Booking.'), ...image('03_poli_jadwal.png', 'Poli & Jadwal.'), ...image('04_profil.png', 'Profil.'),
  heading('12. Persetujuan'),
  table(['Disusun', 'Diperiksa', 'Disetujui'], [['Nama / tanggal / tanda tangan:', 'Nama / tanggal / tanda tangan:', 'Nama / tanggal / tanda tangan:']]),
];

function makeDoc(children, title, name) {
  const doc = new Document({ creator: 'Tim SIPANTES', title, description: title, sections: [{ properties: { page: { margin: { top: 900, right: 900, bottom: 900, left: 900 } } }, children }] });
  return Packer.toBuffer(doc).then((buffer) => fs.writeFileSync(path.join(output, name), buffer));
}
function htmlDocument(title, sections) {
  const esc = (s) => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
  const body = sections.map(([h, content]) => `<section><h1>${esc(h)}</h1>${content}</section>`).join('');
  return `<!doctype html><html><head><meta charset="utf-8"><title>${title}</title><style>@page{size:A4;margin:17mm}body{font:10.5pt Arial;color:#18312f;line-height:1.42}h1{color:#155c55;border-bottom:2px solid #43afa5;padding-bottom:5px;margin-top:22px;font-size:17pt}h2{color:#216c65;font-size:12pt}table{border-collapse:collapse;width:100%;margin:8px 0}td,th{border:1px solid #9ebdb8;padding:6px;vertical-align:top}th{background:#cbeae6}li{margin:4px 0}.cover{height:230mm;text-align:center;padding-top:55mm;page-break-after:always}.cover h1{border:0;font-size:29pt}.note{background:#eaf6f4;border-left:5px solid #43afa5;padding:9px}.fig{page-break-inside:avoid;text-align:center}.fig img{width:69mm;border:1px solid #b5c5c3}.cap{font-style:italic;color:#435552;font-size:9pt}</style></head><body><div class="cover"><h1>${title}</h1><h2>SIPANTES</h2><p>RSUD Oto Iskandar Di Nata Kabupaten Bandung</p><p><b>Versi 1.0 | ${date}</b></p><p>Dokumen operasional internal</p></div>${body}</body></html>`;
}
const userHtml = htmlDocument('MANUAL BOOK PENGGUNA', [
 ['Tujuan dan Ketentuan', '<p>SIPANTES membantu pengguna memperoleh informasi layanan, mengelola akun, menghubungkan rekam medis, melihat layanan personal, serta membuat booking pendaftaran umum.</p><ul><li>Gunakan email aktif untuk OTP.</li><li>Jangan membagikan password, OTP, NIK, atau No. RM.</li><li>Data jadwal, kuota, kamar, dan antrean dapat berubah.</li></ul>'],
 ['Beranda dan Informasi Publik', '<p>Gunakan Beranda untuk pintasan layanan. Tab Poli & Jadwal digunakan untuk mencari poli, dokter, jadwal, dan ketersediaan kamar tanpa login.</p><div class="fig"><img src="screenshots/01_beranda.png"><p class="cap">Beranda sesi akun aktif.</p></div><div class="fig"><img src="screenshots/03_poli_jadwal.png"><p class="cap">Poli & Jadwal.</p></div>'],
 ['Registrasi, Login, dan Lupa Password', '<ol><li>Pilih Login/Registrasi dari Profil.</li><li>Isi data yang diminta dan kirim OTP email.</li><li>Masukkan OTP yang masih berlaku.</li><li>Pada registrasi, buat password 8–72 karakter berisi huruf dan angka.</li><li>Untuk lupa password, gunakan tab Lupa dan verifikasi OTP.</li></ol><p class="note">OTP bersifat rahasia; periksa spam jika email belum diterima.</p>'],
 ['Hubungkan No. RM dan Data Personal', '<ol><li>Buka Profil dan pilih Hubungkan/Ubah No. RM.</li><li>Masukkan No. RM, NIK 16 digit, tanggal lahir, dan password.</li><li>Kirim dan verifikasi OTP email.</li></ol><p>Setelah terhubung, menu personal meliputi profil pasien, riwayat kunjungan, diagnosis/tindakan, hasil lab, radiologi, resep, serta resume medis PDF.</p>'],
 ['Booking dan Antrian', '<ol><li>Pilih Booking.</li><li>Tentukan tanggal, poli, dokter, dan pilihan yang tersedia.</li><li>Tinjau jadwal dan kuota.</li><li>Kirim booking; cek tab Saya untuk riwayat booking.</li></ol><div class="fig"><img src="screenshots/02_booking.png"><p class="cap">Halaman pendaftaran/antrian.</p></div><div class="fig"><img src="screenshots/05_pilih_antrian.png"><p class="cap">Informasi ketersediaan kamar.</p></div><p class="note">Jangan kirim booking berulang saat jaringan lambat.</p>'],
 ['Profil, Logout, Hapus Akun, dan Kendala', '<div class="fig"><img src="screenshots/04_profil.png"><p class="cap">Halaman penghapusan akun.</p></div><p>Logout membersihkan sesi perangkat. Hapus Akun memerlukan password, OTP email, dan konfirmasi permanen. Rekam medis rumah sakit tidak ikut dihapus.</p><table><tr><th>Kendala</th><th>Tindakan</th></tr><tr><td>OTP tidak diterima</td><td>Periksa spam dan minta OTP baru.</td></tr><tr><td>Data gagal dimuat</td><td>Periksa koneksi dan coba kembali.</td></tr><tr><td>Sesi habis</td><td>Login ulang.</td></tr><tr><td>No. RM gagal terhubung</td><td>Validasi data atau hubungi pendaftaran.</td></tr></table>'],
]);
const techHtml = htmlDocument('MANUAL BOOK TEKNIS', [
 ['Ikhtisar dan Struktur', '<p>SIPANTES adalah aplikasi Flutter Android (id.rsudotista.sipantes) dengan flutter_bloc, HTTP ApiClient, flutter_secure_storage, path_provider, dan open_filex.</p><table><tr><th>Lokasi</th><th>Peran</th></tr><tr><td>lib/core</td><td>Config, network, theme, widget bersama.</td></tr><tr><td>lib/features/auth</td><td>OTP, sesi, klaim No. RM, hapus akun.</td></tr><tr><td>lib/features/api_data</td><td>Data pasien dan sumber daya RS.</td></tr><tr><td>lib/features/booking</td><td>Kalender, opsi, booking, riwayat.</td></tr></table>'],
 ['Konfigurasi dan Build', '<p>Base URL default: https://api-mobile.rsudotista.my.id/api/v1. Override melalui APP_ENV, API_BASE_URL, DEV_API_BASE_URL, atau PROD_API_BASE_URL.</p><ol><li>flutter pub get</li><li>flutter analyze</li><li>flutter test</li><li>flutter run</li><li>flutter build apk --release --dart-define=APP_ENV=prod</li></ol><p class="note">Release memerlukan keystore/key.properties yang aman; jangan commit secret.</p>'],
 ['Auth dan Keamanan', '<p>Registrasi: /auth/register → /auth/verify-otp-new-user → /auth/set-password. Login: /auth/login → /auth/verify-otp. Endpoint personal memakai Bearer token.</p><ul><li>Token pair disimpan di secure storage.</li><li>Refresh proaktif dan single-flight pada /auth/refresh.</li><li>401 memicu satu refresh dan satu retry; refresh 401 menghapus sesi.</li><li>allowBackup=false dan usesCleartextTraffic=false pada manifest release.</li><li>Token/OTP/NIK/No. RM tidak boleh masuk URL atau log.</li></ul>'],
 ['Endpoint dan Pengujian', '<p>Endpoint personal: /mobile/patient/profile, visits, medical-summaries, laboratory-results, radiology-results, prescriptions, booking/general/mine, dan PDF resume. Endpoint publik meliputi poli, jadwal dokter, dan kamar.</p><ol><li>Analisis dan test harus lulus.</li><li>Uji guest, auth, klaim RM, data personal, booking, refresh, dan PDF memakai akun/data uji berizin.</li><li>Verifikasi signing sebelum distribusi.</li></ol>'],
 ['Diagnosis dan Bukti Emulator', '<table><tr><th>Gejala</th><th>Tindakan</th></tr><tr><td>Storage emulator penuh</td><td>Wipe Data/hapus aplikasi, flutter clean, lalu run ulang.</td></tr><tr><td>401</td><td>Periksa sesi/refresh dan login ulang.</td></tr><tr><td>Timeout</td><td>Periksa base URL, health API, dan jaringan.</td></tr><tr><td>PDF gagal dibuka</td><td>Periksa respons biner, storage, dan pembaca PDF.</td></tr></table><div class="fig"><img src="screenshots/01_beranda.png"><p class="cap">Beranda.</p></div><div class="fig"><img src="screenshots/02_booking.png"><p class="cap">Booking.</p></div>'],
]);

await makeDoc(userChildren, 'SIPANTES — Manual Book Pengguna', 'Manual_Book_Pengguna_SIPANTES.docx');
await makeDoc(techChildren, 'SIPANTES — Manual Book Teknis', 'Manual_Book_Teknis_SIPANTES.docx');
fs.writeFileSync(path.join(output, 'Manual_Book_Pengguna_SIPANTES.html'), userHtml);
fs.writeFileSync(path.join(output, 'Manual_Book_Teknis_SIPANTES.html'), techHtml);
for (const name of ['Manual_Book_Pengguna_SIPANTES', 'Manual_Book_Teknis_SIPANTES']) {
  const html = fs.readFileSync(path.join(output, `${name}.html`), 'utf8').replace(/screenshots\/([^\"]+\.png)/g, (_, file) => `data:image/png;base64,${fs.readFileSync(path.join(screenshots, file)).toString('base64')}`);
  fs.writeFileSync(path.join(output, `${name}.print.html`), html);
}
console.log('DOCX and HTML source generated.');
