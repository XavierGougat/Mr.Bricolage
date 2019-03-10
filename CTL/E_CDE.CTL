OPTIONS (BINDSIZE=5120000,ROWS=100000)
load data
truncate into table TMP_IMP_ENTETE_CDE
FIELDS terminated by ";"
trailing nullcols
(noligne  RECNUM,
	cdmag				,
  nocdefou     		,
	dtcomman "to_date(:dtcomman,'DD/MM/YYYY')"				,
	cdfo					,
	dsutil				,
	dtlivr		"to_date(:dtlivr,'DD/MM/YYYY')"		,
	ttcomcde				,
	remise_four_pied		,
	remise_fr_port_pied	,
  statut				
)


