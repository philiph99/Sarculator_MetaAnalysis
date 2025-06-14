# Load libraries
library(dplyr)
library(ggplot2)

# Print package versions to ensure reproducibility
packageVersion("dplyr")
packageVersion("ggplot2")

# Sort individual studies by c-statistic ascending
dat_sorted <- dat %>%
  arrange(c_stat) %>%
  mutate(type = "Study")

# Create summary and prediction data
freq_summary <- data.frame(
  study = "Frequentist (Summary Estimate)",
  c_stat = res$est,
  c_stat_LL = res$ci.lb,
  c_stat_UL = res$ci.ub,
  type = "Summary"
)

bayes_summary <- data.frame(
  study = "Bayesian (Summary Estimate)",
  c_stat = bayes$est,
  c_stat_LL = bayes$ci.lb,
  c_stat_UL = bayes$ci.ub,
  type = "Summary"
)

freq_pred <- data.frame(
  study = "Frequentist (Prediction Interval)",
  c_stat = NA,
  c_stat_LL = res$pi.lb,
  c_stat_UL = res$pi.ub,
  type = "Prediction"
)

bayes_pred <- data.frame(
  study = "Bayesian (Prediction Interval)",
  c_stat = NA,
  c_stat_LL = bayes$pi.lb,
  c_stat_UL = bayes$pi.ub,
  type = "Prediction"
)

# Combine all
forest_df <- bind_rows(
  dat_sorted %>% select(study, c_stat, c_stat_LL, c_stat_UL, type),
  freq_summary,
  bayes_summary,
  freq_pred,
  bayes_pred
)

# Set order: studies (ascending) first, then pooled estimates
study_levels <- dat_sorted$study
forest_df$study <- factor(
  forest_df$study,
  levels = rev(c(
    study_levels,
    "Frequentist (Summary Estimate)",
    "Frequentist (Prediction Interval)",
    "Bayesian (Summary Estimate)",
    "Bayesian (Prediction Interval)"
  ))
)

# Forest plot
ggplot(forest_df, aes(x = c_stat, y = study)) +
  # Error bars
  geom_errorbarh(aes(xmin = c_stat_LL, xmax = c_stat_UL), height = 0.2) +
  
  # Study points
  geom_point(data = forest_df %>% filter(type == "Study"), size = 3, shape = 16) +
  
  # Summary estimates as diamonds
  geom_point(
    data = forest_df %>% filter(type == "Summary"),
    aes(shape = type),
    size = 4,
    shape = 23,        
    color = "black",
    fill = "white"     
  ) +

  labs(
    title = "",
    x = "c-Statistic", y = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none") +
  coord_cartesian(xlim = c(0.4, 0.9))