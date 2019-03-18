OPTIONS (BINDSIZE=5120000,ROWS=100000,SKIP=0)
load data
CHARACTERSET UTF8
append into table TMP_PRODUIT_FOURNISSEUR
FIELDS terminated by ";" Optionally enclosed by '"'
trailing nullcols
(noligne   RECNUM,
code_fournisseur  ,
code_anpf  ,
colisage  "replace(TRIM(:colisage),',','.')",
ref_fournisseur  ,
fourn_principal  ,
pab_ht  "replace(TRIM(:pab_ht),',','.')",
groupe_remise  ,
date_de_referencement  ,
date_de_dereferencement  ,
date_debut  ,
date_fin  ,
minimum_commande  ,
operande_de_conversion  ,
code_magasin  ,
unite_achat  ,
pan_ht   "replace(TRIM(:pan_ht),',','.')"
 )
