################################################################################
# 04_table5_labor.R
# Table 5: the paper's headline mechanism. Do roads move workers out of
# agriculture? Outcomes are the share of workers by main occupation and the
# share of households by main income source (agriculture vs manual labour).
################################################################################

# `main` is already loaded by 03_table3_main_indices.R

outcomes <- c("nco2d_cultiv_share", "nco2d_manlab_share",       # occupation (Census 2011)
              "secc_inc_cultiv_share", "secc_inc_manlab_share") # income source (SECC 2012)

t5_fits <- lapply(outcomes, function(y) fit_iv(y, main, "kernel_tri_ik"))

# Mean below the threshold, in the estimation sample, to give the effect a scale
t5_means <- sapply(seq_along(outcomes), function(i) {
  used <- t5_fits[[i]]$used
  sprintf("%.3f", mean(used[[outcomes[i]]][used$t == 0], na.rm = TRUE))
})

make_table(t5_fits,
           col_names = c("Occ: Agriculture", "Occ: Manual labour",
                         "Inc: Agriculture", "Inc: Manual labour"),
           row_label = "New road",
           file_stub = "table5_labor",
           title     = "Table 5. Impact of a new road on occupation (Occ) and household income source (Inc)",
           extra     = list("Control group mean" = t5_means))
