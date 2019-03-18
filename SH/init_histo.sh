#!/bin/sh
. /home/metiadm/cron_setenv.sh

FILE_LOG='../LOG/INIT_HISTO.log'

echo "Creation des tables temporaires des historiques : `date`" > $FILE_LOG
sqlplus -S -L MB002/$PWD_USER@$ORACLE_SERVICE @../SQL/INIT/init_histo.sql >> $FILE_LOG

echo "Alimentation des tables temporaires avec les donnees du dump : `date`" >> $FILE_LOG

echo "Achats : `date`" >> $FILE_LOG
sh load_achat.sh >> $FILE_LOG

echo "Ventes : `date`" >> $FILE_LOG
sh load_vente.sh >> $FILE_LOG

echo "Stocks : `date`" >> $FILE_LOG
sh load_stock.sh >> $FILE_LOG

echo "En-tetes commandes : `date`" >> $FILE_LOG
sh load_e_cde.sh >> $FILE_LOG

echo "Details commandes : `date`" >> $FILE_LOG
sh load_d_cde.sh >> $FILE_LOG

exit 0