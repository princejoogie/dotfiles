#!/usr/bin/env python3
"""Run OCR over screenshot files using the local tesseract CLI."""

from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path


IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".tif", ".tiff", ".bmp", ".webp"}


def image_files(path: Path) -> list[Path]:
    if path.is_file():
        return [path]
    return sorted(p for p in path.rglob("*") if p.suffix.lower() in IMAGE_EXTS)


def main() -> int:
    parser = argparse.ArgumentParser(description="OCR screenshot images with tesseract.")
    parser.add_argument("input", help="Screenshot file or directory.")
    parser.add_argument("--output-dir", required=True, help="Directory for OCR .txt files.")
    parser.add_argument("--lang", default="eng", help="Tesseract language, default: eng.")
    parser.add_argument("--index", default="ocr-notes.md", help="Markdown OCR index path.")
    parser.add_argument("--overwrite", action="store_true", help="Overwrite existing OCR text files.")
    args = parser.parse_args()

    if not shutil.which("tesseract"):
        raise SystemExit("tesseract is required for OCR but was not found on PATH.")

    source = Path(args.input).expanduser()
    if not source.exists():
        raise SystemExit(f"Input not found: {source}")
    out_dir = Path(args.output_dir).expanduser()
    out_dir.mkdir(parents=True, exist_ok=True)

    rows: list[tuple[Path, Path]] = []
    for image in image_files(source):
        out_base = out_dir / image.stem
        out_txt = out_base.with_suffix(".txt")
        if out_txt.exists() and not args.overwrite:
            rows.append((image, out_txt))
            continue
        cmd = ["tesseract", str(image), str(out_base), "-l", args.lang]
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        rows.append((image, out_txt))

    index = Path(args.index).expanduser()
    lines = ["# OCR Notes", "", "| Image | OCR Text |", "|---|---|"]
    for image, text_file in rows:
        lines.append(f"| `{image.name}` | `{text_file}` |")
    index.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(index)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
