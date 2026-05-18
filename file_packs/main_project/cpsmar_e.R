# ------------------------------------------------------------------------
# Source file:  cpsmar_e.R
# Data files:   pppub24.csv, hhpub24.csv (from asecpub24csv.zip)
# Output files: out/LF.csv, out/cpsmar_e.csv
# Content:      Creates March CPS (ASEC Supplement) extract
# Notes:        Applied here to March 2024 survey
# Authors:      Kearns and Cornwell and Cormier
# Last updated: 18 May 26
# -------------------------------------------------------------------------

# Load required packages

library(tidyverse)  # For tidyverse/dplyr verbs
library(here)       # For easy file referencing in project workflows

#-------------------------------------------------------------------------------

# Read person file

cpsmar <- read_csv(here("data", "pppub24.csv"))

# Read household file and select region and household sequence variables

hhcps <- read_csv(here("data", "hhpub24.csv")) %>%
  select("GEREG", "H_SEQ", "GTCO","GTCBSAST")

#-------------------------------------------------------------------------------

# Pre-project exercise code
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

#-------------------------------------------------------------------------------

# Create March CPS "extract" - call it `cpsmar_e`
# Start with the person-file data in `cpsmar`

# Use `rename` and `mutate` to rename CPS variables and
# create new indicator variables for analysis purposes

cpsmar_e <- cpsmar %>%
  rename(
    "age"       = "A_AGE",
    "earnings"  = "PEARNVAL",
    "hours"     = "HRSWK",
    "weeks"     = "WKSWORK",
    "race"      = "PRDTRACE",
    "marital"   = "A_MARITL",
    "education" = "A_HGA",
    "H_SEQ"     = "PH_SEQ"
  ) %>%
  mutate(
    female   = case_when(A_SEX==2~1, TRUE ~ 0),
    hisp     = case_when(PEHSPNON == 1~1, TRUE~0),
    fulltime = case_when(weeks>=48 & hours >=36~1, TRUE~0),
    union    = case_when(A_UNMEM==1~1, TRUE~0),
    uncov    = case_when(A_UNCOV==1~1, TRUE~0),
    HSGrad   = case_when(education == 39 ~ 1, TRUE ~ 0),
    SomeColl = case_when(education >= 40 & education <=42 ~ 1, TRUE ~ 0),
    CollDeg  = case_when(education >= 43 ~ 1, TRUE ~ 0)
  )

# Define character-valued occupation categories

cpsmar_e<- cpsmar_e %>%
  mutate(
    Occ = case_when(
      A_MJOCC==1~"Busn",  # 1 = Management, business, and financial occupations
      A_MJOCC==2~"Prof",  # 2 = Professional and related occupations
      A_MJOCC==3~"Serv",  # 3 = Service occupations
      A_MJOCC==4~"Sale",  # 4 = Sales and related occupations
      A_MJOCC==5~"Admn",  # 5 = Office and administrative support occupations
      A_MJOCC==6~"Farm",  # 6 = Farming, fishing, and forestry occupations
      A_MJOCC==7~"Cons",  # 7 = Construction and extraction occupations
      A_MJOCC==8~"Main",  # 8 = Installation, maintenance, and repair occupations
      A_MJOCC==9~"Prod",  # 9 = Production occupations
      A_MJOCC==10~"Tran", # 10 = Transportation and material moving occupations
      A_MJOCC==11~"Mili", # 11 = Military specific occupations
      TRUE ~ "NA"
      )
  )

# Merge person file with household file by household sequence number
# Add region and county variables and  a city indicator to the extract
# `GTCBSAST` is the Core-based Statistical area (CBSA) status variable
# 1 = Principal City; 2 = Balance of CBSA

cpsmar_e <- merge(hhcps, cpsmar_e, by.x="H_SEQ") %>%
  rename(
    "region" = "GEREG",
    "county" = "GTCO"
    ) %>%
  mutate(city = case_when(GTCBSAST==1 | GTCBSAST==2 ~ 1, TRUE~0))

# Use `group_by` to determine whether there are children under 6 at home
# and add a children-under-6-in-the-household indicator to the extract

cpsmar_e <- cpsmar_e %>%
  group_by(H_SEQ) %>%
  mutate(child_u6 = as.integer(any(age<6))) %>%
  ungroup()

# Use `filter` to restrict extract to full-time workers
# Select variables to be included in the final extract

cpsmar_e <- cpsmar_e %>%
  filter(fulltime==1) %>%
  select(
    "age",
    "female",
    "hisp",
    "HSGrad",
    "SomeColl",
    "CollDeg",
    "earnings",
    "hours",
    "weeks",
    "union",
    "uncov",
    "region",
    "race",
    "marital",
    "fulltime",
    "county",
    "city",
    "Occ",
    "child_u6",
    "H_SEQ"
    )

# Write the extract to a CSV file and place it in the `out` folder

write_csv(cpsmar_e, here("out", "cpsmar_e.csv"))

#-------------------------------------------------------------------------------
