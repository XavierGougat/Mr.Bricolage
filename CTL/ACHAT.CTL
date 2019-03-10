OPTIONS (BINDSIZE=5120000,ROWS=100000)
load data
replace into table TMP_HISTO_ACHAT
FIELDS terminated by ";" Optionally enclosed by '"'
trailing nullcols
(noligne   RECNUM,
cdmag	 ,
date_achat "to_date(:date_achat,'DD/MM/YYYY')",
nart      ,
qt_achete "replace(:qt_achete,',','.')",
valeur_achat  "replace(:valeur_achat,',','.')"
)
