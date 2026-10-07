\name{bareme_amount}
\alias{bareme_amount}
\alias{bareme_amount_electric}
\title{Deductible amount of the French mileage allowance scale}
\description{
Deductible amount in euros, rounded to the cent (half away from zero), for
\code{km} professional kilometres driven in the income year preceding the
declaration year. \code{bareme_amount} applies to thermal, hybrid and hydrogen
vehicles; \code{bareme_amount_electric} adds the 20 \% increase for 100 \%
electric vehicles, applied to the computed amount before rounding.
}
\usage{
bareme_amount(year, vehicle, cv, km)
bareme_amount_electric(year, vehicle, cv, km)
}
\arguments{
  \item{year}{declaration year, 2022 to 2026.}
  \item{vehicle}{\code{"automobile"}, \code{"motocyclette"} (more than 50 cm3)
    or \code{"cyclomoteur"}.}
  \item{cv}{fiscal horsepower, a whole number >= 1 (ignored for mopeds).}
  \item{km}{professional kilometres, a finite number >= 0.}
}
\details{
Arguments are recycled to a common length. The band applies when
\code{min_km < km <= max_km}, or \code{0 <= km <= max_km} for the first band;
amount = \code{km * coef + constant} (see \code{\link{bareme_rates}}).
An input outside the scale signals an error of class
\code{baremekm_out_of_scale} and \code{baremekm_year},
\code{baremekm_vehicle}, \code{baremekm_horsepower} or \code{baremekm_km}.
}
\value{A numeric vector of amounts in euros.}
\source{
French mileage allowance calculator:
\url{https://macalculatriceenligne.com/finance/divers/calcul-frais-kilometriques/}.
This is an aid to calculation, not tax advice. The official texts prevail.
}
\examples{
# 2026 tax return (2025 kilometres), 5 CV car, 4 000 km
bareme_amount(2026, "automobile", 5, 4000)          # 2544
bareme_amount_electric(2026, "automobile", 5, 4000) # 3052.8
bareme_amount(2026, "automobile", 5, c(5000, 5001)) # 3180 3180.36
tryCatch(bareme_amount(2021, "automobile", 5, 4000),
         baremekm_year = function(e) conditionMessage(e))
}
