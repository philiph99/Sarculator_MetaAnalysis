# Frequentist and Bayesian Meta-Analysis of Sarcoma Prognostic Models

This repository contains the code and data used for the meta-analysis conducted as part of my Master's thesis in the MSc Applied Statistics programme. The objective is to evaluate the performance of a prognostic model for sarcomas using both frequentist and Bayesian methods.


## Repository structure
```
+.
+├── data/
+│   ├── dat_ma.csv   # Data for the meta-analysis
+│   └── dat_rob.csv  # Data for the risk of bias plots
+├── meta_analysis.R      # Runs frequentist and Bayesian meta-analyses
+├── forest_plot.R        # Forest plot of the full analysis
+├── forest_plot_sens.R   # Forest plot excluding the study with unclear bias
+└── risk_of_bias.R       # Bar chart and traffic light plot of risk of bias
```

## Usage

1. **Run the meta-analysis**
   Execute `meta_analysis.R` first. This script loads `dat_ma.csv` and performs both frequentist and Bayesian random-effects meta-analyses using the `metamisc` package.

2. **Display forest plots**

   After running the analysis, use `forest_plot.R` to visualise the full results and `forest_plot_sens.R` to view the sensitivity analysis that excludes the study with uncertain risk of bias.

3. **Assess risk of bias**
   
   Run `risk_of_bias.R` to create a bar chart and traffic light plot summarising the risk-of-bias assessments stored in `dat_rob.csv`.

The scripts rely on the packages `metamisc`, `coda`, `ggplot2`, and `dplyr`. Install them in your R environment if they are not already available.

