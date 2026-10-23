################################################################################
# 03_table3_main_indices.R
# Table 3: effect of a new road on five summary indices of village outcomes
# (transport, agricultural occupation, firms, agricultural production,
# consumption).
#
# Method: two-stage least squares (fuzzy RD). Being above the threshold (t)
# instruments for getting a road (r2012). The coefficient on r2012 is the
# effect of a road on villages near the cutoff whose road status was changed
# by the rule.
################################################################################

main <- as.data.frame(zap_labels(read_dta(file.path(data_dir, "pmgsy_working_aer_mainsample.dta"))))
main <- main[st_true(main$mainsample), ]

# Each index (Anderson 2008 method) combines several related outcomes into one
# standardised measure, so testing five indices rather than dozens of
# individual outcomes reduces the risk of false positives.
families <- c("transport", "occupation", "firms", "agriculture", "consumption")

t3_fits <- lapply(families, function(fam)
  fit_iv(paste0(fam, "_index_andrsn"), main, "kernel_tri_ik"))

t3_p <- sapply(t3_fits, function(f) sprintf("%.3f", summarise_fit(f)$p))

make_table(t3_fits,
           col_names = c("Transportation", "Ag occupation", "Firms",
                         "Ag production", "Consumption"),
           row_label = "New road",
           file_stub = "table3_main_indices",
           title     = "Table 3. Impact of a new road on major outcome indices",
           extra     = list("p-value" = t3_p))
