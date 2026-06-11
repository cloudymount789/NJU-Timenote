"""
OCR experiment: test EasyOCR on a timetable screenshot.

Run:
    cd backend
    python scripts/ocr_experiment.py tests/fixtures/screenshots/0FEC4C4FC94F15D9913C4C364704023A.png
"""

import sys
from pathlib import Path


def main(image_path: str) -> None:
    img = Path(image_path)
    if not img.exists():
        print(f"File not found: {image_path}")
        sys.exit(1)

    print(f"=== NJU Timenote OCR Experiment (EasyOCR) ===")
    print(f"Image: {img.name} ({img.stat().st_size / 1024:.0f} KB)")
    print()

    # ── Step 1: Load image ────────────────────────────────────────
    from PIL import Image

    pil_img = Image.open(img)
    w, h = pil_img.size
    print(f"Size: {w}x{h}")
    print()

    # ── Step 2: OCR ────────────────────────────────────────────────
    print("Running EasyOCR (first run downloads model ~100 MB)...")
    print()

    import easyocr

    reader = easyocr.Reader(["ch_sim", "en"], gpu=False)
    results = reader.readtext(str(img))

    # ── Step 3: Print results ───────────────────────────────────────
    if not results:
        print("No text detected.")
        return

    # Sort by y-position, then x-position (top-to-bottom, left-to-right)
    results.sort(key=lambda r: (r[0][0][1], r[0][0][0]))

    print(f"Detected {len(results)} text blocks:\n")

    for i, (box, text, confidence) in enumerate(results):
        center_y = sum(p[1] for p in box) / 4
        center_x = sum(p[0] for p in box) / 4
        height = max(p[1] for p in box) - min(p[1] for p in box)
        print(
            f"  [{i:3d}] "
            f"y={center_y:6.0f}  x={center_x:6.0f}  "
            f"h={height:4.0f}  conf={confidence:.2f}  "
            f'"{text}"'
        )

    print()
    print(f"=== Done ({len(results)} blocks) ===")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python scripts/ocr_experiment.py <image_path>")
        sys.exit(1)
    main(sys.argv[1])
