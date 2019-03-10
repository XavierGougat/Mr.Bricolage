/*
ON RESUME...
- #1 CONNU NATIONAL et LOCAL (EAN+ANPF) : connu_mbcen=1 --> ON FAIT DESCENDRE VIA LE RER (j'insère une caractéristique article afin de spécifier le cas)
- #3 CONNU NATIONAL et LOCAL (EAN uniquement) : connu_mbcen=2  + new_anpf=art_noart MBCEN --> ON AFFECTE LA CORRESPONDANCE AVEC L'ANPF DE MBCEN 
- #2 CONNU NATIONAL (ANPF uniquement) : connu_mbcen=1 + ajout_ean_centrale=1 --> ON AJOUTE L'EAN (secondaire) EN CENTRALE et ON FAIT DESCENDRE VIA LE RER
- #4 INCONNU NATIONAL : connu_mbcen=0 --> ON CREE L ARTICLE AVEC L ANPF NATIONAL DU DUMP
- #5 INCONNU LOCAL : connu_mbcen=0 et new_anpf=[780001 - 790000] -> ON CREE L ARTICLE AVEC UN NOUVEL ANPF SUR PLAGE NOART DISPONIBLE
*/
set serveroutput on
DECLARE
    v_nb_update NUMBER(10) := 0;

    CURSOR c_article IS
        select distinct c.CODE_ANPF, a.art_noart from MGART a
        inner join MGEAN e on e.ean_noart = a.art_noart
        inner join TMP_CODE_BARRE c on c.CODE_BARRE = e.ean_cd
        inner join TMP_IMP_PRODUIT p on p.CODE_ANPF = c.CODE_ANPF
        where connu_mbcen = 2 ;
    TYPE t_article IS TABLE OF c_article%ROWTYPE;
    l_article t_article;
BEGIN
/*------------------------------------------------------------------*/
/* ICI ON GERE LES CAS COMMUNS AVEC LA CENTRALE (Cas 1 / 2 / 3)
/*------------------------------------------------------------------*/
    /*------------------------------------------------------------------*/
    /* (CAS 1) Articles nationaux et locaux communs sur la base du couple EAN+ANPF
    /*------------------------------------------------------------------*/
    update TMP_IMP_PRODUIT set connu_mbcen = 1, ajout_ean_centrale = null, new_anpf = null
    where CODE_ANPF in(select distinct p.code_anpf from TMP_IMP_PRODUIT p
    inner join TMP_CODE_BARRE c on c.CODE_ANPF = p.CODE_ANPF
    inner join MGEAN on ean_noart = p.CODE_ANPF and ean_cd = CODE_BARRE
    inner join MGART on ean_noart = art_noart
    where PRINCIPAL = 1) ;
    commit;

    /*------------------------------------------------------------------*/
    /* (CAS 3) Articles nationaux et locaux communs sur la base de l'EAN uniquement
    /*------------------------------------------------------------------*/
    update TMP_IMP_PRODUIT set connu_mbcen = 2
    where CODE_ANPF in(
        select distinct c.code_anpf from TMP_CODE_BARRE c
        inner join MGEAN on ean_cd = CODE_BARRE
        )
    and connu_mbcen is null;
    commit;
    /* (CAS 3 suite) On stocke l'ANPF MBCEN correspondant */
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

    /*------------------------------------------------------------------*/
    /* (CAS 2) Articles nationaux communs sur la base de l'ANPF uniquement
    /*------------------------------------------------------------------*/
    update TMP_IMP_PRODUIT set connu_mbcen = 1, ajout_ean_centrale = 1, new_anpf = null
    where CODE_ANPF in(select distinct p.code_anpf from TMP_IMP_PRODUIT p
    inner join MGART a on p.code_anpf = a.art_noart
    where p.code_anpf < 750000)
    and connu_mbcen is null ;
    commit;
END;
/
quit