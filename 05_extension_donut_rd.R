################################################################################
# 05_extension_donut_rd.R
# MY EXTENSION: "donut" regression discontinuity.
#
# Why: an RD is only credible if villages could not sort themselves to just
# above the threshold (for example, if population counts near 500 or 1,000
# were misreported to qualify for a road). If that happened, the villages
# closest to the cutoff would be the most suspect.
#
# What: re-estimate the Table 3 indices after dropping villages within d
# people of the threshold (d = 2, 5, 10). If the estimates are stable as the
# "hole" widens, the main results are not driven by the villages right at the
# cutoff.
#
# The paper addresses manipulation with a density plot of the running variable
# (Figure 3); the donut is a complementary check that is not in the paper.
################################################################################

donuts <- c(0, 2, 5, 10)   # d = 0 keeps every village, reproducing Table 3

donut_rows <- list()
for (fam in families) {
  for (d in donuts) {
    dd  <- if (d == 0) main else main[abs(main$v_pop) > d, ]
    s   <- summarise_fit(fit_iv(paste0(fam, "_index_andrsn"), dd, "kernel_tri_ik"))
    donut_rows[[length(donut_rows) + 1]] <- data.frame(
      index = fam, donut = d, estimate = round(s$b, 3), se = round(s$se, 3),
      p_value = round(s$p, 3), N = s$n)
  }
}
donut <- do.call(rbind, donut_rows)
write.csv(donut, file.path(out_dir, "ext_donut_rd.csv"), row.names = FALSE)

cat("Extension. Donut RD: Table 3 indices excluding villages within d people of the threshold\n\n")
print(donut, row.names = FALSE)

# Plot: estimate and 95% CI for each index as the donut widens
pd <- ggplot(donut, aes(factor(donut), estimate)) +
  geom_hline(yintercept = 0, colour = "grey50") +
  geom_pointrange(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se)) +
  facet_wrap(~ index, nrow = 1) +
  labs(x = "Villages excluded within d people of threshold",
       y = "Effect of new road (2SLS, 95% CI)",
       title = "Donut RD: are results driven by villages right at the cutoff?") +
  theme_minimal()
ggsave(file.path(out_dir, "ext_donut_rd.png"), pd, width = 10, height = 4, dpi = 200)
