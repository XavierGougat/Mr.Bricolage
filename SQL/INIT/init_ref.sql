set serveroutput off
set feedback off;
/* FOURNISSEUR */
drop table TMP_IMP_FOURNISSEUR;
commit;

create table TMP_IMP_FOURNISSEUR
(
    noligne   	number,
    code varchar2(10),
    nom varchar2(35),
    adr1 varchar2(60),
    adr2 varchar2(40),
    adr3 varchar2(35),
    cp varchar2(10),
    ville varchar2(40),
    pays varchar2(2),
    tel number(31),
    fax number(31),
    mail varchar2(50),
    url varchar2(255),
    statut varchar2(1),
    date_statut date,
    devise varchar2(3),
    franco number(12,3),
    unite_franco varchar2(3),
    trigramme varchar2(3),
    mode_commande_edi number(1),
    gencod_edi number(13),
    mode_commande_fax number(1),
    mode_commande_sap number(1),
    mode_commande_tls number(1),
    mode_commande_tel number(1),
    mode_commande_mail number(1),
    tva_intracom varchar2(20),
    condition_paiement number(4),
    delai_livraison number(3),
    siret varchar2(16),
    code_comptable varchar2(10),
    code_magasin varchar2(4),
    taux_escompte varchar2(14),
    compte_client varchar2(20),
    commentaire varchar2(255),
    connu_mbcen varchar2(1)
);
/* PRODUIT */
drop table TMP_IMP_PRODUIT;
commit;

CREATE TABLE TMP_IMP_PRODUIT 
(	
    NOLIGNE NUMBER , 
    code_anpf varchar2(18),
    type_pdt varchar2(1),
    code_tva varchar2(1),
    code_marque varchar2(6),
    code_nomenclature varchar2(5),
    unite_mesure varchar2(3),
    valeur_conversion number(15,2),
    unite_sortie varchar2(3),
    code_douane varchar2(17),
    montant_deee number(12,2),
    montant_rpd number(12,2),
    code_amm varchar2(15),
    alerte_produit varchar2(255),
    PVC_agressif number(12,2),
    PVC_positionne number(12,2),
    PVC_confort number(12,2),
    poids_net number(13,3),
    unite_poids varchar2(3),
    volume varchar2(40),
    unite_volume varchar2(3),
    longeur number(13,3),
    largeur number(13,3),
    hauteur number(13,3),
    unite_dimension varchar2(3),
    dangereux number(1),
    premier_prix number(1),
    sensible number(1),
    consigne number(1),
    reparable number(1),
    saisonnier number(1),
    saison_debut varchar2(10),
    saison_fin varchar2(10),
    url_argumentaire_vente varchar2(255),
    url_fiche_technique varchar2(255),
    compte_achat_produit varchar2(8),
    compte_vente_produit varchar2(8),
    article_remplacement varchar2(18),
    date_remplacement DATE,
    code_magasin varchar2(4),
    delai_peremption_valeur number(3),
    delai_peremption_unite varchar2(1),
    sous_type_pdt varchar2(1),
    pamp number(13,3),
    pdt_promo varchar2(1),
    garantie_libelle varchar2(50),
    montant_ecomobilier number(12,2),
    code_exploit_dex varchar2(100),
    etat_produit varchar2(1),
    nom_fournisseur_origine varchar2(250),
    nom_commercial varchar2(250),
    famille_logistique varchar2(250),
    cycle_vie varchar2(1),
    meti_rayon	number(5),
    meti_famille	number(5),
    meti_ssfamille	number(5),
    meti_ubs	number(5),
    meti_cdtva varchar2(1),
    meti_tyunmesu  varchar2(1),
    meti_tyuvec  varchar2(1),
    meti_msconte number(9,4),
    meti_pdunit  number(9,6),
    meti_pdntegout  number(7,4),
    meti_pdbrut  number(6,3),
    meti_cpx_aggr   varchar2(2),
    meti_cpx_posit  varchar2(2),
    meti_cpx_confort  varchar2(2),
    meti_typart varchar2(2),
    COMMENTAIRE VARCHAR2(1000),
    connu_mbcen VARCHAR2(1),
    ajout_ean_centrale VARCHAR2(1),
    new_anpf VARCHAR2(18),
    anpf_deja_utilise varchar2(1)
);
/* CODE A BARRES */
drop table TMP_CODE_BARRE;
commit;

create table TMP_CODE_BARRE
(
    noligne   	number,
    code_anpf varchar2(18),
    code_fournisseur varchar2(10),
    code_barre varchar2(30),
    code_magasin varchar2(4),
    principal number(1),
    code_exploit_dex varchar2(100),
    commentaire varchar2(255)
);
/* AFFECTATION PRODUIT FOURNISSEUR */
drop table TMP_PRODUIT_FOURNISSEUR;
commit;

create table TMP_PRODUIT_FOURNISSEUR
(
    noligne   	number,
    code_fournisseur varchar2(10),
    code_anpf varchar2(18),
    colisage number(9,4),
    ref_fournisseur varchar2(35),
    fourn_principal varchar2(1),
    pab_ht number(9,3),
    groupe_remise varchar2(4),
    date_de_referencement DATE,
    date_de_dereferencement DATE,
    date_debut DATE,
    date_fin DATE,
    minimum_commande varchar2(5),
    operande_de_conversion varchar2(17),
    code_magasin varchar2(4),
    unite_achat varchar2(10),
    pan_ht number(9,3),
    commentaire varchar2(255)
);
/* LIBELLE PRODUIT */
drop table TMP_LIB_PRODUIT;
commit;

create table TMP_LIB_PRODUIT
(
    noligne   	number,
    code_anpf varchar2(18),
    langue varchar2(2),
    lib_long varchar2(80),
    lib_court varchar2(50),
    lib_descr varchar2(50),
    lib_techn varchar2(50),
    code_magasin varchar2(4),
    code_exploit_dex varchar2(100),
    commentaire varchar2(255)
);

drop table LUCON_FOUR_N3;
commit;

create table LUCON_FOUR_N3(
    code VARCHAR2(10),
    nouveau_code VARCHAR2(10)
);

drop table LUCON_CAS_N1;
commit;
create table LUCON_CAS_N1(
    code_mbcen VARCHAR2(18)
);

drop table LUCON_CAS_N3;
commit;
create table LUCON_CAS_N3(
    code_mbcen VARCHAR2(18),
    code_lucon VARCHAR2(18)
);

drop table TMP_RAR;
commit;

create table TMP_RAR (
    noligne   			number,
    code_article 		number(8),
    ean_ppal 			number(14),
    lbarti 				varchar2(30),
    lbcompl				varchar2(30),
    lbmarque			varchar2(10),
    lbcaisse			varchar2(30),
    rayon 				number(5),
    famille				number(5),
    sousfam				number(5),
    unite_besoin		number(5),
    code_tva			number(2),
    type_etiq			varchar2(1),
    nb_etiq				number(4),
    tyuvec				varchar2(1),
    tyunmesu 			varchar2(1),
    msconte				number(9,4),
    pdunit 				number(6,3),
    arv_dtdeb			varchar2(8),
    cdfo				number(8),
    novar				number(3),
    tyuncde				varchar2(1),
    tyunfac				varchar2(1),
    rffou2				varchar2(20),
    pcb					number(4),
    qtmincde			number(4),
    pdul				number(8,3),
    volume_ul			number(7,6),
    devise_tar			varchar2(3),
    date_tar			varchar2(8),
    px_tar				number(17,4),
    date_pvm			number(8),
    px_pvm  			number(17,4),
    nb_ean_sec			number(2),
    ean_sec_1 			number(14),
    ean_sec_2 			number(14),
    ean_sec_3 			number(14),
    ean_sec_4 			number(14),
    ean_sec_5 			number(14),
    ean_sec_6 			number(14),
    ean_sec_7 			number(14),
    ean_sec_8 			number(14),
    ean_sec_9 			number(14),
    ean_sec_10			number(14),
    cd_reseau			varchar2(3),
    cd_assortiment		varchar2(2),
    cd_ul				number(3),
    lb_ul				varchar2(30),
    arv_ppal			varchar2(1),
    montant_d3e			number(6,4),
    arv_dtfin			varchar2(8),
    cdnomencdoua		varchar2(8),
    typart				varchar2(2),
    are_pdntegout 		number(7,4),
    cdtax_rpd			varchar2(4),
    mttax_rpd			number(17,6),
    cdtax_ecomob		varchar2(4),
    mttax_ecomob        number(17,6),
    cdtypregr			varchar2(3),
    noartreg            number(8),
    qtuvcreg			number(5),
    carac01				varchar2(100),
    carac02				varchar2(100),
    carac03				varchar2(100),
    carac04				varchar2(100),
    carac05				varchar2(100),
    carac06				varchar2(100),
    carac07				varchar2(100),
    carac08				varchar2(100),
    carac09				varchar2(100),
    carac10				varchar2(100),
    arc_pdunbrut		number(7,3),
    htarti				number(4,3),
    lnarti				number(4,3),
    lrarti				number(4,3),
    commentaire varchar2(255)
);
commit;

CREATE INDEX index_code_article ON tmp_rar (code_article);
CREATE INDEX index_ean_ppal ON tmp_rar (ean_ppal);
CREATE INDEX index_code_anpf_code_barre ON tmp_code_barre (code_anpf,code_barre);
CREATE INDEX index_code_anpf ON tmp_code_barre (code_anpf);
CREATE INDEX index_code_anpf_pdt ON tmp_imp_produit (code_anpf);
CREATE INDEX index_code_anpf_lib ON tmp_lib_produit (code_anpf); 

DROP SEQUENCE noligne_sequence;
/* Création de la séquence pour numéro de ligne dans le flux RAR */
create sequence noligne_sequence start with 1
increment by 1
minvalue 1
maxvalue 10000000;

Insert into MGCAR (CAR_CDCARACT,CAR_LBCARACT,CAR_CDUNITE,CAR_LBREDCAR,CAR_FLACTIF,CAR_TYVAL,CAR_LONGVAL,CAR_NBDEC,CAR_VALMIN,CAR_VALMAX,CAR_VALDEFAU,CAR_CDGRPCAR,CAR_NOORDGRP) values ('ANPF','Reprise de données            ',null,'ANPF','0','1','7','2',null,null,null,'PV','2');
Insert into MGCAR (CAR_CDCARACT,CAR_LBCARACT,CAR_CDUNITE,CAR_LBREDCAR,CAR_FLACTIF,CAR_TYVAL,CAR_LONGVAL,CAR_NBDEC,CAR_VALMIN,CAR_VALMAX,CAR_VALDEFAU,CAR_CDGRPCAR,CAR_NOORDGRP) values ('RDD_CAS','Reprise de données            ',null,'RDD_CAS','0','1','1','2',null,null,null,'PV','1');
commit;
/
quit