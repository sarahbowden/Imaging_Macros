#!/usr/local/bin/Rscript

# ------------------------------------------------------------------------------
# count_plotQuantification.R
# Batch script to create annotated boxplots from CSVs - COUNT EDITION
# Export as TIFF and PDF
# ------------------------------------------------------------------------------

# Load required libraries (install manually before first run if needed)
library(ggplot2)
library(dplyr)
library(readr)
library(stringr)
library(rlang)

# --- Command-line input ---
args <- commandArgs(trailingOnly = TRUE)
data_folder <- args[1]
output_folder <- args[2]

# --- Find input files ---
csv_files <- list.files(data_folder, pattern = "\\.csv$", full.names = TRUE)

# --- Create output directory if needed ---
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

# --- Plotting function (now takes y_upper) ---
create_plot <- function(data, file_name, plot_data, group_var, value_var, y_upper) {
  data[[group_var]] <- factor(data[[group_var]], levels = unique(data[[group_var]]))

  ggplot(data, aes(x = .data[[group_var]], y = .data[[value_var]])) +
    geom_boxplot(outlier.shape = NA, fill = "lightgray", color = "black") +
    geom_jitter(width = 0.2, size = 2, alpha = 0.7, color = "steelblue") +
    geom_text(
      data = plot_data,
      aes(x = Group, y = y_position, label = paste0("p = ", signif(p_value, 2)), color = color),
      inherit.aes = FALSE,
      size = 4
    ) +
    scale_color_identity() +
    # Dynamic y-axis with a touch of headroom
    scale_y_continuous(limits = c(0, y_upper), expand = expansion(mult = c(0, 0.02))) +
    labs(
      title = paste(str_remove(basename(file_name), "\\.csv$"), "Count"),
      x = group_var,
      y = value_var
    ) +
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      panel.background = element_blank(),
      plot.background = element_blank(),
      axis.line = element_line(color = "black"),
      axis.ticks.y = element_line(color = "black"),
      axis.text.y = element_text(color = "black"),
      axis.text.x = element_text(color = "black")
    )
}

# --- Loop through each CSV file ---
for (file in csv_files) {
  data <- read_csv(file)

  group_var <- names(data)[1]
  value_var <- names(data)[3] # COUNT COLUMN

  # Print data point counts per condition
  cat("Data counts for file:", basename(file), "\n")
  print(data %>% count(.data[[group_var]]))
  cat("\n")
  
  # Convert to factor
  data[[group_var]] <- factor(data[[group_var]], levels = unique(data[[group_var]]))

  control_group <- "UC"
  if (!control_group %in% data[[group_var]]) {
    warning("Skipping file (no control group): ", file)
    next
  }

  other_groups <- setdiff(unique(data[[group_var]]), control_group)

  # --- Dynamic y-axis calculation ---
  y_data_max <- max(data[[value_var]], na.rm = TRUE)
  # Add ~10% headroom; fall back to 1 if all zeros/NA
  y_upper <- if (is.finite(y_data_max) && y_data_max > 0) y_data_max * 1.10 else 1

  # Precompute dynamic label positions near the top
  top_line    <- y_upper * 0.97
  second_line <- y_upper * 0.94

  # --- Compute p-values for comparisons vs UC ---
  p_values <- data.frame(Group = character(), p_value = numeric(), color = character(), stringsAsFactors = FALSE)

  for (g in other_groups) {
    group_data <- data %>%
      filter(.data[[group_var]] %in% c(control_group, g))

    test <- wilcox.test(group_data[[value_var]] ~ group_data[[group_var]])
    p_values <- rbind(p_values, data.frame(Group = g, p_value = test$p.value, color = "black"))
  }

  # Position black p-values at dynamic top
  plot_data <- data.frame(
    Group = p_values$Group,
    p_value = p_values$p_value,
    y_position = top_line,
    color = p_values$color
  )

  # --- Additional Rescue vs MO comparison (dynamic position) ---
  # Only in cases where a rescue condition exists (name ends with "Rescue")
  rescue_group <- grep("Rescue$", unique(data[[group_var]]), value = TRUE)
  mo_group <- grep("MO$", unique(data[[group_var]]), value = TRUE)

  if (length(rescue_group) == 1 && length(mo_group) == 1) {
    rescue_mo_data <- data %>%
      filter(.data[[group_var]] %in% c(rescue_group, mo_group))

    rescue_mo_test <- wilcox.test(rescue_mo_data[[value_var]] ~ rescue_mo_data[[group_var]])

    plot_data <- rbind(plot_data, data.frame(
      Group      = rescue_group,
      p_value    = rescue_mo_test$p.value,
      y_position = second_line,
      color      = "red"
    ))
  }

  # Create and save plot
  plot <- create_plot(data, file, plot_data, group_var, value_var, y_upper)

  # Create base filename without extension
  base_name <- str_replace(basename(file), "\\.csv$", "")

  # Save plot as TIFF
  ggsave(
    filename = file.path(output_folder, paste0(base_name, ".tiff")),
    plot = plot,
    width = 8, height = 6
  )

  # Save plot as PDF
  ggsave(
    filename = file.path(output_folder, paste0(base_name, ".pdf")),
    plot = plot,
    width = 8, height = 6
  )
  
  message("✅ Saved plots for: ", basename(file))
}
