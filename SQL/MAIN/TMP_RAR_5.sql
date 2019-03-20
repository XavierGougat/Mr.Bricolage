set serveroutput on
set feedback off;
DECLARE
    v_code_anpf        tmp_code_barre.code_anpf%TYPE;   
    v_code_barre       tmp_code_barre.code_barre%TYPE;
    v_code_barre_1       tmp_code_barre.code_barre%TYPE;
    v_code_barre_2       tmp_code_barre.code_barre%TYPE;
    v_code_barre_3       tmp_code_barre.code_barre%TYPE;
    v_code_barre_4       tmp_code_barre.code_barre%TYPE;
    v_code_barre_5       tmp_code_barre.code_barre%TYPE;
    i_rar        TMP_RAR%ROWTYPE;   
    
    CURSOR c_ean IS
        select c.code_anpf, c.code_barre as ean
        FROM tmp_code_barre c
        INNER JOIN tmp_imp_produit p on c.code_anpf = p.code_anpf
        WHERE connu_mbcen = 0 and new_anpf between 7800001 and 7900000 AND instr(code_barre,'M') = 0 and principal =1;

    CURSOR c_ean_sec IS
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

    CURSOR c_ean_align IS
        select * from TMP_RAR
        where carac04='RDD_CAS|5' and ean_ppal is null and ean_sec_1 is not null;
BEGIN
    /* Alimentation de la table TMP_RAR sur la centrale MBCEN */
    /* Cas n°5 : INCONNU LOCAL : connu_mbcen=0 et new_anpf=[780001 - 790000] -> ON CREE L ARTICLE AVEC UN NOUVEL ANPF SUR PLAGE NOART DISPONIBLE */
    /* on modifie l'ANPF a l'insertion dans TMP_RAR et on stocke l ancien dans la carac05 */
    /* **** ************************** ***** */
    dbms_output.put_line('Debut Alimentation des articles cas n°5 dans TMP_RAR');
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
    dbms_output.put_line('Debut mise à jour EAN principal dans TMP_RAR pour les articles cas n5');
    OPEN c_ean;
    LOOP
    FETCH c_ean INTO v_code_anpf, v_code_barre;
    EXIT WHEN c_ean%NOTFOUND;
        UPDATE tmp_rar set ean_ppal = v_code_barre
        where code_article = v_code_anpf and carac04 = 'RDD_CAS|5';
        COMMIT;
    END LOOP;
    CLOSE c_ean;

    /* **** ************************** ***** */
    /* Mise à jour des EAN secondaires des articles du cas n5
    /* **** ************************** ***** */
    dbms_output.put_line('Debut mise à jour EAN secondaire dans TMP_RAR pour les articles cas n5');
    OPEN c_ean_sec;
    LOOP
    FETCH c_ean_sec INTO v_code_anpf, v_code_barre_1, v_code_barre_2, v_code_barre_3, v_code_barre_4, v_code_barre_5;
    EXIT WHEN c_ean_sec%NOTFOUND;
        UPDATE tmp_rar set ean_sec_1 = v_code_barre_1, ean_sec_2 = v_code_barre_2, ean_sec_3 = v_code_barre_3, ean_sec_4 = v_code_barre_4, ean_sec_5 = v_code_barre_5
        where code_article = v_code_anpf and carac04 = 'RDD_CAS|5';
        COMMIT;
    END LOOP;
    CLOSE c_ean_sec;

    /* **** ************************** ***** */
    /* Alignement des ean principaux si ils sont null et ean secondaire valorise*/
    /* **** ************************** ***** */
    dbms_output.put_line('Debut mise à jour EAN principal pour les articles cas n5, sans ean principal mais avec ean_secondaire');
    OPEN c_ean_align;
    LOOP
    FETCH c_ean_align INTO i_rar;
    EXIT WHEN c_ean_align%NOTFOUND;
        UPDATE tmp_rar set ean_ppal = i_rar.ean_sec_1, ean_sec_1 = null
        where code_article = i_rar.code_article and carac04 = 'RDD_CAS|5';
        COMMIT;
    END LOOP;
    CLOSE c_ean_align;
END;
/
quit