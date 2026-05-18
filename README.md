# BUSN 5000 Project Guide

The canonical guide for the Pre-project, Progress Check, and Final
Project in BUSN 5000 (Intro to Data Science for Business and
Economics) at the University of Georgia.

**Published site:** <https://abbicormier.github.io/BUSN5000-project/>

## Authors

- Chris Cornwell
- Abbi Cormier

## Source

This is a [Quarto book](https://quarto.org/docs/books/) styled with
the UGA style guide Quarto extension (bundled in `_extensions/uga/`).
The HTML site is rendered and deployed to GitHub Pages on every push
to `main` via GitHub Actions.

## Local build

Requires Quarto ≥ 1.4, R, and a LaTeX engine (TinyTeX is fine).

```bash
quarto preview      # live preview during writing
quarto render       # one-shot build to _book/
```

## Repository layout

```
.
├── _quarto.yml             # book config + UGA theming
├── styles.scss             # HTML overrides on top of UGA SCSS
├── index.qmd               # preface
├── setup.qmd               # Setup chapter
├── pre-project.qmd         # Pre-project chapter
├── main-project.qmd        # Main Project chapter
├── progress-check.qmd      # Progress Check chapter
├── submission.qmd          # Submission chapter
├── common-errors.qmd       # Common Errors / FAQ chapter
├── _extensions/uga/        # UGA branding (Quarto extension)
└── .github/workflows/      # GitHub Actions: render + publish
```
