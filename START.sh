#!/bin/sh
. /home/metiadm/cron_setenv.sh

FILE_LOG=rdd_produit.log
STEP_DEB=$1
STEP_FIN=$2

if [ ! -d "./DATA" ]
then
    echo "Le dossier DATA est absent";
    exit 2
fi

if [ $# -ne 2 ]
then
    echo "Quelles etapes dois-je jouer ? => sh START.sh A Z";
    exit 2
fi

STEP=1
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "=============================================================================="
    echo "| Initialisation tables temporaires : `date` |"
    echo "=============================================================================="
    echo "- Creation des tables temporaires de referentiel : `date`"
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/INIT/init_ref.sql

    echo "- Alimentation des tables temporaires avec les donnees du dump : `date`"
    echo "-- Fournisseurs : `date`"
    sh SH/load_four.sh

    echo "-- Produits : `date`"
    sh SH/load_produit.sh

    echo "-- Libelles produits : `date`"
    sh SH/load_lib_produit.sh

    echo "-- Code a barres : `date`"
    sh SH/load_code_barre.sh

    echo "-- Affectations produits fournisseur : `date`"
    sh SH/load_produit_four.sh

    echo "- Creation des tables temporaires des historiques : `date`"
    sqlplus -S -L MB002/$PWD_USER@$ORACLE_SERVICE @SQL/INIT/init_histo.sql

    echo "- Alimentation des tables temporaires avec les donnees du dump : `date`"
    echo "-- Achats : `date`"
    sh SH/load_achat.sh

    echo "- Ventes : `date`"
    sh SH/load_vente.sh

    echo "- Stocks : `date`"
    sh SH/load_stock.sh

    echo "- En-tetes commandes : `date`"
    sh SH/load_e_cde.sh

    echo "- Details commandes : `date`"
    sh SH/load_d_cde.sh

    echo "============================================================================="
    echo "| Fin Initialisation des tables temporaires : `date` |"
    echo "============================================================================="
fi

STEP=2
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "================================================================================="
    echo "| IDENTIFICATION et INTEGRATION des FOURNISSEURS : `date` |"
    echo "================================================================================="
    echo "- Fournisseurs nationaux : `date`"
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/FOURNISSEUR_NATIONAUX.sql

    echo "- Fournisseurs locaux : `date`"
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/FOURNISSEUR_LOCAUX.sql
fi

STEP=3
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "================================================================================="
    echo "| IDENTIFICATION et TRAVAIL des donnees PRODUIT : `date` |"
    echo "================================================================================="
    echo "- Controle integrite des produits : `date`"
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/PRODUIT_01.sql
    
    echo "- Affectation de la nomenclature METI : `date`"
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/PRODUIT_02.sql

    echo "- Caracteristiques articles et codifications SIGMA -> METI : `date`"
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/PRODUIT_03.sql

    echo "- Identification des articles CONNUS en Centrale MBCEN : `date`"
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/PRODUIT_04.sql

    echo "- Identification des articles INCONNUS en Centrale MBCEN : `date`"
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/PRODUIT_05.sql

    echo "===================================================================================="
    echo "| Fin IDENTIFICATION et TRAVAIL des donnees PRODUIT : `date` |"
    echo "===================================================================================="
fi

STEP=4
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "================================================================================="
    echo "| Alimentation des PRODUITS dans TMP_RAR (8 minutes environ) : `date` |"
    echo "================================================================================="
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/TMP_RAR_1.sql
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/TMP_RAR_2.sql
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/TMP_RAR_3.sql
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/TMP_RAR_4.sql
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/TMP_RAR_5.sql
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/TMP_RAR_final.sql
    echo "===================================================================================="
    echo "| Fin Alimentation des PRODUITS dans TMP_RAR : `date` |"
    echo "===================================================================================="
fi

STEP=5
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "===================================================================================="
    echo "| SPOOL RAR : `date` |"
    echo "===================================================================================="
    sh SH/spool_rar.sh
    echo "===================================================================================="
    echo "| Fin SPOOL RAR : `date` |"
    echo "===================================================================================="
fi

STEP=6
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "===================================================================================="
    echo "| Lance integ. RAR : `date` |"
    echo "===================================================================================="
    sh SH/lance_RAR.sh MBCEN BATCH
    echo "===================================================================================="
    echo "| Fin integ. RAR : `date` |"
    echo "===================================================================================="
fi

STEP=7
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "===================================================================================="
    echo "| Lance integ. RAR : `date` |"
    echo "===================================================================================="
    sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/POST_RAR.sql
    echo "===================================================================================="
    echo "| Fin integ. RAR : `date` |"
    echo "===================================================================================="
fi

STEP=8
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "===================================================================================="
    echo "| Image des stocks à date du dump : `date` |"
    echo "===================================================================================="
    sqlplus -S -L MB002/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/STOCK.sql
    echo "===================================================================================="
    echo "| Fin image des stocks : `date` |"
    echo "===================================================================================="
fi

STEP=9
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "===================================================================================="
    echo "| Reprise des achats : `date` |"
    echo "===================================================================================="
    sqlplus -S -L MB002/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/ACHATS.sql
    echo "===================================================================================="
    echo "| Fin reprise des achats : `date` |"
    echo "===================================================================================="
fi

STEP=10
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "===================================================================================="
    echo "| Reprise des ventes : `date` |"
    echo "===================================================================================="
    sqlplus -S -L MB002/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/VENTES.sql
    echo "===================================================================================="
    echo "| Fin reprise des achats : `date` |"
    echo "===================================================================================="
fi

STEP=11
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "===================================================================================="
    echo "| Reprise des entetes de commandes : `date` |"
    echo "===================================================================================="
    sqlplus -S -L MB002/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/E_COMMANDES.sql
    echo "===================================================================================="
    echo "| Fin reprise des achats : `date` |"
    echo "===================================================================================="
fi

STEP=12
if [ $STEP -ge $STEP_DEB ] && [ $STEP -le $STEP_FIN ]
then
    echo "===================================================================================="
    echo "| Reprise des details de commandes : `date` |"
    echo "===================================================================================="
    sqlplus -S -L MB002/$PWD_USER@$ORACLE_SERVICE @SQL/MAIN/D_COMMANDES.sql
    echo "===================================================================================="
    echo "| Fin reprise des achats : `date` |"
    echo "===================================================================================="
fi
echo "===================================================" >> $FILE_LOG

exit 0