#!/usr/bin/env python
"""Check that the options a thesis is expected to set actually take effect.

Compiles a small document once per language arrangement and once per reference style, and
asserts on the text that comes out. Run it alongside check_layout.py after changing src/.

    ./.venv/Scripts/python.exe tests/check_variants.py     # Windows / Git Bash
    ./.venv/bin/python tests/check_variants.py             # macOS / Linux
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

import pymupdf  # noqa: E402
import typst  # noqa: E402

WORK = ROOT / "build" / "variants"

DOCUMENT = """#import "/src/lib.typ": *

#show: thesis.with(
  lang: "{lang}",
  secondary-lang: {secondary},
  title: (en: "An English Title", de: "Ein deutscher Titel"),
  thesis-type: "{thesis_type}",
  master-degree: "{master_degree}",
  doctor-degree: {doctor_degree},
  curriculum: (en: "Curriculum", de: "Studium"),
  author: (name: "Ada Lovelace", student-number: "0123456", gender: "{gender}"),
  advisor: (name: "Charles Babbage"),
  reviewers: {reviewers},
  reference-style: "{style}",
  date: datetime(year: 2001, month: 1, day: 1),
)

{summaries}

#toc("{lang}")

#show: main-matter

= A Chapter

A citation: @lamport1994latex.

#show: back-matter

#bibliography("/template/refs.bib")
"""

SUMMARY = '#abstract("{lang}")[Some text.]\n'

failures: list[str] = []


def check(label: str, condition: bool, detail: str = "") -> None:
    print(f"  {'ok  ' if condition else 'FAIL'} {label}{'  — ' + detail if detail else ''}")
    if not condition:
        failures.append(label)


def render(
    name: str,
    lang: str,
    secondary: str | None,
    style: str,
    summaries: list[str],
    thesis_type: str = "master",
    master_degree: str = "dipl.",
    doctor_degree: str = "none",
    gender: str = "female",
    reviewers: str = "()",
) -> str:
    WORK.mkdir(parents=True, exist_ok=True)
    source = WORK / f"{name}.typ"
    source.write_text(
        DOCUMENT.format(
            lang=lang,
            secondary=f'"{secondary}"' if secondary else "none",
            style=style,
            summaries="".join(SUMMARY.format(lang=s) for s in summaries),
            thesis_type=thesis_type,
            master_degree=master_degree,
            doctor_degree=doctor_degree,
            gender=gender,
            reviewers=reviewers,
        ),
        encoding="utf-8",
    )
    output = WORK / f"{name}.pdf"
    typst.compile(
        str(source),
        output=str(output),
        root=str(ROOT),
        font_paths=[str(ROOT / "template" / "fonts")],
    )
    doc = pymupdf.open(output)
    # Headings wrap, so collapse whitespace before matching against them.
    return " ".join("\n".join(page.get_text() for page in doc).split())


def title_page_rules(name: str) -> list[tuple[float, float, float]]:
    """The signature and reviewer rules on the first title page, top to bottom."""
    doc = pymupdf.open(WORK / f"{name}.pdf")
    rules = [
        (round(d["rect"].y0, 2), round(d["rect"].x0, 2), round(d["rect"].x1, 2))
        for d in doc[0].get_drawings()
        # Below the advisor block and above the rule over the address in the foot.
        if 540 < d["rect"].y0 < 775 and d["rect"].width > 40
    ]
    return sorted(rules)


def main() -> int:
    print("\nlanguage arrangements")

    text = render("en-de", "en", "de", "alpha", ["en", "de"])
    check("English thesis prints both title pages", "DIPLOMARBEIT" in text and "DIPLOMA THESIS" in text)
    check("English thesis has both summaries", "Abstract" in text and "Kurzfassung" in text)
    check("English declaration of authorship", "Declaration of Authorship" in text)
    check("English contents", "Contents" in text)

    text = render("de-en", "de", "en", "alpha", ["de", "en"])
    check("German thesis prints both title pages", "DIPLOMARBEIT" in text and "DIPLOMA THESIS" in text)
    check("German declaration of authorship", "Erklärung zur Verfassung der Arbeit" in text)
    check("German contents", "Inhaltsverzeichnis" in text)
    check("German bibliography heading", "Literaturverzeichnis" in text)

    text = render("en-only", "en", None, "alpha", ["en"])
    check("English-only prints one title page", "DIPLOMA THESIS" in text and "DIPLOMARBEIT" not in text)
    check("English-only has no Kurzfassung", "Kurzfassung" not in text)

    text = render("de-only", "de", None, "alpha", ["de"])
    check("German-only prints one title page", "DIPLOMARBEIT" in text and "DIPLOMA THESIS" not in text)
    check("German-only has no Abstract chapter", "Abstract" not in text)

    print("\ndegrees derived from the thesis type and the author's gender")
    for label, kwargs, cover, awarded in (
        ("bachelor", dict(thesis_type="bachelor"), "BACHELOR'S THESIS", "Bachelor of Science"),
        (
            "master + dipl., female",
            dict(thesis_type="master", master_degree="dipl.", gender="female"),
            "DIPLOMA THESIS",
            "Diplom-Ingenieurin",
        ),
        (
            "master + dipl., male",
            dict(thesis_type="master", master_degree="dipl.", gender="male"),
            "DIPLOMA THESIS",
            "Diplom-Ingenieur",
        ),
        (
            "master + master",
            dict(thesis_type="master", master_degree="master"),
            "MASTER'S THESIS",
            "Master of Science",
        ),
        (
            "master + rer.nat., female",
            dict(thesis_type="master", master_degree="rer.nat.", gender="female"),
            "MASTER'S THESIS",
            "Magistra der Naturwissenschaften",
        ),
        (
            "doctor + techn., male",
            dict(thesis_type="doctor", doctor_degree='"techn."', gender="male"),
            "DISSERTATION",
            "Doktor der Technischen Wissenschaften",
        ),
    ):
        text = render(f"degree-{len(failures)}-{label[:8]}", "en", None, "alpha", ["en"], **kwargs)
        check(f"{label} — cover says {cover}", cover in text)
        check(f"{label} — awards {awarded}", awarded in text)

    print("\ndissertation title page")
    render(
        "dissertation",
        "en",
        "de",
        "alpha",
        ["en"],
        thesis_type="doctor",
        doctor_degree='"techn."',
        reviewers='((name: "Grace Hopper"), (name: "Alan Turing"))',
    )
    rules = title_page_rules("dissertation")
    # Two reviewer fields, then the author's alone at the outer edge: the class has a
    # dissertation signed by its author only, where a thesis is signed by author and advisor.
    check("dissertation has three rules", len(rules) == 3, f"got {len(rules)}")
    if len(rules) == 3:
        check("first reviewer field", rules[0][1:] == (223.94, 368.5), str(rules[0][1:]))
        check("second reviewer field", rules[1][1:] == (382.68, 527.24), str(rules[1][1:]))
        check("author signs alone, outer edge", rules[2][1:] == (382.68, 527.24), str(rules[2][1:]))

    print("\nreference styles")
    for style, expected, unexpected in (
        ("alpha", "[Lam94]", "[1]"),
        ("numeric", "[1]", "[Lam94]"),
        ("acm", "[1]", "[Lam94]"),
    ):
        text = render(f"style-{style}", "en", None, style, ["en"])
        check(f"{style} cites as {expected}", expected in text and unexpected not in text)

    print()
    if failures:
        print(f"{len(failures)} check(s) failed: {', '.join(failures)}")
        return 1
    print("all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
