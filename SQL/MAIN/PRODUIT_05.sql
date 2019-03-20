set serveroutput on
set feedback off;
DECLARE
    anpf_insere NUMBER(7) := 7800001;
    v_nb_update NUMBER(6) := 0;
    CURSOR c_article_2 IS
        select c.CODE_BARRE, p.CODE_ANPF from TMP_CODE_BARRE c
        inner join TMP_IMP_PRODUIT p on c.CODE_ANPF = p.CODE_ANPF
        inner join mgart on art_noart = p.CODE_ANPF
        where connu_mbcen = 0 and p.CODE_ANPF >= 750000;
    TYPE t_article_2 IS TABLE OF c_article_2%ROWTYPE;
    l_article_2 t_article_2;
BEGIN
/*------------------------------------------------------------------*/
/* ICI ON GERE LES CAS INCONNUS EN CENTRALE (Cas 4 / 5)
/*------------------------------------------------------------------*/
    /*------------------------------------------------------------------*/
    /* (CAS 4) Articles nationaux inconnus
    /*------------------------------------------------------------------*/
    /* on flag connu_mbcen=0 pour tout le reste des articles... */
    update TMP_IMP_PRODUIT set connu_mbcen = 0
    where connu_mbcen is null;
    commit;

    /*------------------------------------------------------------------*/
    /* (CAS 5) Articles locaux inconnus
    /*------------------------------------------------------------------*/
    FOR l_article_2 in c_article_2
        LOOP
            update TMP_IMP_PRODUIT set anpf_deja_utilise = 1 where CODE_ANPF=l_article_2.CODE_ANPF;
            anpf_insere := anpf_insere + (SQL%ROWCOUNT);
            update TMP_IMP_PRODUIT set NEW_ANPF = anpf_insere where CODE_ANPF=l_article_2.CODE_ANPF;
            COMMIT;
            v_nb_update := v_nb_update+1;
            dbms_output.put_line('Ancien ANPF : ' || l_article_2.CODE_ANPF || ' - Nouvel ANPF : ' || (anpf_insere));
    END LOOP;
    dbms_output.put_line('Nombre updates total : ' || (v_nb_update));
END;
/
quit