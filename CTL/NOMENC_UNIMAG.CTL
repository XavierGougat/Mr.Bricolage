OPTIONS (BINDSIZE=5120000,ROWS=100000)
load data
replace into table IMP_NOMENC_UNIMAG
FIELDS terminated by ";" Optionally enclosed by '"'
trailing nullcols
(
    CDUB,
    LIB
)
 
