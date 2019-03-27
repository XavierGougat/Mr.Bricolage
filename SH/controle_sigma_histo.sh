#!/bin/sh
# Extraction des nouveaux menus
. /home/metiadm/cron_setenv.sh

mkdir -p -m777 /tmp/reports
DATE_JOUR=`date`
SCRIPT=SQL/CONTROLS/controle_sigma_histo.sql
MAIL_BODY=/tmp/reports/RDD_Controle_SIGMA_Histo.html
DESTINATAIRE=xgougat@meti.fr

cd /meti/dfex/job/RDD

echo "<html>" > $MAIL_BODY
echo "<head>" >> $MAIL_BODY
echo '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">' >> $MAIL_BODY
echo '<meta name="generator" content="SQL*Plus 11.2.0">' >> $MAIL_BODY
echo '<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.0/css/bootstrap.min.css" integrity="sha384-PDle/QlgIONtM1aqA2Qemk5gPOE7wFq8+Em+G/hmo5Iq0CCmYZLv3fVRDJ4MMwEA" crossorigin="anonymous">' >> $MAIL_BODY
echo '<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.0/js/bootstrap.min.js" integrity="sha384-7aThvCh9TypR7fIc2HV4O/nFMVCBwyIUKL8XCtKE+8xgCgl/PQGuFsvShjr74PBp" crossorigin="anonymous"></script>' >> $MAIL_BODY
echo '</head>' >> $MAIL_BODY
echo '<body>
<div class="container">' >> $MAIL_BODY
echo '<script> 
    function show() { 
        if(document.getElementById("attention").style.display=="none") { 
            document.getElementById("attention").style.display="block"; 
        } 
        return false;
    } 
    function hide() { 
        if(document.getElementById("attention").style.display=="block") { 
            document.getElementById("attention").style.display="none"; 
        } 
        return false;
    }   
</script>' >> $MAIL_BODY
echo "
    <div class='row'>
        <div class='col-sm-10 offset-sm-1'>
        <p><img src='https://pbs.twimg.com/profile_images/738361266583003136/bFwEB0X3_400x400.jpg' height='50' style='float:left;padding-right:10px;'/></p>
        <h2>Contrôle de la reprise de données, le $DATE_JOUR</h2>
            <div class='alert alert-info'>
                <strong>Info!</strong> Indicateurs des volumes après intégration brute des données en provenance de SIGMA.
            </div>" >> $MAIL_BODY
sqlplus -S -L MB002/$PWD_USER@$ORACLE_SERVICE @$SCRIPT >> $MAIL_BODY
echo '</div>
</div>
</div>
</body>' >> $MAIL_BODY
echo '</html>' >> $MAIL_BODY

echo "RDD : Etat des compteurs SIGMA" | mailx -s "[MBrico] RDD - Compteurs SIGMA" -S smtp="smtp01.meti.epm" -r RDD_MrBricolage@meti.fr -a $MAIL_BODY $DESTINATAIRE

rm $MAIL_BODY

exit 0