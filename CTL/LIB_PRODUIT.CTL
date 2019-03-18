OPTIONS (BINDSIZE=5120000,ROWS=100000,SKIP=0)
load data
CHARACTERSET UTF8
append into table TMP_LIB_PRODUIT
FIELDS terminated by ";" Optionally enclosed by '"'
trailing nullcols
(noligne   RECNUM,
code_anpf  ,
langue  ,
lib_long  ,
lib_court  ,
lib_descr  ,
lib_techn  ,
code_magasin  ,
code_exploit_dex
 )
