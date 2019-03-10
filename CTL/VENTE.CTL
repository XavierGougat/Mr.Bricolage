OPTIONS (BINDSIZE=5120000,ROWS=100000)
load data
replace into table TMP_HISTO_VENTE
FIELDS terminated by ";" Optionally enclosed by '"'
trailing nullcols
(noligne  RECNUM,
 cdmag		,
 dtrem "to_date(:dtrem,'DD/MM/YYYY')",
 noart	,
 qtvend	 	"replace(:qtvend,',','.')",
 mtvente	"replace(:mtvente,',','.')",
 mtachat	"replace(:mtachat,',','.')",
 txtva		"replace(:txtva,',','.')",
 mttva		"replace(:mttva,',','.')"
 )
 
