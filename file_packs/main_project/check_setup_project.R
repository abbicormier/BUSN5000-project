# ============================================================
# check_setup_project.R
#
# Verifies your main-project file pack has been sorted correctly
# into your Project/ directory AND that your pre-project files
# are still in place (they carry over — the main project depends
# on them).
#
# To run:
#   1. In RStudio, open this script from the Files pane (click
#      r/check_setup_project.R).
#   2. Select All (Ctrl+A on Windows, Cmd+A on Mac).
#   3. Click the Run button at the top-right of the editor.
#
# Output appears in the Console pane below. Each line is either
#   ✓  (good — this file or folder is correctly placed)
#   ✗  (a problem — read the message and fix it, then re-run)
#
# Authors: Cornwell and Cormier
# ============================================================

# --- Verify required helper package is installed ---
if (!requireNamespace("here", quietly = TRUE)) {
  cat("✗ The 'here' package is not installed.\n")
  cat("  Install it via the Packages pane in RStudio (see the\n")
  cat("  Setup chapter of the Project Guide), then re-run this\n")
  cat("  script.\n")
  stop("Missing required package: here")
}
library(here)

# --- Pretty-printing helpers ---
ok   <- function(msg) cat("✓ ", msg, "\n", sep = "")
fail <- function(msg) cat("✗ ", msg, "\n", sep = "")

# --- Locate a file anywhere within the project root ---
find_file <- function(filename) {
  hits <- list.files(
    here(),
    pattern    = paste0("^", filename, "$"),
    recursive  = TRUE,
    full.names = TRUE
  )
  if (length(hits) == 0) return(NA_character_)
  sub(paste0("^", here(), "/?"), "", hits[1])
}

# --- Check that a file is in its expected subfolder ---
check_file <- function(filename, subfolder) {
  if (subfolder == "") {
    expected      <- filename
    expected_path <- here(filename)
  } else {
    expected      <- paste0(subfolder, "/", filename)
    expected_path <- here(subfolder, filename)
  }

  if (file.exists(expected_path)) {
    ok(paste0(filename, " is in ", expected))
    return(TRUE)
  }

  found_at <- find_file(filename)
  if (!is.na(found_at)) {
    fail(paste0(
      filename, ": expected at ", expected,
      " but I found it at ", found_at,
      ". Move it to ", expected, "."
    ))
  } else {
    fail(paste0(
      filename, ": not found anywhere in your project. Expected at ",
      expected, "."
    ))
  }
  return(FALSE)
}

# --- Check that a subfolder exists ---
check_folder <- function(subfolder) {
  if (dir.exists(here(subfolder))) {
    ok(paste0("Subfolder ", subfolder, "/ exists"))
    return(TRUE)
  }
  fail(paste0(
    "Subfolder ", subfolder, "/ does not exist. Create it inside ",
    "your Project/ folder."
  ))
  return(FALSE)
}

# ============================================================
# Run all checks
# ============================================================

cat("\n=== Main project setup check ===\n")
cat("Project root: ", here(), "\n\n", sep = "")

cat("--- Required subfolders ---\n")
folder_results <- c(
  check_folder("data"),
  check_folder("data_documentation"),
  check_folder("out"),
  check_folder("r"),
  check_folder("css")
)

cat("\n--- Pre-project carry-over files ---\n")
carryover_results <- c(
  check_file("LF.R",                       "r"),
  check_file("project_slidedeck.css",      "css"),
  check_file("pppub24.csv",                "data"),
  check_file("hhpub24.csv",                "data"),
  check_file("cpsmar24_documentation.pdf", "data_documentation")
)

cat("\n--- Main project pack files ---\n")

# Project Rmd: look for project.Rmd OR a renamed *.Rmd in root.
# Exclude pre_project.Rmd (which is pre-project material, not the
# main project working file).
all_rmds_in_root <- list.files(
  here(),
  pattern    = "\\.Rmd$",
  recursive  = FALSE,
  full.names = FALSE
)
project_rmds <- setdiff(all_rmds_in_root, "pre_project.Rmd")

if (length(project_rmds) >= 1) {
  if ("project.Rmd" %in% project_rmds) {
    ok("project.Rmd is in Project/ (root)")
  } else {
    ok(paste0(
      project_rmds[1], " is in Project/ (root) — looks like you've ",
      "renamed project.Rmd to your personalized filename"
    ))
  }
  rmd_result <- TRUE
} else {
  # Check if it's elsewhere
  found_at <- find_file("project.Rmd")
  if (!is.na(found_at)) {
    fail(paste0(
      "project.Rmd: expected in Project/ (root) but I found it at ",
      found_at, ". Move it to the project root."
    ))
  } else {
    fail(paste0(
      "project.Rmd: not found anywhere in your project. Expected ",
      "in Project/ (root). If you've renamed it to ",
      "firstname_lastname_project.Rmd, that's fine — but it must be ",
      "in Project/ (root)."
    ))
  }
  rmd_result <- FALSE
}

other_main_results <- c(
  check_file("cpsmar_e.R",            "r"),
  check_file("check_setup_project.R", "r")
)

# If cpsmar_e.csv exists (i.e., the student has run cpsmar_e.R),
# verify it ended up in out/ — not in data/, where older script
# versions used to write it. If it doesn't exist anywhere, the
# student hasn't run cpsmar_e.R yet; we'll prompt them in the
# summary block below.
cpsmar_e_in_out  <- file.exists(here("out",  "cpsmar_e.csv"))
cpsmar_e_in_data <- file.exists(here("data", "cpsmar_e.csv"))
if (cpsmar_e_in_out) {
  ok("cpsmar_e.csv is in out/ (good — that's where the project Rmd reads it from)")
  cpsmar_e_result <- TRUE
  cpsmar_e_status <- "ready"
} else if (cpsmar_e_in_data) {
  fail(paste0(
    "cpsmar_e.csv is in data/ but should be in out/. ",
    "An older version of cpsmar_e.R wrote the extract to data/; ",
    "the current version writes to out/. Either re-run the new ",
    "cpsmar_e.R (which will write to out/) or manually move the ",
    "existing file from data/ to out/."
  ))
  cpsmar_e_result <- FALSE
  cpsmar_e_status <- "misplaced"
} else {
  # File doesn't exist anywhere — student hasn't run cpsmar_e.R
  # yet. Not a failure; flagged below.
  cpsmar_e_result <- TRUE
  cpsmar_e_status <- "not_yet_run"
}

cat("\n--- Project file (.Rproj) ---\n")
rproj_files <- list.files(here(), pattern = "\\.Rproj$", full.names = FALSE)
if (length(rproj_files) > 0) {
  ok(paste0(".Rproj file found: ", rproj_files[1]))
  rproj_result <- TRUE
} else {
  fail(paste0(
    "No .Rproj file in your Project/ folder. Create one in ",
    "RStudio: File -> New Project -> Existing Directory -> ",
    "select your Project/ folder."
  ))
  rproj_result <- FALSE
}

# --- Summary ---
cat("\n=== Summary ===\n")
all_results <- c(folder_results, carryover_results, rmd_result,
                 other_main_results, cpsmar_e_result, rproj_result)
n_pass <- sum(all_results)
n_fail <- sum(!all_results)

if (n_fail == 0) {
  cat("All ", n_pass, " checks passed.\n", sep = "")
  cat("Your Project/ directory is set up for the main project.\n\n")
  if (cpsmar_e_status == "not_yet_run") {
    cat("Next step: you haven't yet generated out/cpsmar_e.csv.\n")
    cat("Open r/cpsmar_e.R in RStudio, Select All, and click Run.\n")
    cat("Once that produces out/cpsmar_e.csv, open project.Rmd (or\n")
    cat("your renamed working file) and follow the steps in the\n")
    cat("Main Project chapter of the Project Guide.\n")
  } else {
    cat("Next: open project.Rmd (or your renamed working file) and\n")
    cat("follow the steps in the Main Project chapter of the\n")
    cat("Project Guide.\n")
  }
} else {
  cat("Passed: ", n_pass, "  |  Failed: ", n_fail, "\n", sep = "")
  cat("Fix each ✗ above and re-run this script.\n")
}
