################################################################################
# 00_master.R
# Replication of Asher & Novosad (2020), "Rural Roads and Local Economic
# Development", American Economic Review 110(3).
#
# Replicated by: Ananya Joshi
# Runs: Table 2 (first stage), Figure 4 (first-stage RD plot),
#       Table 3 (main outcome indices), Table 5 (labor market),
#       and my extension (donut RD).
#
# HOW TO RUN
# 1. Download the original package from openICPSR (project 109703) and unzip it.
# 2. Change the two paths below.
# 3. Open this file in RStudio and click "Source" (or run source("00_master.R")).
#    Outputs go to the /output folder of this repo.
################################################################################

# ---- 1. PATHS: change these two lines ----------------------------------------
if (!requireNamespace("rstudioapi", quietly = TRUE)) install.packages("rstudioapi")
orig <- rstudioapi::selectDirectory(caption = "Pick the openICPSR folder (the one with 'code' and 'data' inside)")
repo <- dirname(rstudioapi::getSourceEditorContext()$path)

# ---- 2. Derived paths (no need to change) ------------------------------------
data_dir <- file.path(orig, "data", "pmgsy")   # authors' analysis datasets
out_dir  <- file.path(repo, "output")
dir.create(out_dir, showWarnings = FALSE)

# ---- 3. Packages: installs any that are missing --------------------------------
pkgs <- c("haven", "AER", "sandwich", "lmtest", "ggplot2")
missing <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(missing) > 0) install.packages(missing)
invisible(lapply(pkgs, library, character.only = TRUE))

# ---- 4. Check the data are where we expect -------------------------------------
for (f in c("pmgsy_working_aer.dta", "pmgsy_working_aer_mainsample.dta")) {
  if (!file.exists(file.path(data_dir, f))) {
    stop("Cannot find ", f, " in ", data_dir,
         ". Search the unzipped package for this file and update data_dir above.")
  }
}

# ---- 5. Log everything so results can be checked later -------------------------
log_file <- file(file.path(out_dir, "replication_log.txt"), open = "wt")
sink(log_file, split = TRUE)   # split = TRUE: also show in the console
cat("R version:", R.version.string, "\nRun on:", format(Sys.time()), "\n\n")

# ---- 6. Run the analysis ---------------------------------------------------------
source(file.path(repo, "01_setup.R"),               echo = FALSE)
source(file.path(repo, "02_table2_first_stage.R"),  echo = FALSE)
source(file.path(repo, "03_table3_main_indices.R"), echo = FALSE)
source(file.path(repo, "04_table5_labor.R"),        echo = FALSE)
source(file.path(repo, "05_extension_donut_rd.R"),  echo = FALSE)

cat("\nDone. Tables and figures are in", out_dir, "\n")
sink()
close(log_file)
