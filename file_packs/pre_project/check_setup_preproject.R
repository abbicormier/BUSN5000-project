# ============================================================
# check_setup_preproject.R
#
# Verifies your pre-project file pack has been sorted correctly
# into your Project/ directory before you begin the pre-project.
#
# To run:
#   1. In RStudio, open this script from the Files pane (click
#      r/check_setup_preproject.R).
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
# Returns the relative path if found, or NA_character_ otherwise.
find_file <- function(filename) {
  hits <- list.files(
    here(),
    pattern   = paste0("^", filename, "$"),
    recursive = TRUE,
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
      expected, ". Did you download the full pre-project pack and ",
      "place every file inside your Project/ folder?"
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

cat("\n=== Pre-project setup check ===\n")
cat("Project root: ", here(), "\n\n", sep = "")

cat("--- Required subfolders ---\n")
folder_results <- c(
  check_folder("data"),
  check_folder("data_documentation"),
  check_folder("out"),
  check_folder("r"),
  check_folder("css")
)

cat("\n--- Required files (from the pre-project pack) ---\n")
file_results <- c(
  check_file("pre_project.Rmd",            ""),
  check_file("LF.R",                       "r"),
  check_file("project_slidedeck.css",      "css"),
  check_file("pppub24.csv",                "data"),
  check_file("hhpub24.csv",                "data"),
  check_file("cpsmar24_documentation.pdf", "data_documentation"),
  check_file("check_setup_preproject.R",   "r")
)

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
all_results <- c(folder_results, file_results, rproj_result)
n_pass <- sum(all_results)
n_fail <- sum(!all_results)

if (n_fail == 0) {
  cat("All ", n_pass, " checks passed.\n", sep = "")
  cat("Your Project/ directory is correctly set up.\n")
  cat("Next: open pre_project.Rmd and follow the steps in the\n")
  cat("Pre-project chapter of the Project Guide.\n")
} else {
  cat("Passed: ", n_pass, "  |  Failed: ", n_fail, "\n", sep = "")
  cat("Fix each ✗ above and re-run this script.\n")
}
