set serveroutput on
set feedback off;
declare
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
begin
    /* Alimentation de la table TMP_RAR sur la centrale MBCEN */
    /* Cas n°2 : CONNU NATIONAL (ANPF uniquement) : connu_mbcen=1 ajout_ean_centrale = 1 --> ON AJOUTE EAN SECONDAIRE DANS LE TMP_RAR PUIS DESCENTE RER */
    /* aucune modification à l'insertion TMP_RAR */
    dbms_output.put_line('Debut Alimentation des articles cas n2 dans TMP_RAR');
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
/
quit