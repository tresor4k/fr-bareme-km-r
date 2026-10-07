\name{bareme_class}
\alias{bareme_class}
\title{Horsepower class of the French mileage allowance scale}
\description{
Horsepower class of a whole fiscal horsepower, named as in the source:
\code{"cv3_et_moins"}, \code{"cv4"}, \code{"cv5"}, \code{"cv6"},
\code{"cv7_et_plus"} for cars; \code{"cv1_2"}, \code{"cv3_4_5"},
\code{"cv_plus_de_5"} for motorcycles; \code{"toutes"} for mopeds, whose
\code{cv} is ignored.
}
\usage{bareme_class(vehicle, cv)}
\arguments{
  \item{vehicle}{\code{"automobile"}, \code{"motocyclette"} or \code{"cyclomoteur"}.}
  \item{cv}{fiscal horsepower, a whole number >= 1.}
}
\value{A character vector of class names.}
\examples{
bareme_class("automobile", 1:8)
bareme_class("motocyclette", 4)
}
