set serveroutput on
set feedback off;
DECLARE
BEGIN
/* 1) CONTROLE INTEGRITE DES DONNEES */
UPDATE TMP_IMP_PRODUIT set commentaire = null;
commit;

dbms_output.put_line('Etape 1 : Contrôle des doublons de la table MGCGS');
select cgs_cdfamma7, cgs_cdsfama7, cgs_cdubsma7, count(*) as total from mgcgs
group by cgs_cdfamma7, cgs_cdsfama7, cgs_cdubsma7
having count(*) > 1;

--absence du taux de TVA
update TMP_IMP_PRODUIT
set commentaire = CONCAT(commentaire,',taux tva absent')
where code_tva is null;

-- articles en double
UPDATE TMP_IMP_PRODUIT 
SET commentaire = CONCAT(commentaire,',article en double')
WHERE code_anpf IN (
	SELECT code_anpf
	FROM TMP_IMP_PRODUIT     
	GROUP BY code_anpf
	HAVING COUNT(*) > 1
);
commit;

-- rfsf inconnu 
update TMP_IMP_PRODUIT
set commentaire = CONCAT(commentaire,',RFSF inconnu')
WHERE trim(code_nomenclature) not in (select trim(cgs_cdub) from mgcgs);
commit;


-- double ean maître
select EAN_NOART, count(EAN_CD) from MGEAN 
where EAN_MAIT='O' group by EAN_NOART having count(EAN_CD) > 1;

-- absence d'unité de mesure / vente
update TMP_IMP_PRODUIT
set commentaire = CONCAT(commentaire,',absence unité de mesure / vente')
WHERE unite_mesure IS NULL OR unite_sortie IS NULL;
commit;

-- poids >= 1 Tonne 
update TMP_IMP_PRODUIT SET poids_net=0 WHERE poids_net >= 1000; --passage des poids 0 pour ceux supérieurs à 1 T (validation magasin)
commit;

update TMP_IMP_PRODUIT
set commentaire = CONCAT(commentaire,',Poids non gérable en base passé à 0')
WHERE poids_net >= 1000;
commit;

END;
/
quit