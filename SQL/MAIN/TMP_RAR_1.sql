set serveroutput on
set feedback off;
declare
begin
    /* On repart de zéro sur les tables temporaires et de transco */
    DELETE FROM TMP_RAR;
    DELETE FROM LUCON_CAS_N1;
    DELETE FROM LUCON_CAS_N3;
    COMMIT;
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
END;
/
quit