# SIPANTES

Project Flutter untuk aplikasi SIPANTES.

Branding utama:

- Title: SIPANTES
- Subtitle: Sistem Pendaftaran Terintegrasi RSUD Oto Iskandar Di Nata
- Nama rumah sakit: RSUD Oto Iskandar Di Nata Kabupaten Bandung
- Version: `1.0.0`

Identitas rumah sakit:

- Alamat: `Jl. Gading Tutuka, RT 01 RW 01, Kp. Cincin Kolot, Kec. Soreang, Kab. Bandung, Jawa Barat`
- Website: `https://rsudotista.bandungkab.go.id/`
- Email: `rsudotista@bandungkab.go.id`

Konfigurasi API:

- Default dev, prod, dan Android emulator: `https://api-mobile.rsudotista.my.id/api/v1`
- Health prod: `https://api-mobile.rsudotista.my.id/api/v1/health`
- Override dev lokal (opsional): `flutter run --dart-define=APP_ENV=dev --dart-define=DEV_API_BASE_URL=http://localhost:8080/api/v1`
- Override umum (opsional): `flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1`
- Override prod: `flutter run --dart-define=APP_ENV=prod --dart-define=PROD_API_BASE_URL=https://api-mobile.rsudotista.my.id/api/v1`
- Android emulator otomatis memakai endpoint default yang sama; override hanya diperlukan untuk server lokal.

Kebijakan dan penghapusan akun:

- Kebijakan privasi: `https://api-mobile.rsudotista.my.id/privacy-policy`
- Penghapusan akun web: `https://api-mobile.rsudotista.my.id/account-deletion`
- Penghapusan dari aplikasi tersedia pada `Profil & Akun > Hapus Akun` setelah login.
- Penghapusan akun melepaskan identitas akun mobile dan sesi login, tetapi tidak menghapus rekam medis serta dokumen pelayanan rumah sakit.
