set serveroutput on
DECLARE
BEGIN
/* 1) CONTROLE INTEGRITE DES DONNEES */
UPDATE TMP_IMP_PRODUIT set commentaire = null;
commit;

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