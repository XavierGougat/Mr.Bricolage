#!/bin/sh
. /home/metiadm/cron_setenv.sh

SCRIPT=SQL/SPOOL_RAR.sql
RAR=/meti/dfex/job/RDD/RAR.csv

sqlplus -S -L MBCEN/$PWD_USER@$ORACLE_SERVICE @$SCRIPT $RAR &> /dev/null
mv RAR.csv /meti/emag/transfer/MB/MBCEN/central/

exit 0