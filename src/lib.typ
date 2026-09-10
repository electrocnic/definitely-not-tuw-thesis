// tuw-thesis — a Typst port of the vutinfth LaTeX class used for theses at
// TU Wien Informatics.
//
// The single entry point is `thesis`, applied as a show rule at the top of the document.
// It sets the page and text defaults, emits the title pages and the declaration of
// authorship, and then hands over to the author's own content.

#import "layout.typ": *
#import "fonts.typ": *
#import "floats.typ": (
  algorithm, figure-caption-gap, flex-caption, listing, subfigure, subfigure-row,
  subfigure-styles,
)
#import "headings.typ": heading-styles
#import "i18n/i18n.typ": format-date, localised, t
#import "matter.typ": appendix, back-matter, front-matter, main-matter
#import "outlines.typ": (
  list-of-algorithms, list-of-figures, list-of-listings, list-of-tables, outline-styles, toc,
)
#import "page-style.typ": running-foot, running-head, skip-blank-verso
#import "statement-page.typ": statement-page
#import "summaries.typ": abstract, acknowledgements, ai-tools
#import "title-page.typ": title-page
#import "util.typ": person-name

/// How references are labelled and formatted.
///
/// "alpha" is what the LaTeX class produces: BibTeX's alpha style, whose labels are built
/// from the author and the year — [Lam94]. Typst's `alphanumeric` CSL produces those labels
/// but only formats citations, so the entries themselves are laid out by a second style.
#let reference-styles = (
  alpha: (cite: "alphanumeric", entries: "ieee"),
  numeric: (cite: auto, entries: "ieee"),
  acm: (
    cite: auto,
    entries: "association-for-computing-machinery",
  ),
  apa: (cite: auto, entries: "american-psychological-association"),
)

/// The institution printed under the title page. Overridable, but the defaults are the ones
/// the class ships.
#let tu-wien = (
  name: "Technische Universität Wien",
  contact: ("A-1040 Wien", "Karlsplatz 13", "Tel. +43-1-58801-0", "www.tuwien.at"),
)

#let thesis(
  /// Language the thesis is written in: "en" or "de".
  lang: "en",
  /// A second language for the title page and the summaries, or `none` for a thesis that
  /// stays in one language. Austrian theses are usually written in one language and
  /// summarised in both.
  secondary-lang: "de",
  /// Title and subtitle, as a dictionary of per-language variants.
  title: (:),
  subtitle: none,
  /// One of "bachelor", "master", "diploma" or "doctor".
  thesis-type: "diploma",
  /// The academic degree awarded. The class offers "Bachelor of Science",
  /// "Master of Science", "Diplom-Ingenieur(in)", "Magister/Magistra der
  /// Naturwissenschaften", "… der Sozial- und Wirtschaftswissenschaften" and the
  /// corresponding doctorates.
  degree: (en: "Diplom-Ingenieur", de: "Diplom-Ingenieur"),
  /// The curriculum. Dissertations leave this out.
  curriculum: none,
  /// People. Each is a dictionary with `name` and the optional keys `pre-title` and
  /// `post-title`; the author additionally carries a `student-number`. Reviewers apply to a
  /// dissertation, which they sign above the author.
  author: (:),
  advisor: none,
  second-advisor: none,
  assistants: (),
  reviewers: (),
  /// The institution's own details, printed under the title page.
  university: tu-wien,
  /// A name from `reference-styles`, or any CSL style Typst knows.
  reference-style: "alpha",
  keywords: (),
  date: datetime.today(),
  body,
) = {
  assert(lang in ("en", "de"), message: "lang must be \"en\" or \"de\"")
  assert(
    secondary-lang == none or secondary-lang in ("en", "de"),
    message: "secondary-lang must be \"en\", \"de\" or none",
  )
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

  let refs = reference-styles.at(
    reference-style,
    default: (cite: auto, entries: reference-style),
  )
  set cite(style: refs.cite)
  set bibliography(style: refs.entries, title: t(lang, "bibliography"))

  // Figures, tables and equations are numbered within the chapter — "Figure 3.1" — and
  // their counters restart with it, which the chapter show rule takes care of.
  let within-chapter(format) = n => numbering(format, counter(heading).get().first(), n)
  set figure(numbering: within-chapter("1.1"))
  set math.equation(numbering: within-chapter("(1.1)"))
  // memoir puts a table's caption below it, like a figure's.
  show figure.where(kind: table): set figure.caption(position: bottom)
  set figure(gap: figure-caption-gap)

  show: heading-styles.with(lang)
  show: outline-styles
  show: subfigure-styles

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
    university: university,
    date: date,
  )

  // The class issues \frontmatter before the title pages, so they are already part of the
  // roman page sequence — printed without a folio, but counted. The declaration that
  // follows them is page v.
  show: front-matter

  // One title page per language. German comes first where both are printed, which is the
  // order the class's own example uses.
  let title-languages = if secondary-lang == none {
    (lang,)
  } else if lang == "de" {
    (lang, secondary-lang)
  } else {
    (secondary-lang, lang)
  }
  for language in title-languages {
    title-page(language, meta)
    skip-blank-verso
  }

  statement-page(lang, author, date)

  body
}
