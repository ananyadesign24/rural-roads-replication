################################################################################
# 01_setup.R
# Defines the sample, controls, specification and helper functions used
# throughout. These mirror the authors' settings.do so results are comparable.
################################################################################

# -----------------------------------------------------------------------------
# THE DESIGN IN ONE PARAGRAPH
# Under India's PMGSY programme, villages were prioritised for a new paved road
# if their 2001 population was above a threshold (500 or 1,000, depending on
# the state). So villages just above the threshold were much more likely to
# get a road than villages just below, while otherwise being very similar.
# Comparing the two groups near the cutoff is a regression discontinuity (RD).
# Because crossing the threshold raised the CHANCE of a road rather than
# guaranteeing one, it is a FUZZY RD: being above the threshold (t) is used as
# an instrument for actually getting a road (r2012), estimated by two-stage
# least squares (2SLS).
# -----------------------------------------------------------------------------

# Key variables in the authors' data
#   v_pop        : 2001 population minus the threshold (running variable; 0 = cutoff)
#   t            : 1 if village is above the threshold (the instrument)
#   r2012        : 1 if village received a new PMGSY road by 2012 (treatment)
#   left, right  : slope of the running variable below / above the cutoff
#   vhg_dist_id  : district x threshold-group fixed effects
#   kernel_tri_* : triangular kernel weights (more weight close to the cutoff)
#   mainsample   : villages in the main estimation sample

# Baseline (2001) village controls, as in the paper
controls <- c("primary_school", "med_center", "elect", "tdist", "irr_share",
              "ln_land", "pc01_lit_share", "pc01_sc_share", "bpl_landed_share",
              "bpl_inc_source_sub_share", "bpl_inc_250plus")

# Bandwidths: main estimates use the Imbens-Kalyanaraman (IK) optimal
# bandwidth of 84 people either side of the cutoff
rdbands <- c(60, 70, 80, 90, 100, 110)

# ---- Helpers that reproduce Stata's logic in R ------------------------------
# In Stata, a missing value counts as TRUE in an `if` condition, while
# `x == 0` is FALSE for missing x. These helpers copy that behaviour exactly,
# so the samples match the authors' samples.
st_true   <- function(x) is.na(x) | x != 0
st_eq0    <- function(x) !is.na(x) & x == 0
st_range  <- function(x, lo, hi) !is.na(x) & x >= lo & x <= hi

# Sample restrictions, as in the paper:
#   states : state x threshold groups where the rule was followed
#   noroad : villages with no paved road at baseline
#   nobad  : drop villages where two population sources disagree a lot
in_states <- function(d) with(d, st_true(rj_l) | st_true(mp_l) | st_true(mp_h) |
                                 st_true(cg_l) | st_true(cg_h) | st_true(or_l) |
                                 st_true(mh_l) | st_true(gj_l))
no_road   <- function(d) with(d, st_eq0(app_pr) | st_eq0(con00))
no_bad    <- function(d) st_range(d$secc_pop_ratio, 0.8, 1.2)

# ---- Model-building helpers ----------------------------------------------------
# Rows actually used in estimation (rows with missing values are dropped,
# exactly as Stata does)
rows_used <- function(m, d) if (is.null(m$na.action)) d else d[-m$na.action, ]

rhs_exog <- paste(c("left", "right", controls, "factor(vhg_dist_id)"), collapse = " + ")

# First stage / reduced form: OLS, robust SEs (HC1 = Stata's `, robust` after reg)
fit_ols <- function(y, d, w) {
  d <- d[!is.na(d[[w]]) & d[[w]] > 0, ]          # Stata drops zero/missing aweights
  f <- as.formula(paste(y, "~ t +", rhs_exog))
  m <- lm(f, data = d, weights = d[[w]])
  list(model = m, vcov = vcovHC(m, type = "HC1"), coef = "t", df = m$df.residual,
       used = rows_used(m, d))
}

# Fuzzy RD: 2SLS of outcome on road, instrumented by threshold, robust SEs
# (HC0 = Stata's ivregress, vce(robust), which applies no small-sample correction)
fit_iv <- function(y, d, w) {
  d <- d[!is.na(d[[w]]) & d[[w]] > 0, ]
  f <- as.formula(paste(y, "~ r2012 +", rhs_exog, "| t +", rhs_exog))
  m <- ivreg(f, data = d, weights = d[[w]])
  list(model = m, vcov = vcovHC(m, type = "HC0"), coef = "r2012", df = Inf,
       used = rows_used(m, d))
}

# Pull coefficient, SE, p-value, N and R-squared from a fitted model
summarise_fit <- function(fit) {
  ct <- coeftest(fit$model, vcov. = fit$vcov, df = fit$df)
  b  <- ct[fit$coef, 1]; se <- ct[fit$coef, 2]; p <- ct[fit$coef, 4]
  list(b = b, se = se, p = p, n = nobs(fit$model),
       r2 = summary(fit$model)$r.squared)
}

stars <- function(p) ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.10, "*", "")))

# Build a table: one column per model, rows = estimate, (SE), extra stats.
# Saves a CSV and a readable text version, and prints it.
make_table <- function(fits, col_names, row_label, file_stub, title,
                       extra = list()) {
  s <- lapply(fits, summarise_fit)
  tab <- data.frame(
    row.names = c(row_label, "", names(extra), "N", "R-squared"),
    sapply(seq_along(s), function(i) c(
      sprintf("%.3f%s", s[[i]]$b, stars(s[[i]]$p)),
      sprintf("(%.3f)", s[[i]]$se),
      sapply(extra, function(e) e[[i]]),
      format(s[[i]]$n, big.mark = ","),
      sprintf("%.2f", s[[i]]$r2)
    ))
  )
  names(tab) <- col_names
  write.csv(tab, file.path(out_dir, paste0(file_stub, ".csv")))
  txt <- c(title, "", capture.output(print(tab, right = TRUE)), "",
           "Robust standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01")
  writeLines(txt, file.path(out_dir, paste0(file_stub, ".txt")))
  cat(txt, sep = "\n"); cat("\n")
  invisible(s)
}
