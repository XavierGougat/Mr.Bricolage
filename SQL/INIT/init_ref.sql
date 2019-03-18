set serveroutput on size 1000000
/* FOURNISSEUR */
drop table TMP_IMP_FOURNISSEUR;
/
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
    commentaire varchar2(255)
);
/
/* PRODUIT */
drop table TMP_IMP_PRODUIT;
/
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
    COMMENTAIRE VARCHAR2(1000)
);
/
/* CODE A BARRES */
drop table TMP_CODE_BARRE;
/
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
/
/* AFFECTATION PRODUIT FOURNISSEUR */
drop table TMP_PRODUIT_FOURNISSEUR;
/
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
/
/* LIBELLE PRODUIT */
drop table TMP_LIB_PRODUIT;
/
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
/
quit