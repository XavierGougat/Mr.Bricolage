OPTIONS (BINDSIZE=5120000,ROWS=100000,SKIP=0)
load data
CHARACTERSET UTF8
append into table TMP_CODE_BARRE
FIELDS terminated by ";" Optionally enclosed by '"'
trailing nullcols
(noligne   RECNUM,
code_anpf  ,
code_fournisseur  ,
code_barre  ,
code_magasin  ,
principal  ,
code_exploit_dex 
 )
