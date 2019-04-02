set serveroutput on
set feedback off;
DECLARE
BEGIN
    update mgart set art_cdetat = 3 where art_noart in (
        select crt_noart from mgcrt where crt_cdcaract = 'RDD_CAS' and crt_znvaleur in ('4','5')
    );
    commit;

    insert into MGMSA (select 'M', msa_noart, 'A ', '  ' from mgmsa);
    exception
    when dup_val_on_index then null;
    commit;
END;
/
quit