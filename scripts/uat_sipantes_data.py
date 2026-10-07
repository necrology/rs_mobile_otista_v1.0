SCREENSHOTS = [
    {
        "id": "SS-01",
        "file": "01_beranda.png",
        "title": "Beranda dan sesi akun sintetis",
        "description": (
            "Aplikasi berhasil dibuka, branding SIPANTES tampil, sesi akun "
            "sintetis test aktif, dan menu layanan utama tersedia."
        ),
    },
    {
        "id": "SS-02",
        "file": "02_pendaftaran_antrian.png",
        "title": "Pendaftaran dan riwayat antrean umum",
        "description": (
            "Halaman antrean umum tampil dengan tombol pembuatan antrean, "
            "tab riwayat, dan empty state yang informatif."
        ),
    },
    {
        "id": "SS-03",
        "file": "03_poli_jadwal.png",
        "title": "Daftar poli dan jadwal praktik",
        "description": (
            "Daftar poli, pencarian, jadwal praktik, dan status hari layanan "
            "berhasil ditampilkan dari layanan API."
        ),
    },
    {
        "id": "SS-04",
        "file": "04_ketersediaan_kamar.png",
        "title": "Ketersediaan kamar rawat inap",
        "description": (
            "Ringkasan tempat tidur dan rincian ketersediaan per kelas "
            "berhasil ditampilkan."
        ),
    },
    {
        "id": "SS-05",
        "file": "05_hapus_akun.png",
        "title": "Penghapusan akun dengan verifikasi",
        "description": (
            "Halaman menjelaskan dampak penghapusan dan mewajibkan password "
            "sebelum OTP penghapusan dikirim."
        ),
    },
]


UAT_CASES = [
    {
        "id": "UAT-001",
        "module": "Peluncuran",
        "scenario": "Membuka aplikasi SIPANTES",
        "precondition": "Aplikasi terpasang pada emulator.",
        "steps": "Jalankan aplikasi dari launcher.",
        "expected": "Aplikasi terbuka tanpa crash dan branding SIPANTES tampil.",
        "actual": "Beranda tampil normal dengan judul SIPANTES.",
        "status": "LULUS",
        "evidence": "SS-01",
    },
    {
        "id": "UAT-002",
        "module": "Sesi pengguna",
        "scenario": "Memulihkan sesi akun sintetis",
        "precondition": "Akun test pernah login.",
        "steps": "Tutup dan buka ulang aplikasi.",
        "expected": "Sesi tetap aktif dan identitas sintetis tampil.",
        "actual": "Indikator Akun Aktif dan sapaan Halo, test tampil.",
        "status": "LULUS",
        "evidence": "SS-01",
    },
    {
        "id": "UAT-003",
        "module": "Beranda",
        "scenario": "Menampilkan menu layanan utama",
        "precondition": "Berada pada halaman Beranda.",
        "steps": "Periksa kartu layanan dan navigasi bawah.",
        "expected": "Menu utama dan navigasi tersedia serta mudah dikenali.",
        "actual": "Menu layanan dan navigasi utama tampil tanpa error.",
        "status": "LULUS",
        "evidence": "SS-01",
    },
    {
        "id": "UAT-004",
        "module": "Antrean umum",
        "scenario": "Membuka halaman pendaftaran antrean",
        "precondition": "Sesi pengguna aktif.",
        "steps": "Pilih tab Booking/Antrean.",
        "expected": "Halaman pendaftaran antrean dapat dibuka.",
        "actual": "Halaman Antrean Umum dan tombol Buat tampil.",
        "status": "LULUS",
        "evidence": "SS-02",
    },
    {
        "id": "UAT-005",
        "module": "Antrean umum",
        "scenario": "Menampilkan riwayat antrean kosong",
        "precondition": "Akun tidak memiliki antrean aktif.",
        "steps": "Pilih tab Saya.",
        "expected": "Sistem menampilkan empty state yang jelas.",
        "actual": "Pesan belum ada history antrean umum tampil.",
        "status": "LULUS",
        "evidence": "SS-02",
    },
    {
        "id": "UAT-006",
        "module": "Poli dan jadwal",
        "scenario": "Menampilkan daftar poli",
        "precondition": "API produksi dapat dijangkau.",
        "steps": "Pilih tab Poli & Jadwal.",
        "expected": "Daftar poli dan informasi jadwal tampil.",
        "actual": "Daftar poli, hari, jam, dan status praktik tampil.",
        "status": "LULUS",
        "evidence": "SS-03",
    },
    {
        "id": "UAT-007",
        "module": "Poli dan jadwal",
        "scenario": "Menampilkan kontrol pencarian poli",
        "precondition": "Berada pada halaman Poli & Jadwal.",
        "steps": "Periksa bidang pencarian dan tombol Cari.",
        "expected": "Kontrol pencarian tersedia.",
        "actual": "Bidang pencarian dan tombol Cari tampil aktif.",
        "status": "LULUS",
        "evidence": "SS-03",
    },
    {
        "id": "UAT-008",
        "module": "Ketersediaan kamar",
        "scenario": "Menampilkan ringkasan tempat tidur",
        "precondition": "API kamar dapat dijangkau.",
        "steps": "Buka menu Ketersediaan Kamar.",
        "expected": "Jumlah ruang aktif, total bed, dan bed kosong tampil.",
        "actual": "Ringkasan kamar ditampilkan tanpa error.",
        "status": "LULUS",
        "evidence": "SS-04",
    },
    {
        "id": "UAT-009",
        "module": "Ketersediaan kamar",
        "scenario": "Menampilkan rincian per kelas",
        "precondition": "Berada pada halaman Ketersediaan Kamar.",
        "steps": "Periksa daftar kelas kamar.",
        "expected": "Rincian total, terisi, dan kosong tersedia.",
        "actual": "Rincian per kelas tampil lengkap.",
        "status": "LULUS",
        "evidence": "SS-04",
    },
    {
        "id": "UAT-010",
        "module": "Penghapusan akun",
        "scenario": "Menampilkan peringatan penghapusan permanen",
        "precondition": "Sesi pengguna aktif.",
        "steps": "Pilih Profil > Hapus Akun.",
        "expected": "Risiko dan cakupan data dijelaskan sebelum tindakan.",
        "actual": "Peringatan permanen dan retensi rekam medis ditampilkan.",
        "status": "LULUS",
        "evidence": "SS-05",
    },
    {
        "id": "UAT-011",
        "module": "Penghapusan akun",
        "scenario": "Memerlukan password sebelum OTP",
        "precondition": "Berada pada halaman Hapus Akun.",
        "steps": "Periksa formulir verifikasi.",
        "expected": "OTP tidak dapat diminta tanpa password.",
        "actual": "Kolom password dan tombol Kirim OTP tersedia.",
        "status": "LULUS",
        "evidence": "SS-05",
    },
    {
        "id": "UAT-012",
        "module": "API publik",
        "scenario": "Memvalidasi health, poli, dan kamar",
        "precondition": "Internet tersedia.",
        "steps": "Lakukan request GET tanpa kredensial.",
        "expected": "Endpoint publik merespons HTTP 200.",
        "actual": "API-01, API-02, dan API-03 merespons HTTP 200.",
        "status": "LULUS",
        "evidence": "API-01 s.d. API-03",
    },
    {
        "id": "UAT-013",
        "module": "Keamanan sesi",
        "scenario": "Menolak endpoint pengguna tanpa Bearer",
        "precondition": "Request tidak membawa access token.",
        "steps": "GET /api/v1/auth/me.",
        "expected": "Sistem menolak dengan HTTP 401.",
        "actual": "Endpoint merespons HTTP 401.",
        "status": "LULUS",
        "evidence": "API-04",
    },
    {
        "id": "UAT-014",
        "module": "Kepatuhan",
        "scenario": "Membuka kebijakan privasi dan penghapusan akun",
        "precondition": "Internet tersedia.",
        "steps": "Akses URL sementara dan domain API.",
        "expected": "Seluruh halaman publik dapat dibuka dengan HTTP 200.",
        "actual": "WEB-01 sampai WEB-04 merespons HTTP 200.",
        "status": "LULUS",
        "evidence": "WEB-01 s.d. WEB-04",
    },
]


AUTOMATED_TESTS = [
    "ApiClient menolak respons 2xx yang menyatakan success=false",
    "Bearer hanya ditambahkan pada request terlindungi",
    "Refresh token bersamaan diserialisasi dan request diputar ulang",
    "Refresh tidak valid menghapus sesi dan memicu kedaluwarsa",
    "Kegagalan refresh sementara mempertahankan sesi tersimpan",
    "Request terlindungi hanya diulang satu kali setelah refresh",
    "Payload registrasi memakai registration ticket dan kontrak auth diperkeras",
    "Konflik akun terdaftar dipetakan menjadi hasil bertipe",
    "Konflik registrasi lain tetap diteruskan",
    "Respons auth tanpa pasangan token lengkap ditolak",
    "Registrasi menerima permintaan OTP dan memvalidasi OTP lokal",
    "Dialog akun terdaftar menuju Login dan hanya mengisi email",
    "Dialog akun terdaftar menuju Lupa Password dan mengisi email",
    "Penghapusan akun meminta OTP dan membersihkan state autentikasi",
    "Request pasien dan booking mengambil identitas hanya dari Bearer",
    "Shell aplikasi memuat layanan beranda",
]


API_CHECKS = [
    ("API-01", "Health API produksi", "https://api-mobile.rsudotista.my.id/api/v1/health", 200),
    ("API-02", "Daftar poli publik", "https://api-mobile.rsudotista.my.id/api/v1/polis?limit=1", 200),
    ("API-03", "Ketersediaan kamar publik", "https://api-mobile.rsudotista.my.id/api/v1/mobile/hospital/room-availabilities?limit=1", 200),
    ("API-04", "Endpoint sesi tanpa Bearer", "https://api-mobile.rsudotista.my.id/api/v1/auth/me", 401),
    ("WEB-01", "Kebijakan privasi", "https://api-mobile.rsudotista.my.id/privacy-policy", 200),
    ("WEB-02", "Penghapusan akun", "https://api-mobile.rsudotista.my.id/account-deletion", 200),
]
