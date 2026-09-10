#!/usr/bin/env python
"""Build the template and, optionally, compare the result against the LaTeX reference.

The Typst compiler and the PDF tooling both come from the project virtual environment, so
nothing has to be installed system-wide:

    python -m venv .venv
    ./.venv/Scripts/python.exe -m pip install -r requirements.txt   # Windows / Git Bash
    ./.venv/bin/python -m pip install -r requirements.txt           # macOS / Linux

Usage:
    python scripts/build.py                     # build template/thesis.typ -> build/thesis.pdf
    python scripts/build.py --render            # also rasterise every page to build/pages/
    python scripts/build.py --render --pages 1-8
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FONT_DIR = ROOT / "fonts"
DEFAULT_INPUT = ROOT / "template" / "thesis.typ"
DEFAULT_OUTPUT = ROOT / "build" / "thesis.pdf"


def parse_pages(spec: str, last: int) -> list[int]:
    pages: list[int] = []
    for part in spec.split(","):
        if "-" in part:
            start, end = part.split("-")
            pages.extend(range(int(start), int(end) + 1))
        else:
            pages.append(int(part))
    return [p for p in pages if 1 <= p <= last]


def build(source: Path, output: Path) -> None:
    import typst

    output.parent.mkdir(parents=True, exist_ok=True)
    typst.compile(str(source), output=str(output), root=str(ROOT), font_paths=[str(FONT_DIR)])
    print(f"built {output.relative_to(ROOT)}")


def render(pdf: Path, outdir: Path, pages: str | None, dpi: int) -> None:
    import pymupdf

    doc = pymupdf.open(pdf)
    outdir.mkdir(parents=True, exist_ok=True)
    selected = parse_pages(pages, doc.page_count) if pages else range(1, doc.page_count + 1)
    for number in selected:
        image = outdir / f"p{number:02d}.png"
        doc[number - 1].get_pixmap(dpi=dpi).save(image)
    print(f"rendered {len(list(selected))} page(s) to {outdir.relative_to(ROOT)}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", nargs="?", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("-o", "--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--render", action="store_true", help="rasterise the pages to PNG")
    parser.add_argument("--pages", help="page selection for --render, e.g. 1-8,15")
    parser.add_argument("--dpi", type=int, default=110)
    args = parser.parse_args()

    build(args.source, args.output)
    if args.render:
        render(args.output, args.output.parent / "pages", args.pages, args.dpi)
    return 0


if __name__ == "__main__":
    sys.exit(main())
