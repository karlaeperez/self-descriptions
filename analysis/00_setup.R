# =============================================================================
# 00_setup.R
# -----------------------------------------------------------------------------
# Loads packages, defines paths, sets the global seed, and sets the
# control flag that determines whether the embeddings are recomputed.
#
# Run this first! Every other script assumes the objects defined here exist.
# =============================================================================

# ---- Packages ---------------------------------------------------------------

suppressPackageStartupMessages({
  # Data wrangling
  library(tidyverse)     # dplyr, tidyr, purrr, stringr, ggplot2, readr
  library(here)          # project-relative paths (no setwd, no absolute paths)

  # Anonymization
  library(ids)           # random_id() for participant de-identification

  # Semantic similarity 
  library(proxyC)        # fast sparse/dense cosine similarity on matrices

  # Models & effect sizes
  library(lme4)          # mixed-effects models (A3)
  library(lmerTest)      # Satterthwaite df + p-values for lmer
  library(performance)   # R2 (marginal/conditional), ICC, model checks
  library(effectsize)    # eta_squared, cohens_d, standardized effects
  library(emmeans)       # estimated marginal means / contrasts
})

# ---- Paths ------------------------------------------------------------------
# All I/O goes through these. Change the root once and the pipeline follows.
PATHS <- list(
  data_raw       = here("data", "raw"),         # never committed; gitignored
  data_interim   = here("data", "interim"),     # de-identified, gitignored
  data_processed = here("data", "processed"),   # committed for reproducibility
  outputs        = here("outputs")              # figures, tables
)
invisible(lapply(PATHS, function(p) if (!dir.exists(p)) dir.create(p, recursive = TRUE)))

required_raw <- file.path(PATHS$data_raw, c("data_adults.csv", "data_children.csv"))
missing_raw  <- required_raw[!file.exists(required_raw)]
if (length(missing_raw) > 0) {
  message(
    "\n[SETUP] Created project folders. Before running the pipeline, place ",
    "the raw data files in data/raw/:\n  - ",
    paste(basename(missing_raw), collapse = "\n  - "),
    "\nThese are not in the repo because they contain identifiable data."
  )
}

# ---- Reproducibility --------------------------------------------------------
# Global seed to standardize starting point (safety net)
# Still need to set local seeds before every random process
GLOBAL_SEED <- 260507
set.seed(GLOBAL_SEED)

# ---- Control flags ----------------------------------------------------------
# EMBED = TRUE  -> 02_embed.R recomputes the 768-d SBERT embeddings from text.
#                  Requires the `text` package + a working Python backend.
#                  
# EMBED = FALSE -> 02_embed.R loads the cached embedded responses from
#                  data/processed/.
EMBED <- FALSE

# ---- Project constants ------------------------------------------------------
# Centralized so a single edit propagates everywhere (e.g. swapping the model).
SBERT_MODEL   <- "sentence-transformers/all-distilroberta-v1"  # 768-d, L2 later
EMBED_DIM     <- 768
PALETTE       <- c(adult = "#648FFF", child = "#FE6100")       # colorblind-safe
SKIP_TOKEN    <- "no_response"  # sentinel produced during data entry/preprocessing

message("Setup complete. EMBED = ", EMBED, " | seed = ", GLOBAL_SEED)
