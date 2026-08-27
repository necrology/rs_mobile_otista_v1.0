# Panduan Integrasi Auth Bearer SIPANTES

Sistem Pendaftaran Terintegrasi RSUD Oto Iskandar Di Nata

Dokumen ini menjelaskan integrasi aplikasi Flutter dengan API yang telah diamankan. Mode produksi, development, dan Android emulator menggunakan base URL berikut secara default:

`https://api-mobile.rsudotista.my.id/api/v1`

Base URL dapat diganti saat build menggunakan `--dart-define=API_BASE_URL=...`. Gunakan `--dart-define=DEV_API_BASE_URL=...` hanya bila perlu menguji server lokal.

## Kontrak autentikasi

1. Registrasi awal mengirim nama, email, dan nomor telepon. Password belum dikirim pada tahap ini.
2. `POST /auth/verify-otp-new-user` harus mengembalikan `registration_ticket`.
3. Password 8-72 karakter yang mengandung huruf dan angka dikirim ke `POST /auth/set-password` bersama `registration_ticket`.
4. Login dimulai lewat `POST /auth/login`, lalu OTP diverifikasi lewat `POST /auth/verify-otp`.
5. Respons sukses set-password atau verifikasi login wajib berisi identitas, access token, refresh token, serta waktu kedaluwarsanya.
6. Access token dikirim sebagai `Authorization: Bearer <access_token>` hanya untuk endpoint terproteksi.
7. Refresh dilakukan melalui `POST /auth/refresh`. Aplikasi hanya menjalankan satu refresh pada satu waktu agar refresh token yang dirotasi tidak dipakai ulang oleh permintaan paralel.

Pasangan access/refresh token disimpan sebagai satu data atomik di secure storage (`auth_token_pair_v1`). Identitas tampilan disimpan terpisah (`auth_identity`). Instalasi lama yang hanya memiliki identitas tanpa token akan keluar otomatis dan harus login ulang.

## Endpoint yang mengambil identitas dari token

Endpoint berikut tidak boleh lagi menerima `email` atau `no_rm` sebagai sumber otorisasi:

- `/auth/me`
- `/mobile/patient/profile`
- `/mobile/patient/visits`
- `/mobile/patient/medical-summaries`
- `/mobile/patient/laboratory-results`
- `/mobile/patient/radiology-results`
- `/mobile/patient/prescriptions`
- `/mobile/booking/general/mine`
- `POST /mobile/booking/general`
- `/mobile/patient/medical-summaries/{registration_id}/pdf`

`no_rm`, NIK, dan tanggal lahir tetap digunakan hanya dalam proses klaim awal rekam medis. Sesudah rekam medis tertaut, handler harus mengambil user/pasien dari klaim token di server.

## Perilaku sesi

- Access token yang hampir kedaluwarsa diperbarui sebelum permintaan terproteksi.
- Respons 401 memicu satu kali refresh dan satu kali pengulangan permintaan.
- Refresh 401 menghapus sesi lokal dan mengembalikan pengguna ke mode tamu.
- Gangguan jaringan atau respons 503 saat refresh tidak langsung menghapus token agar pengguna dapat mencoba lagi ketika layanan pulih.
- Logout selalu membersihkan sesi lokal, termasuk ketika pemanggilan logout API gagal.
- Token tidak boleh dimasukkan ke URL, log, pesan error, analytics, atau objek identitas pasien.

## Build dan validasi

Jalankan dari root project Flutter:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=APP_ENV=prod
```

APK release berada di `build/app/outputs/flutter-apk/app-release.apk`.

Build Android saat ini masih memakai debug signing pada varian release (`android/app/build.gradle.kts`). APK tersebut valid untuk verifikasi internal, tetapi operator deployment wajib menggantinya dengan production keystore yang disimpan melalui secret/CI sebelum distribusi resmi. Jangan menyimpan password atau file keystore produksi di repository.

Untuk uji integrasi positif, siapkan satu akun uji dengan email yang dapat menerima OTP. Uji minimum mencakup registrasi, set-password, login OTP, `/auth/me`, seluruh data rekam medis, PDF, booking milik pengguna, refresh token, dan logout. Jangan menggunakan akun pasien produksi tanpa persetujuan pemilik data.

## Prasyarat backend

Endpoint kalender booking memerlukan migrasi tabel hari libur yang sesuai dengan source API. Bila `GET /mobile/booking/calendar` masih mengembalikan HTTP 500, operator backend harus menjalankan migration/DDL yang tercatat di repository Go sebelum menguji alur booking penuh. Perbaikan Flutter tidak dapat menggantikan perubahan skema database tersebut.

Manifest release menonaktifkan cleartext HTTP dan Android backup. Manifest debug/profile mengizinkan cleartext hanya untuk pengujian API lokal melalui emulator.

## Bukti verifikasi 16 Juli 2026

- Hasil probe produksi: `docs/evidence/hasil_uji_smoke_bearer_prod_2026-07-16.csv`
- Mode tamu pada APK release: `docs/screenshots/07_release_mode_tamu_bearer.png`
- Form login: `docs/screenshots/08_release_form_login_bearer.png`
- Form registrasi: `docs/screenshots/09_release_form_registrasi_ticket.png`
- Build produksi pada emulator menampilkan 48 poli tanpa error kalender: `docs/screenshots/10_prod_poli_public_48.png`

Probe hanya menggunakan operasi GET yang aman dan request tanpa kredensial. Tidak ada OTP, token pasien, klaim rekam medis, atau transaksi booking produksi yang dibuat.

Dokumen formal yang telah disesuaikan:

- `docs/Modul_RSUD_Otista_Mobile_API_dan_Pengujian.docx` — versi 1.1, 11 halaman, raw contract, hasil test, serta 4 screenshot tertanam.
- `docs/SPO_RSUD_Otista_Mobile_Deployment_dan_Pengujian_API.docx` — versi 1.1, 6 halaman, urutan DDL/deploy/test/rollback untuk operator.

Versi 1.0 yang merekam kondisi Cloudflare 403 sebelum hardening disimpan di `docs/archive/` sebagai bukti historis dan tidak boleh dipakai sebagai status produksi terkini. Kedua DOCX dapat diregenerasi dengan:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_docs_v1_1.ps1
```
