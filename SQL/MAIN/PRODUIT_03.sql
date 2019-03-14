set serveroutput on
DECLARE
BEGIN
    /* ICI ON AFFECTE LES CARACTERISTIQUES ARTICLES LIES A DE LA CODIFICATION SIGMA/METI */

    /* 1) AFFECTATION DU CODE TVA*/
    dbms_output.put_line('Etape 1 : Mise a jour du code TVA');    
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

    /* 3) AFFECTATION DU TYUVEC, TYUNMESU, PDUNIT, MSCONTE*/
    dbms_output.put_line('Etape 3 : Mise a jour unite de mesure et de vente'); 
    -- unité de mesure et vente
    for c1 in (select vco_znvlrubo, vco_znvlrubd from MGVCO where vco_dslogori = 'C4950_REFE'and vco_cdrubori = 'U_MESURE' )
    loop
        update TMP_IMP_PRODUIT
        set meti_tyunmesu = meti_outil.strtoken(c1.vco_znvlrubd, ';', 1),
        meti_tyuvec = meti_outil.strtoken(c1.vco_znvlrubd, ';', 2)
        where trim(unite_mesure) = trim(c1.vco_znvlrubo);
        commit;
    end loop;
    -- POIDS et CONTENANCE
    dbms_output.put_line('Etape 4 : Mise a jour poids et contenance'); 
    -- POIDS
    -- poids > valeur_conversion => poids brut
    dbms_output.put_line('|_Etape 4.1 : poids > valeur_conversion => poids brut');
    update TMP_IMP_PRODUIT
    set meti_pdbrut = poids_net
    where nvl(poids_net, 0) > 0
    and nvl(poids_net, 0) > nvl(valeur_conversion, 0)
    and poids_net < 1000
    and trim(commentaire) is null;
    commit;
    -- poids < valeur_conversion => poids egoutté  
    dbms_output.put_line('|_Etape 4.2 : poids < valeur_conversion => poids egoutté');
    update TMP_IMP_PRODUIT
    set meti_pdntegout = poids_net
    where nvl(poids_net, 0) > 0
    and nvl(poids_net, 0) < nvl(valeur_conversion, 0)
    and trim(commentaire) is null;
    commit;   
    -- CONTENANCE --
    -- unité mesure = kilo => valeur_conversion -> pdunit
    dbms_output.put_line('|_Etape 4.3 : unité mesure = kilo => valeur_conversion -> pdunit');
    update TMP_IMP_PRODUIT
    set meti_pdunit = valeur_conversion
    where trim(meti_tyunmesu) = 'K'
    and valeur_conversion < 1000
    and trim(commentaire) is null;
    commit;
    -- unité mesure != kilo => valeur_conversion -> contenance
    dbms_output.put_line('|_Etape 4.4 : unité mesure != kilo => valeur_conversion -> contenance');
    update TMP_IMP_PRODUIT
    set meti_msconte = valeur_conversion
    where trim(meti_tyunmesu) != 'K'
    and trim(commentaire) is null;
    commit;
END;
/
quit