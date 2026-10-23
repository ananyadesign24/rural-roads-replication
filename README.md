# Replication: Asher & Novosad (2020), "Rural Roads and Local Economic Development"

**Replicated by:** Ananya Joshi (MSc Economics, Singapore Management University)
**Original paper:** Sam Asher and Paul Novosad, *American Economic Review* 110(3), 2020
**Original replication package:** openICPSR project 109703 (V2)

---

## 1. Research question
Do new rural roads transform village economies? The paper studies India's PMGSY programme, a national programme that built paved roads to previously unconnected villages, and asks whether a new road changed transport, jobs, firms, farming and living standards.

## 2. Identification strategy
PMGSY prioritised villages whose 2001 population was above a threshold (500 or 1,000, depending on the state). Villages just above and just below the cutoff are otherwise similar, but those above were far more likely to get a road. This makes a **regression discontinuity (RD)** design. Because crossing the threshold raised the *probability* of a road rather than guaranteeing one, it is a **fuzzy RD**: being above the threshold instruments for actually receiving a road, estimated by two-stage least squares.

Specification (as in the paper, re-implemented in R): local linear regression with separate slopes either side of the cutoff, triangular kernel weights, the Imbens–Kalyanaraman optimal bandwidth (±84 people), baseline village controls, district × threshold-group fixed effects, and robust standard errors.

## 3. Data
The authors' cleaned village-level analysis files from the package:
- `pmgsy_working_aer.dta` – all villages matched to PMGSY data (N = 345,797)
- `pmgsy_working_aer_mainsample.dta` – main RD sample (N = 11,432)

Underlying sources: Population Census (2001, 2011), Economic Census (2013), Socioeconomic and Caste Census (2012), PMGSY administrative records, and MODIS satellite vegetation data. Data are not redistributed here; download them from openICPSR.

## 4. What I replicated
| Output | My file | Reproduced exactly? | Notes |
|---|---|---|---|
| Table 2 – First stage across bandwidths | `table2_first_stage.txt` | | |
| Figure 4 – First-stage RD plot | `figure4_first_stage.png` | | Simplified binned plot without controls |
| Table 3 – Main outcome indices | `table3_main_indices.txt` | | |
| Table 5 – Occupation and income source | `table5_labor.txt` | | |
| Extension – Donut RD | `ext_donut_rd.csv`, `ext_donut_rd.png` | – | Not in paper |

## 5. Extension: donut RD
An RD is only credible if villages could not position themselves just above the threshold, for instance through misreported population counts. I re-estimate the Table 3 indices after excluding villages within 2, 5 and 10 people of the cutoff. Stable estimates indicate the results are not driven by the villages closest to the threshold. The paper tests manipulation with a density plot (Figure 3); the donut is a complementary check not reported in the paper.

**Result:** <!-- fill in after running -->

## 6. Differences from the original code
- The original code is in Stata; I re-implemented the analysis in **R** (`AER::ivreg` for 2SLS, `sandwich` for robust standard errors, `ggplot2` for figures). Robust standard errors follow Stata's conventions: HC1 for the OLS first stage and HC0 for 2SLS, matching `reg, robust` and `ivregress, vce(robust)`.
- Sample restrictions reproduce Stata's treatment of missing values in `if` conditions, so the estimation samples match the authors'.
- Tables are written as CSV and plain text, so no Python or LaTeX is needed (the original uses a Python table generator).
- The first-stage figure is a simple binned scatter with linear fits, rather than the authors' custom `rd` program.
- Bootstrapped consumption estimates (Table 8) are not replicated, since they need proprietary SECC microdata.

## 7. How to run
1. Download and unzip the original package from openICPSR (project 109703).
2. In `00_master.R`, set `orig` to the unzipped package and `repo` to this folder.
3. Open `00_master.R` in RStudio and click **Source**. It installs any missing packages (`haven`, `AER`, `sandwich`, `lmtest`, `ggplot2`) and writes everything to `output/`, including a full log.

## 8. Repository structure
```
├── 00_master.R                  # sets paths, runs everything, writes log
├── 01_setup.R                   # sample, controls, helpers (mirrors the paper)
├── 02_table2_first_stage.R      # Table 2 + Figure 4
├── 03_table3_main_indices.R     # Table 3
├── 04_table5_labor.R            # Table 5
├── 05_extension_donut_rd.R      # extension
├── output/                      # tables, figure, log
└── README.md
```
