# -------------------------------------------------------------------
# Load necessary libraries and check package versions
# -------------------------------------------------------------------
library(metamisc)   
library(coda)       
library(ggplot2)    

# Print package versions to ensure reproducibility
packageVersion("metamisc")
packageVersion("coda")
packageVersion("ggplot2")

# Set seed
set.seed(1)  

# Read dataset 
dat <- read.csv("./data/dat_ma.csv")

# -------------------------------------------------------------------
# Frequentist Random-Effects Meta-Analysis
# -------------------------------------------------------------------
# Run meta-analysis
res <- valmeta(
  cstat = c_stat,           
  cstat.cilb = c_stat_LL,   
  cstat.ciub = c_stat_UL,   
  cstat.cilv = 0.95,       
  slab = study,             
  data = dat                
)

# Display meta-analysis results
print(res)   

# -------------------------------------------------------------------
# Bayesian Meta-Analysis
# -------------------------------------------------------------------
# --- Fit Bayesian model ---
bayes <- valmeta(
  cstat = c_stat,           
  cstat.cilb = c_stat_LL,   
  cstat.ciub = c_stat_UL,   
  cstat.cilv = 0.95,       
  slab = study,             
  data = dat,             
  method = "BAYES"         
)

# Display meta-analysis results
print(bayes)  

# --- Visualize Prior Distribution ---

# Inspect prior distribution
bayes$fit$model

# Sequence of values for curve (x-axis)
x_vals <- seq(-5000, 5000, length.out = 1000)  

# Simulate from vague N(0, 1000^2) prior
prior_density <- dnorm(x_vals, mean = 0, sd = 1000)  

df_prior <- data.frame(mu_tobs = x_vals, density = prior_density)  

# Plot prior density on logit scale
ggplot(df_prior, aes(x = mu_tobs, y = density)) +
  geom_line(color = "blue", size = 1) +
  labs(title = "Prior Distribution of the c-Statistic (Logit Scale)",
       x = "logit(c)", y = "Density") +
  theme_minimal()

# --- Posterior Analysis and Visualization ---

# Extract posterior MCMC samples
posterior <- as.mcmc(do.call(rbind, bayes$fit$mcmc))  

# Get samples of pooled logit(c)
mu_tobs_samples <- posterior[, "mu.tobs"]             

# Convert to c-statistic scale
inv_logit <- function(x) {
  exp(x) / (1 + exp(x))
}

c_stat_samples <- inv_logit(mu_tobs_samples)          
posterior_df <- data.frame(var1 = c_stat_samples)   

mean(c_stat_samples)               # Posterior mean of c-statistic
mean(c_stat_samples < 0.7)         # P(c < 0.7)
mean(c_stat_samples < 0.6)         # P(c < 0.6)
mean(c_stat_samples < 0.5)         # P(c < 0.5)

# Density plot of posterior distribution
ggplot(posterior_df, aes(x = var1)) +
  geom_density(fill = "steelblue", alpha = 0.4) +
  labs(title = "Posterior Distribution of the Pooled c-Statistic",
       x = "c-Statistic", y = "Density") +
  coord_cartesian(xlim = c(0.5, 1))  

# --- ECDF (Cumulative Probability) Plot ---
ggplot(posterior_df, aes(x = var1)) +
  stat_ecdf(geom = "step", size = 1) +                         
  geom_vline(xintercept = 0.5, color = "red", linetype = "dashed") +  
  labs(title = "Posterior Cumulative Probability of the c-Statistic",
       x = "c-Statistic", y = expression(P(c < x))) +
  coord_cartesian(xlim = c(0.5, 1))  

# -------------------------------------------------------------------
# Sensitivity Analysis: Exclude study with uncertain risk of bias
# -------------------------------------------------------------------

# Remove Chadha study from dataset
dat_sens <- dat[dat$study != "Chadha, 2024", ]  

# Frequentist analysis (without Chadha)
res_sens <- valmeta(
  cstat = c_stat, 
  cstat.cilb = c_stat_LL, 
  cstat.ciub = c_stat_UL, 
  cstat.cilv = 0.95, 
  slab = study, 
  data = dat_sens
)

# Display meta-analysis results
print(res_sens)  

# Bayesian analysis (without Chadha)
res_sens_bayes <- valmeta(
  cstat = c_stat,
  cstat.cilb = c_stat_LL,
  cstat.ciub = c_stat_UL,
  cstat.cilv = 0.95,
  slab = study,
  data = dat_sens,
  method = "BAYES"
)

# Display meta-analysis results
print(res_sens_bayes)  
