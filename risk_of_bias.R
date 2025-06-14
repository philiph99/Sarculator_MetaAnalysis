# Load libraries
library(dplyr)
library(ggplot2)

# Print package versions to ensure reproducibility
packageVersion("dplyr")
packageVersion("ggplot2")

# Read dataset
dat <- read.csv("./data/dat_rob.csv")

# -------------------------------------------------------------------
# Bar chart 
# -------------------------------------------------------------------
# Re-arrange dataframe for plotting
risk_of_bias <- dat %>%
  tidyr::pivot_longer(cols = c(-Study), names_to = "Domain", values_to = "Judgment") %>%
  group_by(Domain, Judgment) %>%
  summarise(Count = n(), .groups = 'drop')

# Calculate relative numbers
risk_of_bias <- risk_of_bias %>% mutate(prop = (Count/6)*100)
risk_of_bias$Domain <- factor(risk_of_bias$Domain, levels = rev(names(dat)[2:6]))

# Plot
rob_overall <- risk_of_bias %>% 
  ggplot(aes(x = Domain, y = prop, fill = Judgment)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("Low" = "green", "High" = "red", "Unclear" = "yellow")) +
  coord_flip() +  
  labs(
    title = "",
    x = "Domain",
    y = "Proportion of models [%]",
    fill = "Judgment"
  ) +
  theme_minimal() 

# Display plot
rob_overall

# -------------------------------------------------------------------
# Traffic light plot
# -------------------------------------------------------------------
# Convert to long format
data_long <- dat %>%
  tidyr::pivot_longer(-Study, names_to = "Domain", values_to = "Judgment")

# Create numeric position
data_long$Domain <- factor(data_long$Domain, levels = c("Participants", "Predictors", "Outcome", "Analysis", "Overall"))

# Set fill colors
color_map <- c("Low" = "green", "Unclear" = "yellow", "High" = "red")
shape_map <- c("Low" = "+", "Unclear" = "-", "High" = "×")

# Plot
ggplot(data_long, aes(x = Domain, y = Study, fill = Judgment)) +
  geom_point(shape = 21, size = 10, color = "black") +
  scale_fill_manual(values = color_map) +
  geom_text(aes(label = shape_map[Judgment]), size = 5, color = "black") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    panel.grid = element_blank(),
    legend.position = "right"
  ) +
  labs(title = "", x = NULL, y = NULL)
