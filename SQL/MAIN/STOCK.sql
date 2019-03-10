/*	***	***		***	***		***	***		***	***
*	Le client souhaite connaitre le stock repris le jour de la bascule.
*	Pour cela on va réaliser une régularisation (type comptage) pour TOUS les articles
*	***	***		***	***		***	***		***	**/

/* 
On met TMP_IMP_STOCK à jour avec les nouveaux codes articles.
On fait le lien sur l'ancien code ANPF via la caractéristique ANPF de la table MGCRT 
*/
DECLARE
    v_crt       MGCRT%ROWTYPE;   
    CURSOR c_crt IS
        SELECT t2.*
        FROM TMP_IMP_STOCK t1, MGCRT t2
        WHERE t1.nart = t2.crt_znvaleur and crt_cdcaract='ANPF';
BEGIN
    OPEN c_crt;
    LOOP
        FETCH c_crt INTO v_crt;
            UPDATE TMP_IMP_STOCK set nart = v_crt.crt_noart
            where nart = v_crt.crt_znvaleur;
        EXIT WHEN c_crt%NOTFOUND;
    END LOOP;
    commit;
    CLOSE c_crt;
END;

DECLARE
    tyuvec    mgart.art_tyuvec%TYPE;
    v_cderr VARCHAR2(500);
BEGIN	
    /* On flague "stock à zéro" les articles présents dans MGART qui ne sont absents du DUMP stock */
    /* ATTENTION REQUETE RELATIVEMENT LONGUE : 10 minutes */ 
    insert into TMP_IMP_STOCK 
	(select -1,null, art_noart,0 from mgart
	where art_noart not in (select nart from TMP_IMP_STOCK));
	commit;

	/*	***	***		***	***		***	***		***	***
	 *	On somme les quantités de stock pour chaque article
	 *	On insert une régul comptage avec la quantité totale calculée
     *  Temps de traitement : 20 minutes
	 *	***	***		***	***		***	***		***	***/
	FOR charge IN (
        SELECT nart, quantite
        FROM TMP_IMP_STOCK
    )
    LOOP
        BEGIN
            SELECT mgart.art_tyuvec 
			INTO tyuvec 
			FROM mgart 
			WHERE art_noart = charge.nart;
        EXCEPTION
            WHEN OTHERS THEN
                tyuvec := NULL;
        END;
        IF tyuvec IS NOT NULL
        THEN
            BEGIN
                stock_utility.insert_regule(
                    pi_idtrace => 0,
                    pi_debug              => 'N',
                    pi_cdmag              => '2',
                    pi_noart              => charge.nart,
                    pi_dtmvt              => to_char(sysdate,'DD/MM/YYYY'),
                    pi_qte_mvt            => charge.quantite,
                    pi_first_passage      => 'N',
                    pi_regul_corr         => 'N',
                    pi_tyuvec             => tyuvec,
                    pi_bloque_lot         => 'N',
                    pi_prix_enpmp         => 'N',
                    pi_cdregul            => 5,
                    pi_commentaire        => 'Init. Stock RDD',
                    pi_user               => 'BATCH',
                    pi_cdforesd           => 0,
                    pi_flg_invent         => 'N',
                    pi_cdaul              => 1,
                    ps_cderr              => v_cderr
                );
            END;
        END IF;
    END LOOP;
    COMMIT;	

    /*	***	***		***	***		***	***		***	***
	 *	On initialise le stock a zero pour les articles sans stock dans le dump
	 *	On insert une régul comptage avec la quantité a zero
     *  Temps de traitement : 20 minutes
	 *	***	***		***	***		***	***		***	***/
    FOR charge IN (
        select to_number(code_anpf) as nart from tmp_imp_produit
        minus
        select to_number(nart) as nart from tmp_imp_stock;
    )
    LOOP
        BEGIN
            SELECT mgart.art_tyuvec 
			INTO tyuvec 
			FROM mgart 
			WHERE art_noart = charge.nart;
        EXCEPTION
            WHEN OTHERS THEN
                tyuvec := NULL;
        END;
        IF tyuvec IS NOT NULL
        THEN
            BEGIN
                stock_utility.insert_regule (
                    pi_idtrace => 0,
                    pi_debug              => 'N',
                    pi_cdmag              => '2',
                    pi_noart              => charge.nart,
                    pi_dtmvt              => to_char(sysdate,'DD/MM/YYYY'),
                    pi_qte_mvt            => 0,
                    pi_first_passage      => 'N',
                    pi_regul_corr         => 'N',
                    pi_tyuvec             => tyuvec,
                    pi_bloque_lot         => 'N',
                    pi_prix_enpmp         => 'N',
                    pi_cdregul            => 5,
                    pi_commentaire        => 'Init. Stock RDD',
                    pi_user               => 'BATCH',
                    pi_cdforesd           => 0,
                    pi_flg_invent         => 'N',
                    pi_cdaul              => 1,
                    ps_cderr              => v_cderr
                );
            END;
        END IF;
    END LOOP;
    COMMIT;	
END;
/
quit