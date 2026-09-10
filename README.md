# tuw-thesis

A Typst port of [`vutinfth`](https://gitlab.com/ThomasAUZINGER/vutinfth), the LaTeX class
by Thomas Auzinger used for theses at TU Wien Informatics.

The goal is a document that is hard to tell apart from the LaTeX original: the same page
geometry, the same fonts at the same sizes, memoir's `veelo` chapter openers, the `Ruled`
running heads that reach into the outer margin, and the official title page down to the
position of the signature rules.

## Quick start

```bash
typst compile --font-path fonts --root . template/thesis.typ
```

Edit `template/thesis.typ` — it carries the metadata for the title pages — and put your
chapters in `template/content/`.

`--font-path fonts` matters: the title page is set in Helvetica and the address line under
it in Latin Modern Sans, neither of which Typst bundles. Without the flag the document
still compiles, but those two fall back to whatever sans is installed.

## Building without a Typst binary

`scripts/build.py` drives the compiler through the `typst` Python package, so a Python
virtual environment is all you need:

```bash
python -m venv .venv
./.venv/Scripts/python.exe -m pip install -r requirements.txt   # Windows / Git Bash
./.venv/bin/python -m pip install -r requirements.txt           # macOS / Linux

./.venv/Scripts/python.exe scripts/build.py --render
```

`--render` also rasterises the pages to `build/pages/`, which is how the layout was checked
against the reference PDF.

## Layout

```
src/
  lib.typ            the thesis() entry point and the document-wide defaults
  layout.typ         page geometry, derived from the geometry package's defaults
  fonts.typ          font stacks and the size scale vutinfth defines
  title-page.typ     \AddTitlePage
  statement-page.typ \AddStatementPage
  headings.typ       the veelo chapter opener and the section levels
  page-style.typ     running heads, folios, and \cleardoublepage
  outlines.typ       table of contents, list of figures, list of tables
  matter.typ         \frontmatter, \mainmatter, \backmatter, appendix
  i18n/              the class's own German and English wording
template/            what you copy to start a thesis
fonts/               TeX Gyre Heros, TeX Gyre Cursor, Latin Modern Sans
```

`front-matter`, `main-matter`, `back-matter` and `appendix` are applied as show rules, so
the document reads like the LaTeX one:

```typst
#show: main-matter
```

## How closely it matches

Measured against `example-ref.pdf`, the reference output shipped with the LaTeX class,
every horizontal position on the title page lands within half a point, and the vertical
positions within about two. The chapter opener — the small-caps "Chapter", the oversized
numeral hanging into the margin and the block that runs off the paper — matches to within a
point, as do the running heads, the folios and the table of contents columns.

Two differences are inherent rather than incidental:

- **Font metrics.** The body is set in New Computer Modern, which Typst bundles and which
  is the maintained successor of Latin Modern. Its bold is about 2% wider than the Type 1
  Latin Modern the reference was built with, and its small caps about 7% narrower, so
  individual words differ slightly in width even though sizes and positions agree.
- **Line breaking.** Typst and TeX break paragraphs differently, so a given paragraph will
  not always occupy the same number of lines.

## Fonts

`fonts/` carries the faces the LaTeX class selects, so that they need not be installed:

| File | Stands in for | Licence |
| --- | --- | --- |
| `texgyreheros-*.otf` | `helvet` (URW Nimbus Sans) | GUST Font License |
| `texgyrecursor-*.otf` | `courier` (URW Nimbus Mono) | GUST Font License |
| `lmsans10-*.otf` | Latin Modern Sans | GUST Font License |

The body font, New Computer Modern, ships with Typst itself.

Compiling prints `unknown font family` warnings for the fallback entries in each stack that
are not installed on the machine — `Helvetica`, `Nimbus Sans` and so on. They are harmless;
the stacks exist so the document degrades sensibly elsewhere.

## Licence

MIT, see `LICENSE`. The TU Wien Informatics logo in `src/assets/` is copyright of TU Wien
and is included on the same basis as in the original class.
