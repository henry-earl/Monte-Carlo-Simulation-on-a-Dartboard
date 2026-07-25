# Ensure the package is installed before running
if (!requireNamespace("circlize", quietly = TRUE)) {
  install.packages("circlize", repos = "https://cloud.r-project.org")
}

print("Starting simulation... (Takes around 50s)")
set.seed(0)

segments <- c(20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5)
skill_levels <- c(0.3, 0.1, 0.05, 0.005, 0.0005)

# Generate points based off radius (skill_level) and target area
gen_points <- function(n, radius, target_x, target_y) {
  theta <- runif(n, 0, 2 * pi)
  R <- sqrt(runif(n, 0, radius))
  X_Samp <- target_x + R * cos(theta)
  Y_Samp <- target_y + R * sin(theta)
  return(cbind(X_Samp, Y_Samp))
}

# Find angle and radius of point to score the dart
score_dart <- function(x, y) {
  r <- sqrt(x^2 + y^2)
  angle <- (90 - atan2(y, x) * 180 / pi) %% 360

  if (r <= 0.037) return(50)
  if (r <= 0.094) return(25)
  if (r > 1.00) return(0)

  segment <- segments[floor(angle / 18) + 1]
  if (r >= 0.953) return(segment * 2)
  if (r >= 0.582 && r <= 0.629) return(segment * 3)
  return(segment)
}

score_points <- function(points) {
  mapply(score_dart, points[, 1], points[, 2])
}

n <- 1000
aim_coords_grid <- seq(-1, 1, length.out = 50)
results <- data.frame(skill = skill_levels, best_x = NA, best_y = NA, best_score = NA)

for (i in 1:length(skill_levels)) {
  radius <- skill_levels[i]
  score_matrix <- matrix(NA, nrow = 50, ncol = 50)

  for (j in 1:50) {
    for (k in 1:50) {
      points <- gen_points(n, radius, aim_coords_grid[j], aim_coords_grid[k])
      score_matrix[j, k] <- mean(score_points(points))
    }
  }

  best_target <- which(score_matrix == max(score_matrix), arr.ind = TRUE)
  results$best_x[i] <- aim_coords_grid[best_target[1, 1]]
  results$best_y[i] <- aim_coords_grid[best_target[1, 2]]
  results$best_score[i] <- max(score_matrix)
}

print(results)

# Save output to avoid rerunning simulation for minor style edits
write.csv(results, "simulation_results.csv", row.names = FALSE)
print("Simulation complete. Data saved to simulation_results.csv")