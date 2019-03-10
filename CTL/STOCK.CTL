OPTIONS (BINDSIZE=5120000,ROWS=100000)
load data
replace into table TMP_IMP_STOCK
FIELDS terminated by ";"
trailing nullcols
(noligne  RECNUM,
 cdmag    ,
 nart     ,
 quantite    "replace(:quantite,',','.')"
)