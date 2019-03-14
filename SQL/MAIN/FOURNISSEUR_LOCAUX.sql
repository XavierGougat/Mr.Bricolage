/* **** *********************************** **** */
/*       Traitement des fournisseurs locaux      */
/* affectation nouvelle codification fournisseur */
/* **** *********************************** **** */
drop table LUCON_FOUR_N3;

create table LUCON_FOUR_N3 (
	code VARCHAR2(10),
	nouveau_code VARCHAR2(10)
);

DECLARE
	CURSOR c_four IS
		SELECT * FROM  tmp_imp_fournisseur
		where code > 90000;
		i_four tmp_imp_fournisseur%ROWTYPE;
BEGIN
	OPEN c_four;
	LOOP
		FETCH c_four INTO i_four;                
			INSERT INTO LUCON_FOUR_N3 values(i_four.code,(i_four.code+920000));
			COMMIT;
		EXIT WHEN c_four%NOTFOUND;
	END LOOP;
	CLOSE c_four;
END;

/*on insere dans MGFOU les fournisseurs locaux avec la nouvelle codification > 1 010 000*/
DECLARE
	lvoi VARCHAR2(60);
	cvoi VARCHAR2(60);
CURSOR c_four IS
	SELECT t.* FROM  TMP_IMP_FOURNISSEUR t
	where code is not null and code > 90000;
	i_four TMP_IMP_FOURNISSEUR%ROWTYPE;
BEGIN
	OPEN c_four;
	LOOP
		FETCH c_four INTO i_four;
		conv_adresse(i_four.adr1, i_four.adr2, i_four.adr3, lvoi, cvoi);
		insert into MGFOU(
			FOU_CDFO,
			fou_nm,
			fou_cdtypf,
			FOU_NVOI,
			FOU_BTQ,
			FOU_TVOI,
			FOU_LVOI,
			FOU_CVOI,
			FOU_CPOS2,
			FOU_DIST,
			FOU_CDPAYS,
			FOU_TLPH,
			FOU_FX,
			FOU_EMAI,
			fou_fltartrs
		)values(
			to_number(i_four.code)+920000, 
			i_four.nom,
			'P',
			null,
			null,
			null,
			lvoi,
			cvoi,
			i_four.cp,
			i_four.ville,
			i_four.pays,
			i_four.tel,
			i_four.fax,
			i_four.mail,
			'46'
		);
		commit;
		EXIT WHEN c_four%NOTFOUND;
	END LOOP;
	CLOSE c_four;
END;	   
/* *** ************************ *** */
/* Début intégration des MGCIF */
/* *** ************************ *** */
DECLARE
	v_er_MGFOU_FOU_CDFO  VARCHAR2(200);
	v_er_MGFOU_INIT_CDFO VARCHAR2(200);
	v_er_gene  VARCHAR2(200);
	v_ERREUR  VARCHAR2(200);
	CURSOR c_four IS
		SELECT * FROM MGFOU
		where fou_cdfo > 1010000;
		i_four MGFOU%ROWTYPE;
BEGIN
	OPEN c_four;
	LOOP
		FETCH c_four INTO i_four;                
    	REFE_FOUR_UTIL.PROC_INIT_MGCIF(
    		pe_MGFOU_FOU_CDFO     => i_four.fou_cdfo,
        	pe_MGFOU_INIT_CDFO    => util_param.RECUP_PARAM('FOU_INITIALISAT'),
        	ps_er_MGFOU_FOU_CDFO  => v_er_MGFOU_FOU_CDFO,
        	ps_er_MGFOU_INIT_CDFO => v_er_MGFOU_INIT_CDFO,
        	ps_er_gene            => v_er_gene,
        	ps_ERREUR             => v_ERREUR
    	);
		commit;
		EXIT WHEN c_four%NOTFOUND;
	END LOOP;
	CLOSE c_four;
	
	update mgcif
	set cif_CDTRCDE = 'M'
	where cif_cdfo in (select code from tmp_imp_fournisseur);
	commit;
END;	

/* *** ************************ *** */
/* Début intégration des MGGRV */
/* *** ************************ *** */
DECLARE
	v_er_MGFOU_FOU_CDFO  VARCHAR2(200);
	v_er_MGFOU_INIT_CDFO VARCHAR2(200);
	v_er_gene  VARCHAR2(200);
	v_ERREUR  VARCHAR2(200);
	CURSOR c_four IS
		SELECT * FROM MGFOU
		where fou_cdfo > 1010000;
		i_four MGFOU%ROWTYPE;
BEGIN
	OPEN c_four;
	LOOP
		FETCH c_four INTO i_four;                
    	REFE_FOUR_UTIL.PROC_INIT_MGGRV( 
			pe_MGFOU_FOU_CDFO     => i_four.fou_cdfo,
			pe_MGFOU_INIT_CDFO    => util_param.RECUP_PARAM('FOU_INITIALISAT'),
			ps_er_MGFOU_FOU_CDFO  => v_er_MGFOU_FOU_CDFO,
			ps_er_MGFOU_INIT_CDFO => v_er_MGFOU_INIT_CDFO,
			ps_er_gene            => v_er_gene,
			ps_ERREUR             => v_ERREUR
    	);
		commit;
		EXIT WHEN c_four%NOTFOUND;
	END LOOP;
	CLOSE c_four;
END;

/* mise à jour de la GRV
- franco
*/		
DECLARE
	CURSOR c_four IS
		SELECT t.* FROM TMP_IMP_FOURNISSEUR t
    	inner join MGGRV on code+920000 = grv_cdfo
		where grv_cdfo > 1010000;
		i_four TMP_IMP_FOURNISSEUR%ROWTYPE;
BEGIN
	OPEN c_four;
	LOOP
		FETCH c_four INTO i_four;
			update mggrv
    		set grv_nbminfra = to_number(i_four.franco), grv_flreli ='F'
    		where grv_cdfo = (i_four.code+920000) and grv_cdgrva = 1;
			commit;
		EXIT WHEN c_four%NOTFOUND;
	END LOOP;
	CLOSE c_four;
END;