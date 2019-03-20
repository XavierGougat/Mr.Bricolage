DECLARE
	v_er_MGFOU_FOU_CDFO  VARCHAR2(200);
	v_er_MGFOU_INIT_CDFO VARCHAR2(200);
	v_er_gene  VARCHAR2(200);
	v_ERREUR  VARCHAR2(200);
	
	CURSOR c_four IS
		SELECT * FROM  tmp_imp_fournisseur
		where code > 90000;
		i_four tmp_imp_fournisseur%ROWTYPE;

	CURSOR c_four_FOU IS
		SELECT t.* FROM  TMP_IMP_FOURNISSEUR t
		where code is not null and code > 90000;
		i_four_FOU TMP_IMP_FOURNISSEUR%ROWTYPE; 

	CURSOR c_four_CIF IS
		SELECT * FROM MGFOU
		where fou_cdfo > 1010000;
		i_four_CIF MGFOU%ROWTYPE;

	CURSOR c_four_GRV IS
		SELECT * FROM MGFOU
		where fou_cdfo > 1010000;
		i_four_GRV MGFOU%ROWTYPE;

	CURSOR c_four_GRV_2 IS
		SELECT t.* FROM TMP_IMP_FOURNISSEUR t
		inner join MGGRV on to_number(code)+920000 = grv_cdfo
		where grv_cdfo > 1010000;
		i_four_GRV_2 TMP_IMP_FOURNISSEUR%ROWTYPE;
BEGIN
	OPEN c_four;
	LOOP
		FETCH c_four INTO i_four; 
		EXIT WHEN c_four%NOTFOUND;               
			INSERT INTO LUCON_FOUR_N3 values(i_four.code,(i_four.code+'920000'));
			COMMIT;
	END LOOP;
	CLOSE c_four;

	/* on insere dans MGFOU les fournisseurs locaux avec la nouvelle codification > 1 010 000 */
	OPEN c_four_FOU;
	LOOP
		FETCH c_four_FOU INTO i_four_FOU;
		EXIT WHEN c_four_FOU%NOTFOUND;
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
			to_number(i_four_FOU.code)+920000, 
			i_four_FOU.nom,
			'P',
			null,
			null,
			null,
			null,
			null,
			i_four_FOU.cp,
			i_four_FOU.ville,
			i_four_FOU.pays,
			i_four_FOU.tel,
			i_four_FOU.fax,
			i_four_FOU.mail,
			'46'
		);
		commit;
	END LOOP;
	CLOSE c_four_FOU;

	/* *** ************************ *** */
	/* Début intégration des MGCIF */
	/* *** ************************ *** */
	OPEN c_four_CIF;
	LOOP
		FETCH c_four_CIF INTO i_four_CIF;  
		EXIT WHEN c_four_CIF%NOTFOUND;              
		REFE_FOUR_UTIL.PROC_INIT_MGCIF(
			pe_MGFOU_FOU_CDFO     => i_four_CIF.fou_cdfo,
			pe_MGFOU_INIT_CDFO    => util_param.RECUP_PARAM('FOU_INITIALISAT'),
			ps_er_MGFOU_FOU_CDFO  => v_er_MGFOU_FOU_CDFO,
			ps_er_MGFOU_INIT_CDFO => v_er_MGFOU_INIT_CDFO,
			ps_er_gene            => v_er_gene,
			ps_ERREUR             => v_ERREUR
		);
		commit;
	END LOOP;
	CLOSE c_four_CIF;
	
	update mgcif
	set cif_CDTRCDE = 'M'
	where cif_cdfo in (select code from tmp_imp_fournisseur);
	commit;

	/* *** ************************ *** */
	/* Début intégration des MGGRV */
	/* *** ************************ *** */
	OPEN c_four_GRV;
	LOOP
		FETCH c_four_GRV INTO i_four_GRV;
		EXIT WHEN c_four_GRV%NOTFOUND;                
		REFE_FOUR_UTIL.PROC_INIT_MGGRV( 
			pe_MGFOU_FOU_CDFO     => i_four_GRV.fou_cdfo,
			pe_MGFOU_INIT_CDFO    => util_param.RECUP_PARAM('FOU_INITIALISAT'),
			ps_er_MGFOU_FOU_CDFO  => v_er_MGFOU_FOU_CDFO,
			ps_er_MGFOU_INIT_CDFO => v_er_MGFOU_INIT_CDFO,
			ps_er_gene            => v_er_gene,
			ps_ERREUR             => v_ERREUR
		);
		commit;	
	END LOOP;
	CLOSE c_four_GRV;

	/* mise à jour de la GRV
	- franco
	*/		
	OPEN c_four_GRV_2;
	LOOP
		FETCH c_four_GRV_2 INTO i_four_GRV_2;
		EXIT WHEN c_four_GRV_2%NOTFOUND;
			update mggrv
			set grv_nbminfra = to_number(i_four_GRV_2.franco), grv_flreli ='F'
			where grv_cdfo = (i_four_GRV_2.code+920000) and grv_cdgrva = 1;
			commit;	
	END LOOP;
	CLOSE c_four_GRV_2;
END;
/
quit