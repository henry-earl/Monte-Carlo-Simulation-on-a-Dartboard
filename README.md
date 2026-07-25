# Dart Throwing Optimization: A Monte Carlo Simulation

This repository contains a simulation framework designed to investigate how a dart player's optimal aim point changes based on their skill level. By modeling throwing inaccuracy as a random distribution around an intended target, we evaluate the expected score across a coordinate grid to find the statistically optimal strategy for players of varying proficiencies.

---

## 📋 Table of Contents
* [What is a Monte Carlo Simulation?](#-what-is-a-monte-carlo-simulation)
* [Experiment Outline](#-experiment-outline)
* [Key Results](#-key-results)
* [Simulation Implementation Details](#-simulation-implementation-details)
* [Project Limitations](#-project-limitations)

---

## 🎲 What is a Monte Carlo Simulation?

A **Monte Carlo simulation** is a computerized mathematical technique used to model the probability of different outcomes in a process that cannot easily be predicted due to the intervention of random variables. Instead of solving a complex problem analytically with exact formulas, it uses repeated random sampling to obtain numerical results.

### How it applies to this project:
1. **Deterministic Strategy, Stochastic Outcome:** When a dart player aims at a specific coordinate (e.g., Treble 20), the input strategy is fixed, but the actual landing position is stochastic (random) due to human error.
2. **Aggregated Sampling:** By simulating $n = 1000$ throws for every single potential aim point, we calculate an average expected score for that specific target. 
3. **Law of Large Numbers:** As the number of simulated throws increases, the average score converges toward the true expected value, allowing us to accurately identify the highest-yielding target coordinates.

---

## 🔬 Experiment Outline

We simulate a dart player throwing at a standard dartboard, modeling the landing positions as uniformly distributed within a circle centered on their aim coordinates. 

* **Skill Representation:** Player skill is modeled inversely to the radius of the error circle. As a player's skill improves, this radius shrinks, reducing the spatial variability and spread around the intended target.
* **Objective:** We evaluate the expected score of every grid position across a 50×50 coordinate grid to determine how the optimal aim point shifts across skill levels—specifically answering whether a beginner and an expert should target the same location.

---

## 📊 Key Results

Our simulations confirm the theory that the **optimal aim point is highly skill-dependent**:

* **Beginners / Less Skilled Players (Radius 0.3 to 0.05):** 
  Due to a large throwing spread, these players should target high-value segment clusters, such as areas around the **19 segment**[cite: 1]. Because their high variability frequently results in misses into adjacent sections, targeting a small, isolated high-value zone (like Treble 20) yields lower expected returns than aiming for regions flanked by high-scoring neighbors[cite: 1].
* **Advanced / Expert Players (Radius 0.005 to 0.0005):** 
  As accuracy improves and the error radius shrinks, the optimal target shifts cleanly into the **20 segment**[cite: 1]. The highest-skilled players maximize their expected value by targeting the **Treble 20** for a potential 60 points[cite: 1]. 
* **Score Nuance:** Even when the optimal target point stabilizes for top-tier skill levels, the simulation's average score metrics show subtle upward differences as the radius continues to shrink, reflecting the elimination of minor outer-edge variance[cite: 1].

![Simulation Results](optimal_aim_points.png)

---

## 💻 Simulation Implementation Details

The core optimization loop is built using R, iterating over defined skill levels and generating a dense coordinate grid to find the maximum expected return[cite: 1]:

```r
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

```
