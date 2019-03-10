set serveroutput on size 1000000
DECLARE
    vg_cdmag    mgmag.cli_cdmag%TYPE;
    devise      mgsdv.sdv_cddevi%TYPE;
	cifrow		mgcif%rowtype;
	grvrow		mggrv%rowtype;
	v_commentaire	varchar2(250);
BEGIN

    dbms_output.put_line(to_char(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));

	-- récupération cd mag + code devise
    SELECT a.cli_cdmag, sdv_cddevi
    INTO   vg_cdmag, devise
    FROM   mgmag a, mgsoc b, mgsdv, mgens
    WHERE  b.soc_cdsoc = 1
    AND    sdv_dt = (SELECT MAX(sdv_dt) FROM mgsdv WHERE sdv_cdsoc = soc_cdsoc)
    AND    b.soc_cdmagpr = a.cli_cdmag
    AND    sdv_cdsoc = soc_cdsoc
    AND    soc_cdens = ens_cde;
	
	-- vérification
	-- présence dans MGFOU
	dbms_output.put_line('Erreurs sur fournisseurs inconnus: ');
	v_commentaire := 'Fournisseur inconnu';
	
	for c1 in (
		select cdfo from tmp_imp_entete_cde
		minus
		select fou_cdfo from mgfou
	)
	loop
		update tmp_imp_entete_cde set commentaire = v_commentaire where cdfo = c1.cdfo;
		dbms_output.put_line(c1.cdfo);
	end loop;
	
	-- CIF
	dbms_output.put_line('Erreurs sur les CIFs fournisseurs : ');
	v_commentaire := 'Erreur MGCIF';
	for c1 in (
		select cdfo from tmp_imp_entete_cde
	)
	loop
		begin            
            select * into cifrow from mgcif where cif_cdfo = c1.cdfo;
			exception
			when too_many_rows then
				update tmp_imp_entete_cde set commentaire = v_commentaire where cdfo = c1.cdfo;
				dbms_output.put_line(c1.cdfo || ' : trop de valeurs trouvées');
			when no_data_found then
				update tmp_imp_entete_cde set commentaire = v_commentaire where cdfo = c1.cdfo;
				dbms_output.put_line(c1.cdfo || ' : pas de valeurs trouvées');
		end;
	end loop;	
	
	-- GRV
	insert into MGCDF (
		CDF_CDMAG   ,
		CDF_NOCDEFOU,
		CDF_TYDOCU  ,
		CDF_CDFO    ,
		CDF_NOCIFCDE,
		CDF_NOCIFREG,
		CDF_CDGRVA  ,
		CDF_CDSITU  ,
		CDF_DTCOMMAN,
		CDF_DTLIVR  ,
		CDF_DTRECEPT,
		CDF_NOCDORIG,
		CDF_TYPORT  ,
		CDF_UNPORT  ,
		CDF_TTCOMCDE,
		CDF_TYEDBC  ,
		CDF_MTREMGLB,
		CDF_TYREMGLB)    
	SELECT
		vg_cdmag,
		t1.nocdefou,
		'E', --type de document = Entree  
		cif_cdfo END AS cdfo,
		cif_noci AS nocifcde,
		cif_noci AS nocifreg,
		mggrv.grv_cdgrva AS cdgrva,
		CASE 
			WHEN statut = 1 THEN 1
			WHEN statut = 2 THEN 40
			WHEN statut = 3 THEN 60
			WHEN statut = 4 THEN 70
			WHEN statut = 5 THEN 75
			WHEN statut = 6 THEN 80
		ELSE
			1
		END, -- situ de reprise
		t1.dtcomman,
		t1.dtlivr, -- dtlivr
		t1.dtlivr, --dtrecep
		t1.nocdefou, --nocdorig  
		mggrv.grv_typort AS typort,
		mggrv.grv_unport AS unport,
		t1.ttcomcde,
		'2', -- type de ref fournisseur
		CASE WHEN to_number(replace(remise_four_pied, '.', ',')) > 0 THEN to_number(replace(remise_four_pied, '.', ','))
		ELSE NULL
		END AS mtremglb,
		CASE WHEN to_number(replace(remise_four_pied, '.', ',')) > 0 THEN 'M'
		ELSE NULL
		END AS tyremglb -- mettre type = montant si renseigné
	FROM mgcif
    INNER JOIN (select grv_cdfo, min(grv_Cdgrva) grv_Cdgrva from MGGRV group by grv_cdfo) T ON T.grv_cdfo = cif_cdfo
	INNER JOIN mggrv ON cif_cdfo = mggrv.grv_cdfo and T.grv_Cdgrva= mggrv.grv_Cdgrva
	INNER JOIN tmp_IMP_entete_CDE t1 ON cif_cdfo = t1.cdfo
	where t1.commentaire is null and t1.cdfo < 90000;		
	commit;

	update MGCDF  set CDF_CDUEXP = 'D'  where CDF_cdfo < 90000;
	commit;	

	-- insertion
	insert into MGCDF (
		CDF_CDMAG   ,
		CDF_NOCDEFOU,
		CDF_TYDOCU  ,
		CDF_CDFO    ,
		CDF_NOCIFCDE,
		CDF_NOCIFREG,
		CDF_CDGRVA  ,
		CDF_CDSITU  ,
		CDF_DTCOMMAN,
		CDF_DTLIVR  ,
		CDF_DTRECEPT,
		CDF_NOCDORIG,
		CDF_TYPORT  ,
		CDF_UNPORT  ,
		CDF_TTCOMCDE,
		CDF_TYEDBC  ,
		CDF_MTREMGLB,
		CDF_TYREMGLB)    
	SELECT
		vg_cdmag,
		t1.nocdefou,
		'E', --type de document = Entree  
		cif_cdfo AS cdfo,
		cif_noci AS nocifcde,
		cif_noci AS nocifreg,
		mggrv.grv_cdgrva AS cdgrva,
		CASE 
			WHEN statut = 1 THEN 1
			WHEN statut = 2 THEN 40
			WHEN statut = 3 THEN 60
			WHEN statut = 4 THEN 70
			WHEN statut = 5 THEN 75
			WHEN statut = 6 THEN 80
		ELSE
			1
		END, -- situ de reprise
		t1.dtcomman,
		t1.dtlivr, -- dtlivr
		t1.dtlivr, --dtrecep
		t1.nocdefou, --nocdorig  
		mggrv.grv_typort AS typort,
		mggrv.grv_unport AS unport,
		t1.ttcomcde,
		'2', -- type de ref fournisseur
		CASE WHEN to_number(replace(remise_four_pied, '.', ',')) > 0 THEN to_number(replace(remise_four_pied, '.', ','))
		ELSE NULL
		END AS mtremglb,
		CASE WHEN to_number(replace(remise_four_pied, '.', ',')) > 0 THEN 'M'
		ELSE NULL
		END AS tyremglb -- mettre type = montant si renseigné
	FROM mgcif
    INNER JOIN (select grv_cdfo, min(grv_Cdgrva) grv_Cdgrva from MGGRV group by grv_cdfo) T ON T.grv_cdfo = cif_cdfo
	INNER JOIN mggrv ON cif_cdfo = mggrv.grv_cdfo and T.grv_Cdgrva= mggrv.grv_Cdgrva
	INNER JOIN tmp_IMP_entete_CDE t1 ON cif_cdfo = t1.cdfo+920000
	where t1.commentaire is null and t1.cdfo > 90000;		
	commit;

    update MGCDF  set CDF_CDUEXP = 'DL' where CDF_cdfo >= 90000;
	commit;	
end;
/
quit