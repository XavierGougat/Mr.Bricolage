#!/bin/sh
. /home/metiadm/cron_setenv.sh

FILE_LOG=rdd_produit.log

if [ ! -d "./DATA" ];then
    echo "Le dossier DATA est absent";
    exit 2
fi


cd SQL/INIT/
echo "========================================================================"
echo "| Initialisation tables temporaires : `date` |"
echo "========================================================================"
echo "- Creation des tables temporaires de referentiel : `date`"
sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @init_ref.sql

cd ../../SH
echo "- Alimentation des tables temporaires avec les donnees du dump : `date`"
echo "-- Fournisseurs : `date`"
sh load_four.sh

echo "-- Produits : `date`"
sh load_produit.sh

echo "-- Libelles produits : `date`"
sh load_lib_produit.sh

echo "-- Code a barres : `date`"
sh load_code_barre.sh

echo "-- Affectations produits fournisseur : `date`"
sh load_produit_four.sh

cd ../SQL/INIT/
echo "- Creation des tables temporaires des historiques : `date`"
sqlplus -S -L MB002/$PWD_USER@$ORACLE_SERVICE @init_histo.sql

cd ../../SH
echo "- Alimentation des tables temporaires avec les donnees du dump : `date`"
echo "-- Achats : `date`"
sh load_achat.sh

echo "- Ventes : `date`"
sh load_vente.sh

echo "- Stocks : `date`"
sh load_stock.sh

echo "- En-tetes commandes : `date`"
sh load_e_cde.sh

echo "- Details commandes : `date`"
sh load_d_cde.sh

echo "==================================================="
echo "Fin Initialisation des tables temporaires : `date` "
echo "===================================================" >> $FILE_LOG

exit 0