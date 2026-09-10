#import "../src/lib.typ": *

#show: thesis.with(
  // Language of the body text. Both title pages are printed regardless.
  lang: "en",

  // Give the title and subtitle in both languages; the English one is used for the PDF
  // metadata when `lang` is "en".
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
  assistants: (
    (pre-title: "Pretitle", name: "Forename Surname", post-title: "Posttitle"),
    (pre-title: "Pretitle", name: "Forename Surname", post-title: "Posttitle"),
    (pre-title: "Pretitle", name: "Forename Surname", post-title: "Posttitle"),
  ),
  // Dissertations list their reviewers here instead:
  // reviewers: ((name: "Forename Surname"), (name: "Forename Surname")),

  keywords: ("a", "list", "of", "keywords"),
  date: datetime(year: 2001, month: 1, day: 1),
)

#include "content/abstract.typ"

#toc("en")

#show: main-matter

#include "content/introduction.typ"
#include "content/related-work.typ"

#show: back-matter

#list-of-figures("en")
#list-of-tables("en")

#bibliography("refs.bib", style: "association-for-computing-machinery")
