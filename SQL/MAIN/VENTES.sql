create index Index_temp on TMP_HISTO_VENTE (dtrem, noart);
create index Index_temp2 on TMP_HISTO_VENTE (noart);

DECLARE
    cpt         NUMBER;
    temerr      NUMBER;
    date_prec   DATE;
    numart      NUMBER;
    vg_cdmag    mgmag.cli_cdmag%TYPE;
    devise      mgsdv.sdv_cddevi%TYPE;
    tyuvec      mgart.art_tyuvec%TYPE;
    codefamille NUMBER;
	fam_defaut NUMBER;
	noartfam_defaut number;
    codearticle NUMBER;
    cdtva NUMBER;
    v_file       utl_file.file_type;
    datemin      DATE;
    datemax      DATE;
    anmin        NUMBER;
    anmax        NUMBER;
    moismin      NUMBER;
    moismax      NUMBER;
    semmin       NUMBER;
    semmax       NUMBER;
    v_tva_tx     mgtva.tva_tx%TYPE;
    v_art_tyuvec mgart.art_tyuvec%TYPE;
    v_art_cdtva  mgart.art_cdtva%TYPE;
    cdfo         NUMBER;
    novar        NUMBER;
    flprinci     CHAR;
    v_cur_date   DATE;

    v_cdtva   NUMBER;
    v_txtva   NUMBER;
    v_tva     NUMBER;
    v_ttc_tva NUMBER;
    v_ttc_exo NUMBER;

    v_cdtva_exo NUMBER;
    
    v_ctrl NUMBER;
BEGIN
    dbms_output.put_line(to_char(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    DELETE FROM TMP_HISTO_VENTE WHERE noart IS NULL;
    COMMIT;

    date_prec := to_date('31/12/2999', 'DD/MM/YYYY');
	fam_defaut := 988;
	
	-- récupération cd mag + code devise
    SELECT a.cli_cdmag, sdv_cddevi
    INTO   vg_cdmag, devise
    FROM   mgmag a, mgsoc b, mgsdv, mgens
    WHERE  b.soc_cdsoc = 1
    AND    sdv_dt = (SELECT MAX(sdv_dt) FROM mgsdv WHERE sdv_cdsoc = soc_cdsoc)
    AND    b.soc_cdmagpr = a.cli_cdmag
    AND    sdv_cdsoc = soc_cdsoc
    AND    soc_cdens = ens_cde;

	-- récupération des intervalles par rapport aux dates fournies
    SELECT 
        MIN(dtrem),
        MAX(dtrem),
        MIN(to_char(dtrem, 'YYYY')),
        MAX(to_char(dtrem, 'YYYY')),
        to_char(MIN(dtrem), 'YYYYMM'),
        to_char(MAX(dtrem), 'YYYYMM'),
        to_char(MIN(dtrem), 'YYYYIW'),
        to_char(MAX(dtrem), 'YYYYIW')
    INTO   datemin, datemax, anmin, anmax, moismin, moismax, semmin, semmax
    FROM   TMP_HISTO_VENTE; 
	
    /* On update ave les nouveaux codes articles issus de la caractéristique article ANPF */
    DECLARE
        v_crt       MGCRT%ROWTYPE;   
        CURSOR c_crt IS
            SELECT t2.*
            FROM TMP_HISTO_VENTE t1, MGCRT t2
            WHERE t1.noart = t2.crt_znvaleur and crt_cdcaract='ANPF';
    BEGIN
        OPEN c_crt;
        LOOP
            FETCH c_crt INTO v_crt;
                UPDATE TMP_HISTO_VENTE set noart = v_crt.crt_noart
                where noart = v_crt.crt_znvaleur;
            EXIT WHEN c_crt%NOTFOUND;
        END LOOP;
        commit;
        CLOSE c_crt;
    END;

	/* mise à jour de la famille article : temps de traitement 1 minute*/
    update TMP_HISTO_VENTE
	set meti_famille = (select art_cdf from mgart where art_noart = noart);
	commit;

	select fam_noartfam into noartfam_defaut from mgfam where fam_cdf = fam_defaut;
	
    dbms_output.put_line('REJETS_ARTICLES_INCONNUS_avec ventes seront affecté a l''article famille :');
    FOR curs IN (SELECT DISTINCT nvl(noart, 0) ligne
                FROM   TMP_HISTO_VENTE a
                WHERE  qtvend <> 0
                OR     mtachat <> 0
                OR     mtvente <> 0
                MINUS
                SELECT art_noart FROM mgart)
    LOOP
        --dbms_output.put_line(curs.ligne);
        UPDATE TMP_HISTO_VENTE SET noart = meti_famille WHERE nvl(noart, 0) = curs.ligne;
    END LOOP;

    COMMIT;
    dbms_output.put_line('REJETS_familles_INCONNUES_avec ventes seront affecté a la famille 999 :');    
    FOR curs IN (SELECT DISTINCT nvl(noart, 0) noart
                FROM   TMP_HISTO_VENTE a
                WHERE  noart = meti_famille
                AND    (qtvend <> 0 OR mtachat <> 0 OR mtvente <> 0)
                MINUS
                SELECT fam_cdf FROM mgfam)
    LOOP
        UPDATE TMP_HISTO_VENTE
        SET    noart = noartfam_defaut, meti_famille = fam_defaut
        WHERE  nvl(noart, 0) = curs.noart;
    END LOOP;
    COMMIT;
	-- mise à jour du champ mtventht
	-- = mtvente - mttva, même si les montants sont négatifs ?
    -- Temps de traitement : 1 minute
	update TMP_HISTO_VENTE
	set mtventht = mtvente - mttva;
    /* *** *** *** *** *** *** */
    dbms_output.put_line('chargement des vajr');
    dbms_output.put_line(to_char(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    -- chargement des vajr 
    -- temps de traitement : 6 minutes
    FOR curs IN (
        SELECT
        distinct noart,
        vg_cdmag,
        dtrem,
        SUM(qtvend) qtvend,
        SUM(mtvente) mtvente,
        SUM(mtachat) mtachat,
        art_tyuvec,
        SUM(mtventht) mtventht,
        txtva, --txtva
        tva_cdtva,    --cdtva
        SUM(mtachat) mtachat2
        FROM TMP_HISTO_VENTE, mgart, mgtva
        WHERE  noart = art_noart
        and  tva_tx = txtva
        GROUP BY dtrem, noart, tva_cdtva, txtva, art_tyuvec)           
    LOOP
        INSERT INTO mgvajr(
            vaj_noart,
            vaj_cdmag,
            vaj_dtrem,
            vaj_qtvend,
            vaj_mtvente,
            vaj_mtachat,
            vaj_tyuvec,
            vaj_mtventht,
            vaj_txtva,
            vaj_cdtva,
            VAJ_MTACHRFA
        )
        SELECT 
            curs.noart, 
            curs.vg_cdmag,
            curs.dtrem,
            curs.qtvend,
            curs.mtvente,
            curs.mtachat,
            curs.art_tyuvec,
            curs.mtventht,
            curs.txtva, --txtva
            curs.tva_cdtva, --cdtva
            curs.mtachat2 
    from dual;
    COMMIT;	
	END LOOP;    
    
    dbms_output.put_line('chargement des mgvasm');
    dbms_output.put_line(to_char(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));

    INSERT INTO mgvasm(
        vas_noart, 
        vas_cdmag, 
        vas_aavt, 
        vas_smvt, 
        vas_qtvend, 
        vas_mtcaar, 
        VAS_MTACHRFA,
        vas_tyuvec, 
        vas_mtventht
    )
    SELECT vaj_noart, 
			vaj_cdmag, 
			to_number(to_char(vaj_dtrem, 'YYYY'), '9999') aaaa,
			to_number(to_char(vaj_dtrem, 'IW'), '99') sem, 
			SUM(vaj_qtvend) qtvend,
			SUM(vaj_mtvente) mtvente, 
			SUM(VAJ_MTACHRFA) mtachatrfa, 
			vaj_tyuvec,
			SUM(vaj_mtventht) mtventht
	FROM   mgvajr
	WHERE  to_char(vaj_dtrem, 'YYYYIW') BETWEEN semmin AND semmax
	and    vaj_cdmag=vg_cdmag
	GROUP  BY 
			vaj_noart, 
			vaj_cdmag, 
			to_number(to_char(vaj_dtrem, 'YYYY'), '9999'),
            to_number(to_char(vaj_dtrem, 'IW'), '99'), 
			vaj_tyuvec;
    COMMIT;


    dbms_output.put_line('chargement des mgvams');
    dbms_output.put_line(to_char(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));

    FOR curs IN (
        SELECT 
            vaj_cdmag,
            vaj_noart,
            trunc(vaj_dtrem, 'MM') mois_rem,
            SUM(nvl(vaj_qtvend, 0)) qtvend,
            SUM(vaj_mtvente) mtvente,
            SUM(vaj_mtventht) mtventht,
            SUM(vaj_mtachat) mtachat,
            SUM(decode(vaj_tyuvec, 'K', nvl(vaj_qtvend, 0), 0)) pdvente,
            SUM(VAJ_MTACHRFA) mtachatrfa,
            MAX(vaj_tyuvec) tyuvex
        FROM   mgvajr
        WHERE  to_char(vaj_dtrem, 'YYYYMM') BETWEEN moismin AND moismax
        AND    vaj_cdmag = vg_cdmag
        GROUP BY vaj_cdmag, vaj_noart, trunc(vaj_dtrem, 'MM')
    )
    LOOP
        BEGIN
            SELECT arv_cdfo, arv_novar, arv_flprinci
            INTO   cdfo, novar, flprinci
            FROM   mgarv
            WHERE  arv_noart = curs.vaj_noart
            AND    arv_dtdeb <= curs.mois_rem
            AND    arv_dtfin >= curs.mois_rem
            ORDER  BY arv_flprinci DESC;
        EXCEPTION
            WHEN OTHERS THEN
                -- ajout SMA 18/07 :
                cdfo  := 99999; -- combinaison inexistante dans MGFOV (FK_MGFOV_AFFECT de MGVAMS)
                novar := 991; -- novar:=1 => novar:=991
        END;
    
        INSERT INTO mgvams(
            vam_cdmag,
            vam_cdfo,
            vam_novar,
            vam_noart,
            vam_aavt,
            vam_mmvt,
            vam_qtvend,
            vam_mtvente,
            vam_mtachat,
            vam_pdvente,
            vam_mtachrfa,
            vam_tyuvex,
            vam_mtventht
        )
        VALUES(
            curs.vaj_cdmag,
            cdfo,
            novar,
            curs.vaj_noart,
            to_number(to_char(curs.mois_rem, 'YYYY'), '9999'),
            to_number(to_char(curs.mois_rem, 'MM'), '99'),
            curs.qtvend,
            curs.mtvente,
            curs.mtachat,
            curs.pdvente,
            curs.mtachatrfa,
            curs.tyuvex,
            curs.mtventht
        );
    END LOOP;
    COMMIT;
    
    -- chargement des mgvug et mgfin
    v_cur_date := datemin;
    WHILE v_cur_date <= datemax
    LOOP
        dbms_output.put_line('chargement des mgvug et mgfin : ' || v_cur_date);
        dbms_output.put_line(to_char(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
        FOR charge IN (
            SELECT 
                vaj_cdmag,
                art_cdf fam,
                fam_cdtvaprf,
                vaj_dtrem dtrem,
                SUM(vaj_qtvend) qtvend,
                SUM(vaj_mtvente) mtvente,
                SUM(vaj_mtachat) mtachat,
                SUM(nvl(vaj_mtvente, 0)) ttc,
                SUM(nvl(vaj_mtventht, 0)) ht
            FROM   mgart, mgvajr, mgfam
            WHERE  art_noart = vaj_noart
            AND    art_cdf = fam_cdf
            AND    vaj_dtrem = v_cur_date
            AND    vaj_cdmag = vg_cdmag
            GROUP BY vaj_cdmag, art_cdf, vaj_dtrem, fam_cdtvaprf
        )
        LOOP
            --  codage en dur des codes TVA : 
            --  pour un montant TTC donné on affecte la partie HT au codes TVA préféré famille
            --  et la partie TVA à un code exonéré
            --  permet de gérer les différences issus des calculs/données
            --  (exemple article txtva >0, avec mtventHT = mtventTTC ...)
            IF charge.fam_cdtvaprf = 2 -- codage en dur du code/taux tva   --codage en dur du "décodage" des taux de tva. modif asap
            THEN
                v_cdtva := 2;
                v_txtva := 5.5;            
            END IF;
            IF charge.fam_cdtvaprf = 1 -- codage en dur du code/taux tva   --codage en dur du "décodage" des taux de tva. modif asap
            THEN
                v_cdtva := 1;
                v_txtva := 20;            
            END IF;
            IF charge.fam_cdtvaprf = 4 -- codage en dur du code/taux tva   --codage en dur du "décodage" des taux de tva. modif asap
            THEN
                v_cdtva := 4;
                v_txtva := 2.1;            
            END IF;
            v_tva       := charge.ttc - charge.ht;
            v_ttc_tva   := v_tva * (100 + v_txtva) / (v_txtva); --mis sur le code tva 2 ou 3
            v_ttc_exo   := charge.ttc - v_ttc_tva; -- mis sur le code tva 1 (exo)
            v_cdtva_exo := 1; -- code TVA qui reprend le v_ttc_exo
        
            INSERT INTO mgvug(
                vug_cdmag,
                vug_dtrem,
                vug_cdf,
                vug_mtchaf,
                vug_mtcadvst,
                vug_qtvend,
                vug_qtscan,
                vug_qtmanu,
                vug_mtachat,
                vug_mtachrfa,
                vug_cddeviss,
                vug_mtcapro,
                vug_cdtva1,
                vug_txtva1,
                vug_mtcatva1,
                vug_cdtva2,
                vug_txtva2,
                vug_mtcatva2,
                vug_cdtva3,
                vug_txtva3,
                vug_mtcatva3,
                vug_cdtva4,
                vug_txtva4,
                vug_mtcatva4,
                vug_cdtva5,
                vug_txtva5,
                vug_mtcatva5,
                vug_cdtva6,
                vug_txtva6,
                vug_mtcatva6,
                vug_cdtva7,
                vug_txtva7,
                vug_mtcatva7,
                vug_cdtva8,
                vug_txtva8,
                vug_mtcatva8,
                vug_cdtva9,
                vug_txtva9,
                vug_mtcatva9
            )
            VALUES -- codage en dur des codes tva à insérer dans mgvug
            (
                vg_cdmag,
                charge.dtrem,
                charge.fam,
                charge.mtvente,
                charge.mtvente,
                charge.qtvend,
                charge.qtvend,
                0,
                charge.mtachat,
                charge.mtachat,
                devise,
                0,
                v_cdtva,
                v_txtva,
                v_ttc_tva,
                v_cdtva_exo,
                0,
                v_ttc_exo,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0
            );

            -- update mgvug avec les quantités vendues et le nombre de clients encaissés
            FOR curs IN (
                select dtrem, meti_famille, sum(qtvend) as qtvend, count(*) as nbclient from tmp_histo_vente
                group by dtrem, meti_famille
                order by dtrem, meti_famille
            )           
            LOOP
                update mgvug set vug_qtvend=curs.qtvend , vug_nbclient=curs.nbclient 
                where vug_dtrem=curs.dtrem and vug_cdf=curs.meti_famille;
                COMMIT;	
            END LOOP;

            -- ajout dans mgfin
            UPDATE mgfin
            SET fin_nbarti = fin_nbarti + charge.qtvend, fin_mtcabrut = fin_mtcabrut + charge.mtvente
            WHERE fin_cdmag = vg_cdmag AND fin_dtrem = charge.dtrem;
            IF SQL%ROWCOUNT = 0
            THEN
                INSERT INTO mgfin(
                    fin_cdmag,
                    fin_dtrem,
                    fin_nbarti,
                    fin_mtcabrut,
                    fin_dtmaj,
                    fin_cdetat)
                VALUES
                (
                    vg_cdmag,
                    charge.dtrem,
                    charge.qtvend,
                    charge.mtvente,
                    trunc(SYSDATE),
                    'V'
                );
            END IF;
        END LOOP;
        v_cur_date := v_cur_date + 1;
        COMMIT;
    END LOOP;

    UPDATE mgfin SET fin_nbartrai = 999999;
	COMMIT;

    /* On update les MGVUG avec le nombre de clients et les quantités vendues */
    DECLARE
        v_crt       MGCRT%ROWTYPE;   
        CURSOR c_crt IS
            select vug_dtrem as DT, fam_cdr as RAY, sum(vug_mtchaf) as CA from mgvug
            inner join mgfam on vug_cdf = fam_cdf
            group by vug_dtrem, fam_cdr
            order by vug_dtrem, fam_cdr; 
    BEGIN
        OPEN c_crt;
        LOOP
            FETCH c_crt INTO v_crt;
            
            EXIT WHEN c_crt%NOTFOUND;
        END LOOP;
        commit;
        CLOSE c_crt;
    END;

    dbms_output.put_line('fin chargement');
    dbms_output.put_line(to_char(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));

    FOR curs IN (
        select vug_dtrem as DT, fam_cdr as RAY, sum(vug_mtchaf)as CA, sum(vug_nbclient) as CLIENT, sum(vug_qtvend) as QT from mgvug
        inner join mgfam on vug_cdf = fam_cdf
        group by vug_dtrem, fam_cdr
        order by vug_dtrem, fam_cdr;
    )           
    LOOP
        INSERT INTO mgvry(
            vry_cdmag,
            vry_dtrem,
            vry_cdrayon,
            vry_nbclient,
            vry_qtvend,
            vry_mtchaf
        )
        SELECT 
            2, 
            curs.DT,
            curs.RAY,
            curs.CLIENT,
            curs.QT,
            curs.CA 
        from dual;
    COMMIT;	
	END LOOP;
END;
/
quit