# Cross-check: writes the table of the installed package for tools/crosscheck.mjs --dump.
# Usage: Rscript tools/dump.R path.tsv   (package frbaremekm installed)
r <- frbaremekm::bareme_rates()
g <- function(x) sprintf("%.17g", x)
lines <- paste("rate", r$year, r$vehicle, r$class, g(r$min_km), g(r$max_km), g(r$coef), g(r$constant), sep = "\t")
y <- 2022:2026
lines <- c(lines, paste("source", y, frbaremekm::bareme_source(y), sep = "\t"))
writeLines(lines, commandArgs(TRUE)[1L], useBytes = TRUE)
