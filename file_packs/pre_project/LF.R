# ------------------------------------------------------------------------
# Source file:  LF.R
# Data file:    data/pppub24.csv
# Output file:  out/LF.csv
# Content:      Reads March CPS person file and computes LFPR
# Authors:      Cornwell and Cormier
# Last updated: 18 May 26
# -------------------------------------------------------------------------

# Load required packages

library(readr)  # For read_csv
library(here)   # For easy file referencing in project workflows

#-------------------------------------------------------------------------------

# Defensive check: confirm the raw CPS person file is in the
# expected location before we try to read it. If it isn't, we
# stop here with a helpful message rather than letting read_csv
# fail with a generic "cannot open the connection" error.

if (!file.exists(here("data", "pppub24.csv"))) {
  stop(
    "data/pppub24.csv was not found. Place it inside your ",
    "Project/data/ folder and re-run this script. See the Setup ",
    "chapter of the Project Guide if you need a refresher: ",
    "https://abbicormier.github.io/BUSN5000-project/setup.html"
  )
}

#-------------------------------------------------------------------------------

# Read person file

cpsmar <- read_csv(here("data", "pppub24.csv"))

#-------------------------------------------------------------------------------

# LFPR calculation - should equal 62.7% using March 2024 CPS data

# PEMLR
# Major labor force recode
# 1 = Employed - at work
# 2 = Employed - absent
# 3 = Unemployed - on layoff
# 4 = Unemployed - looking
# 5 = Not in labor force - retired
# 6 = Not in labor force - disabled
# 7 = Not in labor force - other
# Universe: All Persons

E    <- nrow(cpsmar[cpsmar$PEMLR==1 | cpsmar$PEMLR==2 & cpsmar$A_AGE>15,])
U    <- nrow(cpsmar[cpsmar$PEMLR==3 | cpsmar$PEMLR==4 & cpsmar$A_AGE>15,])
LF   <- E + U
NILF <- nrow(cpsmar[cpsmar$PEMLR==5 | cpsmar$PEMLR==6 | cpsmar$PEMLR==7 & cpsmar$A_AGE>15,])
Pop  <- NILF + LF
LFPR <- (LF/Pop)*100

print(paste("March 2024 LFPR =", LFPR))

# Write LFPR calculations to a .csv file

LF <- data.frame(
  E,
  U,
  LF,
  NILF,
  Pop,
  LFPR
)
write_csv(LF, here("out", "LF.csv"), col_names = TRUE)
