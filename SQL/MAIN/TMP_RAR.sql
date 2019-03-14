/* Drop la séquence pour repartir de zéro */
DROP SEQUENCE noligne_sequence

/* Création de la séquence pour numéro de ligne dans le flux RAR */
create sequence noligne_sequence start with 1
increment by 1
minvalue 1
maxvalue 10000000

/* Drop des index pour repartir de zéro */
DROP INDEX index_code_article;
DROP INDEX index_ean_ppal;
DROP INDEX index_code_anpf_code_barre;
DROP INDEX index_code_anpf;
DROP INDEX index_code_anpf_pdt;
DROP INDEX index_code_anpf_lib;

/* On repart de zéro sur les tables temporaires et de transco */
DELETE FROM TMP_RAR;
DELETE FROM LUCON_CAS_N1;
DELETE FROM LUCON_CAS_N3;

/* Création des index pour améliorer les performances en lecture */
CREATE INDEX index_code_article ON tmp_rar (code_article);
CREATE INDEX index_ean_ppal ON tmp_rar (ean_ppal);
CREATE INDEX index_code_anpf_code_barre ON tmp_code_barre (code_anpf,code_barre);
CREATE INDEX index_code_anpf ON tmp_code_barre (code_anpf);
CREATE INDEX index_code_anpf_pdt ON tmp_imp_produit (code_anpf);
CREATE INDEX index_code_anpf_lib ON tmp_lib_produit (code_anpf); 

COMMIT;

/* **** ******************************************* ***** */
/* Alimentation de la table TMP_RAR sur la centrale MBCEN */
/* **** ******************************************* ***** */
begin
	/* **** ******************************************* ***** */
	/* Cas n°1 : CONNU NATIONAL et LOCAL (EAN+ANPF) : connu_mbcen=1 --> ON FAIT DESCENDRE VIA LE RER */
	/* aucune modification à l'insertion TMP_RAR */
	/* **** ******************************************* ***** */
	dbms_output.put_line('Debut Alimentation TMP_RAR');  
	/* **** ************************** ***** */
	dbms_output.put_line('Debut Alimentation des articles cas n°1 dans TMP_RAR');
	/* **** ************************** ***** */
	insert into LUCON_CAS_N1(
		code_mbcen
	)
	select
		code_anpf
	FROM TMP_IMP_PRODUIT
	where trim(commentaire) is null
	and connu_mbcen = 1 and ajout_ean_centrale is null and new_anpf is null;
	COMMIT;

	insert into TMP_RAR(
		noligne,
		code_article,
		carac04,
		cd_reseau,
		cd_assortiment)
	select
		noligne_sequence.nextval,
		code_anpf, -- article
		'RDD_CAS|1',
		'LU',
		'A'
	FROM TMP_IMP_PRODUIT
	where trim(commentaire) is null
	and connu_mbcen = 1 and ajout_ean_centrale is null and new_anpf is null;
	COMMIT;
/* Alimentation de la table TMP_RAR sur la centrale MBCEN */
/* Cas n°2 : CONNU NATIONAL (ANPF uniquement) : connu_mbcen=1 ajout_ean_centrale = 1 --> ON AJOUTE EAN SECONDAIRE DANS LE TMP_RAR PUIS DESCENTE RER */
/* aucune modification à l'insertion TMP_RAR */
	insert into TMP_RAR (
		noligne,
		code_article,
		NB_EAN_SEC,
		EAN_SEC_1,
		carac04,
		cd_reseau,
		cd_assortiment)
	select
		noligne_sequence.nextval,
		code_anpf, -- article
		1, -- Nombre d'EAN
		0, -- l'ean sera alimenté + tard
		'RDD_CAS|2',
		'LU',
		'A'
	FROM TMP_IMP_PRODUIT
	where trim(commentaire) is null
	and connu_mbcen = 1 and ajout_ean_centrale is not null and new_anpf is null;
	COMMIT;
	/* 
	**********************
	On met à jour l ean secondaire via les infos de la table de travail TMP_CODE_BARRE 
	***********************  
	*/
	dbms_output.put_line('Debut mise à jour EAN secondaire dans TMP_RAR pour les articles cas n2');
	DECLARE
		v_code_anpf        tmp_code_barre.code_anpf%TYPE;   
		v_code_barre_1       tmp_code_barre.code_barre%TYPE;
		v_code_barre_2       tmp_code_barre.code_barre%TYPE;
		v_code_barre_3       tmp_code_barre.code_barre%TYPE;
		v_code_barre_4       tmp_code_barre.code_barre%TYPE;
		v_code_barre_5       tmp_code_barre.code_barre%TYPE;
		CURSOR c_ean IS
		SELECT * 
		FROM (
			select c.code_anpf, c.code_barre, row_number()  over  (partition by c.code_anpf ORDER BY c.code_barre) as ean
			FROM tmp_code_barre c
			INNER JOIN tmp_imp_produit p on c.code_anpf = p.code_anpf
			WHERE connu_mbcen = 1 and ajout_ean_centrale is not null and new_anpf is null AND instr(code_barre,'M') = 0)
		pivot (MAX(code_barre) FOR (ean) IN (
			1 AS EAN_SEC_1, 
			2 AS EAN_SEC_2, 
			3 AS EAN_SEC_3, 
			4 AS EAN_SEC_4, 
			5 AS EAN_SEC_5)
		);
	BEGIN
		OPEN c_ean;
		LOOP
		FETCH c_ean INTO v_code_anpf, v_code_barre_1, v_code_barre_2, v_code_barre_3, v_code_barre_4, v_code_barre_5;
			UPDATE tmp_rar set ean_sec_1 = v_code_barre_1, ean_sec_2 = v_code_barre_2, ean_sec_3 = v_code_barre_3, ean_sec_4 = v_code_barre_4, ean_sec_5 = v_code_barre_5
			where code_article = v_code_anpf and ean_sec_1 = 0 and carac04 = 'RDD_CAS|2';
			COMMIT;
		EXIT WHEN c_ean%NOTFOUND;
		END LOOP;
		CLOSE c_ean;
	END;
	/* **** ************************** ***** */
	/* Alimentation de la table TMP_RAR sur la centrale MBCEN */
	/* Cas n°3 : CONNU NATIONAL et LOCAL (EAN uniquement) : connu_mbcen=2  + new_anpf=art_noart MBCEN --> ON AFFECTE LA CORRESPONDANCE AVEC L'ANPF DE MBCEN  */
	/* aucune modification à l'insertion TMP_RAR */
	/* **** ************************** ***** */
	dbms_output.put_line('Debut Alimentation des articles cas n°3 dans TMP_RAR');
	/* **** ************************** ***** */
	insert into LUCON_CAS_N3 (
		code_mbcen,
		code_lucon
	)
	select
		new_anpf,  -- no article centrale
		code_anpf -- no article dump
	FROM TMP_IMP_PRODUIT
	where trim(commentaire) is null and connu_mbcen = 2 and ajout_ean_centrale is null and new_anpf is not null;
	COMMIT;
	insert into TMP_RAR (
		noligne,
		code_article,
		carac04,
		cd_reseau,
		cd_assortiment)
	select
		noligne_sequence.nextval,
		code_mbcen, -- article
		'RDD_CAS|3',
		'LU',
		'A'
	FROM LUCON_CAS_N3;
	COMMIT;
	/* **** ************************** ***** */
	
	/* **** ************************** ***** */
	/* Alimentation de la table TMP_RAR sur la centrale MBCEN */
	/* Cas n°4 : INCONNU NATIONAL : connu_mbcen=0 --> ON CREE L ARTICLE AVEC L ANPF NATIONAL DU DUMP et toutes les infos qui vont avec */
	/* aucune modification à l'insertion dans TMP_RAR */
	/* **** ************************** ***** */
    dbms_output.put_line('Debut Alimentation des articles cas n°4 dans TMP_RAR');
	/* **** ************************** ***** */
	insert into TMP_RAR(
        noligne,
		code_article,
		lbmarque,
		rayon,
		famille,
		sousfam,
		unite_besoin,
		code_tva,
		tyuvec,
		tyunmesu,
		msconte,
		pdunit,
		date_pvm,
		px_pvm,
		montant_d3e,
		cdnomencdoua,
		typart,
		cdtax_rpd,
		mttax_rpd,
		cdtax_ecomob,
		mttax_ecomob,
		carac01,
		carac02,
		carac03,
		carac04,
		arc_pdunbrut,
		lnarti,
		lrarti,
		cd_reseau,
		cd_assortiment
	)
	select
		noligne_sequence.nextval,
		code_anpf, -- article
		code_marque, --lbmarque
		meti_rayon,
		meti_famille,
		meti_ssfamille,
		meti_ubs,
		meti_cdtva,
		meti_tyuvec,
		meti_tyunmesu,
		meti_msconte,
		meti_pdunit, -- pdunit
		to_char(sysdate, 'DDMMYYYY'), --date pvm
		to_number(PVC_positionne),--pvm px
		montant_deee,
		trim(code_douane),
		CASE
			WHEN trim(type_pdt) NOT IN ('N', 'S') THEN NULL
			ELSE trim(type_pdt)
		END as typart, -- typart, transco ?
		'RPD',--cdtax_rpd
		montant_rpd,--mttax_rpd
		'ECOM',--cdtax_ecomob
		montant_ecomobilier,--mttax_ecomob
		'PVC_AGRE'||'|'||replace(to_char(PVC_agressif), ',', '.'),
		'PVC_POSI'||'|'||replace(to_char(PVC_positionne), ',', '.'),
		'PVC_CONF'||'|'||replace(to_char(PVC_confort), ',', '.'),
		'RDD_CAS|4',
		meti_pdbrut, --pdunbrut
		longeur, --lnarti
		largeur, --lrarti
		'LU',
		'A'
	FROM TMP_IMP_PRODUIT
	where trim(commentaire) is null and connu_mbcen = 0 and new_anpf is null;
    COMMIT;
	/* **** ************************** ***** */
	/* Mise à jour des EAN principaux des articles du cas n4
	/* **** ************************** ***** */
	dbms_output.put_line('Debut mise à jour EAN principal dans TMP_RAR pour les articles cas n4');
	DECLARE
    v_code_anpf        tmp_code_barre.code_anpf%TYPE;   
    v_code_barre       tmp_code_barre.code_barre%TYPE;
    CURSOR c_ean IS
        select c.code_anpf, c.code_barre as ean
        FROM tmp_code_barre c
        INNER JOIN tmp_imp_produit p on c.code_anpf = p.code_anpf
        WHERE connu_mbcen = 0 and ajout_ean_centrale is null and new_anpf is null AND instr(code_barre,'M') = 0 and principal =1;
    BEGIN
        OPEN c_ean;
        LOOP
        FETCH c_ean INTO v_code_anpf, v_code_barre;
            UPDATE tmp_rar set ean_ppal = v_code_barre
            where code_article = v_code_anpf and carac04 = 'RDD_CAS|4';
            COMMIT;
        EXIT WHEN c_ean%NOTFOUND;
        END LOOP;
        CLOSE c_ean;
    END;
    /* **** ************************** ***** */
	/* Mise à jour des EAN secondaires des articles du cas n4
	/* **** ************************** ***** */
	dbms_output.put_line('Debut mise à jour EAN secondaire dans TMP_RAR pour les articles cas n4');
	DECLARE
    v_code_anpf        tmp_code_barre.code_anpf%TYPE;   
    v_code_barre_1       tmp_code_barre.code_barre%TYPE;
    v_code_barre_2       tmp_code_barre.code_barre%TYPE;
		v_code_barre_3       tmp_code_barre.code_barre%TYPE;
		v_code_barre_4       tmp_code_barre.code_barre%TYPE;
		v_code_barre_5       tmp_code_barre.code_barre%TYPE;
    CURSOR c_ean IS
      SELECT * 
    	FROM (
        select c.code_anpf, c.code_barre, row_number()  over  (partition by c.code_anpf ORDER BY c.code_barre) as ean
        FROM tmp_code_barre c
        INNER JOIN tmp_imp_produit p on c.code_anpf = p.code_anpf
        WHERE connu_mbcen = 0 and ajout_ean_centrale is null and new_anpf is null AND instr(code_barre,'M') = 0 and principal !=1)
    	pivot (MAX(code_barre) FOR (ean) IN (
        1 AS EAN_SEC_1, 
        2 AS EAN_SEC_2, 
        3 AS EAN_SEC_3, 
        4 AS EAN_SEC_4, 
        5 AS EAN_SEC_5)
    	);
    BEGIN
        OPEN c_ean;
        LOOP
        FETCH c_ean INTO v_code_anpf, v_code_barre_1, v_code_barre_2, v_code_barre_3, v_code_barre_4, v_code_barre_5;
            UPDATE tmp_rar set ean_sec_1 = v_code_barre_1, ean_sec_2 = v_code_barre_2, ean_sec_3 = v_code_barre_3, ean_sec_4 = v_code_barre_4, ean_sec_5 = v_code_barre_5
            where code_article = v_code_anpf and carac04 = 'RDD_CAS|4';
            COMMIT;
        EXIT WHEN c_ean%NOTFOUND;
        END LOOP;
        CLOSE c_ean;
    END;
	/* **** ************************** ***** */
	/* Alignement des ean principaux si ils sont null et ean secondaire valorise*/
	/* **** ************************** ***** */
	dbms_output.put_line('Debut mise à jour EAN principal pour les articles cas n4, sans ean principal mais avec ean_secondaire');
	DECLARE
    i_rar        TMP_RAR%ROWTYPE;   
    CURSOR c_ean IS
        select * from TMP_RAR
        where carac04='RDD_CAS|4' and ean_ppal is null and ean_sec_1 is not null;
    BEGIN
        OPEN c_ean;
        LOOP
        FETCH c_ean INTO i_rar;
            UPDATE tmp_rar set ean_ppal = i_rar.ean_sec_1, ean_sec_1 = null
            where code_article = i_rar.code_article and carac04 = 'RDD_CAS|4';
            COMMIT;
        EXIT WHEN c_ean%NOTFOUND;
        END LOOP;
        CLOSE c_ean;
    END;
	/* Alimentation de la table TMP_RAR sur la centrale MBCEN */
	/* Cas n°5 : INCONNU LOCAL : connu_mbcen=0 et new_anpf=[780001 - 790000] -> ON CREE L ARTICLE AVEC UN NOUVEL ANPF SUR PLAGE NOART DISPONIBLE */
	/* on modifie l'ANPF a l'insertion dans TMP_RAR et on stocke l ancien dans la carac05 */
	/* **** ************************** ***** */
    dbms_output.put_line('Debut Alimentation des articles cas n°4 dans TMP_RAR');
	/* **** ************************** ***** */
	insert into TMP_RAR (
        noligne,
		code_article,
		lbmarque,
		rayon,
		famille,
		sousfam,
		unite_besoin,
		code_tva,
		tyuvec,
		tyunmesu,
		msconte,
		pdunit,
		date_pvm,
		px_pvm,
		montant_d3e,
		cdnomencdoua,
		typart,
		cdtax_rpd,
		mttax_rpd,
		cdtax_ecomob,
		mttax_ecomob,
		carac01,
		carac02,
		carac03,
		carac04,
		carac05,
		arc_pdunbrut,
		lnarti,
		lrarti,
		cd_reseau,
		cd_assortiment
	)
	select
		noligne_sequence.nextval,
		new_anpf, -- article
		code_marque, --lbmarque
		meti_rayon,
		meti_famille,
		meti_ssfamille,
		meti_ubs,
		meti_cdtva,
		meti_tyuvec,
		meti_tyunmesu,
		meti_msconte,
		meti_pdunit, -- pdunit
		to_char(sysdate, 'DDMMYYYY'), --date pvm
		to_number(PVC_positionne),--pvm px
		montant_deee,
		trim(code_douane),
		CASE
			WHEN trim(type_pdt) NOT IN ('N', 'S') THEN NULL
			ELSE trim(type_pdt)
		END as typart, -- typart, transco ?
		'RPD',--cdtax_rpd
		montant_rpd,--mttax_rpd
		'ECOM',--cdtax_ecomob
		montant_ecomobilier,--mttax_ecomob
		'PVC_AGRE'||'|'||replace(to_char(PVC_agressif), ',', '.'),
		'PVC_POSI'||'|'||replace(to_char(PVC_positionne), ',', '.'),
		'PVC_CONF'||'|'||replace(to_char(PVC_confort), ',', '.'),
		'RDD_CAS|5',
		code_anpf,
		meti_pdbrut, --pdunbrut
		longeur, --lnarti
		largeur, --lrarti
		'LU',
		'A'
	FROM TMP_IMP_PRODUIT
	where trim(commentaire) is null and connu_mbcen = 0 and new_anpf between 7800001 and 7900000;
    COMMIT;
	/* **** ************************** ***** */
	/* Mise à jour des EAN principaux des articles du cas n5
	/* **** ************************** ***** */
	dbms_output.put_line('Debut mise à jour EAN principal dans TMP_RAR pour les articles cas n4');
	DECLARE
    v_code_anpf        tmp_code_barre.code_anpf%TYPE;   
    v_code_barre       tmp_code_barre.code_barre%TYPE;
    CURSOR c_ean IS
        select c.code_anpf, c.code_barre as ean
        FROM tmp_code_barre c
        INNER JOIN tmp_imp_produit p on c.code_anpf = p.code_anpf
        WHERE connu_mbcen = 0 and new_anpf between 7800001 and 7900000 AND instr(code_barre,'M') = 0 and principal =1;
    BEGIN
        OPEN c_ean;
        LOOP
        FETCH c_ean INTO v_code_anpf, v_code_barre;
            UPDATE tmp_rar set ean_ppal = v_code_barre
            where code_article = v_code_anpf and carac04 = 'RDD_CAS|5';
            COMMIT;
        EXIT WHEN c_ean%NOTFOUND;
        END LOOP;
        CLOSE c_ean;
    END;
	/* **** ************************** ***** */
	/* Mise à jour des EAN secondaires des articles du cas n5
	/* **** ************************** ***** */
	dbms_output.put_line('Debut mise à jour EAN secondaire dans TMP_RAR pour les articles cas n4');
	DECLARE
    v_code_anpf        tmp_code_barre.code_anpf%TYPE;   
    v_code_barre_1       tmp_code_barre.code_barre%TYPE;
    v_code_barre_2       tmp_code_barre.code_barre%TYPE;
		v_code_barre_3       tmp_code_barre.code_barre%TYPE;
		v_code_barre_4       tmp_code_barre.code_barre%TYPE;
		v_code_barre_5       tmp_code_barre.code_barre%TYPE;
    CURSOR c_ean IS
      SELECT * 
    	FROM (
        select c.code_anpf, c.code_barre, row_number()  over  (partition by c.code_anpf ORDER BY c.code_barre) as ean
        FROM tmp_code_barre c
        INNER JOIN tmp_imp_produit p on c.code_anpf = p.code_anpf
        WHERE connu_mbcen = 0 and new_anpf between 7800001 and 7900000 AND instr(code_barre,'M') = 0 and principal !=1)
    	pivot (MAX(code_barre) FOR (ean) IN (
        1 AS EAN_SEC_1, 
        2 AS EAN_SEC_2, 
        3 AS EAN_SEC_3, 
        4 AS EAN_SEC_4, 
        5 AS EAN_SEC_5)
    	);
    BEGIN
        OPEN c_ean;
        LOOP
        FETCH c_ean INTO v_code_anpf, v_code_barre_1, v_code_barre_2, v_code_barre_3, v_code_barre_4, v_code_barre_5;
            UPDATE tmp_rar set ean_sec_1 = v_code_barre_1, ean_sec_2 = v_code_barre_2, ean_sec_3 = v_code_barre_3, ean_sec_4 = v_code_barre_4, ean_sec_5 = v_code_barre_5
            where code_article = v_code_anpf and carac04 = 'RDD_CAS|5';
            COMMIT;
        EXIT WHEN c_ean%NOTFOUND;
        END LOOP;
        CLOSE c_ean;
    END;
	/* **** ************************** ***** */
	/* Alignement des ean principaux si ils sont null et ean secondaire valorise*/
	/* **** ************************** ***** */
	dbms_output.put_line('Debut mise à jour EAN principal pour les articles cas n4, sans ean principal mais avec ean_secondaire');
	DECLARE
    i_rar        TMP_RAR%ROWTYPE;   
    CURSOR c_ean IS
        select * from TMP_RAR
        where carac04='RDD_CAS|5' and ean_ppal is null and ean_sec_1 is not null;
    BEGIN
        OPEN c_ean;
        LOOP
        FETCH c_ean INTO i_rar;
            UPDATE tmp_rar set ean_ppal = i_rar.ean_sec_1, ean_sec_1 = null
            where code_article = i_rar.code_article and carac04 = 'RDD_CAS|5';
            COMMIT;
        EXIT WHEN c_ean%NOTFOUND;
        END LOOP;
        CLOSE c_ean;
    END;
	/* **** ************************** ***** */
	dbms_output.put_line('Fin Alimentation des PRODUITS dans TMP_RAR');
	/* **** ************************** ***** */
	/* TMP_LIB_PRODUIT */
	/* On affecte les libéllés aux articles sur l'ANPF magasin stocké dans 'code_article' ou dans 'carac05' (pour les changements d'ANPF) */
	/* **** ************************** ***** */
    DECLARE
    	CURSOR c_lib IS
        	SELECT t.* FROM  tmp_lib_produit t
        	inner join tmp_rar on t.code_anpf = code_article
        	where lbarti is null;
            i_lib tmp_lib_produit%ROWTYPE;
    BEGIN
        OPEN c_lib;
        LOOP
            FETCH c_lib INTO i_lib;                
            UPDATE TMP_RAR SET lbarti=i_lib.lib_long, lbcompl=i_lib.lib_descr, lbcaisse=i_lib.lib_court
            WHERE code_article=i_lib.code_anpf;
            COMMIT;
            EXIT WHEN c_lib%NOTFOUND;
        END LOOP;
        CLOSE c_lib;
    END; 

	DECLARE
    	CURSOR c_lib IS
        	SELECT t.* FROM  tmp_lib_produit t
        	inner join tmp_rar on t.code_anpf=carac05
        	where lbarti is null;
            i_lib tmp_lib_produit%ROWTYPE;
    BEGIN
        OPEN c_lib;
        LOOP
            FETCH c_lib INTO i_lib;                
            UPDATE TMP_RAR SET lbarti=i_lib.lib_long, lbcompl=i_lib.lib_descr, lbcaisse=i_lib.lib_court
            WHERE code_article=i_lib.code_anpf;
            COMMIT;
			UPDATE TMP_RAR SET lbarti=i_lib.lib_long, lbcompl=i_lib.lib_descr, lbcaisse=i_lib.lib_court
            WHERE carac05=i_lib.code_anpf;
            COMMIT;
            EXIT WHEN c_lib%NOTFOUND;
        END LOOP;
        CLOSE c_lib;
    END; 
    dbms_output.put_line('Fin mise à jour des LIBELLES dans TMP_RAR');
	/* **** ************************** ***** */
	
	/* **** ************************** ***** */
	/* TMP_PRODUIT_FOURNISSEUR */
	/* **** ************************** ***** */
	dbms_output.put_line('Debut mise à jour des FOURNISSEURS dans TMP_RAR');
	DECLARE
    	CURSOR c_four IS
        	SELECT t.* FROM  tmp_produit_fournisseur t
        	inner join tmp_rar on code_article=code_anpf;
            i_four tmp_produit_fournisseur%ROWTYPE;
    BEGIN
        OPEN c_four;
        LOOP
            FETCH c_four INTO i_four;                
            UPDATE TMP_RAR SET 
			cdfo=CASE WHEN to_number(i_four.code_fournisseur)<90000 THEN i_four.code_fournisseur ELSE i_four.code_fournisseur+920000, 
			novar=2, 
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
            EXIT WHEN c_four%NOTFOUND;
        END LOOP;
        CLOSE c_four;
	END;
	
	/* 5 minutes d'update pour 15000 articles*/
	DECLARE
		CURSOR c_four_cas5 IS
        	SELECT t.* FROM  tmp_produit_fournisseur t
        	inner join tmp_rar on carac05=code_anpf
			where carac04='RDD_CAS|5';
            i_four_cas5 tmp_produit_fournisseur%ROWTYPE;
	BEGIN	
		OPEN c_four_cas5;
        LOOP
            FETCH c_four_cas5 INTO i_four_cas5;                
            UPDATE TMP_RAR SET 
			cdfo=CASE WHEN to_number(i_four.code_fournisseur)<90000 THEN i_four.code_fournisseur ELSE i_four.code_fournisseur+920000, 
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
            EXIT WHEN c_four_cas5%NOTFOUND;
        END LOOP;
        CLOSE c_four_cas5;
    END; 
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
	DECLARE
    	CURSOR c_four IS
        	select t.*
			from tmp_produit_fournisseur t
			inner join tmp_rar on code_article = code_anpf
			where operande_de_conversion != '1.0000';
            i_four tmp_produit_fournisseur%ROWTYPE;
    BEGIN
        OPEN c_four;
        LOOP
            FETCH c_four INTO i_four;   
			/* ici on crée le père à l'identique du fils */             
            insert into tmp_rar
				(select * from tmp_rar where code_article = i_four.code_anpf);
            COMMIT;
			
			/* on affecte un nouveau code article au père, qui commence par '6' sur 7digits */
			UPDATE tmp_rar SET code_article=lpad(code_article,7,'6'), carac05='UD', carac06=i_four.code_anpf
			WHERE code_article =i_four.code_anpf and rownum=1;
			
			/*update tmp_rar SET msconte=i_four.operande_de_conversion where code_article=i_four.code_anpf;
			commit;*/ -- ici je n'arrive pas à convertir le VARCHAR2 en NUMBER ==> donc pas de contenance sur l article pere
            EXIT WHEN c_four%NOTFOUND;
        END LOOP;
        CLOSE c_four;
		COMMIT;
    END; 
	/* --- --- --- ---*/
	dbms_output.put_line('Fin Alimentation TMP_RAR');  
	EXCEPTION
    WHEN OTHERS THEN
	    dbms_output.put_line('An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
		ROLLBACK;
END;