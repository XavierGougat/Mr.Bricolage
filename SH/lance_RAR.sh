#!/bin/sh
. $HOME/cron_setenv.sh

# RÃ©cupÃ©ration du fichier FIC3

# Lancement de la gÃ©nÃ©ration des alertes

TRAITEMENT="OUTI_FLUX_LCT_STD"
DOSSIER=$1
USER=$2
PARAMETRES="<PAR_CDFLUX>RAR_SPE_MBRICO</PAR_CDFLUX>"

. $METI_HOME/dfex/job/lance_traitement.sh