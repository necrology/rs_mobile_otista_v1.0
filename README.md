# RSUD Otista Mobile

Project Flutter untuk aplikasi `RSUD Otista Mobile`.

Branding utama:

- Nama aplikasi: `RSUD Otista Mobile`
- Nama lengkap: `RSUD Oto Iskandar Di Nata Kabupaten Bandung`
- Version: `1.0.0`

Identitas rumah sakit:

- Alamat: `Jl. Gading Tutuka, RT 01 RW 01, Kp. Cincin Kolot, Kec. Soreang, Kab. Bandung, Jawa Barat`
- Website: `https://rsudotista.bandungkab.go.id/`
- Email: `rsudotista@bandungkab.go.id`

Konfigurasi API:

- Prod default: `https://api-mobile.rsudotista.my.id/api/v1`
- Health prod: `https://api-mobile.rsudotista.my.id/api/v1/health`
- Dev lokal: `flutter run --dart-define=APP_ENV=dev --dart-define=DEV_API_BASE_URL=http://localhost:8080/api/v1`
- Override umum: `flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1`
- Override prod: `flutter run --dart-define=APP_ENV=prod --dart-define=PROD_API_BASE_URL=https://api-mobile.rsudotista.my.id/api/v1`
- Android emulator biasanya perlu memakai host mesin: `--dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1`
