"""Create a source-backed PDF of RyanGunshop's emulator launch sequence."""

from pathlib import Path
import argparse
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
REPORTS = ROOT / "reports"
SCREENSHOTS = REPORTS / "screenshots"
VIDEO = ROOT / ".artifacts" / "ryangunshop-logo-animation.mp4"
PDF_PATH = REPORTS / "Laporan_Visual_Masuk_dan_Splash_RyanGunshop.pdf"
FRAMES = {
    "01_animasi_masuk": 4,
    "02_native_launch": 8,
    "03_splash_awal": 16,
    "04_splash_logo": 17,
    "05_dashboard": 23,
}
ONBOARDING_FRAMES = {
    "06_onboarding_scan": ROOT / ".artifacts" / "onboarding-final-1.png",
    "07_onboarding_layout": ROOT / ".artifacts" / "onboarding-final-2.png",
    "08_onboarding_payment": ROOT / ".artifacts" / "onboarding-final-3.png",
}


def extract_frames():
    SCREENSHOTS.mkdir(parents=True, exist_ok=True)
    # Decode from the beginning: this recording has variable frame timestamps,
    # so independent fast seeks can return a preceding native launch frame.
    with tempfile.TemporaryDirectory(prefix="ryangunshop_report_frames_") as tmp:
        frame_dir = Path(tmp)
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", str(VIDEO),
             "-vf", "fps=4", str(frame_dir / "frame_%03d.png")],
            check=True,
        )
        for name, index in FRAMES.items():
            shutil.copyfile(frame_dir / f"frame_{index:03d}.png",
                            SCREENSHOTS / f"{name}.png")
            print(f"Screenshot: {name} / sampled frame {index}")
    for name, source in ONBOARDING_FRAMES.items():
        if not source.exists():
            raise FileNotFoundError(f"Onboarding screenshot not found: {source}")
        shutil.copyfile(source, SCREENSHOTS / f"{name}.png")
        print(f"Screenshot: {name} / final emulator capture")


def create_pdf():
    from reportlab.lib import colors
    from reportlab.lib.enums import TA_LEFT
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.styles import ParagraphStyle
    from reportlab.pdfbase import pdfmetrics
    from reportlab.pdfbase.ttfonts import TTFont
    from reportlab.pdfgen import canvas
    from reportlab.platypus import Paragraph

    font_dir = Path("C:/Windows/Fonts")
    pdfmetrics.registerFont(TTFont("Report", str(font_dir / "segoeui.ttf")))
    pdfmetrics.registerFont(TTFont("ReportBold", str(font_dir / "segoeuib.ttf")))
    pdfmetrics.registerFontFamily("Report", normal="Report", bold="ReportBold")
    width, height = A4
    margin = 46
    slate = colors.HexColor("#565C9D")
    dark = colors.HexColor("#34385F")
    ink = colors.HexColor("#191A2E")
    muted = colors.HexColor("#62657A")
    light = colors.HexColor("#E9EAF6")
    border = colors.HexColor("#D9DAE6")
    c = canvas.Canvas(str(PDF_PATH), pagesize=A4, pageCompression=1)
    c.setTitle("Laporan Visual Masuk dan Splash Screen - RyanGunshop")
    c.setAuthor("Tim Pengembangan RyanGunshop")
    c.setSubject(
        "Dokumentasi screenshot aktual alur pembukaan dan onboarding aplikasi Android"
    )

    def paragraph(text, x, top, max_width, size=10, color=ink, bold=False, leading=None):
        style = ParagraphStyle(
            "body", fontName="ReportBold" if bold else "Report", fontSize=size,
            leading=leading or size * 1.5, textColor=color, alignment=TA_LEFT,
            spaceAfter=0,
        )
        p = Paragraph(text, style)
        _, block_height = p.wrap(max_width, height)
        p.drawOn(c, x, top - block_height)
        return top - block_height

    def footer(page):
        c.setStrokeColor(border)
        c.line(margin, 43, width - margin, 43)
        c.setFont("Report", 8)
        c.setFillColor(muted)
        c.drawString(margin, 28, "RyanGunshop  /  Dokumentasi visual Android")
        c.drawRightString(width - margin, 28, f"{page} / 7")

    def heading(page, title, subtitle):
        c.setFillColor(slate)
        c.setFont("ReportBold", 10)
        c.drawString(margin, height - 47, "RYANGUNSHOP")
        paragraph(title, margin, height - 69, width - 2 * margin, 25, dark, True)
        paragraph(subtitle, margin, height - 110, width - 2 * margin, 10, muted)
        footer(page)

    def screenshot(name, x, top, display_height):
        # Keep the complete emulator frame and its original aspect ratio.
        from PIL import Image
        path = SCREENSHOTS / f"{name}.png"
        with Image.open(path) as image:
            display_width = display_height * image.width / image.height
        c.drawImage(str(path), x, top - display_height, width=display_width,
                    height=display_height, preserveAspectRatio=True, mask="auto")
        return display_width

    # 1: Cover, with a genuine splash screenshot rather than a mockup.
    c.setFillColor(dark)
    c.rect(0, height - 191, width, 191, stroke=0, fill=1)
    paragraph("RyanGunshop", margin, height - 43, 450, 29, colors.white, True)
    paragraph("Laporan visual pembukaan aplikasi", margin, height - 94,
              480, 18, colors.white, True)
    paragraph("Animasi masuk, splash logo, onboarding, dan dashboard",
              margin, height - 131, 480, 11, light)
    screenshot("04_splash_logo", 329, height - 222, 425)
    top = height - 229
    top = paragraph("Tujuan dokumentasi", margin, top, 242, 15, dark, True) - 13
    top = paragraph("Mendokumentasikan tampilan aktual aplikasi ketika dibuka, "
                    "mulai dari transisi Android, splash logo, tiga halaman "
                    "onboarding, hingga dashboard.",
                    margin, top, 242) - 25
    top = paragraph("Sumber screenshot", margin, top, 242, 12, dark, True) - 9
    top = paragraph("Rekaman emulator Pixel 7<br/>Frame asli: 1080 x 2400 px<br/>"
                    "Build: Android debug x64<br/>Rekaman: 17 September 2026",
                    margin, top, 242, 10, muted) - 25
    top = paragraph("Identitas visual", margin, top, 242, 12, dark, True) - 9
    paragraph("Logo resmi dari pengguna. Antarmuka mempertahankan Slate Blue "
              "dan splash menggunakan latar gelap agar logo terbaca jelas.",
              margin, top, 242, 10, muted)
    paragraph("Urutan pembukaan", margin, 165, 480, 13, dark, True)
    paragraph("Animasi sistem Android &rarr; Native launch &rarr; "
              "Splash Flutter &rarr; Onboarding 1-3 &rarr; Dashboard",
              margin, 141, 490, 10)
    paragraph("Catatan: ini laporan visual, bukan hasil benchmark startup atau FPS. "
              "Screenshot adalah frame nyata dari rekaman, bukan desain simulasi.",
              margin, 102, 490, 8.5, muted)
    footer(1)
    c.showPage()

    # 2: System entry and native screen.
    heading(2, "Tampilan masuk aplikasi", "Tahap pertama ketika aplikasi dibuka dari Android.")
    shot_height = 425
    shot_width = shot_height * 1080 / 2400
    x1 = 75
    x2 = width - 75 - shot_width
    screenshot("01_animasi_masuk", x1, 670, shot_height)
    screenshot("02_native_launch", x2, 670, shot_height)
    paragraph("1. Animasi masuk Android", x1, 226, shot_width, 11, dark, True)
    paragraph("Frame transisi dari layar perangkat menuju aplikasi. "
              "Animasi sistem bergantung pada versi Android dan launcher.",
              x1, 202, shot_width, 9, muted)
    paragraph("2. Native launch screen", x2, 226, shot_width, 11, dark, True)
    paragraph("Logo tampil di tengah pada latar Slate Blue saat Flutter "
              "menyiapkan tampilan pertamanya. Area aman mencegah logo terpotong.",
              x2, 202, shot_width, 9, muted)
    paragraph("Frame aktual dipilih dari sampling rekaman 4 frame/detik. "
              "Screenshot ini bukan pengukuran durasi startup.",
              margin, 103, 490, 8.5, muted)
    c.showPage()

    # 3: Two moments of the Flutter splash sequence.
    heading(3, "Splash screen dan animasi logo", "Satu animasi utama; logo, teks, dan status muncul berurutan.")
    screenshot("03_splash_awal", x1, 670, shot_height)
    screenshot("04_splash_logo", x2, 670, shot_height)
    paragraph("3. Fase awal splash Flutter", x1, 226, shot_width, 11, dark, True)
    paragraph("Logo resmi masuk dengan scale dan fade halus. Latar gelap "
              "beraksen Slate Blue menjaga fokus pada identitas aplikasi.",
              x1, 202, shot_width, 9, muted)
    paragraph("4. Splash dengan status loading", x2, 226, shot_width, 11, dark, True)
    paragraph("Tagline dan spinner melengkapi splash: 'Kasir cerdas untuk warung "
              "Anda' dan 'Menyiapkan ruang kerja'.", x2, 202, shot_width, 9, muted)
    paragraph("Konfigurasi implementasi: scale logo 0,86 &rarr; 1,00; "
              "controller 900 ms; splash gate 1.450 ms; dashboard crossfade 280 ms. "
              "Reduced motion menghilangkan transisi animasi.",
              margin, 117, 490, 9, muted)
    c.showPage()

    def onboarding_detail(page, image_name, title, subtitle, description, points):
        heading(page, title, subtitle)
        screenshot(image_name, 55, 688, 548)
        detail_x = 329
        detail_width = width - margin - detail_x
        detail_top = paragraph(
            "Tujuan halaman", detail_x, 675, detail_width, 15, dark, True
        ) - 12
        detail_top = paragraph(
            description, detail_x, detail_top, detail_width, 10
        ) - 24
        detail_top = paragraph(
            "Elemen utama", detail_x, detail_top, detail_width, 12, dark, True
        ) - 9
        detail_top = paragraph(
            "<br/>".join(points), detail_x, detail_top, detail_width, 9, muted
        ) - 24
        detail_top = paragraph(
            "Perilaku", detail_x, detail_top, detail_width, 12, dark, True
        ) - 9
        paragraph(
            "Pengguna dapat menggeser halaman, memilih Lewati, atau menekan "
            "Lanjut/Mulai. Status selesai disimpan lokal agar onboarding tidak "
            "muncul berulang kali.",
            detail_x, detail_top, detail_width, 9, muted,
        )
        c.showPage()

    # 4-6: First-run onboarding, based on final emulator screenshots.
    onboarding_detail(
        4,
        "06_onboarding_scan",
        "Onboarding 1 — Pindai barang",
        "Nilai pertama: memasukkan produk ke transaksi dengan cepat.",
        "Pengguna memahami bahwa kamera memindai satu produk, kemudian hasil "
        "harus dikonfirmasi sebelum masuk ke keranjang.",
        [
            "Ilustrasi pemindai produk",
            "Indikator halaman 1 dari 3",
            "Tombol Lewati dan Lanjut",
        ],
    )
    onboarding_detail(
        5,
        "07_onboarding_layout",
        "Onboarding 2 — Tata letak warung",
        "Menjelaskan hubungan denah digital dengan kondisi warung.",
        "Pengguna diperkenalkan pada penyusunan rak, lemari, kulkas, dan meja "
        "kasir agar barang mudah ditemukan.",
        [
            "Rak A dan Rak B",
            "Kulkas dan meja kasir",
            "Indikator halaman 2 dari 3",
        ],
    )
    onboarding_detail(
        6,
        "08_onboarding_payment",
        "Onboarding 3 — Pembayaran",
        "Menutup pengenalan dengan alur pembayaran dan stok.",
        "Pengguna mengetahui bahwa aplikasi mendukung tunai dan QRIS dinamis, "
        "kemudian menyimpan transaksi serta memperbarui stok.",
        [
            "Contoh total Rp42.500",
            "QRIS dan opsi tunai",
            "Tombol Mulai untuk masuk aplikasi",
        ],
    )

    # 7: The end of the opening flow.
    heading(
        7,
        "Transisi selesai ke dashboard",
        "Hasil akhir setelah splash dan onboarding selesai.",
    )
    screenshot("05_dashboard", 71, 680, 535)
    side_x = 339
    side_width = width - margin - side_x
    top = paragraph("Dashboard aktif", side_x, 670, side_width, 16, dark, True) - 13
    top = paragraph("Logo resmi konsisten pada app bar. Pengguna dapat "
                    "melanjutkan ke kasir, produk, atau pengaturan tata letak.",
                    side_x, top, side_width, 10) - 24
    top = paragraph("Yang terlihat", side_x, top, side_width, 12, dark, True) - 9
    top = paragraph("Tombol Mulai pindai<br/>Akses Kasir / Produk / Tata letak<br/>"
                    "Peta warung dan pilihan Denah / 360&deg;<br/>Navigasi bawah",
                    side_x, top, side_width, 9, muted) - 24
    top = paragraph("Hasil pemeriksaan", side_x, top, side_width, 12, dark, True) - 9
    paragraph("Build debug x64 berhasil.<br/>Aplikasi terpasang dan berjalan "
              "di emulator.<br/>Flutter analyze: tanpa masalah.<br/>11 test berhasil, "
              "termasuk first-run dan layar 360 x 640.",
              side_x, top, side_width, 9, muted)
    paragraph("Lampiran sumber", margin, 116, 490, 11, dark, True)
    paragraph("Screenshot lengkap: reports/screenshots/<br/>"
              "Video: .artifacts/ryangunshop-logo-animation.mp4<br/>"
              "Implementasi splash: mobile/lib/features/splash/presentation/splash_gate.dart<br/>"
              "Implementasi onboarding: mobile/lib/features/onboarding/presentation/",
              margin, 94, 490, 8, muted, leading=11)
    c.save()
    print(f"PDF: {PDF_PATH}")


def verify_pdf():
    import pymupdf
    from PIL import Image

    with pymupdf.open(PDF_PATH) as document:
        assert len(document) == 7, "Unexpected page count"
        previews = []
        for index, page in enumerate(document):
            assert len(page.get_images()) >= 1, f"Page {index + 1}: no screenshot"
            assert page.get_text().strip(), f"Page {index + 1}: no text"
            for block in page.get_text("blocks"):
                x0, y0, x1, y1 = block[:4]
                assert x0 >= 0 and y0 >= 0, "Text outside page"
                assert x1 <= page.rect.width and y1 <= page.rect.height, "Text overflow"
            pixmap = page.get_pixmap(matrix=pymupdf.Matrix(1, 1), alpha=False)
            previews.append(Image.frombytes("RGB", (pixmap.width, pixmap.height), pixmap.samples))
        cell_width, cell_height = previews[0].size
        rows = (len(previews) + 1) // 2
        sheet = Image.new(
            "RGB",
            (cell_width * 2 + 24, cell_height * rows + 24 * (rows - 1)),
            "#d9dae6",
        )
        for index, preview in enumerate(previews):
            sheet.paste(preview, ((index % 2) * (cell_width + 24), (index // 2) * (cell_height + 24)))
        preview_path = ROOT / ".artifacts" / "ryangunshop-laporan-pdf-preview.png"
        sheet.save(preview_path)
        print(f"Verified: {len(document)} pages, screenshots and text present; no text overflow")
        print(f"Preview: {preview_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--frames-only", action="store_true")
    args = parser.parse_args()
    extract_frames()
    if not args.frames_only:
        create_pdf()
        verify_pdf()
