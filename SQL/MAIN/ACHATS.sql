set serveroutput on size 1000000
DECLARE
    v_crt       MGCRT%ROWTYPE;   
    CURSOR c_crt IS
        select * from mgcrt
        where crt_cdcaract = 'ANPF' and crt_znvaleur is not null;
BEGIN
    OPEN c_crt;
    LOOP
        FETCH c_crt INTO v_crt;
            UPDATE TMP_HISTO_ACHAT set nart = v_crt.crt_noart
            where nart = v_crt.crt_znvaleur;
        EXIT WHEN c_crt%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE c_crt;
END;		
/*	***	***		***	***		***	***		***	***
*
*	On intègre les historiques d'achats via la création de mouvements de stocks (table MGMVT)
*
*	***	***		***	***		***	***		***	***/
BEGIN     
    INSERT INTO mgmvt
    (
        mvt_noart, 
        mvt_cdmag, 
        mvt_dtmouvmt, 
        mvt_qtentree, 
        mvt_qtsortie
    )
    SELECT 
        nart, 
        vg_cdmag, 
        date_achat, 
        --si la qtté achetée est positive, alors on alimente qtentree
        CASE
            WHEN SUM(qt_achete) > 0 
            THEN SUM(qt_achete) 
            ELSE 0
        END AS qt_entree,
        --si la qtté achetée est négative, alors on alimente qtsortie
        CASE WHEN SUM(qt_achete) < 0 THEN -1 * SUM(qt_achete)
        ELSE 0
        END AS qt_sortie
    FROM tmp_histo_achat
    GROUP BY date_achat, nart;
    COMMIT;																
END;
/*	***	***		***	***		***	***		***	***
    *
    *	boucle de creation des stocks précédents.
    *  			AKA "moul sto inverse"
    *
    *	***	***		***	***		***	***		***	***
    */
DECLARE
    i NUMBER(2);
    stock NUMBER(10,3);
    entree NUMBER(10,3);
    sortie NUMBER(10,3);

    TYPE type_stock IS RECORD 
    (
        noart MGMVT.mvt_noart%TYPE, 
        stock MGMVT.mvt_qtregul%TYPE
    );

    v_stock type_stock;

    CURSOR cur_stock IS
    select mvt_noart as noart, max(mvt_qtregul) as stock
    from mgmvt
    group by mvt_noart;
BEGIN
    i:=0;
    OPEN cur_stock;
    LOOP
        FETCH cur_stock INTO v_stock;
        EXIT WHEN cur_stock%NOTFOUND;
            stock:=v_stock.stock;
            entree:=null;
            sortie:=null;

            FOR histo IN (
                select * from mgmvt
                where mvt_noart =v_stock.noart
                and mvt_qtregul is null
                order by mvt_dtmouvmt desc
            )
            LOOP
                dbms_output.put_line('Compteur : '||i||' - Stock : '||(stock - nvl(entree,0) + nvl(sortie,0))||' - noart : '||histo.mvt_noart||' - date : '||histo.mvt_dtmouvmt);
                update mgmvt set mvt_qtstomvt = (stock - nvl(entree,0) + nvl(sortie,0)), mvt_dtmaj = sysdate
                where mvt_noart = histo.mvt_noart
                and mvt_dtmouvmt = histo.mvt_dtmouvmt;

                select mvt_qtstomvt, mvt_qtentree, mvt_qtsortie
                into stock, entree, sortie
                from mgmvt 
                where mvt_noart = histo.mvt_noart
                and mvt_dtmouvmt = histo.mvt_dtmouvmt;
                
                commit;
                i:=i+1;
            END LOOP;
    END LOOP;
    CLOSE cur_stock;
END;
/*	***	***		***	***		***	***		***	***
*
*	VERIF  STOCK FLNONSTO ET STOCK A DECIMALE
*
*	***	***		***	***		***	***		***	***
*/
BEGIN
    dbms_output.put_line(' ');
    dbms_output.put_line('Articles avec stock <> 0 mais flag nonstock a VRAI');
    dbms_output.put_line('article;libelle;stk');
    FOR curs IN (
        SELECT art_noart || ';' || art_lbarti || ';' || ast_qtstock ligne
        FROM   mgast, mgart
        WHERE  ast_qtstock <> 0
        AND    ast_noart = art_noart
        AND    art_flnonsto = '54'
        ORDER BY art_noart
    )
    LOOP
        dbms_output.put_line(curs.ligne);
    END LOOP;
    dbms_output.put_line(' - - - - ');	
    dbms_output.put_line(' ');
    dbms_output.put_line('stock à décimales sur article vendu à la pièce');
    dbms_output.put_line('article;stk fourni;stk arrondi;prmp');
    FOR curs IN (
        SELECT art_noart || ';' || ast_qtstock || ';' || round(ast_qtstock) || ';' || ast_pxmoypdr ligne
        FROM   mgast, mgart
        WHERE  ast_noart = art_noart
        AND    art_tyuvec = 'A'
        AND    ast_qtstock <> round(ast_qtstock)
        ORDER BY art_noart
    )
    LOOP
        dbms_output.put_line(curs.ligne);
    END LOOP;
    dbms_output.put_line(' - - - - ');
END;
/
quit