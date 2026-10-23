################################################################################
# 02_table2_first_stage.R
# Table 2: does being above the population threshold raise the probability of
# getting a new road? (first stage), across bandwidths 60 to 110.
# Figure 4: binned RD plot of the first stage.
################################################################################

full <- as.data.frame(zap_labels(read_dta(file.path(data_dir, "pmgsy_working_aer.dta"))))

# ---- Table 2 -----------------------------------------------------------------
# For each bandwidth i: regress road receipt on the threshold indicator,
# allowing separate linear slopes either side of the cutoff, with controls,
# district-group fixed effects and triangular kernel weights.
base_sample <- in_states(full) & no_road(full) & no_bad(full)

fs_fits <- lapply(rdbands, function(i) {
  d <- full[base_sample & st_true(full[[paste0("rd_band_", i)]]), ]
  fit_ols("r2012", d, paste0("kernel_tri_", i))
})

# F-statistic on the instrument: should be well above 10 for a strong first stage
fs_F <- sapply(fs_fits, function(f) {
  s <- summarise_fit(f); sprintf("%.1f", (s$b / s$se)^2)
})

make_table(fs_fits,
           col_names = paste0("+/-", rdbands),
           row_label = "Above threshold",
           file_stub = "table2_first_stage",
           title     = "Table 2. First stage: effect of road priority on new road by 2012",
           extra     = list("F statistic" = fs_F))

# ---- Figure 4: binned first-stage plot ----------------------------------------
# Average road receipt within bins of the running variable, with a separate
# linear fit on each side. A visible jump at 0 is the discontinuity.
ms <- full[st_true(full$mainsample), ]
ms$bin <- floor(ms$v_pop / 6) * 6 + 3                       # 6-person-wide bins
bins <- aggregate(r2012 ~ bin, data = ms, FUN = mean)
bins$n <- aggregate(r2012 ~ bin, data = ms, FUN = length)$r2012
bins$side <- ifelse(bins$bin < 0, "Below threshold", "Above threshold")

p <- ggplot(bins, aes(bin, r2012)) +
  geom_point(size = 1.5) +
  geom_smooth(aes(group = side, weight = n), method = "lm", se = FALSE,
              colour = "black", linewidth = 0.6) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(x = "Population relative to threshold",
       y = "Share of villages with new road by 2012",
       title = "First stage: road receipt at the threshold") +
  theme_minimal()
ggsave(file.path(out_dir, "figure4_first_stage.png"), p, width = 7, height = 4.5, dpi = 200)
