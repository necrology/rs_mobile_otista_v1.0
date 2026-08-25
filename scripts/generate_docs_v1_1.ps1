param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

$docsDirectory = Join-Path $ProjectRoot 'docs'
$archiveDirectory = Join-Path $docsDirectory 'archive'
$modulePath = Join-Path $docsDirectory 'Modul_RSUD_Otista_Mobile_API_dan_Pengujian.docx'
$spoPath = Join-Path $docsDirectory 'SPO_RSUD_Otista_Mobile_Deployment_dan_Pengujian_API.docx'

New-Item -ItemType Directory -Path $archiveDirectory -Force | Out-Null

$moduleArchive = Join-Path $archiveDirectory 'Modul_RSUD_Otista_Mobile_API_dan_Pengujian_v1.0_2026-07-14.docx'
$spoArchive = Join-Path $archiveDirectory 'SPO_RSUD_Otista_Mobile_Deployment_dan_Pengujian_API_v1.0_2026-07-14.docx'
if ((Test-Path -LiteralPath $modulePath) -and -not (Test-Path -LiteralPath $moduleArchive)) {
    Copy-Item -LiteralPath $modulePath -Destination $moduleArchive
}
if ((Test-Path -LiteralPath $spoPath) -and -not (Test-Path -LiteralPath $spoArchive)) {
    Copy-Item -LiteralPath $spoPath -Destination $spoArchive
}

function Get-FileUri {
    param([Parameter(Mandatory)][string]$Path)
    return ([Uri](Resolve-Path -LiteralPath $Path).Path).AbsoluteUri
}

$sharedCss = @'
@page { size: A4; margin: 16mm 17mm 17mm 17mm; }
body { font-family: Aptos, Arial, sans-serif; font-size: 10pt; line-height: 1.35; color: #18312f; }
h1 { color: #174f49; font-size: 19pt; border-bottom: 2px solid #43afa5; padding-bottom: 4px; margin-top: 18px; }
h2 { color: #216c65; font-size: 13pt; margin-top: 14px; }
h3 { color: #2d5955; font-size: 11pt; margin-top: 11px; }
p { margin: 5px 0 7px 0; }
ul, ol { margin-top: 4px; margin-bottom: 8px; }
li { margin-bottom: 3px; }
table { width: 100%; border-collapse: collapse; margin: 8px 0 12px 0; font-size: 8.5pt; }
th { background: #d8efec; color: #123f3b; font-weight: bold; border: 1px solid #7ba9a4; padding: 5px; }
td { border: 1px solid #a7bfbc; padding: 5px; vertical-align: top; }
pre { font-family: Consolas, monospace; font-size: 8pt; white-space: pre-wrap; background: #f2f5f4; border: 1px solid #c7d6d4; padding: 8px; margin: 6px 0 10px 0; color: #172b29; }
.cover { text-align: center; padding-top: 70px; page-break-after: always; }
.cover h1 { border: 0; font-size: 27pt; margin-bottom: 12px; }
.cover h2 { font-size: 18pt; }
.subtitle { font-size: 13pt; color: #486d69; }
.status { font-size: 14pt; font-weight: bold; color: #a34712; border: 2px solid #d8955a; padding: 10px; margin: 22px 0; }
.note { background: #eef8f7; border-left: 5px solid #43afa5; padding: 9px; margin: 8px 0; }
.warning { background: #fff5e9; border-left: 5px solid #df8c39; padding: 9px; margin: 8px 0; }
.danger { background: #fff0ef; border-left: 5px solid #cf5148; padding: 9px; margin: 8px 0; }
.small { font-size: 8pt; color: #536d6a; }
.pass { color: #13745d; font-weight: bold; }
.fail { color: #b33f32; font-weight: bold; }
.hold { color: #a45d13; font-weight: bold; }
.page-break { page-break-before: always; }
.figure { text-align: center; page-break-before: always; }
.figure img { width: 84mm; height: auto; border: 1px solid #b5c5c3; }
.caption { font-size: 9pt; font-style: italic; color: #486663; margin: 7px 20px; }
.signature td { height: 48px; }
'@

$moduleHtml = @'
<!DOCTYPE html>
<html><head><meta charset="utf-8" /><title>MOD-RSOM-API-001 v1.1</title><style>{{CSS}}</style></head><body>
<div class="cover">
  <h1>MODUL INTEGRASI API DAN PENGUJIAN</h1>
  <h2>RSUD Otista Mobile</h2>
  <p class="subtitle">Bearer session, kontrak API, aplikasi Flutter, bukti emulator, dan hasil probe produksi</p>
  <p><b>MOD-RSOM-API-001 &#183; Versi 1.1 &#183; 16 Juli 2026 (WIB)</b></p>
  <div class="status">HOLD UNTUK DISTRIBUSI RESMI</div>
  <p>Cloudflare tidak lagi memblokir API. HOLD tersisa karena kalender booking HTTP 500, alur OTP positif belum diuji dengan akun terkontrol, dan APK release masih memakai debug signing.</p>
  <p class="small">Klasifikasi Internal &#8212; token, OTP, password, NIK, No. RM, dan data klinis nyata dilarang dicantumkan.</p>
</div>

<h1>Pengendalian Dokumen</h1>
<table><tr><th>Atribut</th><th>Nilai</th></tr>
<tr><td>Repositori Flutter</td><td>C:\Source Flutter\rs_mobile_otista_v1.0</td></tr>
<tr><td>Repositori API</td><td>C:\Source Golang\ApiRsudOtistaMobile</td></tr>
<tr><td>Base URL produksi</td><td>https://api-mobile.rsudotista.my.id/api/v1</td></tr>
<tr><td>Health</td><td>https://api-mobile.rsudotista.my.id/api/v1/health</td></tr>
<tr><td>Emulator</td><td>EMULATOR MAUL / emulator-5554</td></tr>
<tr><td>Aplikasi</td><td>id.go.bandungkab.rsudotista.mobile &#183; 1.0.0 (versionCode 1)</td></tr>
</table>

<h1>1. Ringkasan Eksekutif</h1>
<p>Client Flutter telah disesuaikan dengan hardening API Go. Identitas pasien pada endpoint terlindungi kini berasal dari Bearer session di server. Email dan No. RM tidak lagi dikirim sebagai sumber otorisasi. Access/refresh token disimpan sebagai satu pasangan di secure storage dan rotasi refresh dijalankan single-flight agar request paralel tidak memakai ulang refresh token lama.</p>
<table><tr><th>Area</th><th>Hasil</th><th>Status</th></tr>
<tr><td>Health produksi</td><td>HTTP 200 application/json; status ok; tanpa challenge HTML</td><td class="pass">LULUS</td></tr>
<tr><td>Auth tanpa Bearer</td><td>/auth/me dan profil pasien menghasilkan 401</td><td class="pass">LULUS SECURITY</td></tr>
<tr><td>Route generik sensitif</td><td>/tables, /pasiens, registrasi/antrian legacy menghasilkan 404</td><td class="pass">LULUS SECURITY</td></tr>
<tr><td>Flutter analyze</td><td>No issues found</td><td class="pass">LULUS</td></tr>
<tr><td>Flutter test</td><td>9 dari 9 test lulus</td><td class="pass">LULUS</td></tr>
<tr><td>APK release</td><td>Build sukses, 56.649.963 byte</td><td class="pass">LULUS INTERNAL</td></tr>
<tr><td>Kalender booking</td><td>HTTP 500, gagal mengambil kalender booking</td><td class="fail">GAGAL BACKEND</td></tr>
<tr><td>OTP/login positif</td><td>Belum diuji; tidak ada akun/mailbox uji terkontrol</td><td class="hold">BELUM</td></tr>
<tr><td>Signing Android</td><td>Certificate CN=Android Debug</td><td class="hold">HOLD</td></tr>
</table>

<h1>2. Ruang Lingkup dan Batasan</h1>
<ul>
<li>Perubahan source Flutter, kontrak Bearer, unit/contract test, release build, probe GET produksi, dan smoke test emulator.</li>
<li>Tidak membuat akun, mengirim OTP, menghubungkan rekam medis, atau membuat booking produksi.</li>
<li>Tidak memakai kredensial server dan tidak mengubah konfigurasi Cloudflare/server.</li>
<li>Hasil positif endpoint terlindungi dibuktikan lewat contract test lokal. End-to-end tetap memerlukan akun uji dan mailbox OTP.</li>
<li>Screenshot tidak memuat PII/PHI atau token.</li>
</ul>

<h1>3. Arsitektur Sesi dan Identitas</h1>
<pre>Aplikasi Flutter
  &#9500;&#9472; endpoint publik &#8594; tanpa Authorization
  &#9492;&#9472; endpoint protected &#8594; Authorization: Bearer &lt;access_token&gt;
       &#9500;&#9472; access hampir kedaluwarsa / HTTP 401
       &#9500;&#9472; satu POST /auth/refresh untuk seluruh request paralel
       &#9500;&#9472; simpan pasangan access + refresh yang dirotasi
       &#9492;&#9472; ulangi request protected maksimal satu kali

API Go &#8594; Session principal &#8594; user_id/patient_id/email/no_rm dari database</pre>
<ul>
<li>Token opaque tidak dimasukkan ke PatientIdentity, AuthState, URL, log, analytics, atau pesan error.</li>
<li>Refresh 401 menghapus sesi. Refresh 503/network error mempertahankan token agar dapat dicoba kembali.</li>
<li>Cache lama yang hanya memiliki identity tanpa token dianggap guest dan dibersihkan.</li>
<li>Logout memanggil server lalu tetap menghapus sesi lokal dalam <i>finally</i>.</li>
<li>No. RM, NIK, dan tanggal lahir hanya dipakai pada klaim awal; setelah tertaut, ownership berasal dari principal sesi.</li>
</ul>

<h1>4. Kontrak Alur Auth</h1>
<table><tr><th>Tahap</th><th>Endpoint</th><th>Kontrak</th></tr>
<tr><td>Registrasi</td><td>POST /auth/register</td><td>Nama, email, telepon; password belum dikirim</td></tr>
<tr><td>OTP baru</td><td>POST /auth/verify-otp-new-user</td><td>Menghasilkan registration_ticket sekali pakai</td></tr>
<tr><td>Set password</td><td>POST /auth/set-password</td><td>password + registration_ticket; menghasilkan identity + token pair</td></tr>
<tr><td>Login</td><td>POST /auth/login</td><td>Identifier (email atau No. RM) + Password; meminta OTP</td></tr>
<tr><td>Verifikasi login</td><td>POST /auth/verify-otp</td><td>Identifier + OTP; menghasilkan identity + token pair</td></tr>
<tr><td>Refresh</td><td>POST /auth/refresh</td><td>Rotasi access/refresh; single-flight di client</td></tr>
<tr><td>Validasi</td><td>GET /auth/me</td><td>Bearer wajib</td></tr>
<tr><td>Logout</td><td>POST /auth/logout</td><td>Bearer wajib; mencabut session family</td></tr>
<tr><td>Klaim RM</td><td>POST /auth/medical-record/request dan /confirm</td><td>Bearer wajib; payload snake_case</td></tr>
</table>

<h1>5. Endpoint Terproteksi</h1>
<ul>
<li>GET /mobile/patient/profile</li><li>GET /mobile/patient/visits</li>
<li>GET /mobile/patient/medical-summaries</li><li>GET /mobile/patient/medical-summaries/{registration_id}/pdf</li>
<li>GET /mobile/patient/laboratory-results</li><li>GET /mobile/patient/radiology-results</li>
<li>GET /mobile/patient/prescriptions</li><li>GET /mobile/booking/general/mine</li>
<li>POST /mobile/booking/general</li>
</ul>
<div class="note">Semua endpoint mengambil identity/ownership dari Bearer principal. Flutter tidak mengirim email, no_rm, atau identifier sebagai sumber otorisasi. GET /mobile/booking/general tidak tersedia (404) dan telah dilepas dari UI.</div>

<h1>6. Request dan Response Mentah</h1>
<h2>6.1 Health produksi &#8212; hasil aktual</h2>
<pre>GET https://api-mobile.rsudotista.my.id/api/v1/health
Accept: application/json

HTTP/1.1 200 OK
Content-Type: application/json
{"data":{"status":"ok"},"success":true}</pre>

<h2>6.2 Request protected tanpa Bearer &#8212; hasil aktual</h2>
<pre>GET /api/v1/auth/me

HTTP/1.1 401 Unauthorized
Content-Type: application/json
{"message":"autentikasi diperlukan","success":false}</pre>

<h2>6.3 Registrasi dan registration ticket &#8212; kontrak</h2>
<pre>POST /api/v1/auth/register
{"Username":"Pasien Uji","FullName":"Pasien Uji","Email":"qa@example.test","Phone":"0812..."}

POST /api/v1/auth/verify-otp-new-user
{"Email":"qa@example.test","OTP":"[6 DIGIT]"}

HTTP/1.1 200 OK
{"message":"Register otp verified","data":{"registration_ticket":"[REDACTED]","expires_at":"..."}}

POST /api/v1/auth/set-password
{"password":"[SECRET]","registration_ticket":"[REDACTED]"}</pre>

<h2>6.4 Login, token pair, dan refresh &#8212; contoh kontrak, bukan hasil akun prod</h2>
<pre>POST /api/v1/auth/login
{"Identifier":"qa@example.test","Password":"[SECRET]"}

POST /api/v1/auth/verify-otp
{"Identifier":"qa@example.test","OTP":"[6 DIGIT]"}

HTTP/1.1 200 OK
{"data":{"id":"qa@example.test","patientId":0,"email":"qa@example.test",
 "token_type":"Bearer","access_token":"[REDACTED]","access_expires_in":900,
 "refresh_token":"[REDACTED]","refresh_expires_in":2592000}}

POST /api/v1/auth/refresh
{"refresh_token":"[REDACTED]"}</pre>

<h2>6.5 Profil pasien dan PDF</h2>
<pre>GET /api/v1/mobile/patient/profile
Authorization: Bearer [REDACTED]

GET /api/v1/mobile/patient/medical-summaries/{registration_id}/pdf
Authorization: Bearer [REDACTED]

HTTP/1.1 200 OK
Content-Type: application/pdf
[PDF BINARY]</pre>
<p>PDF diambil sebagai byte melalui ApiClient, ditulis ke penyimpanan aplikasi, lalu dibuka sebagai file lokal. Email, No. RM, dan token tidak berada pada URL.</p>

<h2>6.6 Klaim rekam medis dan booking</h2>
<pre>POST /api/v1/auth/medical-record/request
Authorization: Bearer [REDACTED]
{"password":"[SECRET]","no_rm":"[REDACTED]","nik":"[REDACTED]","birth_date":"1990-12-31"}

POST /api/v1/mobile/booking/general
Authorization: Bearer [REDACTED]
{"poli_id":27,"tanggal":"2026-07-20","bayar":"2","jenis_pasien":"umum",
 "dokter_id":"10","queue_group":"HD","is_jkn":false}</pre>

<h2>6.7 Kalender dan route disabled &#8212; hasil aktual</h2>
<pre>GET /api/v1/mobile/booking/calendar?year=2026&amp;month=7&amp;poli_id=2
HTTP/1.1 500 Internal Server Error
{"message":"gagal mengambil kalender booking","success":false}

GET /api/v1/mobile/booking/general?limit=1
HTTP/1.1 404 Not Found
{"message":"route not found","success":false}</pre>

<h1>7. Implementasi Flutter</h1>
<table><tr><th>Komponen</th><th>Perubahan</th></tr>
<tr><td>ApiClient</td><td>requiresAuth, Bearer header, proactive refresh, single-flight, retry satu kali, binary response</td></tr>
<tr><td>Secure storage</td><td>Identity + token pair; token pair menjadi commit sesi; legacy identity-only dibersihkan</td></tr>
<tr><td>Auth</td><td>registration_ticket, Identifier, /auth/me, /auth/logout, claim snake_case</td></tr>
<tr><td>Pasien/booking</td><td>Tidak mengirim email/no_rm/identifier pada endpoint protected</td></tr>
<tr><td>PDF</td><td>Fetch byte dengan Bearer dan buka file lokal</td></tr>
<tr><td>UI booking</td><td>List booking publik yang disabled dihapus; tab tersisa Buat dan Saya</td></tr>
<tr><td>Android release</td><td>allowBackup=false; usesCleartextTraffic=false</td></tr>
<tr><td>Android debug/profile</td><td>Cleartext hanya untuk API lokal emulator</td></tr>
</table>

<h1>8. Hasil Pengujian</h1>
<h2>8.1 Gate source dan build</h2>
<pre>flutter analyze
No issues found!

flutter test
00:02 +9: All tests passed!

flutter build apk --release --dart-define=APP_ENV=prod
Built build\app\outputs\flutter-apk\app-release.apk (54.0MB)</pre>
<ul>
<li>5 test ApiClient: Bearer, concurrent refresh, invalid refresh, 503, dan retry maksimum.</li>
<li>2 test auth: registration ticket/payload serta penolakan response tanpa token pair.</li>
<li>1 test kontrak pasien, booking, dan PDF protected.</li>
<li>1 widget smoke test.</li>
</ul>

<h2>8.2 Probe produksi aman &#8212; 16 Juli 2026</h2>
<table><tr><th>Fungsi</th><th>Path</th><th>HTTP</th><th>Kesimpulan</th></tr>
<tr><td>Health</td><td>/health</td><td>200</td><td class="pass">Lulus</td></tr>
<tr><td>Poli</td><td>/polis?limit=1</td><td>200</td><td class="pass">Lulus publik</td></tr>
<tr><td>Kalender</td><td>/mobile/booking/calendar?...</td><td>500</td><td class="fail">Gagal backend</td></tr>
<tr><td>Me tanpa Bearer</td><td>/auth/me</td><td>401</td><td class="pass">Lulus security</td></tr>
<tr><td>Profil tanpa Bearer</td><td>/mobile/patient/profile</td><td>401</td><td class="pass">Lulus security</td></tr>
<tr><td>Booking publik</td><td>GET /mobile/booking/general</td><td>404</td><td class="pass">Route disabled</td></tr>
<tr><td>Pasien legacy</td><td>/pasiens?limit=1</td><td>404</td><td class="pass">Lulus security</td></tr>
<tr><td>Registrasi legacy</td><td>/registrasis_dummy/search</td><td>404</td><td class="pass">Lulus security</td></tr>
<tr><td>Antrian legacy</td><td>/antrians/search</td><td>404</td><td class="pass">Lulus security</td></tr>
<tr><td>Metadata generic</td><td>/tables</td><td>404</td><td class="pass">Lulus security</td></tr>
</table>

<h1>9. Artefak Release</h1>
<table><tr><th>Artefak</th><th>Nilai</th></tr>
<tr><td>APK</td><td>build\app\outputs\flutter-apk\app-release.apk</td></tr>
<tr><td>Ukuran</td><td>56.649.963 byte / 54,03 MiB</td></tr>
<tr><td>Waktu build</td><td>16 Juli 2026 20:56:33 WIB</td></tr>
<tr><td>SHA-256</td><td>E1BAC2F09AC97B4D40DA79E9CEE0F191CD0E8C134730B8EF7022879B6C219577</td></tr>
<tr><td>Manifest</td><td>allowBackup=false; usesCleartextTraffic=false</td></tr>
<tr><td>Signing</td><td>CN=Android Debug &#8212; hanya verifikasi internal; hash harus dihitung ulang sesudah production signing</td></tr>
</table>

<div class="figure"><h1>10. Bukti Tampilan Mobile</h1><h2>Gambar 1 &#8212; Mode Tamu pada APK release</h2>
<img src="{{IMG_PROFILE}}" /><p class="caption">Identity cache lama tanpa token tidak dianggap sesi aktif.</p></div>
<div class="figure"><h2>Gambar 2 &#8212; Form Login</h2>
<img src="{{IMG_LOGIN}}" /><p class="caption">Email atau No. RM menjadi identifier untuk meminta OTP; token baru diterbitkan setelah OTP valid.</p></div>
<div class="figure"><h2>Gambar 3 &#8212; Form Registrasi</h2>
<img src="{{IMG_REGISTER}}" /><p class="caption">Password tidak ikut request register awal; set-password memakai registration_ticket.</p></div>
<div class="figure"><h2>Gambar 4 &#8212; Poli pada Build Produksi</h2>
<img src="{{IMG_POLI}}" /><p class="caption">Build APP_ENV=prod menampilkan 48 poli. Bukti ini tidak menyatakan kalender berhasil.</p></div>

<h1>11. Temuan dan Keputusan</h1>
<table><tr><th>Prioritas</th><th>Temuan</th><th>Tindakan</th></tr>
<tr><td>P0</td><td>Kalender booking HTTP 500</td><td>Operator cek log dan validasi DDL tanggal_libur_rs, lalu retest 200</td></tr>
<tr><td>P0</td><td>Auth/OTP positif belum end-to-end</td><td>Gunakan akun/mailbox uji yang disetujui</td></tr>
<tr><td>P0</td><td>Release masih debug-signed</td><td>Production keystore dari secret/CI</td></tr>
<tr><td>P1</td><td>Dead TableHandler/ResourceRepository masih ada di Go</td><td>Jangan registrasikan; pertahankan regression test 404 atau hapus dead code</td></tr>
<tr><td>P1</td><td>Positive booking belum diuji</td><td>Uji hanya di staging/data sintetis dengan rollback</td></tr>
</table>
<div class="warning"><b>Keputusan:</b> client dan kontrol negatif produksi sudah lebih aman, tetapi distribusi resmi tetap HOLD sampai kalender 200, auth positif lulus, production signing tersedia, dan approval QA/DBA/Security lengkap.</div>

<h1>12. Lokasi Bukti</h1>
<ul>
<li>docs/evidence/hasil_uji_smoke_bearer_prod_2026-07-16.csv</li>
<li>docs/screenshots/07_release_mode_tamu_bearer.png sampai 10_prod_poli_public_48.png</li>
<li>docs/Panduan_Integrasi_Auth_Bearer_Mobile.md</li>
<li>C:\Source Golang\ApiRsudOtistaMobile\historyQuery\history.sql</li>
<li>C:\Source Golang\ApiRsudOtistaMobile\docs\mobile-auth-security-deployment.md</li>
</ul>
<p class="small">Akhir dokumen MOD-RSOM-API-001 v1.1.</p>
</body></html>
'@

$spoHtml = @'
<!DOCTYPE html>
<html><head><meta charset="utf-8" /><title>SPO-RSOM-API-001 v1.1</title><style>{{CSS}}</style></head><body>
<div class="cover">
<h1>STANDAR PROSEDUR OPERASIONAL</h1>
<h2>Deployment, Pengujian Auth Bearer, dan Rollback</h2>
<p class="subtitle">RSUD Otista Mobile</p>
<p><b>SPO-RSOM-API-001 &#183; Versi 1.1 &#183; 16 Juli 2026 (WIB)</b></p>
<div class="status">DRAFT TERKENDALI &#8212; GO-LIVE MEMERLUKAN PERSETUJUAN</div>
<p class="small">Dilarang mencantumkan password, OTP, token, NIK, No. RM, atau data klinis nyata pada bukti.</p>
</div>

<h1>Pengendalian Dokumen</h1>
<table><tr><th>Atribut</th><th>Nilai</th></tr>
<tr><td>Pemilik proses</td><td>Unit TI / Pengelola Aplikasi RSUD Otista</td></tr>
<tr><td>Objek</td><td>API Go, MySQL, Flutter Android, Cloudflare, emulator/perangkat</td></tr>
<tr><td>Endpoint</td><td>https://api-mobile.rsudotista.my.id/api/v1</td></tr>
<tr><td>Dokumen terkait</td><td>MOD-RSOM-API-001 v1.1 dan docs/mobile-auth-security-deployment.md</td></tr>
<tr><td>Status awal</td><td>API publik dapat dijangkau; distribusi resmi HOLD karena kalender, positive OTP, dan signing</td></tr>
</table>

<h1>1. Tujuan dan Ruang Lingkup</h1>
<p>SPO ini memastikan DDL, backend, endpoint publik, aplikasi Flutter, sesi Bearer, OTP, data pasien, PDF, dan booking dideploy serta diuji secara terkendali, dapat diaudit, dan dapat di-rollback.</p>
<ul><li>Tindakan source tanpa akses server dipisahkan dari tugas operator server/DBA.</li>
<li>Positive write test hanya di staging atau akun/data sintetis yang disetujui.</li>
<li>Cloudflare challenge bukan pengganti autentikasi Bearer dan ownership.</li>
<li>Route generik /tables serta data legacy harus tetap 404.</li></ul>

<h1>2. Peran dan Tanggung Jawab</h1>
<table><tr><th>Peran</th><th>Tanggung jawab</th></tr>
<tr><td>PIC Perubahan</td><td>Tiket, scope, jadwal, keputusan go/no-go</td></tr>
<tr><td>Backend Engineer</td><td>Build API, contract, migration review, log, rollback image</td></tr>
<tr><td>DBA</td><td>Backup/restore, DDL, validasi tabel/index, runtime least privilege</td></tr>
<tr><td>Mobile Engineer</td><td>Analyze/test/build, base URL, manifest, signing, emulator evidence</td></tr>
<tr><td>Infrastructure</td><td>DNS/TLS/Cloudflare, container, observability, rollback jaringan</td></tr>
<tr><td>QA/Security</td><td>Akun uji, negative/positive test, matriks hasil, sign-off</td></tr>
</table>

<h1>3. Prasyarat dan Stop Condition</h1>
<ul>
<li>Tiket perubahan, commit/tag, jadwal, PIC, dan approval tersedia.</li>
<li>Backup database serta prosedur restore disetujui DBA.</li>
<li>Akun DDL terpisah dari akun runtime; secret hanya dari secret manager/CI.</li>
<li>Akun uji memiliki email/mailbox OTP yang dapat diakses QA.</li>
<li>Production keystore tersedia untuk distribusi resmi.</li>
<li>Rollback image, aplikasi, DNS/WAF, dan database telah disiapkan.</li>
</ul>
<div class="danger"><b>Stop:</b> health bukan JSON 200, route sensitif mengembalikan data tanpa token, ownership gagal, kalender/booking 5xx, migrasi parsial, debug-signed APK akan didistribusikan, atau rollback tidak dapat dijamin.</div>

<h1>4. Prosedur Deployment Backend</h1>
<h2>4.1 Baseline source</h2>
<pre>cd "C:\Source Golang\ApiRsudOtistaMobile"
git status --short
go test ./...
go vet ./...
go build ./...</pre>
<p>Catat commit, image tag/digest, versi Go, hasil test, dan nama variable environment tanpa menampilkan secret.</p>

<h2>4.2 Backup dan DDL</h2>
<ol>
<li>Review dan terapkan selektif bagian prasyarat auth mobile bila belum tersedia.</li>
<li>Terapkan bagian <b>2026-07-15</b> pada historyQuery/history.sql: session_user_mobile, auth_ticket_mobile, InnoDB, index, serta hardening OTP.</li>
<li>Terapkan/validasi DDL <b>tanggal_libur_rs</b> agar kalender dapat membaca cache hari libur.</li>
<li>Gunakan akun migrasi setelah backup; jangan memakai akun tersebut sebagai DB_USER runtime.</li>
<li>Alternatif terkontrol: <code>go run ./cmd/migrate</code> setelah review DBA.</li>
</ol>
<pre>SHOW TABLES LIKE 'session_user_mobile';
SHOW TABLES LIKE 'auth_ticket_mobile';
SHOW TABLES LIKE 'tanggal_libur_rs';
SHOW INDEX FROM session_user_mobile;</pre>
<div class="warning">Jangan menjalankan seluruh history.sql tanpa pemeriksaan idempotensi dan kondisi skema target. Binary runtime tidak boleh memiliki hak CREATE/ALTER.</div>

<h2>4.3 Deploy image/API</h2>
<ul><li>Build image immutable dari commit yang sama dengan history.sql.</li>
<li>Scan dependency/image dan deploy canary bila tersedia.</li>
<li>Periksa log startup, koneksi database, dan runtime DB least privilege.</li>
<li>Pastikan generic TableHandler/ResourceRepository tidak didaftarkan pada router publik.</li></ul>
<pre>docker compose config
docker compose build
docker compose up -d
docker ps
curl -i http://127.0.0.1:8080/api/v1/health</pre>

<h1>5. Verifikasi Endpoint Publik</h1>
<table><tr><th>Probe</th><th>Expected</th></tr>
<tr><td>GET /health</td><td>200 application/json; success=true; data.status=ok</td></tr>
<tr><td>GET /polis?limit=1</td><td>200 application/json</td></tr>
<tr><td>GET /auth/me tanpa Bearer</td><td>401 application/json</td></tr>
<tr><td>GET /mobile/patient/profile tanpa Bearer</td><td>401 application/json</td></tr>
<tr><td>GET /tables</td><td>404 route not found</td></tr>
<tr><td>GET /pasiens?limit=1</td><td>404 route not found</td></tr>
<tr><td>GET /registrasis_dummy/search</td><td>404 route not found</td></tr>
<tr><td>GET /antrians/search</td><td>404 route not found</td></tr>
<tr><td>GET /mobile/booking/general</td><td>404 route not found</td></tr>
<tr><td>GET /mobile/booking/calendar?...</td><td>200 JSON sebelum go-live</td></tr>
</table>
<div class="warning"><b>Kondisi 16 Juli 2026:</b> seluruh expected lulus kecuali kalender yang masih HTTP 500. HOLD sampai operator memeriksa log, menerapkan/validasi DDL, dan retest 200.</div>

<h1>6. Pengujian Auth dan Ownership</h1>
<p>Gunakan staging atau akun produksi sintetis yang disetujui. Jangan memakai akun pasien aktif.</p>
<table><tr><th>Kasus</th><th>Expected</th></tr>
<tr><td>Register</td><td>Password tidak ikut request; respons tidak mengenumerasi akun</td></tr>
<tr><td>Verify OTP baru</td><td>registration_ticket ber-expiry dan sekali pakai</td></tr>
<tr><td>Set password</td><td>Ticket + password; identity dan token pair lengkap</td></tr>
<tr><td>Login + verify OTP</td><td>Identifier; token pair lengkap setelah OTP</td></tr>
<tr><td>/auth/me</td><td>Bearer valid &#8594; identity; missing/invalid &#8594; 401</td></tr>
<tr><td>Refresh</td><td>Rotasi kedua token; token lama tidak dapat dipakai ulang</td></tr>
<tr><td>401 paralel</td><td>Hanya satu refresh; session family tidak tercabut akibat reuse</td></tr>
<tr><td>Claim RM</td><td>Bearer + password/no_rm/nik/birth_date; patient tertaut</td></tr>
<tr><td>Cross-patient</td><td>Ditolak; spoof query email/no_rm tidak mengubah identity token</td></tr>
<tr><td>PDF</td><td>Bearer wajib; token/identity tidak berada pada URL</td></tr>
<tr><td>Logout</td><td>Session family dicabut; token berikutnya 401</td></tr>
</table>

<h1>7. Build dan Uji Flutter</h1>
<pre>cd "C:\Source Flutter\rs_mobile_otista_v1.0"
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=APP_ENV=prod
Get-FileHash build\app\outputs\flutter-apk\app-release.apk -Algorithm SHA256</pre>
<ul><li>Base URL adalah https://api-mobile.rsudotista.my.id/api/v1, bukan URL /health.</li>
<li>Manifest release: allowBackup=false dan usesCleartextTraffic=false.</li>
<li>Debug/profile cleartext hanya untuk http://10.0.2.2 saat development.</li>
<li>Distribusi resmi wajib production keystore dari secret/CI.</li>
<li>Catat version, checksum APK, dan certificate fingerprint sesudah signing.</li></ul>

<h1>8. Uji EMULATOR MAUL</h1>
<ol><li>Instal APK final dengan <code>adb install -r</code>; jangan hapus data kecuali test case meminta.</li>
<li>Identity cache lama tanpa token harus kembali ke Mode Tamu.</li>
<li>Uji form login/registrasi tanpa data nyata.</li>
<li>Dengan akun uji: login OTP, /auth/me, profil, visit, resume/PDF, lab, radiologi, resep, booking mine, refresh, logout.</li>
<li>Uji poli, kamar, dan opsi booking. Jangan lanjut booking sampai kalender 200.</li>
<li>Ambil screenshot tanpa PII/PHI atau token.</li></ol>

<h1>9. Booking Integration</h1>
<ul><li>Positive booking hanya di staging atau data sintetis dengan izin.</li>
<li>Uji tanggal lampau, Minggu, hari libur, poli/dokter salah, kuota nol, duplicate/idempotency, dan concurrency.</li>
<li>Body booking tidak boleh membawa email/no_rm/identifier; server mengambil pasien dari principal.</li>
<li>Verifikasi rollback transaksi ketika satu query gagal.</li></ul>

<h1>10. Monitoring</h1>
<ul><li>Pantau 4xx/5xx, latency p95/p99, DB pool, restart container, dan reconnect tunnel.</li>
<li>Alert untuk brute force OTP, reuse refresh token, scraping route 404, serta anomali booking.</li>
<li>Gunakan correlation ID tanpa request body sensitif.</li>
<li>Rule API Cloudflare harus non-interaktif dan tetap rate-limited; jangan allow-all seluruh zone.</li></ul>

<h1>11. Gate Go-Live</h1>
<table><tr><th>Gate</th><th>Kriteria</th><th>Status 16-07-2026</th></tr>
<tr><td>Public health</td><td>200 JSON tanpa challenge</td><td class="pass">LULUS</td></tr>
<tr><td>Auth negative</td><td>Protected tanpa Bearer 401</td><td class="pass">LULUS</td></tr>
<tr><td>Generic exposure</td><td>Route sensitif legacy 404</td><td class="pass">LULUS</td></tr>
<tr><td>Flutter source</td><td>Analyze + 9 test</td><td class="pass">LULUS</td></tr>
<tr><td>Release build</td><td>APK + hash</td><td class="pass">LULUS INTERNAL</td></tr>
<tr><td>Kalender</td><td>200 JSON</td><td class="fail">GAGAL &#8212; 500</td></tr>
<tr><td>Auth positive</td><td>OTP/token/refresh/logout E2E</td><td class="hold">BELUM</td></tr>
<tr><td>Booking staging</td><td>Positive, negative, concurrency</td><td class="hold">BELUM</td></tr>
<tr><td>Production signing</td><td>Keystore resmi</td><td class="hold">BELUM</td></tr>
<tr><td>Approval</td><td>QA, DBA, Infra, Security, PIC</td><td class="hold">BELUM</td></tr>
</table>
<div class="danger"><b>Keputusan:</b> NO-GO untuk distribusi resmi. APK hanya untuk verifikasi internal sampai seluruh gate wajib lulus.</div>

<h1>12. Rollback</h1>
<ol><li>Hentikan rollout/write dan keluarkan instance bermasalah dari traffic.</li>
<li>Pulihkan image API ke tag immutable sebelumnya.</li>
<li>Pulihkan DNS/WAF/tunnel hanya jika perubahan jaringan menjadi penyebab.</li>
<li>Jangan memasang kembali client lama berbasis query identity terhadap API hardened.</li>
<li>Jangan langsung drop session_user_mobile/auth_ticket_mobile; ikuti runbook dan keputusan DBA.</li>
<li>Restore database hanya berdasarkan rencana yang disetujui.</li>
<li>Verifikasi health, route security, serta integritas pasien/booking; catat RCA.</li></ol>

<h1>13. Rekaman dan Retensi Bukti</h1>
<ul><li>Tiket/approval, commit/tag, image digest, checksum APK, signing fingerprint.</li>
<li>Log analyze/test/build, DDL validation, probe API, dan screenshot aman.</li>
<li>Konfigurasi WAF/DNS/tunnel sebelum-sesudah dengan actor/timestamp.</li>
<li>Backup/restore evidence di lokasi terbatas DBA.</li></ul>

<h1>14. Checklist Pelaksanaan</h1>
<table><tr><th>No.</th><th>Aktivitas</th><th>PIC</th><th>Status/Bukti</th></tr>
<tr><td>1</td><td>Tiket, scope, jadwal, approval</td><td>PIC</td><td>&#9744;</td></tr>
<tr><td>2</td><td>Backup dan restore readiness</td><td>DBA</td><td>&#9744;</td></tr>
<tr><td>3</td><td>DDL history.sql diterapkan/divalidasi</td><td>DBA/Backend</td><td>&#9744;</td></tr>
<tr><td>4</td><td>Go test/vet/build dan image scan</td><td>Backend</td><td>&#9744;</td></tr>
<tr><td>5</td><td>Health 200; generic 404; protected 401</td><td>QA/Security</td><td>&#9744;</td></tr>
<tr><td>6</td><td>Kalender booking 200</td><td>Backend/DBA</td><td>&#9744;</td></tr>
<tr><td>7</td><td>Auth/OTP/refresh/logout positif</td><td>QA/Security</td><td>&#9744;</td></tr>
<tr><td>8</td><td>Booking staging/concurrency</td><td>QA/Backend</td><td>&#9744;</td></tr>
<tr><td>9</td><td>Flutter analyze/test/build</td><td>Mobile</td><td>&#9744;</td></tr>
<tr><td>10</td><td>Production signing + checksum</td><td>Mobile/Release</td><td>&#9744;</td></tr>
<tr><td>11</td><td>EMULATOR MAUL fungsi kritis</td><td>QA/Mobile</td><td>&#9744;</td></tr>
<tr><td>12</td><td>Monitoring dan rollback siap</td><td>Infra/Semua</td><td>&#9744;</td></tr>
<tr><td>13</td><td>Sign-off final</td><td>PIC/QA/DBA/Security</td><td>&#9744;</td></tr>
</table>

<h1>15. Persetujuan</h1>
<table class="signature"><tr><th>Disusun</th><th>Diperiksa</th><th>Disetujui</th></tr>
<tr><td>Nama/tanggal/tanda tangan:</td><td>Nama/tanggal/tanda tangan:</td><td>Nama/tanggal/tanda tangan:</td></tr></table>
<p class="small">Akhir dokumen SPO-RSOM-API-001 v1.1.</p>
</body></html>
'@

$moduleHtml = $moduleHtml.Replace('{{CSS}}', $sharedCss)
$moduleHtml = $moduleHtml.Replace('{{IMG_PROFILE}}', (Get-FileUri (Join-Path $ProjectRoot 'docs\screenshots\07_release_mode_tamu_bearer.png')))
$moduleHtml = $moduleHtml.Replace('{{IMG_LOGIN}}', (Get-FileUri (Join-Path $ProjectRoot 'docs\screenshots\08_release_form_login_bearer.png')))
$moduleHtml = $moduleHtml.Replace('{{IMG_REGISTER}}', (Get-FileUri (Join-Path $ProjectRoot 'docs\screenshots\09_release_form_registrasi_ticket.png')))
$moduleHtml = $moduleHtml.Replace('{{IMG_POLI}}', (Get-FileUri (Join-Path $ProjectRoot 'docs\screenshots\10_prod_poli_public_48.png')))
$spoHtml = $spoHtml.Replace('{{CSS}}', $sharedCss)

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Drawing

function ConvertTo-XmlText {
    param([AllowNull()][string]$Text)
    if ($null -eq $Text) { return '' }
    return [Security.SecurityElement]::Escape($Text)
}

function New-WordParagraph {
    param(
        [AllowNull()][string]$Text,
        [string]$Style = '',
        [string]$Align = '',
        [switch]$Bold,
        [switch]$Italic,
        [switch]$Code,
        [string]$Shade = ''
    )

    $paragraphProperties = [Text.StringBuilder]::new()
    if ($Style) { [void]$paragraphProperties.Append(('<w:pStyle w:val="{0}"/>' -f $Style)) }
    if ($Align) { [void]$paragraphProperties.Append(('<w:jc w:val="{0}"/>' -f $Align)) }
    if ($Shade) { [void]$paragraphProperties.Append(('<w:shd w:val="clear" w:color="auto" w:fill="{0}"/>' -f $Shade)) }
    if ($Code) {
        [void]$paragraphProperties.Append('<w:spacing w:after="40"/><w:ind w:left="240"/>')
    }

    $runProperties = [Text.StringBuilder]::new()
    if ($Bold) { [void]$runProperties.Append('<w:b/>') }
    if ($Italic) { [void]$runProperties.Append('<w:i/>') }
    if ($Code) { [void]$runProperties.Append('<w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="16"/>') }

    $escaped = ConvertTo-XmlText $Text
    return ('<w:p><w:pPr>{0}</w:pPr><w:r><w:rPr>{1}</w:rPr><w:t xml:space="preserve">{2}</w:t></w:r></w:p>' -f $paragraphProperties, $runProperties, $escaped)
}

function New-WordPageBreak {
    return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
}

function New-WordImage {
    param([Parameter(Mandatory)]$Node)

    $sourceUri = [Uri]$Node.GetAttribute('src')
    $sourcePath = $sourceUri.LocalPath
    if (-not (Test-Path -LiteralPath $sourcePath)) {
        return New-WordParagraph "Screenshot tidak ditemukan: $sourcePath" -Italic
    }

    $script:ImageCounter++
    $number = $script:ImageCounter
    $relationshipId = "rIdV11Image$number"
    $targetName = "v1_1_image_$number.png"

    $bitmap = [Drawing.Image]::FromFile($sourcePath)
    try {
        $width = 3017520L
        $height = [long][Math]::Round($width * $bitmap.Height / $bitmap.Width)
        $maximumHeight = 6400800L
        if ($height -gt $maximumHeight) {
            $width = [long][Math]::Round($width * $maximumHeight / $height)
            $height = $maximumHeight
        }
    }
    finally {
        $bitmap.Dispose()
    }

    [void]$script:CurrentImages.Add([pscustomobject]@{
        RelationshipId = $relationshipId
        TargetName = $targetName
        SourcePath = $sourcePath
    })

    return @"
<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:drawing>
<wp:inline distT="0" distB="0" distL="0" distR="0">
<wp:extent cx="$width" cy="$height"/><wp:effectExtent l="0" t="0" r="0" b="0"/>
<wp:docPr id="$($number + 100)" name="Screenshot $number"/>
<wp:cNvGraphicFramePr><a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/></wp:cNvGraphicFramePr>
<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
<pic:nvPicPr><pic:cNvPr id="$number" name="$targetName"/><pic:cNvPicPr/></pic:nvPicPr>
<pic:blipFill><a:blip r:embed="$relationshipId"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>
<pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="$width" cy="$height"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>
</pic:pic></a:graphicData></a:graphic>
</wp:inline></w:drawing></w:r></w:p>
"@
}

function Convert-HtmlTable {
    param([Parameter(Mandatory)]$Node)

    $builder = [Text.StringBuilder]::new()
    [void]$builder.Append('<w:tbl><w:tblPr><w:tblStyle w:val="TableGrid"/><w:tblW w:w="0" w:type="auto"/><w:tblLook w:val="04A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="0" w:noVBand="1"/></w:tblPr>')
    foreach ($row in $Node.SelectNodes('./tr')) {
        [void]$builder.Append('<w:tr>')
        foreach ($cell in $row.SelectNodes('./th|./td')) {
            $isHeader = $cell.Name -eq 'th'
            $fill = if ($isHeader) { 'D8EFEC' } else { 'FFFFFF' }
            [void]$builder.Append(('<w:tc><w:tcPr><w:tcW w:w="0" w:type="auto"/><w:shd w:val="clear" w:color="auto" w:fill="{0}"/></w:tcPr>' -f $fill))
            [void]$builder.Append((New-WordParagraph $cell.InnerText.Trim() -Bold:$isHeader))
            [void]$builder.Append('</w:tc>')
        }
        [void]$builder.Append('</w:tr>')
    }
    [void]$builder.Append('</w:tbl>')
    return $builder.ToString()
}

function Convert-HtmlChildren {
    param([Parameter(Mandatory)]$Node)
    $builder = [Text.StringBuilder]::new()
    foreach ($child in $Node.ChildNodes) {
        [void]$builder.Append((Convert-HtmlNode $child))
    }
    return $builder.ToString()
}

function Convert-HtmlNode {
    param([Parameter(Mandatory)]$Node)

    if ($Node.NodeType -ne [Xml.XmlNodeType]::Element) { return '' }
    $name = $Node.Name.ToLowerInvariant()
    switch ($name) {
        'h1' { return New-WordParagraph $Node.InnerText.Trim() -Style 'Heading1' -Bold }
        'h2' { return New-WordParagraph $Node.InnerText.Trim() -Style 'Heading2' -Bold }
        'h3' { return New-WordParagraph $Node.InnerText.Trim() -Style 'Heading3' -Bold }
        'p' {
            $className = $Node.GetAttribute('class')
            return New-WordParagraph $Node.InnerText.Trim() -Italic:($className -eq 'caption')
        }
        'pre' {
            $builder = [Text.StringBuilder]::new()
            foreach ($line in ($Node.InnerText -split "`r?`n")) {
                [void]$builder.Append((New-WordParagraph $line -Code -Shade 'F2F5F4'))
            }
            return $builder.ToString()
        }
        'ul' {
            $builder = [Text.StringBuilder]::new()
            foreach ($item in $Node.SelectNodes('./li')) {
                [void]$builder.Append((New-WordParagraph "- $($item.InnerText.Trim())"))
            }
            return $builder.ToString()
        }
        'ol' {
            $builder = [Text.StringBuilder]::new()
            $index = 0
            foreach ($item in $Node.SelectNodes('./li')) {
                $index++
                [void]$builder.Append((New-WordParagraph "$index. $($item.InnerText.Trim())"))
            }
            return $builder.ToString()
        }
        'table' { return Convert-HtmlTable $Node }
        'img' { return New-WordImage $Node }
        'div' {
            $className = $Node.GetAttribute('class')
            if ($className -eq 'cover') {
                $builder = [Text.StringBuilder]::new()
                foreach ($child in $Node.ChildNodes) {
                    if ($child.NodeType -ne [Xml.XmlNodeType]::Element) { continue }
                    switch ($child.Name.ToLowerInvariant()) {
                        'h1' { [void]$builder.Append((New-WordParagraph $child.InnerText.Trim() -Style 'Title' -Align 'center' -Bold)) }
                        'h2' { [void]$builder.Append((New-WordParagraph $child.InnerText.Trim() -Style 'Subtitle' -Align 'center' -Bold)) }
                        'div' { [void]$builder.Append((New-WordParagraph $child.InnerText.Trim() -Align 'center' -Bold -Shade 'FFF5E9')) }
                        default { [void]$builder.Append((New-WordParagraph $child.InnerText.Trim() -Align 'center')) }
                    }
                }
                [void]$builder.Append((New-WordPageBreak))
                return $builder.ToString()
            }
            if ($className -eq 'figure') {
                return (New-WordPageBreak) + (Convert-HtmlChildren $Node)
            }
            if ($className -in @('note','warning','danger','status')) {
                $shade = switch ($className) {
                    'danger' { 'FFF0EF' }
                    'warning' { 'FFF5E9' }
                    default { 'EEF8F7' }
                }
                return New-WordParagraph $Node.InnerText.Trim() -Bold -Shade $shade
            }
            return Convert-HtmlChildren $Node
        }
        default { return Convert-HtmlChildren $Node }
    }
}

function Convert-HtmlToWordDocumentXml {
    param([Parameter(Mandatory)][string]$Html)

    [xml]$htmlDocument = $Html
    $bodyNode = $htmlDocument.SelectSingleNode('/html/body')
    $script:CurrentImages = [Collections.ArrayList]::new()
    $script:ImageCounter = 0
    $bodyXml = Convert-HtmlChildren $bodyNode
    $documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
 xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
 xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
 xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
 xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
<w:body>$bodyXml<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="900" w:right="900" w:bottom="900" w:left="900" w:header="450" w:footer="450" w:gutter="0"/></w:sectPr></w:body>
</w:document>
"@
    return [pscustomobject]@{
        DocumentXml = $documentXml
        Images = @($script:CurrentImages)
    }
}

function Get-ZipEntryText {
    param($Zip, [string]$Name)
    $entry = $Zip.GetEntry($Name)
    if ($null -eq $entry) { throw "Entry DOCX tidak ditemukan: $Name" }
    $reader = [IO.StreamReader]::new($entry.Open(), [Text.Encoding]::UTF8)
    try { return $reader.ReadToEnd() } finally { $reader.Dispose() }
}

function Set-ZipEntryText {
    param($Zip, [string]$Name, [string]$Content)
    $oldEntry = $Zip.GetEntry($Name)
    if ($null -ne $oldEntry) { $oldEntry.Delete() }
    $entry = $Zip.CreateEntry($Name, [IO.Compression.CompressionLevel]::Optimal)
    $writer = [IO.StreamWriter]::new($entry.Open(), [Text.UTF8Encoding]::new($false))
    try { $writer.Write($Content) } finally { $writer.Dispose() }
}

function Add-ZipImage {
    param($Zip, $Image)
    $entryName = "word/media/$($Image.TargetName)"
    $oldEntry = $Zip.GetEntry($entryName)
    if ($null -ne $oldEntry) { $oldEntry.Delete() }
    $entry = $Zip.CreateEntry($entryName, [IO.Compression.CompressionLevel]::Optimal)
    $input = [IO.File]::OpenRead($Image.SourcePath)
    $output = $entry.Open()
    try { $input.CopyTo($output) } finally { $output.Dispose(); $input.Dispose() }
}

function New-DocxFromHtml {
    param(
        [Parameter(Mandatory)][string]$Html,
        [Parameter(Mandatory)][string]$OutputPath,
        [Parameter(Mandatory)][string]$Title
    )

    $converted = Convert-HtmlToWordDocumentXml $Html
    Copy-Item -LiteralPath $spoArchive -Destination $OutputPath -Force
    $zip = [IO.Compression.ZipFile]::Open($OutputPath, [IO.Compression.ZipArchiveMode]::Update)
    try {
        Set-ZipEntryText $zip 'word/document.xml' $converted.DocumentXml

        [xml]$relationships = Get-ZipEntryText $zip 'word/_rels/document.xml.rels'
        $relationshipNamespace = 'http://schemas.openxmlformats.org/package/2006/relationships'
        foreach ($image in $converted.Images) {
            $relationship = $relationships.CreateElement('Relationship', $relationshipNamespace)
            $relationship.SetAttribute('Id', $image.RelationshipId)
            $relationship.SetAttribute('Type', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image')
            $relationship.SetAttribute('Target', "media/$($image.TargetName)")
            [void]$relationships.DocumentElement.AppendChild($relationship)
            Add-ZipImage $zip $image
        }
        Set-ZipEntryText $zip 'word/_rels/document.xml.rels' $relationships.OuterXml

        [xml]$contentTypes = Get-ZipEntryText $zip '[Content_Types].xml'
        $contentTypeNamespace = 'http://schemas.openxmlformats.org/package/2006/content-types'
        $hasPng = $contentTypes.Types.Default | Where-Object { $_.Extension -eq 'png' }
        if ($null -eq $hasPng) {
            $pngDefault = $contentTypes.CreateElement('Default', $contentTypeNamespace)
            $pngDefault.SetAttribute('Extension', 'png')
            $pngDefault.SetAttribute('ContentType', 'image/png')
            [void]$contentTypes.DocumentElement.AppendChild($pngDefault)
            Set-ZipEntryText $zip '[Content_Types].xml' $contentTypes.OuterXml
        }

        [xml]$coreProperties = Get-ZipEntryText $zip 'docProps/core.xml'
        $namespaceManager = [Xml.XmlNamespaceManager]::new($coreProperties.NameTable)
        $namespaceManager.AddNamespace('dc', 'http://purl.org/dc/elements/1.1/')
        $namespaceManager.AddNamespace('dcterms', 'http://purl.org/dc/terms/')
        $titleNode = $coreProperties.SelectSingleNode('//dc:title', $namespaceManager)
        if ($null -ne $titleNode) { $titleNode.InnerText = $Title }
        $modifiedNode = $coreProperties.SelectSingleNode('//dcterms:modified', $namespaceManager)
        if ($null -ne $modifiedNode) { $modifiedNode.InnerText = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ') }
        Set-ZipEntryText $zip 'docProps/core.xml' $coreProperties.OuterXml
    }
    finally {
        $zip.Dispose()
    }
}

New-DocxFromHtml -Html $moduleHtml -OutputPath $modulePath -Title 'Modul Integrasi API dan Pengujian RSUD Otista Mobile v1.1'
New-DocxFromHtml -Html $spoHtml -OutputPath $spoPath -Title 'SPO Deployment, Pengujian Auth Bearer, dan Rollback RSUD Otista Mobile v1.1'

Get-Item -LiteralPath $modulePath, $spoPath | Select-Object FullName, Length, LastWriteTime
