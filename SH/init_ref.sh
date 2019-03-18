#!/bin/sh
. /home/metiadm/cron_setenv.sh

FILE_LOG='../LOG/INIT_REF.log'

echo "Creation des tables temporaires de referentiel : `date`" > $FILE_LOG
sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @../SQL/INIT/init_ref.sql >> $FILE_LOG

echo "Alimentation des tables temporaires avec les donnees du dump : `date`" >> $FILE_LOG

echo "Fournisseurs : `date`" >> $FILE_LOG
sh load_four.sh >> $FILE_LOG

echo "Produits : `date`" >> $FILE_LOG
sh load_produit.sh >> $FILE_LOG

echo "Libelles produits : `date`" >> $FILE_LOG
sh load_lib_produit.sh >> $FILE_LOG

echo "Code a barres : `date`" >> $FILE_LOG
sh load_code_barre.sh >> $FILE_LOG

echo "Affectations produits fournisseur : `date`" >> $FILE_LOG
sh load_produit_four.sh >> $FILE_LOG

exit 0