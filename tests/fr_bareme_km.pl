/*  fr_bareme_km -- French tax mileage allowance scale (bareme kilometrique)

    Coefficients of the French "bareme kilometrique" used to deduct
    professional travel costs ("frais reels") from income tax, for five
    tax returns: declaration years 2022 to 2026 (income years 2021-2025).

    Data: dataset "Bareme kilometrique fiscal France 2022-2026"
    (MaCalculatriceEnLigne, DOI 10.17632/5s59m9wycw.1, CC BY 4.0),
    each value cross-checked against the official texts listed in
    source_bareme/2 (BOFIP, DGFiP brochures, service-public.gouv.fr).

    Code: MIT licence. See LICENSE and README.md.
    Home: https://macalculatriceenligne.com/finance/divers/calcul-frais-kilometriques/
*/

:- module(fr_bareme_km,
          [ bareme_km/5,          % ?Annee, ?Vehicule, ?Classe, ?Tranche, ?Formule
            classe_puissance/3,   % +Vehicule, +CV, -Classe
            frais_km/5,           % +Annee, +Vehicule, +CV, +Km, -Montant
            frais_km/6,           % +Annee, +Vehicule, +CV, +Km, +Options, -Montant
            annee_revenus/2,      % ?AnneeDeclaration, ?AnneeRevenus
            source_bareme/2       % ?AnneeDeclaration, ?Source
          ]).

/** <module> French tax mileage allowance scale (bareme kilometrique)

Schema of the facts:

    bareme_km(Annee, Vehicule, Classe, tranche(Min, Max), formule(Coef, Constante))

  - Annee: year of the tax return (annee de declaration), 2022..2026.
    The kilometres are those driven the previous year (see annee_revenus/2).
  - Vehicule: automobile, motocyclette (more than 50 cm3) or cyclomoteur.
  - Classe: fiscal horsepower class (see classe_puissance/3).
  - tranche(Min, Max): the band applies when Min < Km =< Max
    (first band: 0 =< Km =< Max). Max = inf for the last band.
  - formule(Coef, Constante): Montant = Km * Coef + Constante (euros).

Electric vehicles: +20 % on the amount (CGI, annexe IV, art. 6 B, II),
option electrique(true) of frais_km/6.
*/

%!  classe_puissance(+Vehicule, +CV, -Classe) is semidet.
%
%   Maps a fiscal horsepower (integer CV) to the class used by the scale.
%   Cyclomoteurs have a single class (toutes), CV is ignored.

classe_puissance(automobile, CV, Classe) :-
    integer(CV), CV >= 1,
    (   CV =< 3 -> Classe = cv3_et_moins
    ;   CV =:= 4 -> Classe = cv4
    ;   CV =:= 5 -> Classe = cv5
    ;   CV =:= 6 -> Classe = cv6
    ;   Classe = cv7_et_plus
    ).
classe_puissance(motocyclette, CV, Classe) :-
    integer(CV), CV >= 1,
    (   CV =< 2 -> Classe = cv1_2
    ;   CV =< 5 -> Classe = cv3_4_5
    ;   Classe = cv_plus_de_5
    ).
classe_puissance(cyclomoteur, _, toutes).

%!  frais_km(+Annee, +Vehicule, +CV, +Km, -Montant) is semidet.
%
%   Deductible amount in euros (rounded to the cent) for Km professional
%   kilometres, thermal / hybrid / hydrogen vehicle.

frais_km(Annee, Vehicule, CV, Km, Montant) :-
    frais_km(Annee, Vehicule, CV, Km, [], Montant).

%!  frais_km(+Annee, +Vehicule, +CV, +Km, +Options, -Montant) is semidet.
%
%   As frais_km/5. Options: electrique(true) applies the 20 % increase
%   for 100 % electric vehicles.

frais_km(Annee, Vehicule, CV, Km, Options, Montant) :-
    number(Km), Km >= 0,
    classe_puissance(Vehicule, CV, Classe),
    bareme_km(Annee, Vehicule, Classe, Tranche, formule(Coef, Constante)),
    dans_tranche(Km, Tranche),
    !,
    Brut is Km * Coef + Constante,
    (   memberchk(electrique(true), Options)
    ->  Total is Brut * 1.2
    ;   Total = Brut
    ),
    Montant is round(Total * 100) / 100.

dans_tranche(Km, tranche(0, Max)) :-
    !,
    Km =< Max.
dans_tranche(Km, tranche(Min, Max)) :-
    Km > Min,
    (   Max == inf -> true ; Km =< Max ).

%!  annee_revenus(?AnneeDeclaration, ?AnneeRevenus) is nondet.
%
%   The 2026 scale (declaration year) applies to 2025 income/kilometres.

annee_revenus(Decl, Rev) :-
    source_bareme(Decl, _),
    Rev is Decl - 1.

%!  source_bareme(?AnneeDeclaration, ?Source) is nondet.
%
%   Official text against which each year was cross-checked.

source_bareme(2022, 'BOFIP BOI-BAREME-000001-20230720, II-B and III (revenus 2021)').
source_bareme(2023, 'BOFIP BOI-BAREME-000001-20230720, II-A and III (revenus 2022)').
source_bareme(2024, 'DGFiP, brochure pratique IR 2024, traitements et salaires').
source_bareme(2025, 'DGFiP, brochure pratique IR 2025, traitements et salaires').
source_bareme(2026, 'service-public.gouv.fr actualite A14686 (09/04/2026) and DGFiP brochure pratique IR 2026').

%!  bareme_km(?Annee, ?Vehicule, ?Classe, ?Tranche, ?Formule) is nondet.
%
%   135 facts: 5 years x (15 automobile + 9 motocyclette + 3 cyclomoteur).

bareme_km(2022, automobile, cv3_et_moins, tranche(0, 5000), formule(0.502, 0)).
bareme_km(2022, automobile, cv3_et_moins, tranche(5000, 20000), formule(0.300, 1007)).
bareme_km(2022, automobile, cv3_et_moins, tranche(20000, inf), formule(0.350, 0)).
bareme_km(2022, automobile, cv4, tranche(0, 5000), formule(0.575, 0)).
bareme_km(2022, automobile, cv4, tranche(5000, 20000), formule(0.323, 1262)).
bareme_km(2022, automobile, cv4, tranche(20000, inf), formule(0.387, 0)).
bareme_km(2022, automobile, cv5, tranche(0, 5000), formule(0.603, 0)).
bareme_km(2022, automobile, cv5, tranche(5000, 20000), formule(0.339, 1320)).
bareme_km(2022, automobile, cv5, tranche(20000, inf), formule(0.405, 0)).
bareme_km(2022, automobile, cv6, tranche(0, 5000), formule(0.631, 0)).
bareme_km(2022, automobile, cv6, tranche(5000, 20000), formule(0.355, 1382)).
bareme_km(2022, automobile, cv6, tranche(20000, inf), formule(0.425, 0)).
bareme_km(2022, automobile, cv7_et_plus, tranche(0, 5000), formule(0.661, 0)).
bareme_km(2022, automobile, cv7_et_plus, tranche(5000, 20000), formule(0.374, 1435)).
bareme_km(2022, automobile, cv7_et_plus, tranche(20000, inf), formule(0.446, 0)).

bareme_km(2022, motocyclette, cv1_2, tranche(0, 3000), formule(0.375, 0)).
bareme_km(2022, motocyclette, cv1_2, tranche(3000, 6000), formule(0.094, 845)).
bareme_km(2022, motocyclette, cv1_2, tranche(6000, inf), formule(0.234, 0)).
bareme_km(2022, motocyclette, cv3_4_5, tranche(0, 3000), formule(0.444, 0)).
bareme_km(2022, motocyclette, cv3_4_5, tranche(3000, 6000), formule(0.078, 1099)).
bareme_km(2022, motocyclette, cv3_4_5, tranche(6000, inf), formule(0.261, 0)).
bareme_km(2022, motocyclette, cv_plus_de_5, tranche(0, 3000), formule(0.575, 0)).
bareme_km(2022, motocyclette, cv_plus_de_5, tranche(3000, 6000), formule(0.075, 1502)).
bareme_km(2022, motocyclette, cv_plus_de_5, tranche(6000, inf), formule(0.325, 0)).

bareme_km(2022, cyclomoteur, toutes, tranche(0, 3000), formule(0.299, 0)).
bareme_km(2022, cyclomoteur, toutes, tranche(3000, 6000), formule(0.070, 458)).
bareme_km(2022, cyclomoteur, toutes, tranche(6000, inf), formule(0.162, 0)).

bareme_km(2023, automobile, cv3_et_moins, tranche(0, 5000), formule(0.529, 0)).
bareme_km(2023, automobile, cv3_et_moins, tranche(5000, 20000), formule(0.316, 1065)).
bareme_km(2023, automobile, cv3_et_moins, tranche(20000, inf), formule(0.370, 0)).
bareme_km(2023, automobile, cv4, tranche(0, 5000), formule(0.606, 0)).
bareme_km(2023, automobile, cv4, tranche(5000, 20000), formule(0.340, 1330)).
bareme_km(2023, automobile, cv4, tranche(20000, inf), formule(0.407, 0)).
bareme_km(2023, automobile, cv5, tranche(0, 5000), formule(0.636, 0)).
bareme_km(2023, automobile, cv5, tranche(5000, 20000), formule(0.357, 1395)).
bareme_km(2023, automobile, cv5, tranche(20000, inf), formule(0.427, 0)).
bareme_km(2023, automobile, cv6, tranche(0, 5000), formule(0.665, 0)).
bareme_km(2023, automobile, cv6, tranche(5000, 20000), formule(0.374, 1457)).
bareme_km(2023, automobile, cv6, tranche(20000, inf), formule(0.447, 0)).
bareme_km(2023, automobile, cv7_et_plus, tranche(0, 5000), formule(0.697, 0)).
bareme_km(2023, automobile, cv7_et_plus, tranche(5000, 20000), formule(0.394, 1515)).
bareme_km(2023, automobile, cv7_et_plus, tranche(20000, inf), formule(0.470, 0)).

bareme_km(2023, motocyclette, cv1_2, tranche(0, 3000), formule(0.395, 0)).
bareme_km(2023, motocyclette, cv1_2, tranche(3000, 6000), formule(0.099, 891)).
bareme_km(2023, motocyclette, cv1_2, tranche(6000, inf), formule(0.248, 0)).
bareme_km(2023, motocyclette, cv3_4_5, tranche(0, 3000), formule(0.468, 0)).
bareme_km(2023, motocyclette, cv3_4_5, tranche(3000, 6000), formule(0.082, 1158)).
bareme_km(2023, motocyclette, cv3_4_5, tranche(6000, inf), formule(0.275, 0)).
bareme_km(2023, motocyclette, cv_plus_de_5, tranche(0, 3000), formule(0.606, 0)).
bareme_km(2023, motocyclette, cv_plus_de_5, tranche(3000, 6000), formule(0.079, 1583)).
bareme_km(2023, motocyclette, cv_plus_de_5, tranche(6000, inf), formule(0.343, 0)).

bareme_km(2023, cyclomoteur, toutes, tranche(0, 3000), formule(0.315, 0)).
bareme_km(2023, cyclomoteur, toutes, tranche(3000, 6000), formule(0.079, 711)).
bareme_km(2023, cyclomoteur, toutes, tranche(6000, inf), formule(0.198, 0)).

bareme_km(2024, automobile, cv3_et_moins, tranche(0, 5000), formule(0.529, 0)).
bareme_km(2024, automobile, cv3_et_moins, tranche(5000, 20000), formule(0.316, 1065)).
bareme_km(2024, automobile, cv3_et_moins, tranche(20000, inf), formule(0.370, 0)).
bareme_km(2024, automobile, cv4, tranche(0, 5000), formule(0.606, 0)).
bareme_km(2024, automobile, cv4, tranche(5000, 20000), formule(0.340, 1330)).
bareme_km(2024, automobile, cv4, tranche(20000, inf), formule(0.407, 0)).
bareme_km(2024, automobile, cv5, tranche(0, 5000), formule(0.636, 0)).
bareme_km(2024, automobile, cv5, tranche(5000, 20000), formule(0.357, 1395)).
bareme_km(2024, automobile, cv5, tranche(20000, inf), formule(0.427, 0)).
bareme_km(2024, automobile, cv6, tranche(0, 5000), formule(0.665, 0)).
bareme_km(2024, automobile, cv6, tranche(5000, 20000), formule(0.374, 1457)).
bareme_km(2024, automobile, cv6, tranche(20000, inf), formule(0.447, 0)).
bareme_km(2024, automobile, cv7_et_plus, tranche(0, 5000), formule(0.697, 0)).
bareme_km(2024, automobile, cv7_et_plus, tranche(5000, 20000), formule(0.394, 1515)).
bareme_km(2024, automobile, cv7_et_plus, tranche(20000, inf), formule(0.470, 0)).

bareme_km(2024, motocyclette, cv1_2, tranche(0, 3000), formule(0.395, 0)).
bareme_km(2024, motocyclette, cv1_2, tranche(3000, 6000), formule(0.099, 891)).
bareme_km(2024, motocyclette, cv1_2, tranche(6000, inf), formule(0.248, 0)).
bareme_km(2024, motocyclette, cv3_4_5, tranche(0, 3000), formule(0.468, 0)).
bareme_km(2024, motocyclette, cv3_4_5, tranche(3000, 6000), formule(0.082, 1158)).
bareme_km(2024, motocyclette, cv3_4_5, tranche(6000, inf), formule(0.275, 0)).
bareme_km(2024, motocyclette, cv_plus_de_5, tranche(0, 3000), formule(0.606, 0)).
bareme_km(2024, motocyclette, cv_plus_de_5, tranche(3000, 6000), formule(0.079, 1583)).
bareme_km(2024, motocyclette, cv_plus_de_5, tranche(6000, inf), formule(0.343, 0)).

bareme_km(2024, cyclomoteur, toutes, tranche(0, 3000), formule(0.315, 0)).
bareme_km(2024, cyclomoteur, toutes, tranche(3000, 6000), formule(0.079, 711)).
bareme_km(2024, cyclomoteur, toutes, tranche(6000, inf), formule(0.198, 0)).

bareme_km(2025, automobile, cv3_et_moins, tranche(0, 5000), formule(0.529, 0)).
bareme_km(2025, automobile, cv3_et_moins, tranche(5000, 20000), formule(0.316, 1065)).
bareme_km(2025, automobile, cv3_et_moins, tranche(20000, inf), formule(0.370, 0)).
bareme_km(2025, automobile, cv4, tranche(0, 5000), formule(0.606, 0)).
bareme_km(2025, automobile, cv4, tranche(5000, 20000), formule(0.340, 1330)).
bareme_km(2025, automobile, cv4, tranche(20000, inf), formule(0.407, 0)).
bareme_km(2025, automobile, cv5, tranche(0, 5000), formule(0.636, 0)).
bareme_km(2025, automobile, cv5, tranche(5000, 20000), formule(0.357, 1395)).
bareme_km(2025, automobile, cv5, tranche(20000, inf), formule(0.427, 0)).
bareme_km(2025, automobile, cv6, tranche(0, 5000), formule(0.665, 0)).
bareme_km(2025, automobile, cv6, tranche(5000, 20000), formule(0.374, 1457)).
bareme_km(2025, automobile, cv6, tranche(20000, inf), formule(0.447, 0)).
bareme_km(2025, automobile, cv7_et_plus, tranche(0, 5000), formule(0.697, 0)).
bareme_km(2025, automobile, cv7_et_plus, tranche(5000, 20000), formule(0.394, 1515)).
bareme_km(2025, automobile, cv7_et_plus, tranche(20000, inf), formule(0.470, 0)).

bareme_km(2025, motocyclette, cv1_2, tranche(0, 3000), formule(0.395, 0)).
bareme_km(2025, motocyclette, cv1_2, tranche(3000, 6000), formule(0.099, 891)).
bareme_km(2025, motocyclette, cv1_2, tranche(6000, inf), formule(0.248, 0)).
bareme_km(2025, motocyclette, cv3_4_5, tranche(0, 3000), formule(0.468, 0)).
bareme_km(2025, motocyclette, cv3_4_5, tranche(3000, 6000), formule(0.082, 1158)).
bareme_km(2025, motocyclette, cv3_4_5, tranche(6000, inf), formule(0.275, 0)).
bareme_km(2025, motocyclette, cv_plus_de_5, tranche(0, 3000), formule(0.606, 0)).
bareme_km(2025, motocyclette, cv_plus_de_5, tranche(3000, 6000), formule(0.079, 1583)).
bareme_km(2025, motocyclette, cv_plus_de_5, tranche(6000, inf), formule(0.343, 0)).

bareme_km(2025, cyclomoteur, toutes, tranche(0, 3000), formule(0.315, 0)).
bareme_km(2025, cyclomoteur, toutes, tranche(3000, 6000), formule(0.079, 711)).
bareme_km(2025, cyclomoteur, toutes, tranche(6000, inf), formule(0.198, 0)).

bareme_km(2026, automobile, cv3_et_moins, tranche(0, 5000), formule(0.529, 0)).
bareme_km(2026, automobile, cv3_et_moins, tranche(5000, 20000), formule(0.316, 1065)).
bareme_km(2026, automobile, cv3_et_moins, tranche(20000, inf), formule(0.370, 0)).
bareme_km(2026, automobile, cv4, tranche(0, 5000), formule(0.606, 0)).
bareme_km(2026, automobile, cv4, tranche(5000, 20000), formule(0.340, 1330)).
bareme_km(2026, automobile, cv4, tranche(20000, inf), formule(0.407, 0)).
bareme_km(2026, automobile, cv5, tranche(0, 5000), formule(0.636, 0)).
bareme_km(2026, automobile, cv5, tranche(5000, 20000), formule(0.357, 1395)).
bareme_km(2026, automobile, cv5, tranche(20000, inf), formule(0.427, 0)).
bareme_km(2026, automobile, cv6, tranche(0, 5000), formule(0.665, 0)).
bareme_km(2026, automobile, cv6, tranche(5000, 20000), formule(0.374, 1457)).
bareme_km(2026, automobile, cv6, tranche(20000, inf), formule(0.447, 0)).
bareme_km(2026, automobile, cv7_et_plus, tranche(0, 5000), formule(0.697, 0)).
bareme_km(2026, automobile, cv7_et_plus, tranche(5000, 20000), formule(0.394, 1515)).
bareme_km(2026, automobile, cv7_et_plus, tranche(20000, inf), formule(0.470, 0)).

bareme_km(2026, motocyclette, cv1_2, tranche(0, 3000), formule(0.395, 0)).
bareme_km(2026, motocyclette, cv1_2, tranche(3000, 6000), formule(0.099, 891)).
bareme_km(2026, motocyclette, cv1_2, tranche(6000, inf), formule(0.248, 0)).
bareme_km(2026, motocyclette, cv3_4_5, tranche(0, 3000), formule(0.468, 0)).
bareme_km(2026, motocyclette, cv3_4_5, tranche(3000, 6000), formule(0.082, 1158)).
bareme_km(2026, motocyclette, cv3_4_5, tranche(6000, inf), formule(0.275, 0)).
bareme_km(2026, motocyclette, cv_plus_de_5, tranche(0, 3000), formule(0.606, 0)).
bareme_km(2026, motocyclette, cv_plus_de_5, tranche(3000, 6000), formule(0.079, 1583)).
bareme_km(2026, motocyclette, cv_plus_de_5, tranche(6000, inf), formule(0.343, 0)).

bareme_km(2026, cyclomoteur, toutes, tranche(0, 3000), formule(0.315, 0)).
bareme_km(2026, cyclomoteur, toutes, tranche(3000, 6000), formule(0.079, 711)).
bareme_km(2026, cyclomoteur, toutes, tranche(6000, inf), formule(0.198, 0)).
