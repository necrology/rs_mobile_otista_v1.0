from pathlib import Path
from datetime import date
import textwrap

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Inches, Pt, RGBColor
from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "docs" / "modul_teknis"
ASSET_DIR = OUT_DIR / "assets"
OUTPUT = OUT_DIR / "Dokumen_Modul_Teknis_SIPANTES_v2.3.docx"
LOGO = ROOT / "assets" / "images" / "otista" / "rsud_full_logo_trimmed.png"

TEAL = "1B7F79"
DARK = "173B3F"
RED = "B42318"
LIGHT = "EAF5F4"
GRAY = "667085"
WHITE = "FFFFFF"


def font(size=24, bold=False):
    candidates = [
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
        "C:/Windows/Fonts/calibrib.ttf" if bold else "C:/Windows/Fonts/calibri.ttf",
    ]
    for candidate in candidates:
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def arrow(draw, start, end, color=(27, 127, 121), width=5):
    draw.line([start, end], fill=color, width=width)
    x2, y2 = end
    if abs(end[0] - start[0]) >= abs(end[1] - start[1]):
        direction = 1 if end[0] > start[0] else -1
        draw.polygon([(x2, y2), (x2 - 18 * direction, y2 - 10), (x2 - 18 * direction, y2 + 10)], fill=color)
    else:
        direction = 1 if end[1] > start[1] else -1
        draw.polygon([(x2, y2), (x2 - 10, y2 - 18 * direction), (x2 + 10, y2 - 18 * direction)], fill=color)


def box(draw, xy, title, lines, fill=(234, 245, 244), outline=(27, 127, 121)):
    draw.rounded_rectangle(xy, radius=18, fill=fill, outline=outline, width=4)
    x1, y1, x2, _ = xy
    title_size = min(27, max(16, int((x2 - x1) * 1.65 / max(len(title), 1))))
    draw.text(((x1 + x2) / 2, y1 + 18), title, font=font(title_size, True), fill=(23, 59, 63), anchor="ma")
    y = y1 + 58
    for line in lines:
        draw.text(((x1 + x2) / 2, y), line, font=font(20), fill=(52, 64, 84), anchor="ma")
        y += 29


def wrapped_lines(text, width=34):
    return textwrap.wrap(text, width=width, break_long_words=False, break_on_hyphens=False)


def centered_text(draw, xy, text, size=22, bold=False, fill=(23, 59, 63), line_gap=7):
    x1, y1, x2, y2 = xy
    lines = wrapped_lines(text, max(12, int((x2 - x1) / max(size * 0.56, 1))))
    face = font(size, bold)
    heights = []
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=face)
        heights.append(bbox[3] - bbox[1])
    total = sum(heights) + line_gap * max(0, len(lines) - 1)
    y = (y1 + y2 - total) / 2
    for line, height in zip(lines, heights):
        draw.text(((x1 + x2) / 2, y), line, font=face, fill=fill, anchor="ma")
        y += height + line_gap


def poly_arrow(draw, points, color=(27, 127, 121), width=4, dashed=False):
    for start, end in zip(points, points[1:]):
        if dashed:
            dashed_line(draw, start, end, color=color, width=width, dash=16, gap=9)
        else:
            draw.line([start, end], fill=color, width=width)
    start, end = points[-2], points[-1]
    x1, y1 = start
    x2, y2 = end
    if abs(x2 - x1) >= abs(y2 - y1):
        direction = 1 if x2 > x1 else -1
        tip = [(x2, y2), (x2 - 16 * direction, y2 - 9), (x2 - 16 * direction, y2 + 9)]
    else:
        direction = 1 if y2 > y1 else -1
        tip = [(x2, y2), (x2 - 9, y2 - 16 * direction), (x2 + 9, y2 - 16 * direction)]
    draw.polygon(tip, fill=color)


def flow_symbol(draw, kind, xy, text, danger=False):
    fill = (254, 243, 242) if danger else (234, 245, 244)
    outline = (180, 35, 24) if danger else (27, 127, 121)
    x1, y1, x2, y2 = xy
    if kind == "terminator":
        draw.rounded_rectangle(xy, radius=(y2 - y1) // 2, fill=fill, outline=outline, width=4)
    elif kind == "decision":
        draw.polygon([((x1 + x2) / 2, y1), (x2, (y1 + y2) / 2), ((x1 + x2) / 2, y2), (x1, (y1 + y2) / 2)], fill=fill, outline=outline)
        draw.line([((x1 + x2) / 2, y1), (x2, (y1 + y2) / 2), ((x1 + x2) / 2, y2), (x1, (y1 + y2) / 2), ((x1 + x2) / 2, y1)], fill=outline, width=4)
    elif kind == "io":
        skew = 35
        draw.polygon([(x1 + skew, y1), (x2, y1), (x2 - skew, y2), (x1, y2)], fill=fill, outline=outline)
        draw.line([(x1 + skew, y1), (x2, y1), (x2 - skew, y2), (x1, y2), (x1 + skew, y1)], fill=outline, width=4)
    elif kind == "database":
        draw.rectangle((x1, y1 + 18, x2, y2 - 18), fill=fill, outline=outline, width=4)
        draw.ellipse((x1, y1, x2, y1 + 36), fill=fill, outline=outline, width=4)
        draw.arc((x1, y2 - 36, x2, y2), 0, 180, fill=outline, width=4)
        draw.arc((x1, y2 - 36, x2, y2), 180, 360, fill=outline, width=4)
    else:
        draw.rectangle(xy, fill=fill, outline=outline, width=4)
    centered_text(draw, xy, text, 19 if kind == "decision" else 21, kind in ("terminator", "decision"), fill=(23, 59, 63))


def flow_legend(draw, y):
    items = [
        ("terminator", "Mulai/Selesai"), ("io", "Input/Output"),
        ("process", "Proses"), ("decision", "Keputusan"), ("database", "Data Store"),
    ]
    x = 80
    for kind, label in items:
        flow_symbol(draw, kind, (x, y, x + 150, y + 58), "")
        draw.text((x + 75, y + 72), label, font=font(16), fill=(52, 64, 84), anchor="ma")
        x += 290


def diagram_architecture(path):
    im = Image.new("RGB", (1500, 850), "white")
    d = ImageDraw.Draw(im)
    d.text((750, 35), "Arsitektur Logis SIPANTES", font=font(36, True), fill=(23, 59, 63), anchor="ma")
    box(d, (70, 150, 410, 380), "Flutter Client", ["UI / BLoC", "Repository", "Remote datasource", "Secure storage"])
    box(d, (580, 150, 920, 380), "REST API Go", ["Fiber routes", "Middleware", "Service", "Repository SQL"])
    box(d, (1090, 150, 1430, 380), "MySQL RS", ["Auth mobile", "Pasien / registrasi", "Klinis", "Antrian"])
    arrow(d, (410, 265), (580, 265))
    arrow(d, (920, 265), (1090, 265))
    box(d, (580, 545, 920, 760), "Layanan Eksternal", ["SMTP OTP", "API kalender libur", "Mobile JKN / URL publik"])
    arrow(d, (750, 380), (750, 545))
    d.text((495, 225), "HTTPS/JSON", font=font(18, True), fill=(102, 112, 133), anchor="ma")
    d.text((1005, 225), "SQL terbatas", font=font(18, True), fill=(102, 112, 133), anchor="ma")
    im.save(path)


def diagram_flow(path, title, steps, danger_index=None):
    height = 160 + len(steps) * 135
    im = Image.new("RGB", (1400, height), "white")
    d = ImageDraw.Draw(im)
    d.text((700, 35), title, font=font(35, True), fill=(23, 59, 63), anchor="ma")
    for idx, step in enumerate(steps):
        y1 = 110 + idx * 135
        fill_color = (254, 243, 242) if danger_index == idx else (234, 245, 244)
        outline = (180, 35, 24) if danger_index == idx else (27, 127, 121)
        d.rounded_rectangle((170, y1, 1230, y1 + 85), radius=16, fill=fill_color, outline=outline, width=4)
        d.ellipse((95, y1 + 12, 155, y1 + 72), fill=outline)
        d.text((125, y1 + 42), str(idx + 1), font=font(24, True), fill="white", anchor="mm")
        d.text((205, y1 + 42), step, font=font(23), fill=(23, 59, 63), anchor="lm")
        if idx < len(steps) - 1:
            arrow(d, (700, y1 + 85), (700, y1 + 130), color=outline, width=4)
    im.save(path)


def diagram_flow_registration(path):
    im = Image.new("RGB", (1700, 2050), "white")
    d = ImageDraw.Draw(im)
    d.text((850, 35), "Flowchart Registrasi Akun Mobile", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    flow_legend(d, 100)
    cx = 850
    nodes = [
        ("terminator", (610, 235, 1090, 325), "Mulai"),
        ("io", (560, 385, 1140, 495), "Pengguna mengisi nama, email, dan telepon"),
        ("decision", (600, 555, 1100, 705), "Format data valid?"),
        ("process", (560, 775, 1140, 885), "API menormalisasi email dan memeriksa akun"),
        ("decision", (600, 945, 1100, 1095), "Akun aktif sudah ada?"),
        ("process", (560, 1165, 1140, 1275), "Bersihkan state legacy soft-delete dan challenge lama"),
        ("process", (560, 1335, 1140, 1445), "Buat OTP registrasi 5 menit dan kirim melalui SMTP"),
        ("io", (560, 1505, 1140, 1615), "Pengguna memasukkan OTP terbaru"),
        ("decision", (600, 1675, 1100, 1825), "OTP valid dan attempt < 5?"),
        ("terminator", (610, 1910, 1090, 2000), "Lanjut ke set password"),
    ]
    for kind, xy, text in nodes:
        flow_symbol(d, kind, xy, text)
    for a, b in zip(nodes, nodes[1:]):
        poly_arrow(d, [((a[1][0] + a[1][2]) / 2, a[1][3]), ((b[1][0] + b[1][2]) / 2, b[1][1])])
    # Cabang validasi input.
    flow_symbol(d, "process", (80, 575, 430, 685), "Tampilkan pesan validasi")
    poly_arrow(d, [(600, 630), (430, 630)], color=(180, 35, 24))
    d.text((500, 602), "Tidak", font=font(18, True), fill=(180, 35, 24), anchor="ma")
    poly_arrow(d, [(255, 575), (255, 440), (560, 440)], color=(180, 35, 24))
    d.text((880, 730), "Ya", font=font(18, True), fill=(27, 127, 121), anchor="ma")
    # Akun aktif tidak boleh ditimpa.
    flow_symbol(d, "terminator", (1270, 965, 1620, 1075), "409: arahkan login / lupa password")
    poly_arrow(d, [(1100, 1020), (1270, 1020)], color=(180, 35, 24))
    d.text((1180, 992), "Ya", font=font(18, True), fill=(180, 35, 24), anchor="ma")
    d.text((880, 1125), "Tidak", font=font(18, True), fill=(27, 127, 121), anchor="ma")
    # OTP salah/expired kembali ke kirim OTP atau selesai locked.
    flow_symbol(d, "decision", (80, 1685, 430, 1815), "Masih boleh mencoba?" )
    poly_arrow(d, [(600, 1750), (430, 1750)], color=(180, 35, 24))
    d.text((500, 1720), "Tidak valid", font=font(17, True), fill=(180, 35, 24), anchor="ma")
    poly_arrow(d, [(255, 1685), (255, 1560), (560, 1560)], color=(180, 83, 9))
    d.text((335, 1625), "Ya", font=font(17, True), fill=(180, 83, 9), anchor="ma")
    flow_symbol(d, "terminator", (80, 1900, 430, 2010), "Challenge terkunci / minta OTP baru")
    poly_arrow(d, [(255, 1815), (255, 1900)], color=(180, 35, 24))
    d.text((330, 1860), "Tidak", font=font(17, True), fill=(180, 35, 24), anchor="ma")
    d.text((880, 1860), "Ya", font=font(18, True), fill=(27, 127, 121), anchor="ma")
    im.save(path)


def diagram_flow_booking(path):
    im = Image.new("RGB", (1700, 1900), "white")
    d = ImageDraw.Draw(im)
    d.text((850, 35), "Flowchart Booking Umum", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    flow_legend(d, 100)
    nodes = [
        ("terminator", (610, 235, 1090, 325), "Mulai"),
        ("decision", (600, 385, 1100, 535), "Session valid?"),
        ("decision", (600, 605, 1100, 755), "Akun sudah terhubung ke pasien?"),
        ("io", (560, 825, 1140, 935), "Pilih poli, tanggal, dokter, dan cara bayar"),
        ("process", (560, 995, 1140, 1105), "API membaca jadwal, hari Minggu, dan hari libur"),
        ("decision", (600, 1165, 1100, 1315), "Tanggal tersedia dan kuota valid?"),
        ("decision", (600, 1385, 1100, 1535), "Booking duplikat?"),
        ("database", (560, 1605, 1140, 1735), "Simpan registrasis_dummy dan nomor antrean"),
        ("terminator", (610, 1800, 1090, 1880), "Selesai: booking ditampilkan"),
    ]
    for kind, xy, text in nodes:
        flow_symbol(d, kind, xy, text)
    for a, b in zip(nodes, nodes[1:]):
        poly_arrow(d, [((a[1][0] + a[1][2]) / 2, a[1][3]), ((b[1][0] + b[1][2]) / 2, b[1][1])])
    for y, text in [(460, "Login diperlukan"), (680, "Hubungkan No. RM"), (1240, "Pilih tanggal lain"), (1460, "Tolak booking ganda")]:
        flow_symbol(d, "terminator", (1250, y - 50, 1630, y + 50), text)
    for source_y, target_y, label in [(460, 460, "Tidak"), (680, 680, "Tidak"), (1240, 1240, "Tidak"), (1460, 1460, "Ya")]:
        poly_arrow(d, [(1100, source_y), (1250, target_y)], color=(180, 35, 24))
        d.text((1175, source_y - 28), label, font=font(17, True), fill=(180, 35, 24), anchor="ma")
    d.text((880, 565), "Ya", font=font(17, True), fill=(27, 127, 121), anchor="ma")
    d.text((880, 785), "Ya", font=font(17, True), fill=(27, 127, 121), anchor="ma")
    d.text((880, 1345), "Ya", font=font(17, True), fill=(27, 127, 121), anchor="ma")
    d.text((880, 1568), "Tidak", font=font(17, True), fill=(27, 127, 121), anchor="ma")
    im.save(path)


def diagram_flow_delete(path):
    im = Image.new("RGB", (1700, 1950), "white")
    d = ImageDraw.Draw(im)
    d.text((850, 35), "Flowchart Hapus Akun Mobile", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    flow_legend(d, 100)
    nodes = [
        ("terminator", (610, 235, 1090, 325), "Mulai"),
        ("io", (560, 385, 1140, 495), "Pengguna memasukkan password"),
        ("decision", (600, 555, 1100, 705), "Session dan password valid?"),
        ("process", (560, 775, 1140, 885), "Nonaktifkan challenge lama; kirim OTP hapus akun"),
        ("io", (560, 945, 1140, 1055), "Pengguna memasukkan OTP penghapusan"),
        ("decision", (600, 1115, 1100, 1265), "OTP valid dan belum kedaluwarsa?"),
        ("process", (560, 1335, 1140, 1445), "BEGIN; lock user_mobile dan challenge OTP"),
        ("database", (560, 1505, 1140, 1635), "Hapus sesi, seluruh OTP, dan ticket mobile"),
        ("process", (560, 1695, 1140, 1805), "Hapus user_mobile; COMMIT"),
        ("terminator", (610, 1860, 1090, 1935), "Selesai: session lokal dibersihkan"),
    ]
    for kind, xy, text in nodes:
        flow_symbol(d, kind, xy, text, danger=kind == "database")
    for a, b in zip(nodes, nodes[1:]):
        poly_arrow(d, [((a[1][0] + a[1][2]) / 2, a[1][3]), ((b[1][0] + b[1][2]) / 2, b[1][1])])
    flow_symbol(d, "terminator", (1250, 575, 1630, 685), "401: autentikasi ditolak")
    poly_arrow(d, [(1100, 630), (1250, 630)], color=(180, 35, 24))
    d.text((1175, 602), "Tidak", font=font(17, True), fill=(180, 35, 24), anchor="ma")
    flow_symbol(d, "terminator", (1250, 1135, 1630, 1245), "Tambah attempt / lock challenge")
    poly_arrow(d, [(1100, 1190), (1250, 1190)], color=(180, 35, 24))
    d.text((1175, 1162), "Tidak", font=font(17, True), fill=(180, 35, 24), anchor="ma")
    d.text((880, 1300), "Ya", font=font(17, True), fill=(27, 127, 121), anchor="ma")
    d.text((1320, 1475), "TIDAK menghapus pasiens, registrasi, EMR, lab, radiologi, atau farmasi", font=font(18, True), fill=(180, 35, 24), anchor="ma")
    im.save(path)


def dashed_line(draw, start, end, color=(180, 83, 9), width=4, dash=18, gap=10):
    x1, y1 = start
    x2, y2 = end
    length = max(abs(x2 - x1), abs(y2 - y1))
    if length == 0:
        return
    for offset in range(0, length, dash + gap):
        ratio1 = offset / length
        ratio2 = min(offset + dash, length) / length
        draw.line(
            [
                (x1 + (x2 - x1) * ratio1, y1 + (y2 - y1) * ratio1),
                (x1 + (x2 - x1) * ratio2, y1 + (y2 - y1) * ratio2),
            ],
            fill=color,
            width=width,
        )


def diagram_erd_auth(path):
    im = Image.new("RGB", (1800, 1250), "white")
    d = ImageDraw.Draw(im)
    d.text((900, 25), "ERD Autentikasi Mobile", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    d.text((900, 75), "Garis hijau = FK fisik  |  Garis putus jingga = relasi logis/query", font=font(21), fill=(102, 112, 133), anchor="ma")
    nodes = {
        "user_mobile": (710, 455, 1090, 690),
        "otp_user_mobile": (70, 150, 450, 355),
        "otp_password_reset_mobile": (500, 150, 880, 355),
        "otp_account_deletion_mobile": (930, 150, 1310, 355),
        "session_user_mobile": (1360, 150, 1740, 355),
        "otp_medical_record_claim_mobile": (70, 865, 450, 1085),
        "otp_verif_email_mobile": (500, 865, 880, 1085),
        "auth_ticket_mobile": (930, 865, 1310, 1085),
        "pasiens": (1360, 865, 1740, 1085),
    }
    lines = {
        "user_mobile": ["PK id", "UK email", "UK patient_id (nullable)", "password hash / verified", "is_deleted / deleted_at"],
        "otp_user_mobile": ["PK id", "FK user_id -> user_mobile.id", "otp_hash / expiry / used", "ON DELETE CASCADE"],
        "otp_password_reset_mobile": ["PK id", "FK user_id -> user_mobile.id", "otp_hash / attempt / locked", "ON DELETE CASCADE"],
        "otp_account_deletion_mobile": ["PK id", "FK user_id -> user_mobile.id", "OTP khusus penghapusan", "ON DELETE CASCADE"],
        "session_user_mobile": ["PK id", "user_id (relasi aplikasi)", "UK access/refresh hash", "family / rotation / revoke"],
        "otp_medical_record_claim_mobile": ["PK id", "FK user_id -> user_mobile.id", "patient_id / no_rm snapshot", "ON DELETE CASCADE"],
        "otp_verif_email_mobile": ["PK id", "email + snapshot profil", "OTP sebelum user dibuat", "tidak memiliki user_id"],
        "auth_ticket_mobile": ["PK id", "verification_id", "email / purpose / ticket_hash", "relasi query ke OTP email"],
        "pasiens": ["PK id", "no_rm / NIK / tanggal_lahir", "referensi logis patient_id", "tidak dihapus bersama akun"],
    }
    for name, xy in nodes.items():
        box(d, xy, name, lines[name], fill=(254, 243, 242) if name == "pasiens" else (234, 245, 244), outline=(180, 35, 24) if name == "pasiens" else (27, 127, 121))
    # FK yang benar-benar dideklarasikan pada migrasi.
    arrow(d, (260, 355), (710, 505), width=4)
    arrow(d, (690, 355), (800, 455), width=4)
    arrow(d, (1120, 355), (1000, 455), width=4)
    arrow(d, (260, 865), (710, 640), width=4)
    # Relasi logis yang digunakan source tetapi tidak dideklarasikan sebagai FK.
    dashed_line(d, (1550, 355), (1090, 505))
    dashed_line(d, (880, 975), (930, 975))
    dashed_line(d, (1090, 640), (1550, 865), color=(180, 35, 24))
    d.text((1450, 560), "user_id: 1 akun -> banyak sesi", font=font(18, True), fill=(180, 83, 9), anchor="ma")
    d.text((905, 940), "verification_id", font=font(17, True), fill=(180, 83, 9), anchor="ma")
    d.text((1405, 745), "patient_id: 0..1 akun -> 1 pasien", font=font(18, True), fill=(180, 35, 24), anchor="ma")
    d.text((900, 1170), "Semua tabel OTP/sesi bersifat anak autentikasi; master pasien/rekam medis berada di luar ownership akun mobile.", font=font(21, True), fill=(23, 59, 63), anchor="ma")
    im.save(path)


def diagram_erd_services(path):
    im = Image.new("RGB", (1900, 1280), "white")
    d = ImageDraw.Draw(im)
    d.text((950, 25), "Peta Relasi Data Layanan yang Dibaca API Mobile", font=font(37, True), fill=(23, 59, 63), anchor="ma")
    d.text((950, 75), "Relasi berikut berasal dari JOIN/query repository; bukan klaim seluruhnya memiliki FOREIGN KEY fisik.", font=font(21), fill=(102, 112, 133), anchor="ma")
    nodes = {
        "user_mobile": (60, 160, 390, 330),
        "pasiens": (520, 160, 850, 330),
        "registrasis": (980, 160, 1310, 330),
        "master_kunjungan": (1450, 135, 1840, 355),
        "resume_diagnosis": (60, 515, 430, 760),
        "laboratorium": (520, 515, 890, 760),
        "radiologi": (980, 515, 1350, 760),
        "farmasi": (1450, 515, 1820, 760),
        "booking_dummy": (60, 945, 430, 1155),
        "kamar_rawat": (520, 945, 890, 1155),
        "jadwal_libur": (980, 945, 1350, 1155),
    }
    lines = {
        "user_mobile": ["patient_id", "no_rm", "identitas login"],
        "pasiens": ["PK id", "no_rm", "master identitas pasien"],
        "registrasis": ["PK id", "pasien_id", "poli/dokter/antrian/bayar"],
        "master_kunjungan": ["polis.id", "pegawais.id", "antrian_poli.id", "carabayars.id"],
        "resume_diagnosis": ["resume_pasiens / EMR", "jkn/perawatan_icd10s", "jkn/perawatan_icd9s", "master icd10s / icd9s"],
        "laboratorium": ["hasillabs / rincian_hasillabs", "order_lab / lica_results", "labsections / labkategoris", "laboratoria"],
        "radiologi": ["order_radiologi", "hasil/detail radiologis", "radiologi_ekspertises", "pegawais dokter"],
        "farmasi": ["penjualans", "penjualandetails", "masterobats", "berdasarkan registrasi"],
        "booking_dummy": ["registrasis_dummy", "no_rm / poli / dokter", "staging booking umum mobile"],
        "kamar_rawat": ["rawatinaps", "kelompok_kelas", "kamars / beds", "registrasi aktif"],
        "jadwal_libur": ["jadwaldokters", "tanggal_libur_rs", "kalender ketersediaan", "tidak terkait data klinis"],
    }
    for name, xy in nodes.items():
        box(d, xy, name, lines[name], fill=(234, 245, 244), outline=(27, 127, 121))
    relation_color = (180, 83, 9)
    for start, end, label, label_xy in [
        ((390, 245), (520, 245), "patient_id = pasiens.id", (455, 215)),
        ((850, 245), (980, 245), "pasien_id", (915, 215)),
        ((1310, 245), (1450, 245), "id/kode master", (1380, 215)),
        ((1145, 330), (245, 515), "registrasi_id / kode ICD", (670, 420)),
        ((1145, 330), (705, 515), "pasien_id / registrasi_id", (900, 465)),
        ((1145, 330), (1165, 515), "registrasi_id", (1215, 425)),
        ((1145, 330), (1635, 515), "registrasi_id", (1515, 425)),
        ((685, 330), (245, 945), "no_rm", (390, 820)),
        ((1145, 330), (705, 945), "rawat inap", (870, 835)),
        ((1645, 355), (1165, 945), "poli/dokter + tanggal", (1450, 850)),
    ]:
        dashed_line(d, start, end, color=relation_color, width=4)
        d.text(label_xy, label, font=font(17, True), fill=relation_color, anchor="ma")
    d.text((950, 1235), "Arah baca utama: akun mobile -> pasien -> registrasi -> detail pelayanan. API selalu membatasi data klinis memakai patient_id principal.", font=font(21, True), fill=(23, 59, 63), anchor="ma")
    im.save(path)


def entity_table(draw, xy, name, rows, header_fill=(27, 127, 121), logical=False):
    x1, y1, x2, y2 = xy
    outline = (180, 83, 9) if logical else (27, 127, 121)
    draw.rectangle(xy, fill="white", outline=outline, width=4)
    header_h = 54
    draw.rectangle((x1, y1, x2, y1 + header_h), fill=header_fill if not logical else (180, 83, 9), outline=outline, width=4)
    centered_text(draw, (x1 + 8, y1 + 3, x2 - 8, y1 + header_h - 3), name, 22, True, fill="white")
    row_h = (y2 - y1 - header_h) / max(len(rows), 1)
    for idx, (key, column) in enumerate(rows):
        top = y1 + header_h + idx * row_h
        if idx:
            draw.line((x1, top, x2, top), fill=(208, 213, 221), width=2)
        draw.text((x1 + 12, top + row_h / 2), key, font=font(16, True), fill=outline, anchor="lm")
        draw.text((x1 + 72, top + row_h / 2), column, font=font(16), fill=(52, 64, 84), anchor="lm")


def er_relation(draw, points, start_card="1", end_card="0..N", label="", logical=False, label_xy=None):
    color = (180, 83, 9) if logical else (27, 127, 121)
    for start, end in zip(points, points[1:]):
        if logical:
            dashed_line(draw, start, end, color=color, width=4, dash=16, gap=9)
        else:
            draw.line((start, end), fill=color, width=4)
    sx, sy = points[0]
    ex, ey = points[-1]
    draw.ellipse((sx - 5, sy - 5, sx + 5, sy + 5), fill=color)
    # Simbol kardinalitas eksplisit ditempatkan di kedua ujung untuk mencegah ambigu.
    draw.text((sx + 12, sy - 22), start_card, font=font(17, True), fill=color)
    draw.text((ex + 12, ey - 22), end_card, font=font(17, True), fill=color)
    if label:
        if label_xy is None:
            mx = (sx + ex) / 2
            my = (sy + ey) / 2
        else:
            mx, my = label_xy
        draw.rounded_rectangle((mx - 90, my - 20, mx + 90, my + 20), radius=8, fill="white")
        draw.text((mx, my), label, font=font(15, True), fill=color, anchor="mm")


def diagram_erd_auth_formal(path):
    im = Image.new("RGB", (2300, 1550), "white")
    d = ImageDraw.Draw(im)
    d.text((1150, 30), "ERD Autentikasi Mobile — Crow's Foot/Cardinality", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    d.text((1150, 78), "Hijau: constraint fisik pada migrasi  |  Jingga putus: relasi logis pada query", font=font(20), fill=(102, 112, 133), anchor="ma")
    boxes = {
        "otp_email": (50, 180, 440, 500),
        "ticket": (50, 760, 440, 1080),
        "user": (900, 150, 1400, 590),
        "patient": (1810, 180, 2250, 500),
        "otp_login": (500, 970, 850, 1390),
        "otp_reset": (875, 970, 1225, 1390),
        "otp_delete": (1250, 970, 1600, 1390),
        "otp_claim": (1625, 970, 1975, 1390),
        "session": (2000, 970, 2270, 1390),
    }
    entity_table(d, boxes["otp_email"], "otp_verif_email_mobile", [
        ("PK", "id"), ("IDX", "email"), ("", "profile snapshot"), ("", "otp_hash"), ("", "attempt/locked"), ("", "expired/used"),
    ])
    entity_table(d, boxes["ticket"], "auth_ticket_mobile", [
        ("PK", "id"), ("UK", "ticket_hash"), ("L-FK", "verification_id"), ("IDX", "email + purpose"), ("", "expires/used/revoked"),
    ], logical=True)
    entity_table(d, boxes["user"], "user_mobile", [
        ("PK", "id"), ("UK", "email"), ("UK", "patient_id (nullable)"), ("IDX", "no_rm"), ("", "username/full_name/phone"), ("", "password hash"), ("", "email_verified/verified_at"), ("", "is_deleted/deleted_at"),
    ])
    entity_table(d, boxes["patient"], "pasiens", [
        ("PK", "id"), ("UK*", "no_rm"), ("", "nik"), ("", "tanggal_lahir"), ("", "identitas pasien"),
    ], logical=True)
    common = [("PK", "id"), ("FK", "user_id"), ("", "otp_hash"), ("", "attempt/locked"), ("", "expired/used")]
    entity_table(d, boxes["otp_login"], "otp_user_mobile", common)
    entity_table(d, boxes["otp_reset"], "otp_password_reset_mobile", common)
    entity_table(d, boxes["otp_delete"], "otp_account_deletion_mobile", common)
    entity_table(d, boxes["otp_claim"], "otp_medical_record_claim_mobile", [
        ("PK", "id"), ("FK", "user_id"), ("L-FK", "patient_id"), ("", "no_rm/patient snapshot"), ("", "otp/status")
    ])
    entity_table(d, boxes["session"], "session_user_mobile", [
        ("PK", "id"), ("L-FK", "user_id"), ("UK", "access_hash"), ("UK", "refresh_hash"), ("", "family/parent"), ("", "expiry/revoked")
    ], logical=True)
    er_relation(d, [(245, 500), (245, 760)], "1", "0..N", "verification_id", logical=True, label_xy=(245, 630))
    er_relation(d, [(1400, 350), (1810, 350)], "0..1", "1", "patient_id", logical=True, label_xy=(1605, 350))
    # Bus relasi anak dibuat di area kosong agar tidak melewati kotak tabel.
    d.line((1150, 590, 1150, 800), fill=(27, 127, 121), width=4)
    d.line((675, 800, 1800, 800), fill=(27, 127, 121), width=4)
    for x, target, physical in [(675, "otp_login", True), (1050, "otp_reset", True), (1425, "otp_delete", True), (1800, "otp_claim", True)]:
        d.line((x, 800, x, boxes[target][1]), fill=(27, 127, 121), width=4)
        d.text((x + 12, 820), "0..N", font=font(17, True), fill=(27, 127, 121))
    d.text((1164, 610), "1", font=font(17, True), fill=(27, 127, 121))
    er_relation(d, [(1350, 590), (1350, 700), (2135, 700), (2135, 970)], "1", "0..N", "user_id", logical=True, label_xy=(1950, 700))
    d.rounded_rectangle((610, 1445, 1690, 1515), radius=12, fill=(242, 244, 247), outline=(102, 112, 133), width=2)
    d.text((1150, 1480), "PK = primary key | FK = foreign key fisik | L-FK = referensi logis | UK = unique key | 1 / 0..1 / 0..N = kardinalitas", font=font(18, True), fill=(52, 64, 84), anchor="mm")
    im.save(path)


def diagram_erd_service_formal(path):
    im = Image.new("RGB", (2300, 1750), "white")
    d = ImageDraw.Draw(im)
    d.text((1150, 25), "ERD Logis Pelayanan — Relasi M:N melalui Associative Entity", font=font(36, True), fill=(23, 59, 63), anchor="ma")
    d.text((1150, 72), "Seluruh garis jingga putus adalah relasi query pada tabel SIMRS existing; bukan pernyataan FK fisik.", font=font(20), fill=(102, 112, 133), anchor="ma")
    boxes = {
        "patient": (50, 180, 410, 500), "reg": (650, 160, 1050, 540),
        "poli": (1320, 100, 1620, 350), "doctor": (1900, 100, 2200, 350),
        "diag_link": (1250, 600, 1620, 930), "icd10": (1900, 620, 2200, 900),
        "proc_link": (1250, 1030, 1620, 1360), "icd9": (1900, 1050, 2200, 1330),
        "lab": (50, 680, 410, 1000), "radiology": (50, 1120, 410, 1440),
        "sales": (650, 1120, 1050, 1440), "drug_detail": (650, 1510, 1050, 1715),
    }
    entity_table(d, boxes["patient"], "pasiens", [("PK", "id"), ("UK*", "no_rm"), ("", "nik"), ("", "tanggal_lahir"), ("", "nama")], logical=True)
    entity_table(d, boxes["reg"], "registrasis", [("PK", "id"), ("L-FK", "pasien_id"), ("L-FK", "poli_id"), ("L-FK", "dokter_id"), ("L-FK", "antrian_poli_id"), ("", "tanggal/status/bayar")], logical=True)
    entity_table(d, boxes["poli"], "polis", [("PK", "id"), ("", "kode/nama"), ("", "dokter_id")], logical=True)
    entity_table(d, boxes["doctor"], "pegawais", [("PK", "id"), ("", "nama"), ("", "profesi/status")], logical=True)
    entity_table(d, boxes["diag_link"], "perawatan_icd10s / jkn_icd10s", [("PK*", "id"), ("L-FK", "registrasi_id"), ("L-FK", "icd10"), ("", "status/jenis")], logical=True)
    entity_table(d, boxes["icd10"], "icd10s", [("PK*", "nomor"), ("", "nama diagnosis"), ("", "aktif")], logical=True)
    entity_table(d, boxes["proc_link"], "perawatan_icd9s / jkn_icd9s", [("PK*", "id"), ("L-FK", "registrasi_id"), ("L-FK", "icd9"), ("", "status/jenis")], logical=True)
    entity_table(d, boxes["icd9"], "icd9s", [("PK*", "nomor"), ("", "nama tindakan"), ("", "aktif")], logical=True)
    entity_table(d, boxes["lab"], "hasillabs", [("PK", "id"), ("L-FK", "pasien_id"), ("L-FK", "registrasi_id"), ("L-FK", "order_lab_id"), ("", "tanggal/status")], logical=True)
    entity_table(d, boxes["radiology"], "hasilradiologis", [("PK", "id"), ("L-FK", "registrasi_id"), ("", "hasil/status"), ("", "tanggal")], logical=True)
    entity_table(d, boxes["sales"], "penjualans", [("PK", "id"), ("L-FK", "registrasi_id"), ("L-FK", "dokter_id"), ("", "tanggal/status")], logical=True)
    entity_table(d, boxes["drug_detail"], "penjualandetails", [("PK", "id"), ("L-FK", "penjualan_id"), ("L-FK", "masterobat_id")], logical=True)
    # Relasi ditempatkan pada koridor kosong dan tidak memotong tabel.
    er_relation(d, [(410, 340), (650, 340)], "1", "0..N", "pasien_id", logical=True, label_xy=(530, 340))
    er_relation(d, [(1050, 250), (1320, 250)], "0..N", "1", "poli_id", logical=True, label_xy=(1185, 250))
    er_relation(d, [(1050, 430), (1750, 430), (1750, 250), (1900, 250)], "0..N", "1", "dokter_id", logical=True, label_xy=(1750, 430))
    er_relation(d, [(850, 540), (850, 765), (1250, 765)], "1", "0..N", "registrasi_id", logical=True, label_xy=(1050, 765))
    er_relation(d, [(1620, 765), (1900, 765)], "0..N", "1", "icd10", logical=True, label_xy=(1760, 765))
    er_relation(d, [(900, 540), (900, 1195), (1250, 1195)], "1", "0..N", "registrasi_id", logical=True, label_xy=(1080, 1195))
    er_relation(d, [(1620, 1195), (1900, 1195)], "0..N", "1", "icd9", logical=True, label_xy=(1760, 1195))
    er_relation(d, [(650, 470), (530, 470), (530, 840), (410, 840)], "1", "0..N", "registrasi_id", logical=True, label_xy=(530, 660))
    er_relation(d, [(650, 500), (560, 500), (560, 1280), (410, 1280)], "1", "0..N", "registrasi_id", logical=True, label_xy=(560, 1080))
    er_relation(d, [(850, 540), (850, 1120)], "1", "0..N", "registrasi_id", logical=True, label_xy=(850, 950))
    er_relation(d, [(850, 1440), (850, 1510)], "1", "1..N", "penjualan_id", logical=True, label_xy=(850, 1475))
    d.rounded_rectangle((1180, 1470, 2220, 1665), radius=16, fill=(255, 247, 237), outline=(180, 83, 9), width=3)
    centered_text(d, (1200, 1485, 2200, 1645), "Relasi konseptual M:N:\nregistrasis M:N icd10s diselesaikan oleh perawatan_icd10s/jkn_icd10s.\nregistrasis M:N icd9s diselesaikan oleh perawatan_icd9s/jkn_icd9s.\nSatu relasi M:N tidak digambar langsung; associative entity menyimpan pasangan key.", 19, True, fill=(120, 53, 15))
    im.save(path)


def dfd_entity(draw, xy, text):
    draw.rectangle(xy, fill=(242, 244, 247), outline=(52, 64, 84), width=4)
    centered_text(draw, xy, text, 21, True)


def dfd_process(draw, xy, number, text):
    draw.rounded_rectangle(xy, radius=45, fill=(234, 245, 244), outline=(27, 127, 121), width=4)
    x1, y1, x2, y2 = xy
    draw.ellipse((x1 + 12, y1 + 12, x1 + 72, y1 + 72), fill=(27, 127, 121))
    draw.text((x1 + 42, y1 + 42), number, font=font(18, True), fill="white", anchor="mm")
    centered_text(draw, (x1 + 75, y1, x2 - 10, y2), text, 21, True)


def dfd_store(draw, xy, code, text):
    x1, y1, x2, y2 = xy
    draw.line((x1, y1, x2, y1), fill=(180, 83, 9), width=4)
    draw.line((x1, y2, x2, y2), fill=(180, 83, 9), width=4)
    draw.line((x1 + 75, y1, x1 + 75, y2), fill=(180, 83, 9), width=3)
    draw.text((x1 + 38, (y1 + y2) / 2), code, font=font(18, True), fill=(180, 83, 9), anchor="mm")
    centered_text(draw, (x1 + 80, y1, x2, y2), text, 18, True, fill=(120, 53, 15))


def dfd_flow(draw, points, label, label_xy):
    poly_arrow(draw, points, color=(52, 64, 84), width=3)
    x, y = label_xy
    lines = wrapped_lines(label, 25)
    bbox_h = 18 * len(lines) + 12
    draw.rounded_rectangle((x - 115, y - bbox_h / 2, x + 115, y + bbox_h / 2), radius=7, fill="white")
    for idx, line in enumerate(lines):
        draw.text((x, y - (len(lines) - 1) * 9 + idx * 18), line, font=font(15, True), fill=(52, 64, 84), anchor="mm")


def diagram_dfd_context(path):
    im = Image.new("RGB", (1900, 1250), "white")
    d = ImageDraw.Draw(im)
    d.text((950, 30), "DFD Level 0 — Diagram Konteks SIPANTES", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    dfd_process(d, (700, 455, 1200, 760), "0", "Sistem SIPANTES")
    dfd_entity(d, (70, 170, 430, 330), "Pengguna Mobile")
    dfd_entity(d, (70, 910, 430, 1070), "Operator Teknis")
    dfd_entity(d, (1470, 120, 1830, 280), "SIMRS / Database RS")
    dfd_entity(d, (1470, 380, 1830, 540), "SMTP Email")
    dfd_entity(d, (1470, 640, 1830, 800), "API Kalender Libur")
    dfd_entity(d, (1470, 900, 1830, 1060), "Google Play Store")
    dfd_flow(d, [(430, 230), (620, 230), (620, 520), (700, 520)], "kredensial, OTP, permintaan layanan", (600, 360))
    dfd_flow(d, [(700, 680), (580, 680), (580, 285), (430, 285)], "status auth, informasi, hasil pelayanan", (580, 600))
    dfd_flow(d, [(430, 990), (700, 700)], "konfigurasi/deployment", (560, 870))
    dfd_flow(d, [(1200, 520), (1370, 520), (1370, 200), (1470, 200)], "query pasien, kunjungan, jadwal", (1380, 350))
    dfd_flow(d, [(1470, 255), (1400, 255), (1400, 690), (1200, 690)], "data SIMRS", (1390, 570))
    dfd_flow(d, [(1200, 560), (1470, 460)], "pesan OTP", (1340, 505))
    dfd_flow(d, [(1470, 720), (1200, 650)], "tanggal libur", (1340, 690))
    dfd_flow(d, [(1200, 735), (1470, 980)], "cek versi / buka listing", (1340, 865))
    d.text((950, 1170), "Aturan konteks: hanya satu proses sistem; tidak ada data store internal; seluruh arus data level bawah harus seimbang dengan arus pada level ini.", font=font(19, True), fill=(102, 112, 133), anchor="ma")
    im.save(path)


def diagram_dfd_level1(path):
    im = Image.new("RGB", (2200, 1650), "white")
    d = ImageDraw.Draw(im)
    d.text((1100, 25), "DFD Level 1 — Dekomposisi Proses SIPANTES", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    dfd_entity(d, (40, 180, 340, 330), "Pengguna Mobile")
    dfd_entity(d, (40, 1240, 340, 1390), "Operator Teknis")
    processes = [
        ((500, 130, 900, 300), "1.0", "Kelola Autentikasi & Akun"),
        ((500, 430, 900, 600), "2.0", "Sajikan Profil & Rekam Medis"),
        ((500, 730, 900, 900), "3.0", "Kelola Booking & Antrian"),
        ((500, 1030, 900, 1200), "4.0", "Sajikan Informasi RS"),
        ((500, 1330, 900, 1500), "5.0", "Kelola Update Aplikasi"),
    ]
    for xy, no, name in processes:
        dfd_process(d, xy, no, name)
    stores = [
        ((1100, 130, 1550, 230), "D1", "Data Auth Mobile"),
        ((1100, 450, 1550, 550), "D2", "Data Pasien & Klinis SIMRS"),
        ((1100, 770, 1550, 870), "D3", "Staging Booking"),
        ((1100, 1080, 1550, 1180), "D4", "Jadwal & Hari Libur"),
    ]
    for xy, code, name in stores:
        dfd_store(d, xy, code, name)
    dfd_entity(d, (1800, 130, 2140, 280), "SMTP Email")
    dfd_entity(d, (1800, 1060, 2140, 1210), "API Kalender")
    dfd_entity(d, (1800, 1350, 2140, 1500), "Google Play Store")
    # Pengguna ke tiap proses: koridor horizontal terpisah.
    for y, label in [(215, "registrasi/login/OTP/akun"), (515, "permintaan data pasien"), (815, "pilihan dan booking"), (1115, "permintaan informasi"), (1415, "cek versi")]:
        dfd_flow(d, [(340, y), (500, y)], label, (420, y - 25))
    # Proses ke data store dan eksternal.
    dfd_flow(d, [(900, 215), (1100, 180)], "akun, OTP, tiket, sesi", (1000, 170))
    dfd_flow(d, [(900, 515), (1100, 500)], "patient_id dan data klinis", (1000, 470))
    dfd_flow(d, [(900, 815), (1100, 820)], "booking mobile", (1000, 785))
    dfd_flow(d, [(900, 1115), (1100, 1130)], "jadwal/libur", (1000, 1085))
    dfd_flow(d, [(1550, 180), (1800, 205)], "email OTP", (1675, 165))
    dfd_flow(d, [(1800, 1135), (1550, 1135)], "data libur", (1675, 1100))
    dfd_flow(d, [(900, 1415), (1800, 1425)], "versi aplikasi/listing", (1350, 1380))
    dfd_flow(d, [(340, 1315), (500, 1410)], "konfigurasi rilis", (420, 1370))
    d.text((1100, 1595), "Setiap proses hanya berkomunikasi dengan entitas luar atau data store melalui arus data bernama; tidak ada arus langsung antar data store.", font=font(19, True), fill=(102, 112, 133), anchor="ma")
    im.save(path)


def diagram_dfd_auth_level2(path):
    im = Image.new("RGB", (2200, 1600), "white")
    d = ImageDraw.Draw(im)
    d.text((1100, 25), "DFD Level 2 — Proses 1.0 Autentikasi & Akun", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    dfd_entity(d, (40, 170, 340, 320), "Pengguna Mobile")
    dfd_entity(d, (1840, 170, 2160, 320), "SMTP Email")
    dfd_entity(d, (1840, 1220, 2160, 1370), "SIMRS Pasien")
    processes = [
        ((480, 120, 900, 290), "1.1", "Registrasi & OTP Email"),
        ((480, 400, 900, 570), "1.2", "Set Password & Buat Akun"),
        ((480, 680, 900, 850), "1.3", "Login, OTP & Session"),
        ((480, 960, 900, 1130), "1.4", "Klaim No. RM"),
        ((480, 1240, 900, 1410), "1.5", "Hapus Akun Mobile"),
    ]
    for xy, no, label in processes:
        dfd_process(d, xy, no, label)
    dfd_store(d, (1100, 150, 1600, 250), "D1.1", "OTP Email & Auth Ticket")
    dfd_store(d, (1100, 440, 1600, 540), "D1.2", "user_mobile")
    dfd_store(d, (1100, 720, 1600, 820), "D1.3", "OTP User & Session")
    dfd_store(d, (1100, 1010, 1600, 1110), "D1.4", "OTP Klaim No. RM")
    dfd_store(d, (1100, 1290, 1600, 1390), "D1.5", "OTP Hapus Akun")
    for y, label in [(205, "profil registrasi/OTP"), (485, "password + ticket"), (765, "credential/OTP"), (1045, "No. RM/NIK/tgl lahir"), (1325, "password/OTP hapus")]:
        dfd_flow(d, [(340, y), (480, y)], label, (410, y - 25))
    for y, label in [(205, "challenge/ticket"), (485, "akun"), (765, "OTP/sesi"), (1045, "challenge klaim"), (1325, "challenge hapus")]:
        dfd_flow(d, [(900, y), (1100, y)], label, (1000, y - 25))
    dfd_flow(d, [(900, 190), (1700, 190), (1840, 225)], "email OTP registrasi", (1700, 155))
    dfd_flow(d, [(900, 750), (1700, 750), (1700, 260), (1840, 260)], "email OTP login/reset", (1700, 600))
    dfd_flow(d, [(900, 1045), (1730, 1045), (1730, 1295), (1840, 1295)], "verifikasi identitas pasien", (1700, 1130))
    dfd_flow(d, [(1600, 490), (1750, 490), (1750, 1325), (1840, 1325)], "patient_id/no_rm", (1750, 900))
    d.text((1100, 1535), "Balance: input/output pengguna, SMTP, dan SIMRS merupakan rincian arus proses 1.0 pada DFD Level 1; data store D1 dipecah menjadi D1.1–D1.5.", font=font(19, True), fill=(102, 112, 133), anchor="ma")
    im.save(path)


def actor(draw, center, label):
    x, y = center
    draw.ellipse((x - 28, y - 90, x + 28, y - 34), outline=(52, 64, 84), width=4)
    draw.line((x, y - 34, x, y + 55), fill=(52, 64, 84), width=4)
    draw.line((x - 48, y, x + 48, y), fill=(52, 64, 84), width=4)
    draw.line((x, y + 55, x - 42, y + 115), fill=(52, 64, 84), width=4)
    draw.line((x, y + 55, x + 42, y + 115), fill=(52, 64, 84), width=4)
    centered_text(draw, (x - 125, y + 125, x + 125, y + 190), label, 19, True)


def use_case(draw, xy, text):
    draw.ellipse(xy, fill=(234, 245, 244), outline=(27, 127, 121), width=4)
    centered_text(draw, xy, text, 19, True)


def diagram_use_case(path):
    im = Image.new("RGB", (2200, 1700), "white")
    d = ImageDraw.Draw(im)
    d.text((1100, 25), "Use Case Diagram SIPANTES Mobile", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    boundary = (360, 100, 1830, 1590)
    d.rectangle(boundary, outline=(23, 59, 63), width=5)
    d.text((390, 125), "Sistem SIPANTES", font=font(24, True), fill=(23, 59, 63))
    actor(d, (160, 330), "Pengunjung")
    actor(d, (160, 850), "Pengguna Mobile")
    actor(d, (160, 1340), "Pasien Tertaut")
    actor(d, (2040, 300), "SMTP")
    actor(d, (2040, 820), "SIMRS")
    actor(d, (2040, 1340), "Play Store")
    cases = [
        ((500, 190, 920, 300), "Melihat informasi RS"),
        ((1050, 190, 1470, 300), "Melihat poli/jadwal/kamar"),
        ((500, 430, 920, 540), "Registrasi akun"),
        ((1050, 430, 1470, 540), "Login / reset password"),
        ((500, 680, 920, 790), "Kelola profil akun"),
        ((1050, 680, 1470, 790), "Hubungkan No. RM"),
        ((500, 940, 920, 1050), "Melihat rekam medis"),
        ((1050, 940, 1470, 1050), "Membuat booking umum"),
        ((500, 1200, 920, 1310), "Melihat antrean saya"),
        ((1050, 1200, 1470, 1310), "Hapus akun mobile"),
        ((770, 1430, 1200, 1540), "Memperbarui aplikasi"),
    ]
    for xy, text in cases:
        use_case(d, xy, text)
    # Association lines are routed by actor bands to avoid crossing.
    for target in [(500, 245), (1050, 245)]:
        d.line(((208, 330), (320, 330), (320, target[1]), target), fill=(52, 64, 84), width=3)
    for target in [(500, 485), (1050, 485), (500, 735), (1050, 735), (1050, 1255)]:
        d.line(((208, 850), (300, 850), (300, target[1]), target), fill=(52, 64, 84), width=3)
    for target in [(500, 995), (1050, 995), (500, 1255)]:
        d.line(((208, 1340), (335, 1340), (335, target[1]), target), fill=(52, 64, 84), width=3)
    d.line(((1470, 485), (1900, 485), (1900, 300), (1990, 300)), fill=(52, 64, 84), width=3)
    for target_y in [735, 995, 1255]:
        d.line(((1470, target_y), (1890, target_y), (1890, 820), (1990, 820)), fill=(52, 64, 84), width=3)
    d.line(((1200, 1485), (1900, 1485), (1900, 1340), (1990, 1340)), fill=(52, 64, 84), width=3)
    # Include relationships.
    d.line(((920, 485), (1050, 485)), fill=(180, 83, 9), width=3)
    d.text((985, 455), "<<include OTP>>", font=font(15, True), fill=(180, 83, 9), anchor="ma")
    d.line(((920, 735), (1050, 735)), fill=(180, 83, 9), width=3)
    d.text((985, 705), "<<include verifikasi>>", font=font(15, True), fill=(180, 83, 9), anchor="ma")
    d.line(((920, 995), (1050, 995)), fill=(180, 83, 9), width=3)
    d.text((985, 965), "otorisasi patient_id", font=font(15, True), fill=(180, 83, 9), anchor="ma")
    im.save(path)


def diagram_dfd_level1_formal(path):
    im = Image.new("RGB", (2200, 1750), "white")
    d = ImageDraw.Draw(im)
    d.text((1100, 25), "DFD Level 1 — Dekomposisi Proses SIPANTES", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    rows = [
        (190, "1.0", "Kelola Autentikasi & Akun", "data registrasi/login/OTP", "status auth/akun", "D1", "Data Auth Mobile"),
        (500, "2.0", "Sajikan Profil & Rekam Medis", "permintaan data pasien", "profil/riwayat/hasil", "D2", "Data Pasien & Klinis SIMRS"),
        (810, "3.0", "Kelola Booking & Antrian", "pilihan booking", "konfirmasi/nomor antrean", "D3", "Staging Booking"),
        (1120, "4.0", "Sajikan Informasi RS", "permintaan informasi", "poli/jadwal/kamar", "D4", "Jadwal & Hari Libur"),
        (1430, "5.0", "Kelola Update Aplikasi", "cek versi", "status versi/listing", "", ""),
    ]
    for idx, (y, no, process, request, response, store_code, store_name) in enumerate(rows):
        dfd_entity(d, (40, y - 70, 330, y + 70), "Pengguna Mobile" + (" (duplikasi)" if idx else ""))
        dfd_process(d, (500, y - 85, 900, y + 85), no, process)
        dfd_flow(d, [(330, y - 22), (500, y - 22)], request, (415, y - 48))
        dfd_flow(d, [(500, y + 28), (330, y + 28)], response, (415, y + 55))
        if store_code:
            dfd_store(d, (1100, y - 50, 1550, y + 50), store_code, store_name)
            dfd_flow(d, [(900, y - 20), (1100, y - 20)], "baca/tulis", (1000, y - 47))
            dfd_flow(d, [(1100, y + 25), (900, y + 25)], "data", (1000, y + 52))
    dfd_entity(d, (1810, 120, 2140, 260), "SMTP Email")
    dfd_entity(d, (1810, 1060, 2140, 1200), "API Kalender")
    dfd_entity(d, (1810, 1370, 2140, 1510), "Google Play Store")
    dfd_flow(d, [(900, 155), (950, 155), (950, 300), (1650, 300), (1650, 190), (1810, 190)], "pesan OTP", (1450, 270))
    dfd_flow(d, [(1810, 1130), (1550, 1130)], "data libur", (1680, 1095))
    dfd_flow(d, [(900, 1430), (1810, 1440)], "versi/listing", (1350, 1395))
    dfd_entity(d, (40, 1590, 330, 1710), "Operator Teknis")
    dfd_flow(d, [(330, 1650), (700, 1515)], "konfigurasi rilis", (500, 1570))
    d.text((1100, 1715), "Entitas Pengguna Mobile digandakan secara visual untuk menjaga keterbacaan; seluruh duplikasi mewakili entitas eksternal yang sama.", font=font(18, True), fill=(102, 112, 133), anchor="ma")
    im.save(path)


def diagram_dfd_auth_level2_formal(path):
    im = Image.new("RGB", (2200, 1750), "white")
    d = ImageDraw.Draw(im)
    d.text((1100, 25), "DFD Level 2 — Proses 1.0 Autentikasi & Akun", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    rows = [
        (190, "1.1", "Registrasi & OTP Email", "profil/OTP", "ticket/status", "D1.1", "OTP Email & Auth Ticket"),
        (500, "1.2", "Set Password & Buat Akun", "password + ticket", "akun/session", "D1.2", "user_mobile"),
        (810, "1.3", "Login, OTP & Session", "credential/OTP", "access/refresh token", "D1.3", "OTP User & Session"),
        (1120, "1.4", "Klaim No. RM", "No. RM/NIK/tgl lahir", "status patient link", "D1.4", "OTP Klaim No. RM"),
        (1430, "1.5", "Hapus Akun Mobile", "password/OTP hapus", "status penghapusan", "D1.5", "OTP Hapus Akun"),
    ]
    for idx, (y, no, process, request, response, code, store) in enumerate(rows):
        dfd_entity(d, (40, y - 70, 330, y + 70), "Pengguna Mobile" + (" (duplikasi)" if idx else ""))
        dfd_process(d, (500, y - 85, 900, y + 85), no, process)
        dfd_flow(d, [(330, y - 22), (500, y - 22)], request, (415, y - 48))
        dfd_flow(d, [(500, y + 28), (330, y + 28)], response, (415, y + 55))
        dfd_store(d, (1100, y - 50, 1550, y + 50), code, store)
        dfd_flow(d, [(900, y - 20), (1100, y - 20)], "baca/tulis", (1000, y - 47))
        dfd_flow(d, [(1100, y + 25), (900, y + 25)], "data", (1000, y + 52))
    dfd_entity(d, (1810, 120, 2140, 260), "SMTP Email")
    dfd_entity(d, (1810, 1030, 2140, 1170), "SIMRS Pasien")
    dfd_flow(d, [(900, 155), (950, 155), (950, 300), (1650, 300), (1650, 190), (1810, 190)], "OTP registrasi", (1450, 270))
    dfd_flow(d, [(900, 775), (960, 775), (960, 660), (1690, 660), (1690, 225), (1810, 225)], "OTP login/reset", (1450, 630))
    dfd_flow(d, [(900, 1085), (950, 1085), (950, 1200), (1700, 1200), (1700, 1080), (1810, 1080)], "verifikasi identitas", (1370, 1170))
    dfd_flow(d, [(1810, 1130), (1730, 1130), (1730, 1240), (930, 1240), (930, 1140), (900, 1140)], "patient_id/no_rm", (1370, 1270))
    d.text((1100, 1690), "Balance Level 2: seluruh input/output Pengguna, SMTP, dan SIMRS merupakan rincian arus proses 1.0 pada Level 1; D1 dipecah menjadi D1.1–D1.5.", font=font(18, True), fill=(102, 112, 133), anchor="ma")
    im.save(path)


def diagram_use_case_formal(path):
    im = Image.new("RGB", (2200, 1800), "white")
    d = ImageDraw.Draw(im)
    d.text((1100, 25), "Use Case Diagram SIPANTES Mobile", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    boundary = (430, 90, 1770, 1710)
    d.rectangle(boundary, outline=(23, 59, 63), width=5)
    d.text((460, 115), "System Boundary: SIPANTES", font=font(23, True), fill=(23, 59, 63))
    actor(d, (170, 330), "Pengunjung")
    actor(d, (170, 850), "Pengguna Mobile")
    actor(d, (170, 1390), "Pasien Tertaut")
    actor(d, (2030, 390), "SMTP")
    actor(d, (2030, 980), "SIMRS")
    actor(d, (2030, 1480), "Play Store")
    primary = [
        ((540, 180, 980, 280), "Melihat informasi RS"),
        ((540, 330, 980, 430), "Registrasi / login / reset"),
        ((540, 600, 980, 700), "Kelola profil akun"),
        ((540, 750, 980, 850), "Hubungkan No. RM"),
        ((540, 900, 980, 1000), "Hapus akun mobile"),
        ((540, 1140, 980, 1240), "Melihat rekam medis"),
        ((540, 1290, 980, 1390), "Membuat booking umum"),
        ((540, 1440, 980, 1540), "Melihat antrean sendiri"),
        ((540, 1590, 980, 1690), "Memperbarui aplikasi"),
    ]
    support = [
        ((1260, 330, 1680, 430), "Kirim OTP email"),
        ((1260, 750, 1680, 850), "Validasi identitas pasien"),
        ((1260, 1140, 1680, 1240), "Akses data SIMRS"),
        ((1260, 1590, 1680, 1690), "Buka listing Play Store"),
    ]
    for xy, label in primary + support:
        use_case(d, xy, label)
    # Association actor kiri melalui koridor di luar boundary, tidak melintasi oval.
    for actor_y, targets in [
        (330, [230, 380]), (850, [650, 800, 950]), (1390, [1190, 1340, 1490, 1640]),
    ]:
        spine_x = 370
        d.line(((218, actor_y), (spine_x, actor_y)), fill=(52, 64, 84), width=3)
        d.line(((spine_x, min(targets)), (spine_x, max(targets))), fill=(52, 64, 84), width=3)
        for target_y in targets:
            d.line(((spine_x, target_y), (540, target_y)), fill=(52, 64, 84), width=3)
    # Association aktor eksternal hanya ke use case pendukung yang sejajar.
    for actor_y, target_y in [(390, 380), (980, 1190), (1480, 1640)]:
        d.line(((1680, target_y), (1840, target_y), (1840, actor_y), (1982, actor_y)), fill=(52, 64, 84), width=3)
    # Include menggunakan garis putus dan panah, pada koridor horizontal bebas simbol.
    poly_arrow(d, [(980, 380), (1260, 380)], color=(180, 83, 9), width=3, dashed=True)
    d.text((1120, 350), "<<include>>", font=font(15, True), fill=(180, 83, 9), anchor="ma")
    poly_arrow(d, [(980, 800), (1260, 800)], color=(180, 83, 9), width=3, dashed=True)
    d.text((1120, 770), "<<include>>", font=font(15, True), fill=(180, 83, 9), anchor="ma")
    poly_arrow(d, [(980, 1190), (1260, 1190)], color=(180, 83, 9), width=3, dashed=True)
    d.text((1120, 1160), "<<include>>", font=font(15, True), fill=(180, 83, 9), anchor="ma")
    poly_arrow(d, [(980, 1640), (1260, 1640)], color=(180, 83, 9), width=3, dashed=True)
    d.text((1120, 1610), "<<include>>", font=font(15, True), fill=(180, 83, 9), anchor="ma")
    im.save(path)


def diagram_erd_visit_core(path):
    im = Image.new("RGB", (2200, 1450), "white")
    d = ImageDraw.Draw(im)
    d.text((1100, 25), "ERD Logis Inti Kunjungan dan Booking", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    d.text((1100, 72), "Jingga putus = relasi query SIMRS existing; kardinalitas ditulis pada tiap ujung relasi.", font=font(20), fill=(102, 112, 133), anchor="ma")
    entity_table(d, (60, 220, 430, 590), "pasiens", [("PK", "id"), ("UK*", "no_rm"), ("", "nik"), ("", "tanggal_lahir"), ("", "nama")], logical=True)
    entity_table(d, (760, 180, 1240, 680), "registrasis", [("PK", "id"), ("L-FK", "pasien_id"), ("L-FK", "poli_id"), ("L-FK", "dokter_id"), ("L-FK", "antrian_poli_id"), ("L-FK", "bayar"), ("", "tanggal/status")], logical=True)
    entity_table(d, (1510, 110, 1840, 370), "polis", [("PK", "id"), ("", "kode/nama"), ("", "aktif")], logical=True)
    entity_table(d, (1880, 110, 2160, 370), "pegawais", [("PK", "id"), ("", "nama"), ("", "status")], logical=True)
    entity_table(d, (1510, 780, 1840, 1040), "antrian_poli", [("PK", "id"), ("", "nomor"), ("", "status")], logical=True)
    entity_table(d, (1880, 780, 2160, 1040), "carabayars", [("PK", "id"), ("", "nama"), ("", "aktif")], logical=True)
    entity_table(d, (60, 900, 500, 1320), "registrasis_dummy", [("PK*", "id"), ("L-FK", "no_rm"), ("L-FK", "poli_id/kode_poli"), ("L-FK", "dokter_id/kode_dokter"), ("", "tanggal/nomor"), ("", "flag=mobile_umum")], logical=True)
    er_relation(d, [(430, 405), (760, 405)], "1", "0..N", "pasien_id", logical=True, label_xy=(595, 405))
    er_relation(d, [(1240, 300), (1400, 300), (1400, 240), (1510, 240)], "0..N", "1", "poli_id", logical=True, label_xy=(1400, 270))
    er_relation(d, [(1240, 390), (1860, 390), (1860, 240), (1880, 240)], "0..N", "1", "dokter_id", logical=True, label_xy=(1760, 420))
    er_relation(d, [(1240, 500), (1400, 500), (1400, 910), (1510, 910)], "0..N", "0..1", "antrian_poli_id", logical=True, label_xy=(1400, 700))
    er_relation(d, [(1240, 590), (1860, 590), (1860, 910), (1880, 910)], "0..N", "0..1", "bayar", logical=True, label_xy=(1760, 650))
    er_relation(d, [(245, 590), (245, 900)], "1", "0..N", "no_rm", logical=True, label_xy=(245, 745))
    d.rounded_rectangle((650, 1100, 1450, 1330), radius=18, fill=(255, 247, 237), outline=(180, 83, 9), width=3)
    centered_text(d, (675, 1120, 1425, 1310), "registrasis adalah transaksi kunjungan definitif.\nregistrasis_dummy merupakan staging booking mobile.\nKeduanya dibatasi ke pasien terautentikasi oleh repository, tetapi tidak digambar sebagai relasi langsung karena kontrak source memakai no_rm dan lifecycle berbeda.", 19, True, fill=(120, 53, 15))
    im.save(path)


def diagram_erd_clinical_mn(path):
    im = Image.new("RGB", (2200, 1450), "white")
    d = ImageDraw.Draw(im)
    d.text((1100, 25), "ERD Relasi M:N Diagnosis dan Tindakan", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    d.text((1100, 72), "Relasi M:N direalisasikan melalui associative entity; tidak ada garis M:N langsung antar master dan registrasi.", font=font(20), fill=(102, 112, 133), anchor="ma")
    entity_table(d, (80, 500, 460, 850), "registrasis", [("PK", "id"), ("L-FK", "pasien_id"), ("", "tanggal/status"), ("", "diagnosa awal")], logical=True)
    entity_table(d, (750, 180, 1250, 540), "perawatan_icd10s / jkn_icd10s", [("PK*", "id"), ("L-FK", "registrasi_id"), ("L-FK", "icd10"), ("", "status/jenis")], logical=True)
    entity_table(d, (750, 900, 1250, 1260), "perawatan_icd9s / jkn_icd9s", [("PK*", "id"), ("L-FK", "registrasi_id"), ("L-FK", "icd9"), ("", "status/jenis")], logical=True)
    entity_table(d, (1700, 220, 2070, 500), "icd10s", [("PK*", "nomor"), ("", "nama diagnosis"), ("", "aktif")], logical=True)
    entity_table(d, (1700, 940, 2070, 1220), "icd9s", [("PK*", "nomor"), ("", "nama tindakan"), ("", "aktif")], logical=True)
    er_relation(d, [(460, 610), (610, 610), (610, 360), (750, 360)], "1", "0..N", "registrasi_id", logical=True, label_xy=(610, 480))
    er_relation(d, [(1250, 360), (1700, 360)], "0..N", "1", "icd10", logical=True, label_xy=(1475, 360))
    er_relation(d, [(460, 740), (610, 740), (610, 1080), (750, 1080)], "1", "0..N", "registrasi_id", logical=True, label_xy=(610, 910))
    er_relation(d, [(1250, 1080), (1700, 1080)], "0..N", "1", "icd9", logical=True, label_xy=(1475, 1080))
    d.rounded_rectangle((600, 1325, 1600, 1410), radius=14, fill=(242, 244, 247), outline=(102, 112, 133), width=2)
    d.text((1100, 1368), "registrasis M:N icd10s melalui tabel diagnosis | registrasis M:N icd9s melalui tabel tindakan", font=font(19, True), fill=(52, 64, 84), anchor="mm")
    im.save(path)


def diagram_erd_service_results(path):
    im = Image.new("RGB", (2200, 1550), "white")
    d = ImageDraw.Draw(im)
    d.text((1100, 25), "ERD Logis Hasil Pelayanan", font=font(38, True), fill=(23, 59, 63), anchor="ma")
    d.text((1100, 72), "Setiap relasi memakai koridor tersendiri; rincian master ditampilkan pada level yang dibaca API mobile.", font=font(20), fill=(102, 112, 133), anchor="ma")
    entity_table(d, (100, 140, 470, 450), "pasiens", [("PK", "id"), ("UK*", "no_rm"), ("", "nama"), ("", "tanggal_lahir")], logical=True)
    entity_table(d, (850, 120, 1320, 480), "registrasis", [("PK", "id"), ("L-FK", "pasien_id"), ("L-FK", "poli_id"), ("L-FK", "dokter_id"), ("", "tanggal/status")], logical=True)
    entity_table(d, (80, 760, 480, 1120), "hasillabs", [("PK", "id"), ("L-FK", "pasien_id"), ("L-FK", "registrasi_id"), ("L-FK", "order_lab_id"), ("", "tanggal/status")], logical=True)
    entity_table(d, (700, 760, 1100, 1120), "hasilradiologis", [("PK", "id"), ("L-FK", "registrasi_id"), ("", "hasil/status"), ("", "tanggal")], logical=True)
    entity_table(d, (1320, 760, 1720, 1120), "penjualans", [("PK", "id"), ("L-FK", "registrasi_id"), ("L-FK", "dokter_id"), ("", "tanggal/status")], logical=True)
    entity_table(d, (1320, 1260, 1720, 1500), "penjualandetails", [("PK", "id"), ("L-FK", "penjualan_id"), ("L-FK", "masterobat_id")], logical=True)
    entity_table(d, (1840, 1260, 2160, 1500), "masterobats", [("PK", "id"), ("", "nama obat"), ("", "satuan")], logical=True)
    er_relation(d, [(470, 295), (850, 295)], "1", "0..N", "pasien_id", logical=True, label_xy=(660, 295))
    er_relation(d, [(285, 450), (285, 760)], "1", "0..N", "pasien_id", logical=True, label_xy=(285, 605))
    er_relation(d, [(950, 480), (950, 650), (430, 650), (430, 760)], "1", "0..N", "registrasi_id", logical=True, label_xy=(690, 650))
    er_relation(d, [(1080, 480), (1080, 650), (900, 650), (900, 760)], "1", "0..N", "registrasi_id", logical=True, label_xy=(990, 650))
    er_relation(d, [(1210, 480), (1210, 650), (1520, 650), (1520, 760)], "1", "0..N", "registrasi_id", logical=True, label_xy=(1380, 650))
    er_relation(d, [(1520, 1120), (1520, 1260)], "1", "1..N", "penjualan_id", logical=True, label_xy=(1520, 1190))
    er_relation(d, [(1720, 1380), (1840, 1380)], "0..N", "1", "masterobat_id", logical=True, label_xy=(1780, 1380))
    im.save(path)


def set_cell_shading(cell, fill):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)


def set_cell_margins(cell, top=100, start=100, bottom=100, end=100):
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    tc_mar = tc_pr.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for m, v in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        node = tc_mar.find(qn(f"w:{m}"))
        if node is None:
            node = OxmlElement(f"w:{m}")
            tc_mar.append(node)
        node.set(qn("w:w"), str(v))
        node.set(qn("w:type"), "dxa")


def add_field(paragraph, instruction):
    run = paragraph.add_run()
    begin = OxmlElement("w:fldChar")
    begin.set(qn("w:fldCharType"), "begin")
    instr = OxmlElement("w:instrText")
    instr.set(qn("xml:space"), "preserve")
    instr.text = instruction
    separate = OxmlElement("w:fldChar")
    separate.set(qn("w:fldCharType"), "separate")
    end = OxmlElement("w:fldChar")
    end.set(qn("w:fldCharType"), "end")
    run._r.extend([begin, instr, separate, end])


def set_repeat_table_header(row):
    tr_pr = row._tr.get_or_add_trPr()
    tbl_header = OxmlElement("w:tblHeader")
    tbl_header.set(qn("w:val"), "true")
    tr_pr.append(tbl_header)


def configure_document(doc):
    section = doc.sections[0]
    section.top_margin = Cm(2.0)
    section.bottom_margin = Cm(1.8)
    section.left_margin = Cm(2.2)
    section.right_margin = Cm(2.0)
    section.header_distance = Cm(0.8)
    section.footer_distance = Cm(0.8)

    normal = doc.styles["Normal"]
    normal.font.name = "Aptos"
    normal.font.size = Pt(10)
    normal.font.color.rgb = RGBColor.from_string(DARK)
    normal.paragraph_format.space_after = Pt(6)
    normal.paragraph_format.line_spacing = 1.12

    for style_name, size, color in [
        ("Title", 30, DARK),
        ("Heading 1", 18, TEAL),
        ("Heading 2", 14, DARK),
        ("Heading 3", 11, TEAL),
        ("Heading 4", 10, DARK),
    ]:
        style = doc.styles[style_name]
        style.font.name = "Aptos Display"
        style.font.size = Pt(size)
        style.font.bold = True
        style.font.color.rgb = RGBColor.from_string(color)
        style.paragraph_format.keep_with_next = True
        style.paragraph_format.space_before = Pt(12)
        style.paragraph_format.space_after = Pt(6)

    styles = doc.styles
    if "Caption Source" not in styles:
        styles.add_style("Caption Source", 1)
    caption = styles["Caption Source"]
    caption.font.name = "Aptos"
    caption.font.size = Pt(8)
    caption.font.italic = True
    caption.font.color.rgb = RGBColor.from_string(GRAY)
    caption.paragraph_format.alignment = WD_ALIGN_PARAGRAPH.CENTER

    settings = doc.settings._element
    update_fields = OxmlElement("w:updateFields")
    update_fields.set(qn("w:val"), "true")
    settings.append(update_fields)


def add_header_footer(doc):
    for section in doc.sections:
        header = section.header
        p = header.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        run = p.add_run("SIPANTES  |  Modul Teknis v2.3")
        run.font.size = Pt(8)
        run.font.bold = True
        run.font.color.rgb = RGBColor.from_string(TEAL)
        footer = section.footer
        fp = footer.paragraphs[0]
        fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = fp.add_run("Internal RSUD Oto Iskandar Di Nata  •  Halaman ")
        r.font.size = Pt(8)
        r.font.color.rgb = RGBColor.from_string(GRAY)
        add_field(fp, "PAGE")
        fp.add_run(" dari ")
        add_field(fp, "NUMPAGES")


def add_table(doc, headers, rows, widths=None, font_size=8):
    table = doc.add_table(rows=1, cols=len(headers))
    table.style = "Table Grid"
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = True
    hdr = table.rows[0]
    set_repeat_table_header(hdr)
    for i, header in enumerate(headers):
        cell = hdr.cells[i]
        set_cell_shading(cell, TEAL)
        cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = p.add_run(str(header))
        run.bold = True
        run.font.color.rgb = RGBColor.from_string(WHITE)
        run.font.size = Pt(font_size)
    for row_idx, values in enumerate(rows):
        cells = table.add_row().cells
        for i, value in enumerate(values):
            cell = cells[i]
            set_cell_margins(cell)
            if row_idx % 2:
                set_cell_shading(cell, "F7FAFA")
            p = cell.paragraphs[0]
            p.paragraph_format.space_after = Pt(0)
            run = p.add_run(str(value))
            run.font.size = Pt(font_size)
    if widths:
        for row in table.rows:
            for i, width in enumerate(widths):
                row.cells[i].width = Cm(width)
    doc.add_paragraph()
    return table


def add_bullets(doc, items, level=0):
    for item in items:
        p = doc.add_paragraph(style="List Bullet" if level == 0 else "List Bullet 2")
        p.add_run(item)


def add_numbered(doc, items):
    for item in items:
        doc.add_paragraph(item, style="List Number")


def add_note(doc, title, text, danger=False):
    table = doc.add_table(rows=1, cols=1)
    table.style = "Table Grid"
    cell = table.cell(0, 0)
    set_cell_shading(cell, "FEF3F2" if danger else LIGHT)
    p = cell.paragraphs[0]
    r = p.add_run(title + " — ")
    r.bold = True
    r.font.color.rgb = RGBColor.from_string(RED if danger else TEAL)
    p.add_run(text)
    doc.add_paragraph()


def add_picture(doc, path, caption):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.add_run().add_picture(str(path), width=Inches(6.4))
    doc.add_paragraph(caption, style="Caption Source")


def add_code(doc, text):
    table = doc.add_table(rows=1, cols=1)
    table.style = "Table Grid"
    cell = table.cell(0, 0)
    set_cell_shading(cell, "F2F4F7")
    p = cell.paragraphs[0]
    p.paragraph_format.space_after = Pt(0)
    run = p.add_run(text)
    run.font.name = "Consolas"
    run.font.size = Pt(8)
    doc.add_paragraph()


def build_document():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    arch = ASSET_DIR / "arsitektur.png"
    auth_flow = ASSET_DIR / "flowchart_registrasi.png"
    booking_flow = ASSET_DIR / "flowchart_booking.png"
    delete_flow = ASSET_DIR / "flowchart_hapus_akun.png"
    dfd_context = ASSET_DIR / "dfd_level_0_context.png"
    dfd_level1 = ASSET_DIR / "dfd_level_1.png"
    dfd_auth = ASSET_DIR / "dfd_level_2_auth.png"
    use_case = ASSET_DIR / "use_case_sipantes.png"
    erd_auth = ASSET_DIR / "erd_auth_mobile_formal.png"
    erd_visit = ASSET_DIR / "erd_inti_kunjungan.png"
    erd_clinical = ASSET_DIR / "erd_many_to_many_klinis.png"
    erd_results = ASSET_DIR / "erd_hasil_pelayanan.png"
    diagram_architecture(arch)
    diagram_flow_registration(auth_flow)
    diagram_flow_booking(booking_flow)
    diagram_flow_delete(delete_flow)
    diagram_dfd_context(dfd_context)
    diagram_dfd_level1_formal(dfd_level1)
    diagram_dfd_auth_level2_formal(dfd_auth)
    diagram_use_case_formal(use_case)
    diagram_erd_auth_formal(erd_auth)
    diagram_erd_visit_core(erd_visit)
    diagram_erd_clinical_mn(erd_clinical)
    diagram_erd_service_results(erd_results)

    doc = Document()
    configure_document(doc)

    # Cover
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(55)
    if LOGO.exists():
        p.add_run().add_picture(str(LOGO), width=Inches(3.0))
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(35)
    run = p.add_run("DOKUMEN MODUL TEKNIS")
    run.font.name = "Aptos Display"
    run.font.size = Pt(30)
    run.font.bold = True
    run.font.color.rgb = RGBColor.from_string(DARK)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("SIPANTES")
    run.font.name = "Aptos Display"
    run.font.size = Pt(40)
    run.font.bold = True
    run.font.color.rgb = RGBColor.from_string(TEAL)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run("Sistem Pendaftaran Terintegrasi\nRSUD Oto Iskandar Di Nata Kabupaten Bandung")
    r.font.size = Pt(15)
    r.font.color.rgb = RGBColor.from_string(GRAY)
    doc.add_paragraph()
    cover_table = doc.add_table(rows=4, cols=2)
    cover_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    cover_table.style = "Table Grid"
    for i, (key, value) in enumerate([
        ("Nomor Dokumen", "FSD-TECH-SIPANTES-002"),
        ("Versi", "2.3"),
        ("Tanggal", "8 Oktober 2026"),
        ("Klasifikasi", "Internal / Teknis"),
    ]):
        cover_table.cell(i, 0).text = key
        cover_table.cell(i, 1).text = value
        set_cell_shading(cover_table.cell(i, 0), TEAL)
        for run in cover_table.cell(i, 0).paragraphs[0].runs:
            run.font.color.rgb = RGBColor.from_string(WHITE)
            run.bold = True
    doc.add_paragraph()
    p = doc.add_paragraph("Dokumen teknis berdasarkan implementasi Flutter, REST API Go, dan skema database pada snapshot 8 Oktober 2026.")
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.runs[0].italic = True
    p.runs[0].font.size = Pt(8)
    doc.add_page_break()

    doc.add_heading("Pengendalian Dokumen", level=1)
    add_table(doc, ["Atribut", "Nilai"], [
        ("Project", "SIPANTES – Sistem Pendaftaran Terintegrasi"),
        ("Client", "RSUD Oto Iskandar Di Nata Kabupaten Bandung"),
        ("Aplikasi", "Flutter rs_mobile_otista_v1_0, versi 1.0.0+5"),
        ("Backend", "ApiRsudOtistaMobile, REST API Go/Fiber"),
        ("Frontend source", r"D:\source\flutter\rs_mobile_otista_v1.0"),
        ("Backend source", r"D:\source\golang\ApiRsudOtistaMobile"),
        ("API prefix", "/api/v1"),
        ("Pemilik dokumen", "Tim Pengembangan SIPANTES"),
    ], [4, 12], 9)

    doc.add_heading("Riwayat Revisi", level=2)
    add_table(doc, ["Versi", "Tanggal", "Ringkasan Perubahan", "Status"], [
        ("1.0", "10 September 2026", "Manual teknis awal aplikasi.", "Baseline"),
        ("2.0", "7 Oktober 2026", "Spesifikasi modul lengkap; tombol tampil password; hardening lifecycle OTP registrasi; endpoint dan transaksi hapus akun khusus user mobile.", "Baseline"),
        ("2.1", "7 Oktober 2026", "Reset ticket saat kirim ulang OTP; pemulihan akun testing soft-delete; notifikasi update Play Store.", "Baseline"),
        ("2.2", "7 Oktober 2026", "ERD faktual diperluas: notasi, kardinalitas, FK fisik vs relasi logis, peta data layanan, matriks relasi, batas penghapusan, dan query verifikasi skema.", "Baseline"),
        ("2.3", "8 Oktober 2026", "Penyempurnaan notasi formal: flowchart, DFD level 0–2, ERD berbentuk tabel dengan key/kardinalitas/associative entity, dan use case.", "Current"),
    ], [2, 3, 10, 2], 8)

    doc.add_heading("Daftar Isi", level=1)
    toc = doc.add_paragraph()
    add_field(toc, 'TOC \\o "1-3" \\h \\z \\u')
    doc.add_paragraph("Catatan: buka dokumen di Microsoft Word dan pilih Update Field bila nomor halaman daftar isi belum diperbarui otomatis.", style="Caption Source")
    doc.add_page_break()

    doc.add_heading("1. Pendahuluan", level=1)
    doc.add_paragraph(
        "SIPANTES adalah aplikasi mobile pasien RSUD Oto Iskandar Di Nata. Aplikasi menyediakan pendaftaran poli umum, nomor antrian, informasi rumah sakit, serta akses terproteksi ke identitas dan riwayat pelayanan pasien. Dokumen ini memadukan spesifikasi fungsional dan teknis agar developer, QA, DevOps, dan pemilik layanan memiliki acuan implementasi yang sama."
    )
    doc.add_heading("1.1 Tujuan Dokumen", level=2)
    add_bullets(doc, [
        "Mendefinisikan seluruh modul, alur, aturan bisnis, hak akses, API, dan sumber data SIPANTES.",
        "Menjadi baseline pengembangan, pengujian, deployment, troubleshooting, dan pemeliharaan.",
        "Menetapkan batas privasi: akun mobile dapat dihapus, sedangkan rekam medis dan dokumen pelayanan tidak ikut dihapus.",
        "Mendokumentasikan kontrol keamanan OTP, password, bearer session, rate limit, dan validasi kepemilikan pasien.",
    ])
    doc.add_heading("1.2 Ruang Lingkup", level=2)
    add_bullets(doc, [
        "Aplikasi Flutter Android/iOS/Web/Desktop sesuai target bawaan Flutter; rilis utama berorientasi mobile.",
        "REST API Go/Fiber, MySQL, SMTP OTP, dan API kalender hari libur.",
        "Autentikasi, profil akun, pengaitan No. RM, data pasien, booking/antrian, jadwal poli, kamar, dan informasi rumah sakit.",
        "Tidak mencakup perubahan data klinis inti, proses klaim BPJS, atau administrasi SIMRS di luar jalur mobile.",
    ])
    add_note(doc, "Batas penghapusan", "Operasi hapus akun hanya boleh menghapus baris user_mobile dan artefak autentikasi mobile. Tabel pasiens dan seluruh data pelayanan rumah sakit berada di luar transaksi penghapusan.", True)
    doc.add_heading("1.3 Istilah", level=2)
    add_table(doc, ["Istilah", "Definisi"], [
        ("Akun mobile", "Identitas login pada tabel user_mobile."),
        ("No. RM", "Nomor rekam medis pasien pada SIMRS."),
        ("Linked patient", "Akun mobile yang patient_id dan no_rm telah diverifikasi."),
        ("OTP", "One-Time Password 6 digit, berlaku 5 menit dan dibatasi 5 percobaan."),
        ("Registration ticket", "Token acak sekali pakai setelah OTP registrasi valid, digunakan untuk set password."),
        ("Access token", "Bearer token opaque berumur pendek; hanya hash disimpan di server."),
        ("Refresh token", "Token rotasi untuk memperbarui access token; reuse mencabut seluruh family."),
        ("Principal", "Identitas sesi hasil validasi access token pada middleware."),
    ], [4, 12], 8)

    doc.add_heading("2. Gambaran Sistem dan Site Map", level=1)
    add_picture(doc, arch, "Gambar 1. Arsitektur logis SIPANTES berdasarkan struktur source Flutter dan Go API.")
    doc.add_heading("2.1 Site Map", level=2)
    add_table(doc, ["Area", "Halaman/Modul", "Akses"], [
        ("Shell", "Splash Gate; Beranda; Booking; Profil", "Publik / kontekstual"),
        ("Autentikasi", "Login; Registrasi; Lupa Password", "Publik"),
        ("Informasi", "Profil RS; Visi Misi; Jam Layanan; Alamat; Kontak; Fasilitas", "Publik"),
        ("Layanan", "Poli & Jadwal; Ketersediaan Kamar", "Publik"),
        ("Booking", "Kalender; Opsi Poli/Dokter; Buat Pendaftaran; Nomor Antrian Saya", "Opsi publik; transaksi linked patient"),
        ("Rekam Medis", "Profil Pasien; Kunjungan; Diagnosis/Tindakan; Lab; Radiologi; Resep; PDF Resume", "Linked patient"),
        ("Akun", "Profil; Hubungkan No. RM; Logout; Hapus Akun", "User mobile login"),
        ("Eksternal", "Mobile JKN; website; Maps; email; telepon; WhatsApp", "Publik"),
    ], [3, 9, 4], 8)
    doc.add_heading("2.2 Aktor dan Hak Akses", level=2)
    add_table(doc, ["Kapabilitas", "Publik", "User Mobile", "Linked Patient", "Operator Teknis"], [
        ("Informasi RS, poli, kamar", "Ya", "Ya", "Ya", "Monitoring"),
        ("Registrasi/login/reset", "Ya", "N/A", "N/A", "Support"),
        ("Profil akun dan logout", "Tidak", "Ya", "Ya", "Support terbatas"),
        ("Hubungkan No. RM", "Tidak", "Ya", "Sudah terhubung", "Support data"),
        ("Data klinis personal", "Tidak", "Tidak", "Ya", "Sesuai kewenangan SIMRS"),
        ("Booking umum", "Tidak", "Tidak", "Ya", "Monitoring"),
        ("Hapus akun mobile", "Tidak", "Ya", "Ya", "Audit/dukungan"),
        ("Deploy/migrasi", "Tidak", "Tidak", "Tidak", "Ya"),
    ], [5, 2.5, 3, 3, 3], 8)
    doc.add_heading("2.3 Use Case Sistem", level=2)
    doc.add_paragraph(
        "Use case memodelkan tujuan aktor terhadap batas Sistem SIPANTES. Garis asosiasi menunjukkan aktor yang berinteraksi langsung; relasi <<include>> dipakai ketika sebuah perilaku selalu menjadi bagian dari use case utama. SMTP, SIMRS, dan Play Store ditempatkan sebagai aktor sistem eksternal."
    )
    add_picture(doc, use_case, "Gambar 2. Use case SIPANTES dengan system boundary, aktor utama, aktor eksternal, dan relasi include.")
    add_table(doc, ["Aktor", "Peran", "Use Case Utama"], [
        ("Pengunjung", "Belum memiliki sesi", "Informasi RS; poli/jadwal/kamar; registrasi; login/reset password."),
        ("Pengguna Mobile", "Memiliki akun dan sesi valid", "Profil akun; hubungkan No. RM; logout; hapus akun."),
        ("Pasien Tertaut", "User mobile dengan patient_id terverifikasi", "Rekam medis; booking; nomor antrean sendiri."),
        ("SMTP", "Sistem eksternal pengiriman email", "Menerima permintaan pengiriman OTP."),
        ("SIMRS", "Sumber data rumah sakit", "Memberikan identitas pasien, kunjungan, klinis, jadwal, dan master."),
        ("Play Store", "Sumber versi dan distribusi aplikasi", "Pemeriksaan versi serta pembaruan aplikasi."),
    ], [4, 6, 10], 7.5)

    doc.add_heading("3. Arsitektur Aplikasi Flutter", level=1)
    doc.add_paragraph("Frontend menggunakan feature-first clean layering. UI tidak mengakses HTTP atau secure storage secara langsung.")
    add_table(doc, ["Lapisan", "Lokasi", "Tanggung Jawab"], [
        ("Presentation", "lib/features/*/presentation", "Page/widget, validasi input awal, BLoC/Cubit state."),
        ("Domain", "lib/features/*/domain", "Entity dan kontrak repository."),
        ("Data", "lib/features/*/data", "Remote datasource, model response, repository implementation."),
        ("Core", "lib/core", "ApiConfig, ApiClient, tema, branding, widget bersama."),
        ("Shared", "lib/shared", "Katalog fitur dan data konten aplikasi."),
    ], [3, 6, 8], 8)
    doc.add_heading("3.1 State dan Navigasi", level=2)
    add_bullets(doc, [
        "AuthCubit memegang status checking, guest, atau authenticated dan identity aktif.",
        "RsApiCubit mengoordinasikan loading/error data pasien dan resource rumah sakit.",
        "Navigasi memakai MaterialPageRoute dan shell tab; fitur terproteksi menampilkan guard login/No. RM.",
        "SplashGatePage memulihkan session dari secure storage dan memverifikasi /auth/me.",
    ])
    doc.add_heading("3.2 Konfigurasi API", level=2)
    add_table(doc, ["Parameter", "Sumber", "Prioritas/Keterangan"], [
        ("API_BASE_URL", "--dart-define", "Override tertinggi."),
        ("APP_ENV", "--dart-define", "dev (default) atau prod."),
        ("DEV_API_BASE_URL", "--dart-define", "Dipakai ketika APP_ENV bukan prod."),
        ("PROD_API_BASE_URL", "--dart-define", "Dipakai ketika APP_ENV=prod."),
        ("Default source snapshot", "api_config.dart", "https://otista.maulana-gandawijaya.my.id/api/v1"),
    ], [4, 5, 8], 8)
    add_note(doc, "Konfigurasi", "README masih menyebut domain api-mobile.rsudotista.my.id, sedangkan source api_config.dart pada snapshot ini memakai domain otista.maulana-gandawijaya.my.id. Nilai deployment harus ditetapkan eksplisit melalui dart-define agar tidak ambigu.")
    doc.add_heading("3.3 Dependensi Utama", level=2)
    add_table(doc, ["Paket", "Fungsi"], [
        ("flutter_bloc 9.1.1", "State management."),
        ("http 1.6.0", "REST client."),
        ("flutter_secure_storage 9.2.4", "Penyimpanan token/identity terenkripsi platform."),
        ("equatable 2.0.5", "Value equality state/entity."),
        ("url_launcher 6.3.2", "Tautan eksternal dan Mobile JKN."),
        ("path_provider 2.1.6 + open_filex 4.7.0", "Unduh dan buka PDF resume medis."),
        ("upgrader 13.7.0", "Mendeteksi versi publik terbaru dan membuka halaman update Play Store."),
        ("google_fonts / font_awesome_flutter", "Tipografi dan ikon."),
    ], [6, 11], 8)

    doc.add_heading("4. Arsitektur REST API", level=1)
    add_table(doc, ["Lapisan", "Lokasi", "Tanggung Jawab"], [
        ("Routes", "internal/http/routes", "Registrasi endpoint dan middleware."),
        ("Handlers", "internal/http/handlers", "Parse input, timeout, mapping status/response."),
        ("Auth service", "internal/auth", "Aturan password, OTP, email, session."),
        ("Repository", "internal/repository", "Query SQL eksplisit dan transaksi."),
        ("Database", "internal/database", "Koneksi, migrasi idempotent, validasi skema."),
        ("Model", "internal/model", "DTO dan session model."),
    ], [3, 6, 8], 8)
    doc.add_heading("4.1 Runtime", level=2)
    add_bullets(doc, [
        "Go 1.26.2, Fiber 2.52.13, mysql driver 1.10.0.",
        "Body limit 1 MiB; read timeout 15 detik; write timeout 30 detik; idle timeout 60 detik.",
        "Middleware global: recover, security headers, CORS GET/POST/OPTIONS, request logger.",
        "Query data pasien mempunyai context timeout 8–15 detik tergantung endpoint.",
        "Generic table handler tidak diregistrasikan; seluruh resource memakai projection eksplisit.",
    ])
    doc.add_heading("4.2 Kontrak Response", level=2)
    add_code(doc, '{"success": true, "data": {...}}\n{"success": true, "data": [...], "pagination": {...}}\n{"success": false, "message": "pesan aman untuk klien"}')
    doc.add_paragraph("Beberapa endpoint autentikasi legacy-compatible mengembalikan message dan data secara langsung, namun ApiClient menormalisasi data envelope sebelum membentuk entity.")
    doc.add_heading("4.3 Data Flow Diagram", level=2)
    doc.add_paragraph(
        "DFD menggunakan empat unsur: entitas eksternal (persegi), proses bernomor (rounded process), data store terbuka, dan arus data berpanah serta bernama. Tidak ada arus langsung entitas-ke-data-store atau data-store-ke-data-store. DFD level 0, level 1, dan level 2 dijaga balance: arus lintas batas pada level atas tetap muncul saat proses didekomposisi."
    )
    add_picture(doc, dfd_context, "Gambar 3. DFD Level 0/diagram konteks: SIPANTES diperlakukan sebagai satu proses dan berinteraksi dengan lima entitas eksternal.")
    add_picture(doc, dfd_level1, "Gambar 4. DFD Level 1: dekomposisi SIPANTES menjadi autentikasi, data pasien, booking, informasi RS, dan update aplikasi.")
    add_picture(doc, dfd_auth, "Gambar 5. DFD Level 2 proses 1.0: registrasi, set password, login/session, klaim No. RM, dan hapus akun.")
    add_table(doc, ["Level", "Tujuan", "Aturan Balance"], [
        ("Level 0", "Menentukan boundary sistem dan entitas eksternal.", "Tidak menampilkan data store internal."),
        ("Level 1", "Memecah proses 0 menjadi proses 1.0–5.0.", "Input/output pengguna dan sistem eksternal tetap konsisten dengan level 0."),
        ("Level 2 Auth", "Memecah proses 1.0 menjadi 1.1–1.5.", "D1 dipecah menjadi data store OTP/ticket, user, session, klaim, dan hapus akun."),
    ], [3, 8, 10], 7.5)

    doc.add_heading("5. Spesifikasi Modul Fungsional", level=1)
    modules = [
        ("5.1 Splash dan Pemulihan Sesi", "Memuat branding, membaca secure storage, memanggil /auth/me bila token tersedia, lalu membuka MainShell. Token refresh kedaluwarsa menghapus session lokal.", ["Tidak memblokir aplikasi bila jaringan gagal dan session lokal masih layak.", "HTTP 401 menghapus session dan mengubah state menjadi guest."]),
        ("5.2 Beranda dan Informasi RS", "Menampilkan katalog layanan utama, identitas rumah sakit, kontak, tautan website/Maps/WhatsApp, visi misi, jam layanan, dan fasilitas.", ["Konten statis berasal dari AppBranding/DummyData.", "Tautan dibuka melalui url_launcher; kegagalan harus menampilkan feedback."]),
        ("5.3 Registrasi Akun", "Mengirim nama, email, dan telepon; menerima OTP email; memverifikasi OTP; membuat password dan session.", ["Email dinormalisasi lowercase; akun aktif yang sama menghasilkan 409 account_already_registered.", "Password 8–72 byte, mengandung huruf dan angka, tanpa spasi awal/akhir.", "OTP 6 digit, berlaku 5 menit, maksimal 5 percobaan.", "Setelah sukses, seluruh OTP/tiket registrasi email dibersihkan."]),
        ("5.4 Login dan Sesi", "Memvalidasi email atau No. RM + password, mengirim OTP login, memverifikasi OTP, lalu menerbitkan access/refresh token.", ["Login No. RM hanya tersedia untuk akun dengan pasien terhubung.", "Token mentah tidak disimpan server; hanya SHA-256 hash.", "Refresh token berotasi; reuse mencabut family sesi."]),
        ("5.5 Lupa Password", "Mengirim OTP reset ke email, memverifikasi OTP dan menyimpan bcrypt password baru.", ["Respons forgot password tidak membocorkan keberadaan email.", "Reset sukses mencabut seluruh sesi user."]),
        ("5.6 Tombol Tampil/Sembunyikan Password", "Ikon mata tersedia pada password login, registrasi, reset, verifikasi No. RM, dan hapus akun.", ["Default tetap tersembunyi.", "Tooltip berubah antara Tampilkan password dan Sembunyikan password.", "State visibilitas hanya di UI dan tidak mengubah payload."]),
        ("5.7 Profil dan Pengaitan No. RM", "User login mengisi No. RM, NIK, tanggal lahir, dan password; OTP email mengonfirmasi hubungan ke pasien.", ["Pencocokan dilakukan server-side terhadap pasiens.", "Satu patient_id hanya dapat terhubung ke satu user mobile aktif.", "Data klaim disimpan sebagai snapshot pada OTP challenge hingga dikonfirmasi."]),
        ("5.8 Profil Pasien", "Menampilkan identitas pasien berdasarkan principal.user_id dan principal.patient_id.", ["Wajib bearer session dan linked patient.", "Identitas query tidak boleh berasal dari parameter klien."]),
        ("5.9 Riwayat Kunjungan", "Menampilkan registrasi/kunjungan rawat jalan, IGD, dan rawat inap dengan limit.", ["Default limit 20.", "Hanya data patient_id principal yang boleh dikembalikan."]),
        ("5.10 Diagnosis, Tindakan, dan PDF Resume", "Menampilkan ringkasan medis, ICD, tindakan, serta PDF per registration_id.", ["PDF hanya dibuat bila registrasi milik patient_id principal.", "download=true mengubah Content-Disposition menjadi attachment; default inline.", "Response PDF memakai Cache-Control no-store."]),
        ("5.11 Hasil Laboratorium", "Menggabungkan order/hasil lab dan memprioritaskan data LIS bila tersedia.", ["Wajib linked patient.", "Nilai hasil dan detail pemeriksaan mengikuti sumber SIMRS/LIS."]),
        ("5.12 Hasil Radiologi", "Menampilkan order, hasil, detail pemeriksaan, dan ekspertise radiologi.", ["Wajib linked patient.", "Tidak ada endpoint mutasi hasil dari mobile."]),
        ("5.13 Resep dan Obat", "Menampilkan transaksi resep dan rincian master obat pasien.", ["Wajib linked patient.", "Data bersifat read-only."]),
        ("5.14 Poli dan Jadwal Dokter", "Pencarian/paginasi poli serta jadwal dokter, jam praktik, kuota, dan kelompok antrian.", ["Daftar poli bersifat publik.", "Alias /polis dipertahankan untuk kompatibilitas."]),
        ("5.15 Ketersediaan Kamar", "Menampilkan kamar aktif, kelas, total bed, dan bed kosong.", ["Endpoint publik; limit maksimum dikontrol repository.", "Data dapat berubah mengikuti operasional rawat inap."]),
        ("5.16 Kalender Booking", "Menggabungkan jadwal poli/dokter dengan Minggu, hari libur nasional, dan cuti rumah sakit.", ["Parameter year, month, poli_id divalidasi.", "Hari off tidak dapat dipilih kecuali terdapat jadwal yang mengizinkan."]),
        ("5.17 Booking Umum", "Linked patient memilih poli, tanggal, dokter/kelompok antrian, lalu membuat registrasis_dummy dan nomor antrean.", ["Sumber ditandai mobile_umum.", "Tidak menerima patient_id/no_rm dari payload; identitas dari bearer principal.", "Mencegah booking duplikat sesuai aturan tanggal/poli pasien."]),
        ("5.18 Nomor Antrian Saya", "Menampilkan booking pasien aktif/historis dengan filter tanggal, status, dan limit.", ["Default tanggal adalah hari ini; all_dates meniadakan filter tanggal.", "Hanya booking patient_id principal."]),
        ("5.19 Integrasi Mobile JKN", "Membuka aplikasi Mobile JKN atau Play Store bila aplikasi belum terpasang.", ["Tidak membuat klaim BPJS pada API SIPANTES.", "Merupakan deep link/tautan eksternal."]),
        ("5.20 Notifikasi Update Play Store", "Build release memeriksa versi publik terbaru saat aplikasi dibuka dan dilanjutkan ketika aplikasi kembali aktif.", ["Dialog berbahasa Indonesia menampilkan versi/release notes dan tombol Nanti atau Perbarui Sekarang.", "Perbarui Sekarang membuka listing package yang sama dengan applicationId build.", "Pemeriksaan dinonaktifkan pada debug/test agar tidak mengganggu pengembangan.", "Track internal/closed yang tidak memiliki halaman publik memerlukan Appcast atau pengujian setelah build dipasang melalui Play Store.", "Snapshot memakai applicationId id.rsudotista.sipantes, sementara listing SIPANTES lama yang publik memakai com.rssaderek; Play Console harus menetapkan package/signing target sebelum rilis."]),
        ("5.21 Hapus Akun Mobile", "Password menghasilkan OTP penghapusan khusus; OTP valid mengeksekusi hard delete akun mobile dan artefak auth.", ["Wajib bearer session aktif.", "OTP penghapusan terpisah dari OTP login/reset/registrasi.", "Penghapusan atomik: session, OTP klaim/reset/login/delete, tiket/OTP email, lalu user_mobile.", "pasiens, registrasi, antrian, resep, lab, radiologi, dan rekam medis tidak dihapus."]),
    ]
    for heading, description, rules in modules:
        doc.add_heading(heading, level=2)
        doc.add_paragraph(description)
        p = doc.add_paragraph()
        p.add_run("Rules: ").bold = True
        for idx, rule in enumerate(rules):
            p = doc.add_paragraph(rule, style="List Bullet")

    doc.add_heading("6. Flowchart Proses Utama", level=1)
    doc.add_paragraph(
        "Flowchart memakai simbol baku: terminator untuk awal/akhir, parallelogram untuk input/output, rectangle untuk proses, diamond untuk keputusan bercabang, dan cylinder untuk penyimpanan data. Setiap keputusan mempunyai cabang Ya/Tidak yang eksplisit; panah menunjukkan satu arah kendali dan jalur penanganan gagal tidak dibiarkan tanpa terminator."
    )
    doc.add_heading("6.1 Flowchart Registrasi", level=2)
    add_picture(doc, auth_flow, "Gambar 6. Flowchart registrasi: validasi data, perlindungan akun aktif, OTP terbaru, attempt limit, dan kelanjutan set password.")
    doc.add_heading("6.2 Flowchart Booking Umum", level=2)
    add_picture(doc, booking_flow, "Gambar 7. Flowchart booking: validasi session/patient link, kalender, kuota, duplikasi, dan penyimpanan staging.")
    doc.add_heading("6.3 Flowchart Hapus Akun", level=2)
    add_picture(doc, delete_flow, "Gambar 8. Flowchart hapus akun: re-authentication, OTP khusus, transaksi atomik, dan boundary data klinis.")
    doc.add_heading("6.4 Jenis OTP", level=2)
    add_table(doc, ["Purpose", "Tabel", "Pemicu", "Efek Sukses"], [
        ("Registrasi", "otp_verif_email_mobile", "POST /auth/register", "Menerbitkan registration ticket; sesudah set password seluruh row email dibersihkan."),
        ("Login", "otp_user_mobile", "POST /auth/login", "Challenge ditandai used; session diterbitkan."),
        ("Reset password", "otp_password_reset_mobile", "POST /auth/forgot-password", "Password berubah dan semua session dicabut."),
        ("Klaim No. RM", "otp_medical_record_claim_mobile", "POST /auth/medical-record/request", "user_mobile dihubungkan ke patient_id/no_rm."),
        ("Hapus akun", "otp_account_deletion_mobile", "POST /auth/account-deletion/request", "Akun dan artefak auth mobile dihapus permanen."),
    ], [3, 5, 5, 7], 7)
    add_bullets(doc, [
        "OTP baru membatalkan challenge lama dengan purpose yang sama.",
        "OTP baru disimpan dalam bentuk bcrypt pada otp_hash; otp_code hanya fallback skema legacy dan selalu ditulis kosong oleh binary baru.",
        "Kesalahan OTP menambah attempt_count; attempt kelima mengisi locked_at.",
        "Query verifikasi memakai SELECT ... FOR UPDATE untuk mencegah konsumsi ganda.",
        "OTP, token, password, dan NIK tidak boleh dicatat pada log.",
    ])

    doc.add_heading("7. Katalog API Lengkap", level=1)
    endpoints = [
        ("GET", "/", "Publik", "Redirect ke /api/v1/health"),
        ("GET", "/api/v1/health", "Publik", "Health database/API"),
        ("POST", "/api/v1/auth/register", "Publik", "Minta OTP registrasi"),
        ("POST", "/api/v1/auth/verify-otp-new-user", "Publik", "Verifikasi OTP registrasi"),
        ("POST", "/api/v1/auth/set-password", "Ticket", "Selesaikan registrasi dan issue session"),
        ("POST", "/api/v1/auth/login", "Publik", "Validasi password dan minta OTP login"),
        ("POST", "/api/v1/auth/verify-otp", "Publik", "Verifikasi OTP login dan issue session"),
        ("POST", "/api/v1/auth/forgot-password", "Publik", "Minta OTP reset"),
        ("POST", "/api/v1/auth/reset-password", "Publik", "Reset password"),
        ("POST", "/api/v1/auth/refresh", "Refresh token", "Rotasi session"),
        ("GET", "/api/v1/auth/verify", "Dipensiunkan", "Selalu 404"),
        ("GET", "/api/v1/auth/me", "Bearer", "Identity akun"),
        ("POST", "/api/v1/auth/logout", "Bearer", "Cabut session family"),
        ("POST", "/api/v1/auth/medical-record/request", "Bearer", "Minta OTP klaim No. RM"),
        ("POST", "/api/v1/auth/medical-record/confirm", "Bearer", "Konfirmasi klaim No. RM"),
        ("POST", "/api/v1/auth/account-deletion/request", "Bearer", "Minta OTP hapus akun"),
        ("POST", "/api/v1/auth/account-deletion/confirm", "Bearer", "Hapus akun mobile"),
        ("GET", "/api/v1/polis", "Publik", "Alias daftar poli"),
        ("GET", "/api/v1/mobile/hospital/polyclinics", "Publik", "Daftar/pencarian poli"),
        ("GET", "/api/v1/mobile/hospital/room-availabilities", "Publik", "Ketersediaan kamar"),
        ("GET", "/api/v1/mobile/booking/options/:poli_id", "Publik", "Opsi dokter/jadwal"),
        ("GET", "/api/v1/mobile/booking/calendar", "Publik", "Kalender booking"),
        ("POST", "/api/v1/mobile/booking/general", "Bearer + linked", "Buat booking umum"),
        ("GET", "/api/v1/mobile/booking/general/mine", "Bearer + linked", "Daftar booking sendiri"),
        ("GET", "/api/v1/mobile/booking/general", "Dipensiunkan", "Selalu 404"),
        ("GET", "/api/v1/mobile/patient/profile", "Bearer + linked", "Profil pasien"),
        ("GET", "/api/v1/mobile/patient/visits", "Bearer + linked", "Riwayat kunjungan"),
        ("GET", "/api/v1/mobile/patient/medical-summaries", "Bearer + linked", "Diagnosis/tindakan"),
        ("GET", "/api/v1/mobile/patient/medical-summaries/:registration_id/pdf", "Bearer + linked", "PDF resume"),
        ("GET", "/api/v1/mobile/patient/laboratory-results", "Bearer + linked", "Hasil lab"),
        ("GET", "/api/v1/mobile/patient/radiology-results", "Bearer + linked", "Hasil radiologi"),
        ("GET", "/api/v1/mobile/patient/prescriptions", "Bearer + linked", "Resep"),
    ]
    add_table(doc, ["Method", "Path", "Akses", "Fungsi"], endpoints, [2, 8, 3, 7], 6.5)

    doc.add_heading("7.1 Parameter Endpoint", level=2)
    params = [
        ("register", "Body", "Username, FullName, Email, Phone", "Semua string; NoRM dari klien diabaikan."),
        ("verify-otp-new-user", "Body", "Email, OTP", "OTP 6 digit."),
        ("set-password", "Body", "password, registration_ticket", "Ticket sekali pakai."),
        ("login", "Body", "Identifier, Password", "Identifier=email atau No. RM terhubung."),
        ("verify-otp", "Body", "Identifier, OTP", "OTP login."),
        ("forgot-password", "Body", "Identifier", "Email."),
        ("reset-password", "Body", "Identifier, OTP, Password", "Mencabut semua session."),
        ("refresh", "Body", "refresh_token", "Token opaque."),
        ("medical-record/request", "Body", "password, no_rm, nik, birth_date", "Tanggal YYYY-MM-DD/DD-MM-YYYY/DD/MM/YYYY."),
        ("medical-record/confirm", "Body", "otp", "OTP klaim."),
        ("account-deletion/request", "Body", "password", "Password akun login."),
        ("account-deletion/confirm", "Body", "otp", "OTP khusus penghapusan."),
        ("polyclinics", "Query", "q/search, page, limit", "Default page=1 limit=20."),
        ("room-availabilities", "Query", "q/search, limit", "Default limit=100."),
        ("booking/options", "Path/Query", "poli_id", "ID positif."),
        ("booking/calendar", "Query", "year, month, poli_id", "Default tahun/bulan berjalan."),
        ("booking/general POST", "Body", "poli_id, tanggal, bayar, jenis_pasien, dokter_id, queue_group, is_jkn", "patient_id/no_rm dari principal."),
        ("booking/general/mine", "Query", "status, tanggal/date, all_dates, limit", "Default hari ini, limit 50."),
        ("patient lists", "Query", "limit", "Default 20."),
        ("medical summary PDF", "Path/Query", "registration_id, download", "download=true untuk attachment."),
    ]
    add_table(doc, ["Endpoint", "Lokasi", "Field", "Catatan"], params, [4, 3, 7, 7], 7)

    doc.add_heading("7.2 Status HTTP", level=2)
    add_table(doc, ["Status", "Arti", "Contoh"], [
        ("200", "Sukses", "Read, verify OTP, refresh, confirm."),
        ("202", "Diterima", "Request registrasi."),
        ("400", "Input/aturan bisnis tidak valid", "Format password/OTP/tanggal."),
        ("401", "Autentikasi/OTP/session tidak valid", "Bearer atau credential gagal."),
        ("403", "Akun belum linked patient", "Akses data klinis/booking."),
        ("404", "Resource/route tidak ada", "Route retired atau data tidak ditemukan."),
        ("409", "Konflik akun", "account_already_registered."),
        ("429", "Rate limit", "Terlalu banyak request OTP/auth."),
        ("500", "Kesalahan internal", "Query/render tidak terduga."),
        ("503", "Dependency auth tidak tersedia", "SMTP/session issue; Retry-After dikirim."),
        ("504", "Timeout", "Query pasien melewati deadline."),
    ], [2, 7, 8], 8)

    doc.add_heading("8. Desain Database dan ERD", level=1)
    doc.add_paragraph(
        "Bagian ini memisahkan fakta struktur yang dibuat oleh migrasi API dari relasi logis yang hanya terlihat pada query repository. "
        "Pemisahan tersebut penting: kolom dengan nama berpasangan belum tentu memiliki FOREIGN KEY di database produksi. "
        "Snapshot ini diturunkan dari internal/database/auth_migration.go, validasi startup, historyQuery/history.sql, dan JOIN pada internal/repository/*.go tanggal 8 Oktober 2026."
    )
    doc.add_heading("8.1 Notasi, Kardinalitas, dan Tingkat Kepastian", level=2)
    add_table(doc, ["Notasi", "Arti", "Konsekuensi Teknis"], [
        ("PK", "Primary key; identitas unik baris.", "Menjadi target relasi dan lookup utama."),
        ("UK", "Unique key/index.", "Nilai non-NULL tidak boleh duplikat sesuai aturan MySQL."),
        ("FK fisik / garis hijau", "FOREIGN KEY tercantum eksplisit pada migrasi.", "Database menjaga referensi; tabel OTP terkait memakai ON DELETE CASCADE."),
        ("Relasi logis / garis putus", "Relasi dibuktikan oleh JOIN atau filter source, tetapi migrasi API tidak mendeklarasikan FK.", "Integritas bergantung pada aplikasi/data SIMRS; jangan menyimpulkan cascade otomatis."),
        ("1 / 0..1 / 0..N", "Kardinalitas Crow's Foot tekstual: tepat satu, nol atau satu, serta nol atau banyak.", "Contoh: satu user_mobile dapat memiliki nol atau banyak sesi dan histori OTP."),
        ("M:N", "Many-to-many tidak direalisasikan langsung.", "Harus dipecah menjadi dua relasi 1:N melalui associative/junction entity yang menyimpan pasangan key."),
        ("0..1 -> 1", "Relasi opsional dari sisi akun.", "user_mobile.patient_id boleh NULL; jika terisi menunjuk satu pasiens.id secara logis."),
        ("Snapshot", "Nilai disalin saat challenge dibuat.", "no_rm/patient_name pada OTP klaim bukan master pasien dan tidak boleh dianggap selalu mutakhir."),
    ], [3, 7, 10], 7.5)
    add_note(doc, "Batas fakta ERD", "FK fisik hanya dinyatakan jika ada pada migrasi yang dikelola API. Relasi tabel SIMRS existing didokumentasikan sebagai relasi query karena source ini tidak memiliki DDL kanonik seluruh SIMRS. Struktur server aktual tetap harus diverifikasi melalui information_schema sebelum perubahan produksi.", True)

    doc.add_heading("8.2 ERD Autentikasi Mobile", level=2)
    add_picture(doc, erd_auth, "Gambar 9. ERD autentikasi berbentuk tabel: nama entitas pada header, atribut pada baris, penanda PK/FK/L-FK/UK, serta kardinalitas setiap relasi.")
    auth_tables = [
        ("user_mobile", "Akun login mobile", "id; username; email; no_rm; patient_id; phone; full_name; password; email_verified; verification_token; verified_at; medical_record_verified_at; is_deleted; deleted_at; created_at; updated_at", "UK email; UK patient_id"),
        ("otp_verif_email_mobile", "OTP registrasi email + snapshot profil", "id; username; email; no_rm; phone; full_name; otp_code; otp_hash; attempt_count; last_attempt_at; locked_at; used_at; expired_at; is_used; created_at", "Index email/status/expiry"),
        ("otp_user_mobile", "OTP login", "id; user_id; otp_code; otp_hash; attempt_count; last_attempt_at; locked_at; used_at; expired_at; is_used; created_at", "FK user ON DELETE CASCADE"),
        ("otp_password_reset_mobile", "OTP reset password", "Kolom challenge sama dengan otp_user_mobile", "FK user ON DELETE CASCADE"),
        ("otp_account_deletion_mobile", "OTP hapus akun", "Kolom challenge sama dengan otp_user_mobile", "FK user ON DELETE CASCADE"),
        ("otp_medical_record_claim_mobile", "OTP pengaitan No. RM", "id; user_id; patient_id; no_rm; patient_name; kolom challenge", "FK user; index user dan no_rm"),
        ("session_user_mobile", "Access/refresh session", "id; family_id; parent_session_id; user_id; access_token_hash; refresh_token_hash; access_expires_at; refresh_expires_at; rotated_at; revoked_at; revoke_reason; replaced_by_session_id; created_at; updated_at", "UK hash token; index user/family"),
        ("auth_ticket_mobile", "Registration ticket", "id; verification_id; email; purpose; ticket_hash; expires_at; used_at; revoked_at; created_at", "UK ticket_hash; index email/purpose"),
    ]
    add_table(doc, ["Tabel", "Fungsi", "Kolom", "Relasi/Index"], auth_tables, [4, 5, 10, 5], 6.5)

    doc.add_heading("8.3 Matriks Relasi Auth dan Kardinalitas", level=2)
    add_table(doc, ["Induk", "Anak/Target", "Kolom Relasi", "Kardinalitas", "Jenis", "Perilaku"], [
        ("user_mobile.id", "otp_user_mobile.user_id", "id = user_id", "1 -> 0..N", "FK fisik", "ON DELETE CASCADE; OTP login ikut hilang."),
        ("user_mobile.id", "otp_password_reset_mobile.user_id", "id = user_id", "1 -> 0..N", "FK fisik", "ON DELETE CASCADE; OTP reset ikut hilang."),
        ("user_mobile.id", "otp_account_deletion_mobile.user_id", "id = user_id", "1 -> 0..N", "FK fisik", "ON DELETE CASCADE; hanya challenge terbaru aktif."),
        ("user_mobile.id", "otp_medical_record_claim_mobile.user_id", "id = user_id", "1 -> 0..N", "FK fisik", "ON DELETE CASCADE; patient_id/no_rm adalah snapshot klaim."),
        ("user_mobile.id", "session_user_mobile.user_id", "id = user_id", "1 -> 0..N", "Relasi aplikasi", "Tidak ada FK pada migrasi; repository menghapus/revoke eksplisit."),
        ("session_user_mobile.id", "session_user_mobile.parent_session_id", "id = parent_session_id", "1 -> 0..N", "Self-reference logis", "Menelusuri rotasi refresh token; bukan FK fisik."),
        ("session_user_mobile.id", "session_user_mobile.replaced_by_session_id", "id = replaced_by_session_id", "0..1 -> 1", "Self-reference logis", "Menunjuk sesi pengganti setelah rotasi."),
        ("otp_verif_email_mobile.id", "auth_ticket_mobile.verification_id", "id = verification_id", "1 -> 0..N", "Relasi query", "INNER JOIN saat konsumsi ticket; tidak ada FK fisik."),
        ("otp_verif_email_mobile.email", "auth_ticket_mobile.email", "email = email", "1 -> 0..N", "Scope bisnis", "Cleanup registrasi dan hapus akun dilakukan berdasarkan email."),
        ("user_mobile.patient_id", "pasiens.id", "patient_id = id", "0..1 -> 1", "Relasi query", "UK patient_id mencegah satu pasien ditautkan ke banyak akun; master pasien tidak ikut dihapus."),
    ], [4, 5, 4, 3, 4, 7], 6.2)

    doc.add_heading("8.4 Lifecycle Entitas Auth", level=2)
    add_table(doc, ["Entitas", "Dibuat", "Dinonaktifkan/Dikonsumsi", "Dihapus"], [
        ("otp_verif_email_mobile", "Request registrasi", "Setelah OTP benar atau OTP baru menggantikan challenge lama", "Sesudah registrasi selesai atau cleanup akun berdasarkan email"),
        ("auth_ticket_mobile", "OTP registrasi berhasil", "used_at setelah password/akun berhasil dibuat; revoked_at ketika diganti", "Sesudah registrasi selesai atau cleanup berdasarkan email"),
        ("user_mobile", "Konsumsi registration ticket + set password", "Legacy dapat memiliki is_deleted/deleted_at", "Hard-delete saat konfirmasi hapus akun atau cleanup legacy soft-delete"),
        ("otp_* berbasis user", "Request login/reset/klaim/hapus", "is_used, expired_at, locked_at, maksimal lima attempt", "Explicit cleanup dan/atau cascade dari user_mobile"),
        ("session_user_mobile", "Login/registrasi/refresh", "revoked_at, rotated_at, expiry", "Hapus akun menghapus semua sesi user"),
        ("pasiens dan pelayanan", "Dikelola SIMRS", "Mengikuti aturan SIMRS, bukan lifecycle akun mobile", "Tidak pernah dihapus oleh transaksi hapus akun mobile"),
    ], [5, 5, 7, 7], 6.8)

    doc.add_heading("8.5 Peta Relasi Data Layanan", level=2)
    add_picture(doc, erd_visit, "Gambar 10. ERD logis inti kunjungan dan booking: pasien, registrasi, staging booking, poli, dokter, antrean, dan cara bayar.")
    add_picture(doc, erd_clinical, "Gambar 11. ERD M:N klinis: diagnosis dan tindakan menggunakan associative entity sehingga tidak ada relasi many-to-many langsung.")
    add_picture(doc, erd_results, "Gambar 12. ERD logis hasil pelayanan: laboratorium, radiologi, penjualan resep, detail resep, dan master obat.")
    source_tables = [
        ("user_mobile -> pasiens", "user_mobile.patient_id = pasiens.id; inner join untuk profil patient-linked. user_mobile.no_rm hanya atribut bantu/legacy."),
        ("pasiens -> registrasis", "pasiens.id = registrasis.pasien_id; satu pasien dapat memiliki banyak kunjungan."),
        ("registrasis -> master kunjungan", "poli_id -> polis.id; dokter_id (cast UNSIGNED) -> pegawais.id; antrian_poli_id -> antrian_poli.id; bayar (cast) -> carabayars.id."),
        ("registrasis -> rawat inap", "Subquery memilih rawatinaps terbaru per registrasi; kelompokkelas_id, kamar_id, dan bed_id dipetakan ke kelompok_kelas, kamars, beds."),
        ("registrasis -> resume/EMR", "registrasi_id menghubungkan resume_pasiens, emr_resume, emr_riwayats, dan emr_inap_medical_records."),
        ("registrasis -> diagnosis/tindakan", "registrasi_id menghubungkan jkn/perawatan_icd10s dan icd9s; kode icd10/icd9 dipetakan ke master berdasarkan nomor."),
        ("pasiens/registrasis -> laboratorium", "hasillabs.pasien_id dan registrasi_id; order_lab_id; rincian_hasillabs mengacu ke master section, kategori, dan laboratoria."),
        ("registrasis -> radiologi", "order_radiologi/hasilradiologis/radiologi_ekspertises memakai registrasi_id; detailradiologis.hasilradiologi_id = hasilradiologis.id."),
        ("registrasis -> farmasi", "penjualans.registrasi_id; penjualandetails menjadi detail transaksi; masterobat_id mengarah ke masterobats.id."),
        ("registrasis_dummy", "Staging booking umum mobile; no_rm menghubungkan pasien, sedangkan poli/dokter dapat dicari dari id maupun kode karena kompatibilitas skema lama."),
        ("jadwal/libur", "jadwaldokters dibaca bersama master poli/dokter; tanggal_libur_rs berdiri sendiri sebagai pengecualian kalender."),
    ]
    add_table(doc, ["Relasi/Grup", "Fakta Pemakaian oleh API"], source_tables, [7, 17], 6.7)
    add_note(doc, "Ownership dan otorisasi", "Repository mobile membaca tabel layanan dengan projection eksplisit. patient_id selalu berasal dari principal sesi, bukan parameter bebas klien. Mutasi bisnis mobile dibatasi pada akun autentikasi dan staging registrasis_dummy; endpoint mobile tidak mengedit master pasiens maupun tabel klinis.")

    doc.add_heading("8.6 Batas Transaksi Hapus Akun", level=2)
    add_table(doc, ["Di dalam transaksi penghapusan", "Di luar transaksi / wajib dipertahankan"], [
        ("session_user_mobile berdasarkan user_id", "pasiens dan identitas rekam medis"),
        ("otp_user_mobile, otp_password_reset_mobile, otp_account_deletion_mobile berdasarkan user_id", "registrasis, registrasis_dummy, antrian_poli"),
        ("otp_medical_record_claim_mobile berdasarkan user_id", "resume/EMR, diagnosis, tindakan"),
        ("auth_ticket_mobile dan otp_verif_email_mobile berdasarkan email", "laboratorium, radiologi, farmasi"),
        ("user_mobile sebagai langkah terakhir", "master poli/dokter/cara bayar/kamar/bed serta tabel libur"),
    ], [11, 13], 7)
    add_note(doc, "Mengapa user_mobile dihapus terakhir", "Repository mengunci user_mobile dan OTP penghapusan, memverifikasi challenge, membersihkan seluruh artefak mobile, baru menghapus user_mobile dan melakukan COMMIT. Jika satu statement gagal, transaksi di-ROLLBACK sehingga tidak ada kondisi akun terhapus sebagian.", True)

    doc.add_heading("8.7 Verifikasi ERD terhadap Database Server", level=2)
    doc.add_paragraph("Gunakan query baca-saja berikut sebelum deployment atau audit. Hasil aktual harus dibandingkan dengan diagram dan kamus data di atas.")
    add_code(doc, "SELECT TABLE_NAME, ENGINE\nFROM information_schema.TABLES\nWHERE TABLE_SCHEMA = DATABASE()\n  AND TABLE_NAME IN ('user_mobile','otp_user_mobile','otp_verif_email_mobile',\n    'otp_password_reset_mobile','otp_account_deletion_mobile',\n    'otp_medical_record_claim_mobile','session_user_mobile','auth_ticket_mobile');\n\nSELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY\nFROM information_schema.COLUMNS\nWHERE TABLE_SCHEMA = DATABASE()\n  AND TABLE_NAME LIKE '%mobile'\nORDER BY TABLE_NAME, ORDINAL_POSITION;\n\nSELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME,\n       REFERENCED_COLUMN_NAME\nFROM information_schema.KEY_COLUMN_USAGE\nWHERE TABLE_SCHEMA = DATABASE()\n  AND REFERENCED_TABLE_NAME IS NOT NULL\nORDER BY TABLE_NAME, CONSTRAINT_NAME, ORDINAL_POSITION;")

    doc.add_heading("9. Keamanan dan Privasi", level=1)
    add_table(doc, ["Kontrol", "Implementasi"], [
        ("Password", "bcrypt DefaultCost; validasi panjang 8–72 byte, huruf+angka, tanpa trim tersembunyi."),
        ("OTP", "6 digit; bcrypt; expiry 5 menit; maksimal 5 attempt; challenge lama dinonaktifkan."),
        ("Registration ticket", "Token acak, hash SHA-256 di DB, purpose-bound, expiry, sekali pakai."),
        ("Session", "Access/refresh opaque; hash saja di DB; refresh rotation; family revocation."),
        ("Mobile storage", "flutter_secure_storage; identity ditulis sebelum token sebagai commit session."),
        ("Authorization", "Bearer middleware; linked patient middleware; patient identity dari principal."),
        ("Rate limit", "Global + per identifier/email/token untuk endpoint auth dan OTP."),
        ("Headers", "SecurityHeaders middleware; CORS dibatasi method/header."),
        ("Logging", "Tidak mencatat OTP/token/password/NIK; log hanya path/error type untuk auth."),
        ("Response", "Allowlist pesan error auth mencegah kebocoran error SQL/crypto/SMTP."),
        ("PDF", "Ownership registration diverifikasi; Cache-Control no-store."),
        ("Delete account", "Re-auth password + OTP khusus + transaksi; hanya data mobile auth."),
    ], [5, 14], 8)
    doc.add_heading("9.1 Matriks Data Saat Hapus Akun", level=2)
    add_table(doc, ["Data", "Aksi", "Alasan"], [
        ("user_mobile", "Hapus permanen", "Identitas akun mobile."),
        ("session_user_mobile", "Hapus", "Meniadakan seluruh access/refresh session."),
        ("Seluruh otp_*_mobile", "Hapus", "Mencegah OTP tersisa/nyangkut."),
        ("auth_ticket_mobile", "Hapus berdasarkan email", "Mencegah ticket registrasi lama."),
        ("pasiens", "Pertahankan", "Master pasien/rekam medis rumah sakit."),
        ("Registrasi/antrian/resep/lab/radiologi/EMR", "Pertahankan", "Dokumen pelayanan kesehatan dan audit operasional."),
    ], [7, 5, 9], 8)

    doc.add_heading("10. Konfigurasi, Build, dan Deployment", level=1)
    doc.add_heading("10.1 Flutter", level=2)
    add_code(doc, "flutter pub get\nflutter analyze\nflutter test\nflutter run --dart-define=APP_ENV=dev --dart-define=DEV_API_BASE_URL=https://host/api/v1\nflutter build apk --release --dart-define=APP_ENV=prod --dart-define=PROD_API_BASE_URL=https://host/api/v1")
    doc.add_heading("10.2 API Go", level=2)
    add_code(doc, "go test ./...\ngo run ./cmd/migrate\ngo run ./cmd/api\n# atau\ndocker compose -f docker-compose.yml -f docker-compose.target.yml up -d --build")
    doc.add_heading("10.3 Environment API", level=2)
    add_table(doc, ["Variabel", "Wajib Prod", "Keterangan"], [
        ("APP_NAME", "Tidak", "Nama aplikasi."),
        ("APP_ENV", "Ya", "production untuk validasi ketat."),
        ("APP_PORT", "Ya", "Port listener."),
        ("DB_HOST/DB_PORT/DB_USER/DB_PASSWORD/DB_NAME", "Ya", "Koneksi MySQL; user prod tidak boleh root."),
        ("SMTP_HOST/SMTP_PORT/SMTP_EMAIL/SMTP_PASSWORD", "Ya", "Pengiriman OTP."),
        ("HOLIDAY_API_BASE_URL", "Tidak", "Default tanggalmerah.upset.dev."),
    ], [7, 3, 10], 8)
    doc.add_heading("10.4 Urutan Deployment", level=2)
    add_numbered(doc, [
        "Backup tabel user_mobile dan seluruh tabel otp/session/auth_ticket mobile.",
        "Terapkan migrasi yang membuat otp_account_deletion_mobile dan pastikan seluruh tabel auth memakai InnoDB.",
        "Jalankan validasi skema startup; jangan lanjut bila ada tabel/kolom/index wajib yang hilang.",
        "Deploy API dan verifikasi GET /api/v1/health.",
        "Uji register → OTP → set password → login → refresh → logout pada akun uji.",
        "Uji hapus akun: konfirmasi user_mobile/artefak auth hilang dan pasiens/data pelayanan tetap ada.",
        "Build Flutter dengan base URL eksplisit dan jalankan smoke test perangkat.",
    ])
    add_note(doc, "Migrasi produksi", "historyQuery/history.sql adalah riwayat/manual SQL. Untuk instalasi terkontrol gunakan cmd/migrate atau script migrasi yang menjalankan EnsureAuthSchema, lalu audit hasilnya melalui information_schema.", True)

    doc.add_heading("11. Pengujian dan Acceptance Criteria", level=1)
    add_table(doc, ["ID", "Skenario", "Hasil Diharapkan"], [
        ("AUTH-01", "Registrasi email baru", "OTP terkirim, ticket terbit, user dibuat, OTP/ticket email bersih."),
        ("AUTH-02", "Registrasi email aktif", "409 account_already_registered; diarahkan login/lupa password."),
        ("AUTH-03", "OTP salah 5 kali", "Challenge locked; OTP tidak dapat dipakai."),
        ("AUTH-04", "Retry set-password setelah OTP verified", "Client memakai ticket cached; tidak perlu verifikasi OTP ulang selama ticket valid."),
        ("AUTH-05", "Login dan refresh concurrent", "Satu refresh ter-serialize; request di-replay sekali."),
        ("AUTH-06", "Kirim ulang OTP registrasi pada email testing", "Ticket attempt lama dibuang; hanya OTP terbaru yang dapat menghasilkan ticket baru."),
        ("AUTH-07", "Daftar ulang akun legacy soft-delete", "Artefak auth dan user_mobile lama dibersihkan; akun aktif tidak pernah ditimpa."),
        ("PWD-01", "Ikon mata pada 5 form password", "obscureText berubah tanpa mengubah controller/payload."),
        ("MR-01", "Klaim No. RM valid", "patient_id/no_rm terhubung setelah OTP."),
        ("MR-02", "Patient sudah terhubung user lain", "Klaim ditolak."),
        ("DATA-01", "Akses data pasien tanpa link", "403."),
        ("DATA-02", "Manipulasi patient_id dari klien", "Diabaikan; identity tetap dari principal."),
        ("BOOK-01", "Booking pada hari tersedia", "registrasis_dummy/antrian dibuat dan nomor kembali."),
        ("BOOK-02", "Booking pada hari libur/off", "Ditolak dengan 400 business validation."),
        ("DEL-01", "Password salah", "OTP hapus tidak dibuat."),
        ("DEL-02", "OTP hapus salah", "attempt bertambah; akun tetap ada."),
        ("DEL-03", "OTP hapus valid", "Akun/session/OTP/ticket mobile hilang; data pasien tetap."),
        ("DEL-04", "Daftar ulang email yang telah dihapus", "Registrasi baru dapat diselesaikan tanpa stale OTP."),
        ("SEC-01", "Reuse refresh token", "Seluruh session family dicabut."),
        ("SEC-02", "Log audit", "Tidak mengandung token, OTP, password, NIK."),
        ("UPDATE-01", "Versi Play Store lebih baru pada build release", "Dialog update berbahasa Indonesia muncul dan membuka Play Store."),
    ], [2.5, 8, 11], 7)
    doc.add_heading("11.1 Perintah Verifikasi Snapshot", level=2)
    add_code(doc, "# Flutter\ndart format --output=none --set-exit-if-changed lib test\nflutter analyze\nflutter test\n\n# Go API\ngofmt -w <file yang berubah>\ngo test ./...")
    doc.add_paragraph("Hasil fungsional yang menjadi baseline revisi 2.3: flutter analyze tanpa issue, seluruh 19 test Flutter lulus, dan seluruh package test Go lulus. Validasi model data dilakukan dengan mencocokkan migrasi, schema validator, transaksi repository, dan seluruh JOIN yang digunakan API mobile.")

    doc.add_heading("12. Operasional dan Troubleshooting", level=1)
    add_table(doc, ["Gejala", "Pemeriksaan", "Tindakan"], [
        ("OTP tidak masuk", "SMTP config, queue dispatcher, spam, 503/Retry-After", "Perbaiki SMTP; jangan mencetak OTP ke log."),
        ("OTP selalu invalid", "Expiry, locked_at, purpose/table, jam server", "Minta OTP baru; pastikan timezone/NTP konsisten."),
        ("Registrasi berhenti setelah OTP", "registration_ticket pada response; /set-password; tabel auth_ticket", "Pastikan migrasi ticket lengkap dan client tidak membuang ticket."),
        ("Email tidak bisa daftar ulang setelah delete", "user_mobile, otp_verif_email_mobile, auth_ticket_mobile", "Pastikan endpoint confirm memakai hard-delete transaksi revisi 2.0."),
        ("Hapus akun 404", "Route API deployed", "Deploy binary API yang mendaftarkan /auth/account-deletion/* dan migrasi tabel OTP delete."),
        ("401 berulang", "Expiry/revocation token, refresh response", "Clear secure storage dan login ulang setelah memastikan server sehat."),
        ("403 data pasien", "patient_id/no_rm pada user_mobile", "Jalankan alur Hubungkan No. RM."),
        ("PDF 404", "registration_id dan ownership pasien", "Pilih resume milik akun yang terhubung."),
        ("Booking ditolak", "Kalender, jadwal dokter/poli, duplikat", "Tampilkan pesan business validation dan pilih tanggal lain."),
        ("Health gagal", "DB connectivity dan validasi skema", "Periksa env DB, InnoDB, kolom/index auth."),
    ], [6, 8, 9], 7)
    doc.add_heading("12.1 Monitoring Minimum", level=2)
    add_bullets(doc, [
        "Availability dan latency /api/v1/health.",
        "Rate 4xx/5xx/429/503 per endpoint tanpa merekam payload sensitif.",
        "Kedalaman queue SMTP dan error pengiriman OTP.",
        "Koneksi/pool MySQL, timeout query pasien, dan kegagalan transaksi booking/delete.",
        "Jumlah session aktif/revoked secara agregat; jangan mengekspos token hash.",
        "Pertumbuhan tabel OTP/ticket; lakukan retention terjadwal untuk row expired/used bila dibutuhkan.",
    ])

    doc.add_heading("13. Struktur Source yang Dipelihara", level=1)
    add_code(doc, "rs_mobile_otista_v1.0/\n  lib/core/                  # config, network, theme, shared widgets\n  lib/features/auth/         # auth/session/OTP\n  lib/features/profile/      # profil, link No. RM, hapus akun\n  lib/features/booking/      # booking umum dan riwayat antrean\n  lib/features/api_data/     # data pasien/hospital API\n  lib/features/home/         # beranda dan katalog layanan\n  test/                      # unit/widget tests\n  docs/                      # manual dan spesifikasi\n\nApiRsudOtistaMobile/\n  cmd/api, cmd/migrate       # entrypoint\n  internal/auth              # service/session/mail/OTP\n  internal/http              # routes, middleware, handler, response\n  internal/repository        # query/transaksi\n  internal/database          # schema/migration/validation\n  internal/model             # DTO/model\n  historyQuery               # riwayat SQL produksi\n  docs                       # panduan deployment/security")

    doc.add_heading("14. Traceability Perubahan Revisi Mobile", level=1)
    add_table(doc, ["Permintaan", "Implementasi Flutter", "Implementasi API/DB", "Verifikasi"], [
        ("Tombol password view", "Suffix eye pada login, registrasi, reset, link No. RM, hapus akun.", "Tidak mengubah kontrak API.", "Widget test toggle + analyze/test."),
        ("OTP nyangkut setelah registrasi", "Request/kirim ulang OTP membuang ticket attempt lama; email/data dikunci saat menunggu OTP dan tersedia aksi Kirim ulang/Ganti data.", "Soft-delete legacy dibersihkan sebelum registrasi; CompleteRegistration menghapus ticket dan OTP email setelah sukses tanpa menimpa akun aktif.", "Go test + Cubit/widget retry tests."),
        ("OTP/hapus akun nyangkut", "Halaman request/confirm OTP dan clear secure session setelah sukses.", "Endpoint request/confirm, tabel OTP khusus, limit attempt, hard-delete atomik + cleanup email scoped.", "Go test + Cubit/datasource tests."),
        ("Hapus akun hanya user mobile", "Copy UI menegaskan data rekam medis tetap ada.", "Query hanya menyentuh user_mobile, session/OTP/ticket mobile; tidak ada DELETE tabel pasiens/klinis.", "Review SQL dan acceptance DEL-03."),
        ("Notifikasi versi Play Store", "AppUpdatePrompt memeriksa versi pada build release dan menampilkan dialog Indonesia.", "Tidak memerlukan perubahan API; versi dibaca dari listing Play Store.", "Analyze, widget suite, dan UAT release via Play Store."),
        ("Modul teknis lengkap", "Inventaris seluruh page/feature.", "Inventaris seluruh route, schema, security, deploy.", "Dokumen ini."),
    ], [5, 6, 8, 5], 7)

    doc.add_heading("15. Checklist Serah Terima", level=1)
    add_table(doc, ["Item", "Kriteria", "Status"], [
        ("Source Flutter", "Format, analyze, test lulus", "Lulus pada snapshot"),
        ("Source Go API", "gofmt dan go test ./... lulus", "Lulus pada snapshot"),
        ("Migrasi", "otp_account_deletion_mobile tersedia dan tervalidasi", "Wajib diterapkan per environment"),
        ("Secret", "Tidak ada password DB/SMTP/token di repo atau dokumen", "Wajib diverifikasi"),
        ("Base URL", "Ditetapkan eksplisit untuk dev/staging/prod", "Wajib diputuskan saat rilis"),
        ("UAT", "Seluruh acceptance criteria AUTH/DATA/BOOK/DEL/SEC", "Wajib dijalankan dengan akun uji"),
        ("Backup/rollback", "Backup auth mobile dan image API sebelumnya tersedia", "Wajib sebelum deploy"),
        ("Dokumen", "TOC diperbarui, diagram terbaca, dan format akhir diverifikasi", "Lulus pada snapshot"),
    ], [6, 11, 5], 8)

    doc.add_heading("Lampiran A. Contoh Payload", level=1)
    add_code(doc, "POST /api/v1/auth/account-deletion/request\nAuthorization: Bearer <access-token>\n{\"password\":\"<password-user>\"}\n\nPOST /api/v1/auth/account-deletion/confirm\nAuthorization: Bearer <access-token>\n{\"otp\":\"123456\"}\n\nPOST /api/v1/mobile/booking/general\nAuthorization: Bearer <access-token>\n{\"poli_id\":12,\"tanggal\":\"2026-10-08\",\"bayar\":\"UMUM\",\"jenis_pasien\":\"UMUM\",\"dokter_id\":\"34\",\"queue_group\":\"A\",\"is_jkn\":false}")
    add_note(doc, "Keamanan contoh", "Nilai password, OTP, dan token di atas hanyalah placeholder. Jangan menaruh credential nyata di tiket, chat, screenshot, source, atau dokumen.", True)

    doc.add_heading("Lampiran B. Referensi Source of Truth", level=1)
    add_table(doc, ["Topik", "File Utama"], [
        ("Konfigurasi base URL", "lib/core/config/api_config.dart"),
        ("HTTP client/refresh", "lib/core/network/api_client.dart"),
        ("UI auth/password", "lib/features/auth/presentation/pages/auth_page.dart"),
        ("UI hapus akun", "lib/features/profile/presentation/pages/account_deletion_page.dart"),
        ("Remote auth", "lib/features/auth/data/datasources/auth_remote_datasource.dart"),
        ("Routes API", "internal/http/routes/*.go"),
        ("Auth rules", "internal/auth/service.go"),
        ("Delete transaction", "internal/repository/account_deletion_repository.go"),
        ("Registration cleanup", "internal/repository/auth_ticket_repository.go"),
        ("Schema", "internal/database/auth_migration.go"),
        ("SQL produksi", "historyQuery/history.sql"),
    ], [6, 14], 8)

    doc.add_heading("Penutup", level=1)
    doc.add_paragraph(
        "Dokumen ini adalah baseline teknis revisi 2.3. Perubahan route, skema, foreign key, relasi query, aturan booking, sumber data klinis, atau kebijakan retensi harus memperbarui source, migrasi, pengujian, diagram, dan dokumen secara bersamaan agar tidak terjadi drift."
    )

    add_header_footer(doc)
    doc.save(OUTPUT)
    return OUTPUT


if __name__ == "__main__":
    print(build_document())
