"""
Parse EasyOCR output into structured course candidates from a timetable screenshot.

Run:
    cd backend
    python scripts/ocr_parser.py tests/fixtures/screenshots/0FEC4C4FC94F15D9913C4C364704023A.png
"""

import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional


@dataclass
class TextBlock:
    text: str
    x: float
    y: float
    w: float
    h: float
    confidence: float


@dataclass
class CourseCandidate:
    name: str
    location: str = ""
    day_of_week: int = 1
    start_period: int = 1
    end_period: int = 1
    weeks: str = "1-16"
    week_rule: str = "all"
    confidence: float = 0.0


WEEKDAY_NAMES = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
LOCATION_MARKERS = ["楼", "馆", "教", "场", "机房", "实验室", "逸", "仙林", "鼓楼"]


# ── Step 0: OCR ──────────────────────────────────────────────────────

def run_ocr(image_path: str) -> list[TextBlock]:
    import easyocr
    reader = easyocr.Reader(["ch_sim", "en"], gpu=False)
    results = reader.readtext(image_path)
    blocks = []
    for box, text, conf in results:
        if conf < 0.25 or not text.strip():
            continue
        xs = [p[0] for p in box]
        ys = [p[1] for p in box]
        blocks.append(TextBlock(
            text=text.strip(),
            x=sum(xs) / 4, y=sum(ys) / 4,
            w=max(xs) - min(xs), h=max(ys) - min(ys),
            confidence=conf,
        ))
    return blocks


# ── Step 1: Detect grid ──────────────────────────────────────────────

def detect_grid(blocks: list[TextBlock], image_w: int) -> tuple[list[float], list[float]]:
    """Find day column edges and period row edges."""
    # Column edges: use day-name positions to find left edge of grid, then evenly divide
    day_xs: list[float] = []
    for b in blocks:
        if b.text in WEEKDAY_NAMES:
            day_xs.append(b.x)

    if len(day_xs) >= 7:
        # Grid starts at the midpoint between the "time" labels (x≈100) and "周一"
        time_labels_x = [b.x for b in blocks
                         if b.text.startswith("第") and "节" in b.text]
        time_label_x = min(time_labels_x) if time_labels_x else 100
        grid_left = (time_label_x + day_xs[0]) / 2
        col_width = (day_xs[-1] - grid_left) / 6.5  # approx
        col_edges = [0.0]  # time column (left of grid)
        for i in range(8):
            col_edges.append(grid_left + i * col_width)
        col_edges.append(99999.0)
    else:
        # Fallback
        margin = image_w * 0.10
        col_w = (image_w - margin) / 7
        col_edges = [0.0]
        for i in range(8):
            col_edges.append(margin + i * col_w)
        col_edges.append(99999.0)

    # Row edges from period labels (第N节)
    period_blocks = [b for b in blocks
                     if b.text.startswith("第") and "节" in b.text]
    period_blocks.sort(key=lambda b: b.y)

    row_edges = [0.0]
    if len(period_blocks) >= 2:
        for i in range(len(period_blocks) - 1):
            row_edges.append((period_blocks[i].y + period_blocks[i + 1].y) / 2)
    else:
        # Fallback: 12 rows evenly spaced
        period_y = sorted(
            {b.y for b in blocks if 0 < b.y < 5000},
        )[:24]
        if len(period_y) >= 2:
            for i in range(len(period_y) - 1):
                row_edges.append((period_y[i] + period_y[i + 1]) / 2)
    row_edges.append(99999.0)

    return col_edges, row_edges


# ── Step 2: Assign to cells ──────────────────────────────────────────

def assign_to_cells(
    blocks: list[TextBlock], col_edges: list[float], row_edges: list[float]
) -> dict[tuple[int, int], list[TextBlock]]:
    cells: dict[tuple[int, int], list[TextBlock]] = {}
    for b in blocks:
        col = _bin(b.x, col_edges)
        row = _bin(b.y, row_edges)
        if col < 0 or row < 0 or col > 7:
            continue
        key = (col, row)
        cells.setdefault(key, []).append(b)
    return cells


def _bin(v: float, edges: list[float]) -> int:
    for i in range(len(edges) - 1):
        if edges[i] <= v < edges[i + 1]:
            return i
    return -1


# ── Step 3: Extract courses ──────────────────────────────────────────

def extract_courses(
    cells: dict[tuple[int, int], list[TextBlock]],
) -> list[CourseCandidate]:
    courses: list[CourseCandidate] = []

    for col in range(1, 8):
        row = 0
        while row < 12:
            key = (col, row)
            if key not in cells:
                row += 1
                continue

            # Start of a course block
            start_row = row
            all_blocks = list(cells[key])
            end_row = start_row

            # Extend downward if subsequent rows in same column have content
            # AND the content looks like it belongs to the same course
            for nr in range(row + 1, 12):
                nkey = (col, nr)
                if nkey not in cells:
                    break
                # Merge if the blocks look like continuation text (not a new course)
                nblocks = cells[nkey]
                ntext = "".join(b.text for b in nblocks)
                # A new row that starts with a period label means a new section
                if ntext.startswith("第") and "节" in ntext:
                    break
                # A new row with a time range means a different period
                if "-" in ntext and ":" in ntext and len(ntext) <= 12:
                    break
                all_blocks.extend(nblocks)
                end_row = nr

            candidate = _build_candidate(all_blocks, col, start_row, end_row)
            if candidate and candidate.name:
                courses.append(candidate)

            row = end_row + 1

    # Deduplicate: merge courses that appear in the same period range on the same day
    return _deduplicate(courses)


def _build_candidate(
    blocks: list[TextBlock], col: int, start_row: int, end_row: int
) -> Optional[CourseCandidate]:
    blocks = sorted(blocks, key=lambda b: (b.y, b.x))
    conf = sum(b.confidence for b in blocks) / len(blocks) if blocks else 0

    # Merge adjacent text blocks with same rough y-position into lines
    lines: list[list[TextBlock]] = []
    for b in blocks:
        if lines and abs(b.y - lines[-1][0].y) < b.h * 1.5:
            lines[-1].append(b)
        else:
            lines.append([b])
        lines[-1].sort(key=lambda x: x.x)

    # Combine lines into name and location
    name_parts: list[str] = []
    loc_parts: list[str] = []

    for line in lines:
        line_text = "".join(b.text for b in line)
        # Skip period labels, time ranges, pure numbers
        if any(
            line_text.startswith(p) for p in ["第", "08", "09", "10", "11", "12",
                                                "13", "14", "15", "16", "17",
                                                "18", "19", "20", "21", "22"]
        ):
            continue
        if line_text in WEEKDAY_NAMES:
            continue

        has_loc = any(m in line_text for m in LOCATION_MARKERS)
        is_short_code = len(line_text) <= 6 and any(c.isdigit() for c in line_text)

        if has_loc or is_short_code:
            loc_parts.append(line_text)
        else:
            # Filter out obvious noise
            if len(line_text) >= 2 and line_text not in ("次)", "1(", "(", ")"):
                name_parts.append(line_text)

    name = "".join(name_parts).strip()
    location = "".join(loc_parts).strip()

    # Skip if name looks like metadata/header
    if not name or len(name) < 2:
        return None
    for kw in ["课表", "学年", "学期", "06/", "06月", "全部课程", "第15周"]:
        if kw in name:
            return None

    return CourseCandidate(
        name=name, location=location,
        day_of_week=col, start_period=start_row + 1, end_period=end_row + 1,
        confidence=round(conf, 2),
    )


def _deduplicate(courses: list[CourseCandidate]) -> list[CourseCandidate]:
    """Remove courses that are zero-width or near-duplicates."""
    result = []
    for c in courses:
        if c.start_period > c.end_period:
            continue
        if not c.name or len(c.name) < 2:
            continue
        result.append(c)
    return result


# ── Step 4: Output ───────────────────────────────────────────────────

def print_courses(courses: list[CourseCandidate]) -> None:
    print(f"\n{'─' * 70}")
    print(f"  {'课程名称':<18} {'地点':<16} {'时间':<16} {'置信度'}")
    print(f"{'─' * 70}")
    for c in courses:
        day = WEEKDAY_NAMES[c.day_of_week - 1]
        period = f"{day} 第{c.start_period}-{c.end_period}节"
        print(f"  {c.name:<18} {c.location:<16} {period:<16} {c.confidence:.2f}")
    print(f"{'─' * 70}")
    print(f"  共 {len(courses)} 门候选课程\n")


def print_json(courses: list[CourseCandidate]) -> None:
    import json
    data = [{
        "name": c.name, "location": c.location,
        "dayOfWeek": c.day_of_week,
        "startPeriod": c.start_period, "endPeriod": c.end_period,
        "weeks": c.weeks, "weekRule": c.week_rule,
        "confidence": c.confidence,
    } for c in courses]
    print(json.dumps(data, ensure_ascii=False, indent=2))


# ── Main ─────────────────────────────────────────────────────────────

def main(image_path: str, json_output: bool = False) -> None:
    img = Path(image_path)
    if not img.exists():
        print(f"File not found: {image_path}")
        sys.exit(1)

    from PIL import Image
    w, _ = Image.open(img).size

    print(f"=== NJU Timenote OCR Parser ===\nImage: {img.name} ({w}px)")

    print("[1/4] Running OCR...")
    blocks = run_ocr(str(img))
    print(f"  {len(blocks)} text blocks detected")

    print("[2/4] Detecting grid...")
    col_edges, row_edges = detect_grid(blocks, w)

    print("[3/4] Assigning to cells...")
    cells = assign_to_cells(blocks, col_edges, row_edges)
    print(f"  {len(cells)} non-empty cells")

    print("[4/4] Extracting courses...")
    courses = extract_courses(cells)

    if json_output:
        print_json(courses)
    else:
        print_courses(courses)


if __name__ == "__main__":
    json_flag = "--json" in sys.argv
    args = [a for a in sys.argv[1:] if a != "--json"]
    if len(args) < 1:
        print("Usage: python scripts/ocr_parser.py <image_path> [--json]")
        sys.exit(1)
    main(args[0], json_output=json_flag)
