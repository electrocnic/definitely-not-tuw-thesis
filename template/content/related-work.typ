= Related Work

#lorem(150)

== Typesetting Systems

#lorem(120)

Typst @typst is a markup-based typesetting system, while LaTeX @lamport1994latex
has been the established choice in academia for decades.

#figure(
  rect(width: 60%, height: 4cm, stroke: 0.4pt),
  caption: [A placeholder figure at 60% of the text width.],
) <fig-placeholder>

@fig-placeholder shows a placeholder. #lorem(40)

== Comparison

#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(),
    [*System*], [*Input*], [*Compilation*],
    table.hline(stroke: 0.4pt),
    [LaTeX], [Macro language], [Multi-pass],
    [Typst], [Markup and scripting], [Incremental],
    table.hline(),
  ),
  caption: [A comparison of two typesetting systems.],
) <tab-comparison>

#lorem(130)

=== Mathematical Expressions

An expression can be set inline as $sum_(n = 1)^oo 1 / n^2 = pi^2 / 6$, or displayed
outside the text stream as

// Display equations are numbered by default; opt out for a single one like this.
#[
  #set math.equation(numbering: none)
  $ sum_(n = 1)^oo 1 / n^2 = pi^2 / 6 $
]

or as a numbered equation with

$ sum_(n = 1)^oo 1 / n^2 = pi^2 / 6. $ <eq-basel>

#lorem(50)

=== Discussion

#lorem(160)
