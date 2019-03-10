set serveroutput on size 1000000
spool &1 append

DECLARE
BEGIN
/* LES DONNNES BRUTES DE SIGMA ONT ETE CHARGEES EN BASE
MAINTENANT ON RETRAVAILE DES DONNEES AVANT DE LES SPOOLER DANS FLUX RAR */

/* 1) CONTROLE DES DOUBLONS MGCGS */
dbms_output.put_line('Etape 1 : Contrôle des doublons de la table MGCGS');
select cgs_cdfamma7, cgs_cdsfama7, cgs_cdubsma7, count(*) as total from mgcgs
group by cgs_cdfamma7, cgs_cdsfama7, cgs_cdubsma7
having count(*) > 1;

/* 2) CONTROLE INTEGRITE DES DONNEES */
dbms_output.put_line('Etape 2 : Contrôle et mise à jour pour intégrité des données');
-- articles en double
UPDATE TMP_IMP_PRODUIT 
SET commentaire = CONCAT(commentaire,',article en double')
WHERE code_anpf IN (
	SELECT code_anpf
	FROM TMP_IMP_PRODUIT     
	GROUP BY code_anpf
	HAVING COUNT(*) > 1
);

-- mauvais PLC
update TMP_IMP_PRODUIT
set commentaire = CONCAT(commentaire,',mauvaise info PLC')
WHERE trim(code_nomenclature) NOT IN (SELECT distinct TRIM(old_modu) FROM tmp_nomenclature);

-- absence d'unité de mesure / vente
update TMP_IMP_PRODUIT
set commentaire = CONCAT(commentaire,',absence unité de mesure / vente')
WHERE unite_mesure IS NULL OR unite_sortie IS NULL;

-- poids >= 1 Tonne 
update TMP_IMP_PRODUIT SET poids_net=0 WHERE poids_net >= 1000; --passage des poids 0 pour ceux supérieurs à 1 T (validation magasin)

update TMP_IMP_PRODUIT
set commentaire = CONCAT(commentaire,',Poids non gérable en base passé à 0')
WHERE poids_net >= 1000;

/* 3) AFFECTATION DE LA NOMENCLATURE METI*/
dbms_output.put_line('Etape 3 : Mise a jour de la nomenclature');
FOR curs IN (SELECT DISTINCT TRIM(code_nomenclature) AS code_plc FROM TMP_IMP_PRODUIT) 
LOOP
	BEGIN
		SELECT DISTINCT
        fam_cdr,
        a.cgs_cdfamma7,
        a.cgs_cdsfama7,
        a.cgs_cdubsma7
		INTO
        ray,
        fam,
        sfa,
        ubs
		FROM mgcgs a, mgfam
		WHERE trim(cgs_cdub) = trim(curs.code_plc)
		AND cgs_cdfamma7 = fam_cdf;
		EXCEPTION
		WHEN no_data_found THEN
			ray := 9;
			fam := 99;
			sfa := 9999;
			ubs := 19;	
	end;
	
	update TMP_IMP_PRODUIT t1
	set meti_rayon = ray,
		meti_famille = fam,
		meti_ssfamille = sfa,
		meti_ubs = ubs
	WHERE trim(t1.code_nomenclature) = trim(curs.code_plc);
	commit;
	
END LOOP;
/*------------------------------------------------------------------*/
/* 4) AFFECTATION DU CODE TVA*/
dbms_output.put_line('Etape 4 : Mise a jour du code TVA');
BEGIN     
	update TMP_IMP_PRODUIT set meti_cdtva = 1 where code_tva is null; 
	
	update TMP_IMP_PRODUIT set meti_cdtva = 6 where code_tva = 'C';
	
	update TMP_IMP_PRODUIT   
	set meti_cdtva =
	CASE
		WHEN code_tva is null THEN 1
		WHEN code_tva = 0 THEN 9
		WHEN code_tva = 1 THEN 1
		WHEN code_tva = 2 THEN 2
		WHEN code_tva = 4 THEN 4
	END
	where code_tva is not null and code_tva <> 'C';	
	commit;
END;   
/*------------------------------------------------------------------*/

/* 5) AFFECTATION DU TYPE ARTICLE */
dbms_output.put_line('Etape 5 : Affectation du type article');

/* 6) AFFECTATION DU TYUVEC, TYUNMESU, PDUNIT, MSCONTE*/
dbms_output.put_line('Etape 6.1 : Mise a jour unite de mesure et de vente'); 
-- unité de mesure et vente
for c1 in (select vco_znvlrubo, vco_znvlrubd 
from MGVCO
where vco_dslogori = 'C4950_REFE'
and vco_cdrubori = 'U_MESURE' )
loop
	update TMP_IMP_PRODUIT
	set meti_tyunmesu = meti_outil.strtoken(c1.vco_znvlrubd, ';', 1),
	meti_tyuvec = meti_outil.strtoken(c1.vco_znvlrubd, ';', 2)
	where trim(unite_mesure) = trim(c1.vco_znvlrubo);
end loop;

-- POIDS et CONTENANCE
dbms_output.put_line('Etape 6.1 : Mise a jour poids et contenance'); 
-- POIDS --
-- poids > valeur_conversion => poids brut
dbms_output.put_line('poids > valeur_conversion => poids brut');
update TMP_IMP_PRODUIT
set meti_pdbrut = poids_net
where nvl(poids_net, 0) > 0
and nvl(poids_net, 0) > nvl(valeur_conversion, 0)
and poids_net < 1000
and trim(commentaire) is null;

-- poids < valeur_conversion => poids egoutté  
dbms_output.put_line('poids < valeur_conversion => poids egoutté  ');
update TMP_IMP_PRODUIT
set meti_pdntegout = poids_net
where nvl(poids_net, 0) > 0
and nvl(poids_net, 0) < nvl(valeur_conversion, 0)
and trim(commentaire) is null;
commit;   


-- CONTENANCE --
-- unité mesure = kilo => valeur_conversion -> pdunit
dbms_output.put_line('unité mesure = kilo => valeur_conversion -> pdunit');
update TMP_IMP_PRODUIT
set meti_pdunit = valeur_conversion
where trim(meti_tyunmesu) = 'K'
and valeur_conversion < 1000
and trim(commentaire) is null;
commit;
-- unité mesure != kilo => valeur_conversion -> contenance
dbms_output.put_line('unité mesure != kilo => valeur_conversion -> contenance');
update TMP_IMP_PRODUIT
set meti_msconte = valeur_conversion
where trim(meti_tyunmesu) != 'K'
and trim(commentaire) is null;
commit;

/*------------------------------------------------------------------*/
/* IDENTIFICATION DES CAS PRODUITS
/*------------------------------------------------------------------*/    
/*------------------------------------------------------------------*/
/* (1) PRODUITS CONNUS EN CENTRALE MBCEN
/*------------------------------------------------------------------*/
/* (1.1) Identification des matchs complets (ANPF unique national et couple ANPF+EAN)*/
update TMP_IMP_PRODUIT set connu_mbcen = 1, ajout_ean_centrale = 1, new_anpf = null
where CODE_ANPF in(select distinct p.code_anpf from TMP_IMP_PRODUIT p
inner join MGART a on p.code_anpf = a.art_noart
where p.code_anpf < 750000) ;
commit;

update TMP_IMP_PRODUIT set connu_mbcen = 1, ajout_centrale = null, new_anpf = null
where CODE_ANPF in(select distinct p.code_anpf from TMP_IMP_PRODUIT p
inner join TMP_CODE_BARRE c on c.CODE_ANPF = p.CODE_ANPF
inner join MGEAN on ean_noart = p.CODE_ANPF and ean_cd = CODE_BARRE
inner join MGART on ean_noart = art_noart
where PRINCIPAL = 1) ;
commit;


/* (1.2) Identification des matchs incomplets (EAN uniquement)*/
update TMP_IMP_PRODUIT set connu_mbcen = 2
where CODE_ANPF in(
	select distinct c.code_anpf from TMP_CODE_BARRE c
	inner join MGEAN on ean_cd = CODE_BARRE
	where PRINCIPAL = 1
	)
and connu_mbcen is null;
commit;

/* (1.2.1) On stocke l'ANPF MBCEN correspondant */
/* - 2 minutes pour 8500 articles - */
CURSOR c_article IS
	select distinct c.CODE_ANPF, a.art_noart from MGART a
	inner join MGEAN e on e.ean_noart = a.art_noart
	inner join TMP_CODE_BARRE c on c.CODE_BARRE = e.ean_cd
	inner join TMP_IMP_PRODUIT p on p.CODE_ANPF = c.CODE_ANPF
	where connu_mbcen = 2 and ean_mait='O';
TYPE t_article IS TABLE OF c_article%ROWTYPE;
l_article t_article;
BEGIN
OPEN c_article;
LOOP FETCH c_article BULK COLLECT INTO l_article LIMIT 5000;
    EXIT WHEN l_article.count = 0; 
    FORALL i IN INDICES OF l_article
		/* on attribue le nouvel ANPF...*/
		update TMP_IMP_PRODUIT set new_anpf = l_article(i).art_noart 
		where CODE_ANPF = l_article(i).CODE_ANPF and connu_mbcen = 2;
		v_nb_update := v_nb_update + (SQL%ROWCOUNT);
		COMMIT;
        dbms_output.put_line((v_nb_update) || ' commit intermediaire pour update RDD Lucon ');
END LOOP;
CLOSE c_article;
END;

/*------------------------------------------------------------------*/
/* (2) PRODUITS INCONNUS EN CENTRALE MBCEN
/*------------------------------------------------------------------*/
/* (2.1) Identification des inconnus (c'est en fait le reste des ANPF non-flagués) */
update TMP_IMP_PRODUIT set connu_mbcen = 0
where connu_mbcen is null;
commit;

/* (2.2) Lors l'ANPF inconnu est local (>750 000), on ré-attribue un ANPF sur la plage 780 000 <-> 790 000 */
CURSOR c_article IS
	select c.CODE_BARRE, p.CODE_ANPF from TMP_CODE_BARRE c
	inner join TMP_IMP_PRODUIT p on c.CODE_ANPF = p.CODE_ANPF
	inner join mgart on art_noart = p.CODE_ANPF
	where connu_mbcen = 0 and p.CODE_ANPF >= 750000 and PRINCIPAL=1;
TYPE t_article IS TABLE OF c_article%ROWTYPE;
l_article t_article;
BEGIN
OPEN c_article;
LOOP FETCH c_article BULK COLLECT INTO l_article LIMIT 5000;
    EXIT WHEN l_article.count = 0; 
    FORALL i IN INDICES OF l_article
		/* on flag...*/
		update TMP_IMP_PRODUIT set anpf_deja_utilise = 1 where CODE_ANPF=l_article(i).CODE_ANPF;
		v_nb_update := v_nb_update + (SQL%ROWCOUNT);
		/* on attribue le nouvel ANPF*/
		update TMP_IMP_PRODUIT set new_anpf = 780001+v_nb_update;
		where CODE_ANPF=l_article(i).CODE_ANPF;
		COMMIT;
        dbms_output.put_line((v_nb_update) || ' commit intermediaire pour update RDD Lucon ');
END LOOP;
CLOSE c_article;
END;

/*
ON RESUME...
- CONNU NATIONAL et LOCAL (EAN+ANPF) : connu_mbcen=1 --> ON FAIT DESCENDRE VIA LE RER (j'insère une caractéristique article afin de spécifier le cas)
- CONNU NATIONAL (ANPF uniquement) : connu_mbcen=1 + ajout_ean_centrale=1 --> ON AJOUTE L'EAN (secondaire) EN CENTRALE et ON FAIT DESCENDRE VIA LE RER
- CONNU NATIONAL et LOCAL (EAN uniquement) : connu_mbcen=2  + new_anpf=art_noart MBCEN --> ON AFFECTE LA CORRESPONDANCE AVEC L'ANPF DE MBCEN 
- INCONNU NATIONAL : connu_mbcen=0 --> ON CREE L ARTICLE AVEC L ANPF NATIONAL DU DUMP
- INCONNU LOCAL : connu_mbcen=0 et new_anpf=[780001 - 790000] -> ON CREE L ARTICLE AVEC UN NOUVEL ANPF SUR PLAGE NOART DISPONIBLE
*/

/
spool off
exit