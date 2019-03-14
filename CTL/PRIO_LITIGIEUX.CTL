OPTIONS (BINDSIZE=5120000,ROWS=100000)
load data
replace into table prio_four_litigieux
FIELDS terminated by ";" Optionally enclosed by '"'
trailing nullcols
(
    noart,
    flprinci 
)