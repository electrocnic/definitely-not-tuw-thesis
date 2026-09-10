// tuw-thesis — a Typst port of the vutinfth LaTeX class used for theses at
// TU Wien Informatics.
//
// The single entry point is `thesis`, applied as a show rule at the top of the document.
// It sets the page and text defaults, emits the German and English title pages and the
// declaration of authorship, and then hands over to the author's own content.

#import "layout.typ": *
#import "fonts.typ": *
#import "headings.typ": heading-styles
#import "i18n/i18n.typ": format-date, localised, t
#import "matter.typ": appendix, back-matter, front-matter, main-matter
#import "outlines.typ": list-of-figures, list-of-tables, outline-styles, toc
#import "page-style.typ": running-foot, running-head, skip-blank-verso
#import "statement-page.typ": statement-page
#import "title-page.typ": title-page
#import "util.typ": person-name, signature-line

#let thesis(
  /// Language of the body text: "en" or "de". Both title pages are always produced.
  lang: "en",
  /// Title and subtitle, as a dictionary of per-language variants.
  title: (:),
  subtitle: none,
  /// One of "bachelor", "master", "diploma" or "doctor".
  thesis-type: "diploma",
  /// The academic degree awarded, e.g. "Diplom-Ingenieur".
  degree: (en: "Diplom-Ingenieur", de: "Diplom-Ingenieur"),
  /// The curriculum. Dissertations leave this out.
  curriculum: none,
  /// People, each a dictionary with `name` and optional `pre-title` / `post-title`.
  /// The author additionally carries a `student-number`.
  author: (:),
  advisor: none,
  second-advisor: none,
  assistants: (),
  reviewers: (),
  keywords: (),
  date: datetime.today(),
  body,
) = {
  assert(lang in ("en", "de"), message: "lang must be \"en\" or \"de\"")
  assert(
    thesis-type in ("bachelor", "master", "diploma", "doctor"),
    message: "unknown thesis type: " + thesis-type,
  )

  set document(
    title: localised(title, lang),
    author: author.at("name", default: ""),
    keywords: keywords,
    date: date,
  )

  set page(
    width: paper-width,
    height: paper-height,
    margin: body-margin,
    header-ascent: header-ascent,
    footer-descent: footer-descent,
    header: running-head(),
    footer: running-foot(),
  )

  // LaTeX's \baselineskip is a baseline-to-baseline distance, whereas Typst's `leading` is
  // the gap between line *boxes*. Pinning the box to exactly one em makes the two models
  // agree, so every leading in the template can be written the way the class states it.
  set text(font: serif, size: body-size, lang: lang, top-edge: 0.75em, bottom-edge: -0.25em)
  set par(
    justify: true,
    leading: body-baseline - body-size,
    // vutinfth's example turns on \nonzeroparskip and removes the indent, so paragraphs
    // are separated by space rather than by a first-line indent.
    first-line-indent: 0pt,
    spacing: body-baseline - body-size + 5.5pt,
  )
  set heading(supplement: t(lang, "chapter"))
  show heading.where(level: 2): set heading(supplement: t(lang, "section"))
  set text(hyphenate: true)
  show raw: set text(font: mono)

  // Figures, tables and equations are numbered within the chapter — "Figure 3.1" — and
  // their counters restart with it, which the chapter show rule takes care of.
  let within-chapter(format) = n => numbering(format, counter(heading).get().first(), n)
  set figure(numbering: within-chapter("1.1"))
  set math.equation(numbering: within-chapter("(1.1)"))
  // memoir puts a table's caption below it, like a figure's.
  show figure.where(kind: table): set figure.caption(position: bottom)

  show: heading-styles.with(lang)
  show: outline-styles

  let meta = (
    title: title,
    subtitle: subtitle,
    thesis-type: thesis-type,
    degree: degree,
    curriculum: curriculum,
    author: author,
    advisor: advisor,
    second-advisor: second-advisor,
    assistants: assistants,
    reviewers: reviewers,
    date: date,
  )

  // The class issues \frontmatter before the title pages, so they are already part of the
  // roman page sequence — printed without a folio, but counted. The declaration that
  // follows them is page v.
  show: front-matter

  // Both title pages are printed, German first, each on its own right-hand page.
  title-page("de", meta)
  skip-blank-verso
  title-page("en", meta)
  skip-blank-verso

  statement-page(lang, author, date)

  body
}
