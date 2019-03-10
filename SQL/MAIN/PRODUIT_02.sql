set serveroutput on
DECLARE
ray NUMBER(5);
fam NUMBER(5);
sfa NUMBER(5);
ubs NUMBER(5);
BEGIN
    /* 2) AFFECTATION DE LA NOMENCLATURE METI */
    FOR curs IN (SELECT DISTINCT TRIM(code_nomenclature) AS code_plc FROM TMP_IMP_PRODUIT) 
    LOOP
        BEGIN
            SELECT DISTINCT
            fam_cdr,
            a.cgs_cdfamma7,
            a.cgs_cdsfama7,
            a.cgs_cdubsma7
            INTO
            ray,
            fam,
            sfa,
            ubs
            FROM mgcgs a, mgfam
            WHERE trim(cgs_cdub) = trim(curs.code_plc)
            AND cgs_cdfamma7 = fam_cdf;
            EXCEPTION
            WHEN no_data_found THEN
                ray := 9;
                fam := 99;
                sfa := 9999;
                ubs := 19;	
        END;
        
        UPDATE TMP_IMP_PRODUIT t1
        SET meti_rayon = ray,
            meti_famille = fam,
            meti_ssfamille = sfa,
            meti_ubs = ubs
        WHERE trim(t1.code_nomenclature) = trim(curs.code_plc);
        COMMIT; 
    END LOOP;
END;
/
quit