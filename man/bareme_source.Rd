\name{bareme_source}
\alias{bareme_source}
\alias{bareme_income_year}
\title{Official source and income year of a declaration year}
\description{
\code{bareme_source} returns the official text against which the scale of a
declaration year was cross-checked. \code{bareme_income_year} returns the
income year whose kilometres are declared (declaration year - 1).
}
\usage{
bareme_source(year)
bareme_income_year(year)
}
\arguments{
  \item{year}{declaration year, 2022 to 2026.}
}
\value{A character vector (\code{bareme_source}) or an integer vector
(\code{bareme_income_year}).}
\examples{
bareme_source(2026)
bareme_income_year(2026) # 2025
}
