# frbaremekm (R)

Dependency-free R package published by
[MaCalculatriceEnLigne](https://macalculatriceenligne.com/). Author: Rédaction
MaCalculatrice.

French tax mileage allowance scale ("bareme kilometrique"), used to deduct
professional travel costs ("frais reels") from French income tax.

- Tax returns 2022 to 2026 (income years 2021 to 2025)
- Cars, motorcycles (more than 50 cm3) and mopeds
- 135 rates, three distance bands per horsepower class
- 20 % increase for 100 % electric vehicles

## Installation

R 4.0 or later, base R only.

```r
# install.packages("remotes")
remotes::install_github("tresor4k/fr-bareme-km-r")
```

## Usage

```r
library(frbaremekm)

# 2026 tax return (2025 kilometres), 5 CV car, 4 000 km
bareme_amount(2026, "automobile", 5, 4000)          # 2544

# Same car, 100 % electric
bareme_amount_electric(2026, "automobile", 5, 4000) # 3052.8

# Vectorised: both sides of the 5 000 km band limit
bareme_amount(2026, "automobile", 5, c(5000, 5001)) # 3180 3180.36

bareme_class("motocyclette", 4) # "cv3_4_5"
bareme_income_year(2026)        # 2025
bareme_source(2026)             # official text of the 2026 scale
nrow(bareme_rates())            # 135
```

Vehicles are named as in the source: `"automobile"`, `"motocyclette"`,
`"cyclomoteur"`. Inputs outside the scale (year, vehicle type, horsepower,
distance) signal an error of class `baremekm_out_of_scale` and
`baremekm_year`, `baremekm_vehicle`, `baremekm_horsepower` or `baremekm_km`.

The same computation is available online, in French, with the detail of each
band: [French mileage allowance calculator](https://macalculatriceenligne.com/finance/divers/calcul-frais-kilometriques/).

The rates are a port of the Go package `baremekm`, itself a port of the
SWI-Prolog pack `fr_bareme_km` 1.0.0. `R/rates.R` is generated from the Go
source (`tools/gen_data.mjs`) and cross-checked rate by rate
(`tools/crosscheck.mjs`, 135/135 required); the tests replay each of the 135
facts of the pack and its test cases (`R CMD check`). Official sources: BOFIP
BOI-BAREME-000001 (2022, 2023), DGFiP brochures pratiques IR (2024 to 2026),
service-public.gouv.fr A14686 (2026). Dataset: doi:10.17632/5s59m9wycw.1
(CC BY 4.0).

This package is an aid to calculation, not tax advice. The official texts
prevail.

## Licence

Code: MIT, see LICENSE.md. The scale values are official French tax data
(DGFiP, Licence Ouverte / Open Licence Etalab 2.0).
