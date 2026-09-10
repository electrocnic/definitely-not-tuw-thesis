#import "../src/lib.typ": *

#show: thesis.with(
  // Language the thesis is written in, and the language it is additionally summarised in.
  //
  //   lang: "en", secondary-lang: "de"    English thesis, German Kurzfassung as well
  //   lang: "de", secondary-lang: "en"    German thesis, English abstract as well
  //   lang: "en", secondary-lang: none    English only
  //   lang: "de", secondary-lang: none    German only
  //
  // A title page is printed for each language in use, German first.
  lang: "en",
  secondary-lang: "de",

  title: (
    en: "Title of the Thesis",
    de: "Titel der Arbeit",
  ),
  subtitle: (
    en: "Optional Subtitle of the Thesis",
    de: "Optionaler Untertitel der Arbeit",
  ),

  // "bachelor", "master", "diploma" or "doctor".
  thesis-type: "diploma",
  // The degree awarded. Other names the class offers are "Bachelor of Science",
  // "Master of Science", "Diplom-Ingenieurin", "Magister/Magistra der Naturwissenschaften"
  // and "… der Sozial- und Wirtschaftswissenschaften".
  degree: (en: "Diplom-Ingenieur", de: "Diplom-Ingenieur"),
  curriculum: (
    en: "Media Informatics and Visual Computing",
    de: "Medieninformatik und Visual Computing",
  ),

  author: (
    pre-title: "Pretitle",
    name: "Forename Surname",
    post-title: "Posttitle",
    student-number: "0123456",
  ),
  advisor: (pre-title: "Pretitle", name: "Forename Surname", post-title: "Posttitle"),
  // second-advisor: (name: "Forename Surname"),
  assistants: (
    (pre-title: "Pretitle", name: "Forename Surname", post-title: "Posttitle"),
    (pre-title: "Pretitle", name: "Forename Surname", post-title: "Posttitle"),
    (pre-title: "Pretitle", name: "Forename Surname", post-title: "Posttitle"),
  ),
  // Dissertations name their reviewers instead of assistants:
  // reviewers: (
  //   (name: "Forename Surname", affiliation: "Affiliation, Country"),
  //   (name: "Forename Surname", affiliation: "Affiliation, Country"),
  // ),

  // The institution under the title page. Defaults to TU Wien; override for another one.
  // university: (name: "…", contact: ("…", "…")),

  // "alpha" gives BibTeX's [Lam94] labels, "numeric" gives [1], and "acm" and "apa" the
  // respective house styles. Any CSL style name Typst knows also works.
  reference-style: "alpha",

  keywords: ("a", "list", "of", "keywords"),
  date: datetime(year: 2001, month: 1, day: 1),
)

// Front matter. Each summary carries the language it is written in, so the heading is
// "Danksagung" or "Acknowledgements", "Kurzfassung" or "Abstract" accordingly. Drop the
// ones you do not need — a single-language thesis keeps only one of each.
#include "content/summaries.typ"

#toc("en")

#show: main-matter

#include "content/introduction.typ"
#include "content/related-work.typ"
#include "content/template-tour.typ"

#show: back-matter

// The appendix the declaration of authorship refers to.
#ai-tools("en")[
  List here every generative AI tool used in the making of this thesis, where it was used,
  and — for passages taken over without substantial changes — the prompts and the product
  name and version of the application.
]

#list-of-figures("en")
#list-of-tables("en")
#list-of-algorithms("en")
#list-of-listings("en")

#bibliography("refs.bib")
