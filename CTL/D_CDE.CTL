OPTIONS (BINDSIZE=5120000,ROWS=100000)
load data
truncate into table TMP_IMP_LIGNE_CDE
FIELDS terminated by ";"
trailing nullcols
(noligne  RECNUM,       
	cdmag	 			,
    nocdefou      		,
    noart		 		,
	qtte        "replace(:qtte,',','.')",
	qtte_livree        "replace(:qtte_livree,',','.')",
	colisage        "replace(:colisage,',','.')",
	prix_base_ht        "replace(:prix_base_ht,',','.')",
	remise_four        "replace(:remise_four,',','.')",
	mt_frport        "replace(:mt_frport,',','.')",
	txtva_frport        "replace(:txtva_frport,',','.')",
	remise_frport        "replace(:remise_frport,',','.')",
	dtlivr       "to_date(:dtlivr,'DD/MM/YYYY')" ,
	pa_ht_apres_remises        "replace(:pa_ht_apres_remises,',','.')",
	txtva        "replace(:txtva,',','.')",
	mttva        "replace(:mttva,',','.')",
    commentaire		
)
