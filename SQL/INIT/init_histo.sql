set serveroutput on size 1000000
BEGIN
    /* STOCK */
    drop table TMP_IMP_STOCK;
    create table TMP_IMP_STOCK
    (
        noligne   number,
        cdmag	 varchar2(4) ,
        nart      number(8),
        quantite  number(12,2)
    );
    /* ACHAT */
    drop table TMP_HISTO_ACHAT;
    create table TMP_HISTO_ACHAT
    (
        noligne   number,
        cdmag	 varchar2(4),
        date_achat date,
        nart      number,
        qt_achete number(10,3),
        valeur_achat   number
    );
    /* VENTE */
    drop table TMP_HISTO_VENTE;
    create table TMP_HISTO_VENTE
    (
        noligne 	number,
        cdmag 		varchar2(6),
        dtrem		date,
        noart		number(8),
        qtvend		number,
        mtvente		number,
        mtachat		number,
        txtva		number,
        mttva		number,
        mtventht	number,
        meti_famille number,
        commentaire varchar2(200)
    )
    /* EN-TETE COMMANDE */
    drop table TMP_IMP_ENTETE_CDE;
    create table TMP_IMP_ENTETE_CDE (
        noligne   number,
        cdmag	 varchar2(5),
        nocdefou      number,
        dtcomman		date,
        cdfo			number,
        dsutil		varchar2(50),
        dtlivr		date,
        ttcomcde		varchar2(250),
        remise_four_pied		varchar2(20),
        remise_fr_port_pied		varchar2(20),
        statut			number,
        commentaire	varchar2(250)
    );
    /* DETAIL COMMANDE */
    drop table TMP_IMP_LIGNE_CDE;
    create table TMP_IMP_LIGNE_CDE (
        noligne   number,
        cdmag	 varchar2(5),
        nocdefou      number,
        noart	 number,
        qtte		 number,
        qtte_livree number,
        colisage 	number,
        prix_base_ht number,
        remise_four number,
        mt_frport	number,
        txtva_frport number,
        remise_frport number,
        dtlivr		date,
        pa_ht_apres_remises number,
        txtva number,
        mttva number,
        entete_cdfo number,
        commentaire	varchar2(250)
    );
END;
/
quit