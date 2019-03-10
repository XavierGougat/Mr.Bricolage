#!/bin/sh
. /home/metiadm/cron_setenv.sh

SCRIPT_RDD_FOUR=FOURNISSEUR.sql

SCRIPT_RDD_01=PRODUIT_01.sql
SCRIPT_RDD_02=PRODUIT_02.sql
SCRIPT_RDD_03=PRODUIT_03.sql
SCRIPT_RDD_04=PRODUIT_04.sql
SCRIPT_RDD_05=PRODUIT_05.sql

FILE_LOG=rdd_produit.log

cd /meti/dfex/job/RDD/

echo "Debut RDD Fournisseur : `date`"
echo "Debut RDD Fournisseur : `date`" > $FILE_LOG
sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @$SCRIPT_RDD_FOUR >> $FILE_LOG

echo "Debut RDD Produit : `date`"
echo "Debut RDD Produit : `date`" > $FILE_LOG
echo "1- Controle et MaJ integrite des donnees"
echo "1- Controle et MaJ integrite des donnees" >> $FILE_LOG
sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @$SCRIPT_RDD_01 >> $FILE_LOG

echo "2- Affectation de la nomenclature METI"
echo "2- Affectation de la nomenclature METI" >> $FILE_LOG
sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @$SCRIPT_RDD_02 >> $FILE_LOG

echo "3- Mise à jour vers codification METI"
echo "3- Mise à jour vers codification METI" >> $FILE_LOG
sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @$SCRIPT_RDD_03 >> $FILE_LOG

echo "4- Identification des produits connus en Centrale"
echo "4- Identification des produits connus en Centrale" >> $FILE_LOG
sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @$SCRIPT_RDD_04 >> $FILE_LOG

echo "5- Identification des produits inconnus en Centrale"
echo "5- Identification des produits inconnus en Centrale" >> $FILE_LOG
sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @$SCRIPT_RDD_05 >> $FILE_LOG

echo "Fin RDD Produit : `date`" >> $FILE_LOG

exit 0