library(circlize)

if (!file.exists("simulation_results.csv")) {
  stop("Missing 'simulation_results.csv'. Please run simulate.R first.")
}

results <- read.csv("simulation_results.csv")
print("Generating plot image...")

# Setup output graphic file device
png("optimal_dart_targets.png", width = 900, height = 900, res = 130)

circos.clear()
fcts <- 1:20

circos.par(
  "gap.degree" = 0, 
  "cell.padding" = c(0, 0, 0, 0),
  start.degree = 360 / 40, 
  track.margin = c(0, 0), 
  "clock.wise" = FALSE
)

circos.initialize(factors = fcts, xlim = c(0, 1))
circos.trackPlotRegion(ylim = c(0, 1), factors = fcts, bg.col = "black", track.height = 0.15)

circos.trackText(
  rep(0.5, 20), rep(0.5, 20), rep(0.5, 20),
  labels = c(13, 4, 18, 1, 20, 5, 12, 9, 14, 11, 8, 16, 7, 19, 3, 17, 2, 15, 10, 6),
  factors = fcts, col = "#EEEEEE", font = 2, facing = "downward"
)

# Double ring
circos.trackPlotRegion(ylim = c(0, 1), factors = fcts, bg.col = rep(c("#df2623", "#11a551"), 10), bg.border = "#EEEEEE", track.height = 0.05)
# Outer single segments
circos.trackPlotRegion(ylim = c(0, 1), factors = fcts, bg.col = rep(c("black", "#e6cda5"), 10), bg.border = "#EEEEEE", track.height = 0.275)
# Triple ring
circos.trackPlotRegion(ylim = c(0, 1), factors = fcts, bg.col = rep(c("#df2623", "#11a551"), 10), bg.border = "#EEEEEE", track.height = 0.05)
# Inner single segments
circos.trackPlotRegion(ylim = c(0, 1), factors = fcts, bg.col = rep(c("black", "#e6cda5"), 10), bg.border = "#EEEEEE", track.height = 0.375)

# Outer Bullseye (25 pts)
draw.sector(center = c(0, 0), start.degree = 0, end.degree = 360, rou1 = 0.1, col = "#11a551", border = "#EEEEEE")
# Inner Bullseye (50 pts)
draw.sector(center = c(0, 0), start.degree = 0, end.degree = 360, rou1 = 0.05, col = "#df2623", border = "#EEEEEE")

title("Optimal Target by Skill Level")
colors <- c("#FF0000", "#FF6600", "#0000FF", "#00CC00", "#FFCC00")
labels <- c("Skill 0.3", "Skill 0.1", "Skill 0.05", "Skill 0.005", "Skill 0.0005")

# Coordinate mapping scaling adjustments
graph_treble <- 1 - 0.15 - 0.05 - 0.275 - 0.025
sim_treble   <- (0.582 + 0.629) / 2
scale_factor <- graph_treble / sim_treble
rotation     <- 9 * pi / 180

# Overlay optimized data points onto the layout
for (i in 1:nrow(results)) {
  x <- results$best_x[i] * scale_factor
  y <- results$best_y[i] * scale_factor

  x_rot <- x * cos(rotation) - y * sin(rotation)
  y_rot <- x * sin(rotation) + y * cos(rotation)

  points(x_rot, y_rot, pch = 19, col = colors[i], cex = 1.6)
}

legend(
  "topright",
  inset   = c(-0.05, 0),
  legend  = paste0(labels, " (", round(results$best_score, 1), " pts)"),
  col     = colors,
  pch     = 19,
  cex     = 0.8,
  bg      = "white",
  xpd     = TRUE
)

circos.clear()
dev.off() # Render the image file cleanly

print("Plot successfully saved as 'optimal_dart_targets.png'")