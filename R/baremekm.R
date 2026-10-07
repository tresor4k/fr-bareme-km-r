# French tax mileage allowance scale ("bareme kilometrique"), tax returns
# 2022 to 2026 (income years 2021 to 2025), with the 20 % increase for
# 100 % electric vehicles. Port of the Go package baremekm.
#
# Published by MaCalculatriceEnLigne:
# https://macalculatriceenligne.com/finance/divers/calcul-frais-kilometriques/

vehicles <- c("automobile", "motocyclette", "cyclomoteur")

# Signals an input outside the scale, as a condition of classes
# baremekm_<field>, baremekm_out_of_scale, error.
out_of_scale <- function(field, value, msg) {
  cond <- structure(
    class = c(paste0("baremekm_", field), "baremekm_out_of_scale", "error", "condition"),
    list(message = sprintf("baremekm: %s %s: %s", field, format(value), msg),
         call = NULL, field = field, value = value)
  )
  stop(cond)
}

is_whole <- function(x) is.numeric(x) && length(x) == 1L && !is.na(x) && is.finite(x) && x == trunc(x)

# Go math.Round: half away from zero (amounts are never negative).
round_cent <- function(x) {
  y <- x * 100
  t <- floor(y)
  (t + (y - t >= 0.5)) / 100
}

class_one <- function(vehicle, cv) {
  if (!is.character(vehicle) || length(vehicle) != 1L || is.na(vehicle) || !(vehicle %in% vehicles))
    out_of_scale("vehicle", vehicle, "unknown vehicle type")
  if (vehicle == "cyclomoteur") return("toutes")
  if (!is_whole(cv) || cv < 1)
    out_of_scale("horsepower", cv, "fiscal horsepower must be a whole number >= 1")
  if (vehicle == "automobile") {
    if (cv <= 3) "cv3_et_moins" else if (cv == 4) "cv4" else if (cv == 5) "cv5" else if (cv == 6) "cv6" else "cv7_et_plus"
  } else {
    if (cv <= 2) "cv1_2" else if (cv <= 5) "cv3_4_5" else "cv_plus_de_5"
  }
}

amount_one <- function(year, vehicle, cv, km, electric) {
  if (!is.numeric(km) || length(km) != 1L || is.na(km) || !is.finite(km) || km < 0)
    out_of_scale("km", km, "distance must be a finite number >= 0")
  cls <- class_one(vehicle, cv)
  t <- rates_table
  i <- which(t$year == year & t$vehicle == vehicle & t$class == cls &
               (t$min_km == 0 | km > t$min_km) & km <= t$max_km)
  if (length(i) == 0L)
    out_of_scale("year", year, "declaration year not covered by the scale")
  total <- km * t$coef[i[1L]] + t$constant[i[1L]]
  if (electric) total <- total * 1.2
  round_cent(total)
}

bareme_rates <- function() rates_table

bareme_class <- function(vehicle, cv) {
  as.character(mapply(class_one, vehicle, cv, USE.NAMES = FALSE))
}

bareme_amount <- function(year, vehicle, cv, km) {
  as.numeric(mapply(amount_one, year, vehicle, cv, km, MoreArgs = list(electric = FALSE), USE.NAMES = FALSE))
}

bareme_amount_electric <- function(year, vehicle, cv, km) {
  as.numeric(mapply(amount_one, year, vehicle, cv, km, MoreArgs = list(electric = TRUE), USE.NAMES = FALSE))
}

bareme_source <- function(year) {
  vapply(year, function(y) {
    if (!is_whole(y) || !(as.character(y) %in% names(source_texts)))
      out_of_scale("year", y, "declaration year not covered by the scale")
    unname(source_texts[[as.character(y)]])
  }, character(1), USE.NAMES = FALSE)
}

bareme_income_year <- function(year) {
  bareme_source(year)
  as.integer(year) - 1L
}
