set serveroutput on
set feedback off;
declare
BEGIN
    /* **** ************************** ***** */
    /* Alimentation de la table TMP_RAR sur la centrale MBCEN */
    /* Cas n°3 : CONNU NATIONAL et LOCAL (EAN uniquement) : connu_mbcen=2  + new_anpf=art_noart MBCEN --> ON AFFECTE LA CORRESPONDANCE AVEC L'ANPF DE MBCEN  */
    /* aucune modification à l'insertion TMP_RAR */
    /* **** ************************** ***** */
    dbms_output.put_line('Debut Alimentation des articles cas n3 dans TMP_RAR');
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
        carac05,
        cd_reseau,
        cd_assortiment
        )
    select
        noligne_sequence.nextval,
        code_mbcen, -- article
        'RDD_CAS|3',
        code_lucon
        'LU',
        'A'
    FROM LUCON_CAS_N3;
    COMMIT;
END;
/
quit