#!/bin/sh
. /home/metiadm/cron_setenv.sh

SCRIPT=SPOOL_RAR.sql
RAR=/meti/dfex/job/RDD/RAR.csv
cd /meti/dfex/job/RDD

sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @$SCRIPT $RAR &> /dev/null
mv RAR.csv /meti/emag/transfer/MB/MB002/central/

exit 0