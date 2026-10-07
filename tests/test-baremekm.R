# Tests without dependency (base R only).
library(frbaremekm)

# fr_bareme_km.pl is an unmodified copy of prolog/fr_bareme_km.pl from the
# SWI-Prolog pack fr_bareme_km 1.0.0 (MIT, same publisher).
src <- readLines("fr_bareme_km.pl", encoding = "UTF-8")

fails <- character()
check <- function(ok, what) if (!isTRUE(ok)) fails <<- c(fails, what)
err_class <- function(expr) tryCatch({ expr; "none" }, baremekm_out_of_scale = function(e) class(e)[1L])

# Replays every bareme_km/5 fact of the pack: same values in the same order,
# and the amount at both ends of each band equals km * coef + constant
# rounded to the cent.
facts <- grep("^bareme_km\\(", src, value = TRUE)
r <- bareme_rates()
check(length(facts) == 135L && nrow(r) == 135L, "135 facts and 135 rates")
rep_cv <- c(cv3_et_moins = 3, cv4 = 4, cv5 = 5, cv6 = 6, cv7_et_plus = 7,
            cv1_2 = 2, cv3_4_5 = 4, cv_plus_de_5 = 6, toutes = 1)
round_cent <- function(x) { y <- x * 100; t <- floor(y); (t + (y - t >= 0.5)) / 100 }
for (i in seq_along(facts)) {
  f <- gsub("^bareme_km\\(|\\)\\)\\.$|tranche\\(|formule\\(|\\)", "", facts[i])
  f <- strsplit(f, ", ", fixed = TRUE)[[1L]]
  num <- function(s) if (s == "inf") Inf else as.numeric(s)
  check(identical(r$year[i], as.integer(f[1L])) && r$vehicle[i] == f[2L] && r$class[i] == f[3L] &&
          r$min_km[i] == num(f[4L]) && r$max_km[i] == num(f[5L]) &&
          r$coef[i] == num(f[6L]) && r$constant[i] == num(f[7L]), paste("fact", i))
  lo <- if (r$min_km[i] == 0) 0 else r$min_km[i] + 1
  hi <- if (is.infinite(r$max_km[i])) r$min_km[i] + 10000 else r$max_km[i]
  for (km in c(lo, hi))
    check(bareme_amount(r$year[i], r$vehicle[i], rep_cv[[r$class[i]]], km) ==
            round_cent(km * r$coef[i] + r$constant[i]), paste("fact", i, km, "km"))
}

# Replays source_bareme/2 and annee_revenus/2.
sources <- regmatches(src, regexec("^source_bareme\\((\\d{4}), '([^']*)'\\)\\.", src))
sources <- Filter(length, sources)
check(length(sources) == 5L, "5 sources")
for (s in sources) {
  y <- as.integer(s[2L])
  check(bareme_source(y) == s[3L], paste("source", y))
  check(bareme_income_year(y) == y - 1L, paste("income year", y))
}

# The cases of test/test_fr_bareme_km.pl.
check(bareme_amount(2026, "automobile", 5, 4000) == 2544, "service_public_2026_5cv_4000km")
check(bareme_amount(2026, "automobile", 3, 10000) == 4225, "auto_2026_3cv_10000km")
check(bareme_amount(2022, "automobile", 9, 25000) == 11150, "auto_2022_9cv_25000km")
check(bareme_amount(2026, "motocyclette", 8, 4500) == 1938.5, "moto_2026_8cv_4500km")
check(bareme_amount(2026, "cyclomoteur", 1, 2000) == 630, "cyclo_2026_2000km")
check(bareme_amount_electric(2026, "automobile", 5, 4000) == 3052.8, "electrique_2026_5cv_4000km")
check(identical(bareme_amount(2026, "automobile", 5, c(5000, 5001)), c(3180, 3180.36)), "limite_tranche")

# Freeze 2023 to 2026: each 2023 rate exists unchanged in 2024, 2025 and 2026.
cols <- c("vehicle", "class", "min_km", "max_km", "coef", "constant")
key <- function(d) do.call(paste, c(d[cols], sep = "|"))
base <- key(r[r$year == 2023L, ])
check(length(base) == 27L, "27 rates in 2023")
for (y in 2024:2026) check(all(base %in% key(r[r$year == y, ])), paste("gel", y))

# Inputs outside the scale.
check(err_class(bareme_amount(2021, "automobile", 5, 4000)) == "baremekm_year", "year 2021")
check(err_class(bareme_amount(2026, "automobile", 0, 100)) == "baremekm_horsepower", "cv 0")
check(err_class(bareme_amount(2026, "motocyclette", -1, 100)) == "baremekm_horsepower", "cv -1")
check(err_class(bareme_amount(2026, "automobile", 4.5, 100)) == "baremekm_horsepower", "cv 4.5")
check(err_class(bareme_amount(2026, "camion", 5, 100)) == "baremekm_vehicle", "vehicle")
for (km in c(-1, NaN, Inf, NA))
  check(err_class(bareme_amount(2026, "automobile", 5, km)) == "baremekm_km", paste("km", km))
check(err_class(bareme_income_year(2027)) == "baremekm_year", "income year 2027")
check(bareme_class("cyclomoteur", 0) == "toutes", "moped ignores cv")
check(identical(bareme_class("automobile", 1:8),
                c(rep("cv3_et_moins", 3), "cv4", "cv5", "cv6", "cv7_et_plus", "cv7_et_plus")), "car classes")

if (length(fails)) stop(length(fails), " failure(s): ", paste(head(fails, 10), collapse = "; "))
cat("all checks passed\n")
