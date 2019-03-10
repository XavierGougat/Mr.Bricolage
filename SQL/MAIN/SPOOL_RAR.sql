spool &1
set heading off
set feedback off;
set pagesize 0
set linesize 5000
select
code_article||';'||
ean_ppal||';'||
lbarti||';'||
lbcompl||';'||
lbmarque||';'||
lbcaisse||';'||
rayon||';'||
famille||';'||
sousfam||';'||
unite_besoin||';'||
code_tva||';'||
type_etiq||';'||
nb_etiq||';'||
tyuvec||';'||
tyunmesu||';'||
msconte||';'||
pdunit||';'||
arv_dtdeb||';'||
cdfo||';'||
novar||';'||
tyuncde||';'||
tyunfac||';'||
rffou2||';'||
pcb||';'||
qtmincde||';'||
pdul||';'||
volume_ul||';'||
devise_tar||';'||
date_tar||';'||
px_tar||';'||
date_pvm||';'||
px_pvm||';'||
nb_ean_sec||';'||
ean_sec_1||';'||
ean_sec_2||';'||
ean_sec_3||';'||
ean_sec_4||';'||
ean_sec_5||';'||
ean_sec_6||';'||
ean_sec_7||';'||
ean_sec_8||';'||
ean_sec_9||';'||
ean_sec_10||';'||
cd_reseau||';'||
cd_assortiment||';'||
cd_ul||';'||
lb_ul||';'||
arv_ppal||';'||
montant_d3e||';'||
arv_dtfin||';'||
cdnomencdoua||';'||
typart||';'||
are_pdntegout||';'||
cdtax_rpd||';'||
mttax_rpd||';'||
cdtax_ecomob||';'||
mttax_ecomob||';'||
cdtypregr||';'||
noartreg||';'||
qtuvcreg||';'||
carac01||';'||
carac02||';'||
carac03||';'||
carac04||';'||
'ANPF|'||carac05||';'||
carac06||';'||
carac07||';'||
carac08||';'||
carac09||';'||
carac10||';'||
arc_pdunbrut||';'||
htarti||';'||
lnarti||';'||
lrarti||';'
from tmp_rar
order by carac04, code_article;
/
spool off
quit