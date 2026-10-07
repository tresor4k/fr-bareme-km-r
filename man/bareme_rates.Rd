\name{bareme_rates}
\alias{bareme_rates}
\title{The 135 rates of the French mileage allowance scale}
\description{
The French tax mileage allowance scale ("bareme kilometrique"), tax returns
2022 to 2026, in the order of the source: one row per distance band.
}
\usage{bareme_rates()}
\value{
A \code{data.frame} of 135 rows and 7 columns:
\describe{
  \item{year}{declaration year (integer).}
  \item{vehicle}{\code{"automobile"}, \code{"motocyclette"} or \code{"cyclomoteur"}.}
  \item{class}{horsepower class, see \code{\link{bareme_class}}.}
  \item{min_km, max_km}{band limits; \code{max_km} is \code{Inf} for the last band.}
  \item{coef, constant}{amount in euros = \code{km * coef + constant}.}
}
}
\source{
Port of the Go package \code{baremekm} (generated from its source), itself a
port of the SWI-Prolog pack \code{fr_bareme_km} 1.0.0. Official sources: BOFIP
BOI-BAREME-000001 (2022, 2023), DGFiP brochures pratiques IR (2024 to 2026),
service-public.gouv.fr A14686 (2026). Dataset: doi:10.17632/5s59m9wycw.1
(CC BY 4.0). See also \code{\link{bareme_source}}.
}
\examples{
r <- bareme_rates()
r[r$year == 2026 & r$vehicle == "automobile", ]
}
