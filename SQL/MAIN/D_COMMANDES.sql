set serveroutput on size 1000000
DECLARE
  V_VERIF NUMBER;
  NOVAR   MGARV.ARV_NOVAR%TYPE;
  TYUNCDE MGARV.ARV_TYUNCDE%TYPE;
  TYUNFAC MGARV.ARV_TYUNFACT%TYPE;
  LBARTI  MGART.ART_LBARTI%TYPE;
  CDF     MGART.ART_CDF%TYPE;
  CDUL    MGVUL.VUL_CDUL%TYPE;
  RFFOU2  MGVUL.VUL_RFFOU2%TYPE;
  DTLIVR  DATE;
  QTCDEE  NUMBER;
  QTRECEP NUMBER;
  QTFACT  NUMBER;
  PDCDEE  NUMBER;
  PDRECEP NUMBER;
  PDFACT  NUMBER;
  V_ERREUR VARCHAR2(200) := NULL;
  VG_CDMAG      MGMAG.CLI_CDMAG%TYPE;
  DEVISE        MGSDV.SDV_CDDEVI%TYPE;
  V_COMMENTAIRE VARCHAR2(250);
  i number := 0;
  TYPE tab_rowid IS TABLE OF ROWID;
  l_r tab_rowid;

  v_crt MGCRT%ROWTYPE;   
  CURSOR c_crt IS
    SELECT t2.*
    FROM TMP_HISTO_VENTE t1, MGCRT t2
    WHERE t1.noart = t2.crt_znvaleur and crt_cdcaract='ANPF';
BEGIN
  DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
  -- récupération cd mag + code devise
  SELECT A.CLI_CDMAG, SDV_CDDEVI
  INTO VG_CDMAG, DEVISE
  FROM MGMAG A, MGSOC B, MGSDV, MGENS
  WHERE B.SOC_CDSOC = 1
  AND SDV_DT = (SELECT MAX(SDV_DT) FROM MGSDV WHERE SDV_CDSOC = SOC_CDSOC)
  AND B.SOC_CDMAGPR = A.CLI_CDMAG
  AND SDV_CDSOC = SOC_CDSOC
  AND SOC_CDENS = ENS_CDE;

  -- mise à jour 
  update tmp_IMP_LIGNE_CDE
  set entete_cdfo = 
  (
    select cdf_cdfo 
    from mgcdf 
    where cdf_nocdefou = nocdefou 
    and cdf_cdmag = VG_CDMAG
  );

  /* Mise à jour des codes articles et des codes fournisseurs */
  BEGIN
    OPEN c_crt;
    LOOP
        FETCH c_crt INTO v_crt;
            UPDATE TMP_IMP_LIGNE_CDE set noart = v_crt.crt_noart
            where noart = v_crt.crt_znvaleur;
        EXIT WHEN c_crt%NOTFOUND;
    END LOOP;
    commit;
    CLOSE c_crt;
  END;
  -- vérifications
	update tmp_IMP_LIGNE_CDE set commentaire = 'pas de fournisseur trouvé pour cette commande' where nvl(entete_cdfo, 0) = 0;

	for cur in  
  (
    SELECT entete_cdfo as fou, noart
    from tmp_IMP_LIGNE_CDE
    where commentaire is null
    MINUS
    SELECT arv_cdfo, arv_noart FROM mgarv
  )
	loop
    V_COMMENTAIRE := 'Pas de lien article - fournisseur dans MGARV';
    update tmp_IMP_LIGNE_CDE
    set commentaire = v_commentaire
    where entete_cdfo = cur.fou
    and noart = cur.noart;
	end loop;
  
  FOR C1 IN (
    SELECT 
      DISTINCT NOCDEFOU,
      entete_cdfo as cdfo,
      NOART,
      COLISAGE,
      SUM(QTTE) AS S_QTTE,
      SUM(QTTE_LIVREE) AS S_QTTE_LIVREE
    FROM TMP_IMP_LIGNE_CDE
    WHERE nvl(trim(COMMENTAIRE), 'z') = 'z'
    GROUP BY NOCDEFOU, entete_cdfo, NOART, COLISAGE
    order by NOCDEFOU, entete_cdfo, NOART, COLISAGE) 
    LOOP
      SELECT COUNT(*)
      INTO V_VERIF
      FROM MGCDF
      WHERE MGCDF.CDF_NOCDEFOU = C1.NOCDEFOU;
  
      IF V_VERIF = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Erreur commande absente de MGCDF : ' || C1.NOCDEFOU);
      ELSE
        BEGIN
          SELECT max(ARV_NOVAR), ARV_TYUNCDE, ARV_TYUNFACT
          INTO NOVAR, TYUNCDE, TYUNFAC
          FROM MGARV
          WHERE ARV_CDFO = c1.cdfo
          AND ARV_NOART = C1.NOART
          GROUP BY ARV_NOVAR, ARV_TYUNCDE, ARV_TYUNFACT;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Erreur - aucun ARV existant sur le produit ' || C1.NOART || ' avec le fournisseur : ' || c1.cdfo);
        END;

        BEGIN
          SELECT VUL_CDUL, VUL_RFFOU2
          INTO CDUL, RFFOU2
          FROM MGVUL
          WHERE VUL_NOART = C1.NOART
          AND VUL_CDFO = c1.cdfo
          AND VUL_NBPCBUL = C1.COLISAGE;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              DBMS_OUTPUT.PUT_LINE('Pas de code UL existant pour ce colisage ! -> commande ' || C1.NOCDEFOU || ' noart ' || C1.NOART || ' colisage ' || C1.COLISAGE);
              DBMS_OUTPUT.PUT_LINE('Récupération de l''UL mini pour l''article');
              BEGIN
                SELECT VUL_CDUL, VUL_RFFOU2
                INTO CDUL, RFFOU2
                FROM MGVUL
                WHERE VUL_NOART = C1.NOART
                AND VUL_CDFO = c1.cdfo
                AND VUL_CDUL = (SELECT MIN(VUL_CDUL)
                FROM MGVUL
                WHERE VUL_NOART = C1.NOART
                AND VUL_CDFO = c1.cdfo);
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_ERREUR := 'Erreur - Pas de code UL existant pour cet article -> commande ' || C1.NOCDEFOU || ' noart ' || C1.NOART;
                    DBMS_OUTPUT.PUT_LINE(V_ERREUR);
              END;
        END;

        BEGIN
          IF TYUNFAC = 'A' THEN
          
            QTCDEE  := C1.S_QTTE;
            QTRECEP := C1.S_QTTE_LIVREE;
            QTFACT  := C1.S_QTTE_LIVREE;
            PDCDEE  := NULL;
            PDRECEP := NULL;
            PDFACT  := NULL;
          
          ELSE
          
            QTCDEE  := NULL;
            QTRECEP := NULL;
            QTFACT  := NULL;
            PDCDEE  := C1.S_QTTE;
            PDRECEP := C1.S_QTTE_LIVREE;
            PDFACT  := C1.S_QTTE_LIVREE;
          
          END IF;
        END;

        BEGIN
          SELECT ART_LBARTI, ART_CDF
          INTO LBARTI, CDF
          FROM MGART
          WHERE ART_NOART = C1.NOART;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_ERREUR := 'Erreur - article inconnu ' || C1.NOART;
              DBMS_OUTPUT.PUT_LINE(V_ERREUR);
        END;

		    BEGIN
          INSERT INTO MGDCF(
            DCF_CDMAG,
            DCF_NOCDEFOU,
            DCF_CDFO,
            DCF_NOVAR,
            DCF_NOART,
            DCF_NOLGCD,
            DCF_CDUL,
            DCF_LBARTI,
            DCF_TXTVA,
            DCF_CDFAMI,
            DCF_QTCDEE,
            DCF_QTRECP,
            DCF_QTFACT,
            DCF_PDCDEE,
            DCF_PDRECP,
            DCF_PDFACT,
            DCF_TYUNCDE,
            DCF_TYUNFAC,
            DCF_PXNET,
            DCF_PXREVIEN,
            DCF_RFFOU
          )
          SELECT 
            VG_CDMAG,
            C1.NOCDEFOU,
            c1.cdfo,
            NOVAR,
            C1.NOART,
            i, --num ligne
            1,
            LBARTI,
            TXTVA,
            CDF,
            QTCDEE,
            QTRECEP,
            QTFACT,
            PDCDEE,
            PDRECEP,
            PDFACT,
            TYUNCDE,
            TYUNFAC,
            PA_HT_APRES_REMISES,
            PA_HT_APRES_REMISES,
            RFFOU2
          FROM TMP_IMP_LIGNE_CDE
          WHERE NOCDEFOU = C1.NOCDEFOU AND NOART = C1.NOART;
          EXCEPTION
            WHEN dup_val_on_index THEN null;    
        END;
      END IF;
    END LOOP;
    COMMIT;

/* ***************************************
UPDATE POST-DCF
*************************************** */
/*
CDF_NBLIGCDE     << update post lignes : select count(*) from mgdcf where DCF_NOCDEFOU = CDF_NOCDEFOU
CDF_MTACHAT      << update post lignes : sum(pa_ht_apres_remises->DCF_PXNET) from mgdcf where DCF_NOCDEFOU = CDF_NOCDEFOU
CDF_MTTVA        << update post lignes : sum(mttva) 
CDF_NBCOLIS      << update post lignes : sum(colisage->DCF_QTCDEE) from mgdcf where DCF_NOCDEFOU = CDF_NOCDEFOU
*/
-- mise à jour des numéros de lignes 
/*
for c1 in (select distinct dcf_nocdefou 
from mgdcf 
where dcf_cdmag = vg_cdmag)
loop

  i := 1;

  for c2 in (
    select distinct dcf_noart 
    from mgdcf 
    where dcf_nocdefou = c1.dcf_nocdefou
    and dcf_cdmag = vg_cdmag
    order by dcf_noart
  )
  loop
    update mgdcf
    set dcf_nolgcd = i
    where dcf_noart = c2.dcf_noart
    and dcf_nocdefou = c1.dcf_nocdefou
    and dcf_cdmag = vg_cdmag;

    i := i + 1;
  end loop;
end loop;
*/

update mgcdf
set CDF_NBLIGCDE = (select count(*) from mgdcf where dcf_nocdefou = cdf_nocdefou),
CDF_MTACHAT  = (select sum(dcf_pxnet) from mgdcf where dcf_nocdefou = cdf_nocdefou),
CDF_MTTVA    = (select sum(mttva) from TMP_IMP_LIGNE_CDE where nocdefou = cdf_nocdefou),
CDF_NBCOLIS  = (select case when sum(DCF_QTCDEE) > 0 then sum(DCF_QTCDEE) else null end from mgdcf where DCF_NOCDEFOU = CDF_NOCDEFOU);
END;
/
quit