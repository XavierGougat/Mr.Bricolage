set serveroutput on size 1000000
spool &1 append

/* désactivation des triggers de traces des tables MGAST et ENPMP*/
alter trigger enpmp_trace disable ;
alter trigger mgast_trace disable ;

begin
	-- on met à jour les prix moyen pondérés
    DECLARE
        CURSOR c_pamp IS
        SELECT * FROM  tmp_imp_produit;
        i_pamp tmp_imp_produit%ROWTYPE;
        BEGIN
          OPEN c_pamp;
          LOOP
            FETCH c_pamp INTO i_pamp;
            UPDATE mgast set ast_pxmoypdr = i_pamp.pamp where ast_noart = i_pamp.code_anpf; 
            UPDATE enpmp set epmp_pxmoypdr = i_pamp.pamp where epmp_noart = i_pamp.code_anpf; 
            COMMIT;
            EXIT WHEN c_pamp%NOTFOUND;
          END LOOP;
          CLOSE c_pamp;
        END;
END;
/

alter trigger enpmp_trace enable ;
alter trigger mgast_trace enable ;

UPDATE mgart SET art_cdplualp = art_noart WHERE art_cdplualp IS NULL;
COMMIT;

spool off
exit