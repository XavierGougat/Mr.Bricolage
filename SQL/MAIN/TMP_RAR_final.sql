set serveroutput on
set feedback off;
DECLARE
	CURSOR c_lib IS
		SELECT t.* FROM  tmp_lib_produit t
		inner join tmp_rar on t.code_anpf = code_article
		where lbarti is null;
		i_lib tmp_lib_produit%ROWTYPE;

	CURSOR c_lib_carac05 IS
		SELECT t.* FROM  tmp_lib_produit t
		inner join tmp_rar on t.code_anpf=carac05
		where lbarti is null;
		i_lib_carac05 tmp_lib_produit%ROWTYPE;

	CURSOR c_four IS
		SELECT t.* FROM  tmp_produit_fournisseur t
		inner join tmp_rar on code_article=code_anpf;
		i_four tmp_produit_fournisseur%ROWTYPE;

	CURSOR c_four_cas5 IS
		SELECT t.* FROM  tmp_produit_fournisseur t
		inner join tmp_rar on carac05=code_anpf
		where carac04='RDD_CAS|5';
		i_four_cas5 tmp_produit_fournisseur%ROWTYPE;

	CURSOR c_four_ud IS
		select t.*
		from tmp_produit_fournisseur t
		inner join tmp_rar on code_article = code_anpf
		where operande_de_conversion != '1.0000';
		i_four_ud tmp_produit_fournisseur%ROWTYPE;
BEGIN
	dbms_output.put_line('Début mise à jour des LIBELLES dans TMP_RAR');
	OPEN c_lib;
	LOOP
		FETCH c_lib INTO i_lib;
		EXIT WHEN c_lib%NOTFOUND;             
			UPDATE TMP_RAR SET lbarti=substr(upper(replace(i_lib.lib_long,'�','')),1,30), lbcompl=substr(upper(replace(i_lib.lib_descr,'�','')),1,30), lbcaisse=substr(upper(replace(i_lib.lib_court,'�','')),1,30)
			WHERE code_article=i_lib.code_anpf;
			COMMIT;
	END LOOP;
	CLOSE c_lib;

	OPEN c_lib_carac05;
	LOOP
		FETCH c_lib_carac05 INTO i_lib_carac05;
		EXIT WHEN c_lib_carac05%NOTFOUND;                
			UPDATE TMP_RAR SET lbarti=substr(upper(replace(i_lib_carac05.lib_long,'�','')),1,29), lbcompl=substr(upper(replace(i_lib_carac05.lib_descr,'�','')),1,29), lbcaisse=substr(upper(replace(i_lib_carac05.lib_court,'�','')),1,29)
			WHERE code_article=i_lib_carac05.code_anpf;
			COMMIT;
			UPDATE TMP_RAR SET lbarti=substr(upper(replace(i_lib_carac05.lib_long,'�','')),1,29), lbcompl=substr(upper(replace(i_lib_carac05.lib_descr,'�','')),1,29), lbcaisse=substr(upper(replace(i_lib_carac05.lib_court,'�','')),1,29)
			WHERE carac05=i_lib_carac05.code_anpf;
			COMMIT;
	END LOOP;
	CLOSE c_lib_carac05;
	dbms_output.put_line('Fin mise à jour des LIBELLES dans TMP_RAR');
	
	/* **** ************************** ***** */
	/* TMP_PRODUIT_FOURNISSEUR */
	/* **** ************************** ***** */
	dbms_output.put_line('Debut mise à jour des FOURNISSEURS dans TMP_RAR');
	OPEN c_four;
	LOOP
		FETCH c_four INTO i_four;
		EXIT WHEN c_four%NOTFOUND;              
			UPDATE TMP_RAR SET 
			cdfo=CASE WHEN to_number(i_four.code_fournisseur)<90000 THEN to_number(i_four.code_fournisseur) ELSE to_number(i_four.code_fournisseur)+920000 END, 
			novar=20, 
			pcb=to_number(i_four.colisage), 
			rffou2=i_four.ref_fournisseur, 
			arv_ppal=CASE WHEN trim(i_four.fourn_principal) = '1' THEN 'O' ELSE 'N' END, 
			arv_dtdeb=to_char(i_four.date_de_referencement, 'DDMMYYYY'), 
			arv_dtfin=to_char(i_four.date_de_dereferencement, 'DDMMYYYY'),
			date_tar=to_char(i_four.date_debut, 'DDMMYYYY'),
			qtmincde=to_number(i_four.minimum_commande),
			tyunfac=case when upper(trim(i_four.unite_achat)) in ('KG','KM','L' ,'LT','M' ,'M2','M3','MA','ME','ML','PE') then 'K' else 'A' END,
			px_tar=to_number(i_four.pan_ht)
			WHERE code_article=i_four.code_anpf;
			COMMIT;
	END LOOP;
	CLOSE c_four;

	/* 5 minutes d'update pour 15000 articles*/
	OPEN c_four_cas5;
	LOOP
		FETCH c_four_cas5 INTO i_four_cas5;
		EXIT WHEN c_four_cas5%NOTFOUND;               
			UPDATE TMP_RAR SET 
			cdfo=CASE WHEN to_number(i_four.code_fournisseur)<90000 THEN to_number(i_four.code_fournisseur) ELSE to_number(i_four.code_fournisseur)+920000 END, 
			novar=20, 
			pcb=to_number(i_four_cas5.colisage), 
			rffou2=i_four_cas5.ref_fournisseur, 
			arv_ppal=CASE WHEN trim(i_four_cas5.fourn_principal) = '1' THEN 'O' ELSE 'N' END, 
			arv_dtdeb=to_char(i_four_cas5.date_de_referencement, 'DDMMYYYY'), 
			arv_dtfin=to_char(i_four_cas5.date_de_dereferencement, 'DDMMYYYY'),
			date_tar=to_char(i_four_cas5.date_debut, 'DDMMYYYY'),
			qtmincde=to_number(i_four_cas5.minimum_commande),
			tyunfac=case when upper(trim(i_four_cas5.unite_achat)) in ('KG','KM','L' ,'LT','M' ,'M2','M3','MA','ME','ML','PE') then 'K' else 'A' END,
			px_tar=to_number(i_four_cas5.pan_ht)
			WHERE carac05=i_four_cas5.code_anpf;
		COMMIT;
	END LOOP;
	CLOSE c_four_cas5;
	dbms_output.put_line('Fin mise à jour des FOURNISSEURS dans TMP_RAR');
	
	/*
	***********************
	GESTION DES ETIQUETTES
	***********************
	*/
	dbms_output.put_line('Mise à jour type étiquettes');    
	UPDATE TMP_RAR SET type_etiq='G', nb_etiq=1;
	commit;
	
	/*
	***********************
	GESTION DES ARTICLES DERIVES
	***********************
	***********************
	*/	
	dbms_output.put_line('Alimentation des regroupements articles : Unité dérivées');
	OPEN c_four_ud;
	LOOP
		FETCH c_four_ud INTO i_four_ud;
		EXIT WHEN c_four_ud%NOTFOUND;  
		/* ici on crée le père à l'identique du fils */             
		insert into tmp_rar
			(select * from tmp_rar where code_article = i_four_ud.code_anpf);
		COMMIT;
		/* on affecte un nouveau code article au père, qui commence par '6' sur 7digits */
		UPDATE tmp_rar SET code_article=lpad(code_article,7,'6'), carac05='UD', carac06=i_four_ud.code_anpf
		WHERE code_article =i_four_ud.code_anpf and rownum=1;
		
		/*update tmp_rar SET msconte=i_four.operande_de_conversion where code_article=i_four.code_anpf;
		commit;*/ -- ici je n'arrive pas à convertir le VARCHAR2 en NUMBER ==> donc pas de contenance sur l article pere
	END LOOP;
	CLOSE c_four_ud;
	COMMIT;
END; 
/
quit