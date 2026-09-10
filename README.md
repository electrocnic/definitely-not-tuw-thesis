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

Everything a thesis needs to set lives at the top of `template/thesis.typ`; the chapters go
in `template/content/`. `template/content/template-tour.typ` is a chapter that exercises
every element the template supports — read it once, then delete it.

`--font-path fonts` matters: the title page is set in Helvetica and the address line under
it in Latin Modern Sans, neither of which Typst bundles. Without the flag the document still
compiles, but those two fall back to whatever sans is installed.

## What you set in `thesis.typ`

### Language

An Austrian thesis is written in one language and usually summarised in both. `lang` is the
language of the thesis, `secondary-lang` the one it is additionally summarised in — or
`none`. A title page is printed for each language in use, German first.

| | `lang` | `secondary-lang` |
| --- | --- | --- |
| English, with a German Kurzfassung | `"en"` | `"de"` |
| German, with an English abstract | `"de"` | `"en"` |
| English only | `"en"` | `none` |
| German only | `"de"` | `none` |

The summaries themselves carry the language they are written in, so the heading follows:

```typst
#acknowledgements("de")[Ihr Text hier.]
#acknowledgements("en")[Enter your text here.]
#abstract("de")[…]     // titled "Kurzfassung"
#abstract("en")[…]     // titled "Abstract"
```

The declaration of authorship, the running heads and the contents follow `lang`.

### People and data

`author`, `advisor`, `second-advisor`, `assistants` and `reviewers` all take the same shape
as the class's `\setauthor` and friends — a `name` with optional `pre-title` and
`post-title`. The author additionally carries a `student-number`, and a reviewer may carry
an `affiliation`. `title`, `subtitle`, `degree` and `curriculum` take one variant per
language. `date` is a `datetime` and is rendered the way `datetime2` renders it: "1. Jänner
2001" in German, "January 1, 2001" in English.

The institution under the title page is `university`, defaulting to TU Wien:

```typst
university: (name: "…", contact: ("A-1040 Wien", "Karlsplatz 13", "…")),
```

### References

`reference-style` defaults to `"alpha"` — BibTeX's alpha style, whose labels are built from
the author and the year, as in `[Lam94]`. `"numeric"` gives `[1]`, and `"acm"` and `"apa"`
the respective house styles. Any CSL style name Typst knows also works. The style is applied
as a set rule, so `#bibliography("refs.bib")` in the document needs no arguments, and a
`style:` given there still wins.

## Writing

Beyond ordinary Typst, the template adds:

| | |
| --- | --- |
| `subfigure`, `subfigure-row` | panels side by side, captioned "(a)" and referenced "Figure 3.1a" |
| `algorithm` | ruled, line-numbered pseudo code in the manner of `algorithm2e` |
| `listing` | a numbered, captioned code block |
| `flex-caption(long, short)` | LaTeX's `\caption[short]{long}` — the short form appears in the lists |
| `toc`, `list-of-figures`, `list-of-tables`, `list-of-algorithms`, `list-of-listings` | |
| `front-matter`, `main-matter`, `back-matter`, `appendix` | applied as `#show:` rules |
| `ai-tools` | the appendix the declaration of authorship refers to |

Figures, tables, equations, algorithms and listings are numbered within their chapter and
their counters restart with it.

Code is syntax-highlighted by default. For the plain black of the LaTeX original, add
`#show raw: set text(fill: black)` to `thesis.typ`.

## Layout

```
src/
  lib.typ            the thesis() entry point and the document-wide defaults
  layout.typ         page geometry, derived from the geometry package's defaults
  fonts.typ          font stacks and the size scale vutinfth defines
  title-page.typ     \AddTitlePage
  statement-page.typ \AddStatementPage
  summaries.typ      Kurzfassung, Abstract, Danksagung, Acknowledgements
  headings.typ       the veelo chapter opener and the section levels
  page-style.typ     running heads, folios, and \cleardoublepage
  floats.typ         sub-figures, algorithms, listings, flexible captions
  outlines.typ       the table of contents and the four lists
  matter.typ         \frontmatter, \mainmatter, \backmatter, appendix
  i18n/              the class's own German and English wording
template/            what you copy to start a thesis
fonts/               TeX Gyre Heros, TeX Gyre Cursor, Latin Modern Sans
tests/               regression checks against the reference metrics
```

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

## Tests

```bash
./.venv/Scripts/python.exe tests/check_layout.py     # geometry against the reference
./.venv/Scripts/python.exe tests/check_variants.py   # language modes, reference styles
```

`check_layout.py` asserts the numbers measured from `example-ref.pdf`, the reference output
shipped with the LaTeX class. `check_variants.py` compiles the template once per language
arrangement and per reference style and checks what comes out.

## How closely it matches

Every horizontal position on the title page lands within half a point of the reference and
the vertical positions within about two. The chapter opener — the small-caps "Chapter", the
oversized numeral hanging into the margin and the block that runs off the paper — matches to
within a point, as do the running heads, the folios and the table of contents columns.

Two differences are inherent rather than incidental:

- **Font metrics.** The body is set in New Computer Modern, which Typst bundles and which is
  the maintained successor of Latin Modern. Its bold is about 2% wider than the Type 1 Latin
  Modern the reference was built with, and its small caps about 7% narrower, so individual
  words differ slightly in width even though sizes and positions agree.
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

MIT, see `LICENSE`. The TU Wien Informatics logo in `src/assets/` and the cover image in
`template/graphics/` are copyright of TU Wien and are included on the same basis as in the
original class.
