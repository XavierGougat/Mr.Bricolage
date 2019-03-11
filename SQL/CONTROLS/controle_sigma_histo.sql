SET SERVEROUTPUT ON;
declare
    v_nb_cde VARCHAR2(10);
    v_nb_fourn_cde VARCHAR2(10);
    v_nb_ligne_cde VARCHAR2(5);
    v_nb_mt_total VARCHAR2(11);
BEGIN
/* controles en-tête commandes*/
select count(distinct nocdefou) into v_nb_cde from tmp_imp_entete_cde;
select count(distinct cdfo) into v_nb_fourn_cde from TMP_IMP_ENTETE_CDE;
/* controles détails commandes*/
select count(*) into v_nb_ligne_cde from TMP_IMP_LIGNE_CDE d 
inner join TMP_IMP_ENTETE_CDE e on d.nocdefou = e.nocdefou;
select to_char(sum(pa_ht_apres_remises+mttva),'999G999D99') into v_nb_mt_total from TMP_IMP_LIGNE_CDE d
inner join TMP_IMP_ENTETE_CDE e on d.nocdefou = e.nocdefou;


/* TABLEAU COMMANDES */
dbms_output.put_line('<h3 style="color:DarkRed;">Les En-têtes Commandes</h3>
<table class="table">
    <thead class="thead-dark">
        <tr>
            <th colspan="2" scope="col">Données brutes SIGMA</th>
        </tr>
    </thead>
    <tbody>
    <tr>');
dbms_output.put_line('<td><strong>Nombre de commandes</strong></td><td style="text-align:right;">'||v_nb_cde||'</td>');
dbms_output.put_line('</tr>');
dbms_output.put_line('<tr class="table-secondary"><td colspan="2"><strong>Statut commande</strong></td></tr>');
FOR res IN (select statut, CASE WHEN statut='2' THEN 'Situation n°40' WHEN statut='4' THEN 'Situation n°70' ELSE 'METI - ??' END as lib_statut, count(*) as nb from tmp_imp_entete_cde group by statut order by statut) 
LOOP  
    dbms_output.put_line('<tr><td><strong>'||res.statut||' ('||res.lib_statut||')</strong></td><td style="text-align:right;">'||res.nb||'</td></tr>');
END LOOP;
dbms_output.put_line('<tr>');
dbms_output.put_line('<td><strong>Nombre de fournisseurs ayant livré de la mrch</strong></td><td style="text-align:right;">'||v_nb_fourn_cde||'</td>');
dbms_output.put_line('</tr>');
dbms_output.put_line('</tbody>');
dbms_output.put_line('</table>');
dbms_output.put_line('<hr><h3 style="color:DarkRed;">Les Lignes Commandes</h3>');
dbms_output.put_line('
<table class="table">
    <thead class="thead-dark">
        <tr>
            <th colspan="2" scope="col">Données brutes SIGMA</th>
        </tr>
    </thead>
    <tbody>
        <tr>');
dbms_output.put_line('<td><strong>Nombre de lignes de détails commandes</strong></td><td style="text-align:right;">'||v_nb_ligne_cde||'</td>');
dbms_output.put_line('</tr><tr>');
dbms_output.put_line('<td><strong>Montant total commandé</strong></td><td style="text-align:right;">'||v_nb_mt_total||' €</td>');
dbms_output.put_line('</tr>');
dbms_output.put_line('</tbody>');
dbms_output.put_line('</table>');
dbms_output.put_line('<hr><h3 style="color:DarkRed;">Les Achats</h3>');
dbms_output.put_line('
<table class="table">
    <thead class="thead-dark">
        <tr>
            <th colspan="2" scope="col">Données brutes SIGMA</th>
        </tr>
    </thead>
    <tbody>
    <tr class="table-secondary">
            <td scope="col">YYYY/MM</td>
            <td scope="col" style="text-align:right;">Montant achat</td>
        </tr>');
    DECLARE
    v_date_mois     varchar2(2);
    v_date_annee    varchar2(2); 
    v_montant_mois  varchar2(20);
    CURSOR c_ca IS
    select substr(date_achat,9,2), substr(date_achat,4,2), to_char(sum(valeur_achat*qt_achete),'999G999G999D99') from TMP_HISTO_ACHAT
    group by substr(date_achat,9,2), substr(date_achat,4,2)
    order by substr(date_achat,9,2), substr(date_achat,4,2);
    BEGIN
        OPEN c_ca;
        LOOP
        FETCH c_ca INTO v_date_annee, v_date_mois, v_montant_mois;
        EXIT WHEN c_ca%NOTFOUND;
            dbms_output.put_line('<tr><td>20'||v_date_annee||'/'||v_date_mois||'</td><td style="text-align:right;">'||v_montant_mois||' €</td></tr>');
        END LOOP;
        CLOSE c_ca;
    END;
dbms_output.put_line('</tbody>');
dbms_output.put_line('</table>');
dbms_output.put_line('<hr><h3 style="color:DarkRed;">Les Ventes</h3>');
dbms_output.put_line('
<table class="table">
    <thead class="thead-dark">
        <tr>
            <th colspan="2" scope="col">Données brutes SIGMA</th>
            <th colspan="1" scope="col" style="text-align:right;">Données METI</th>
        </tr>
    </thead>
    <tbody>
    <tr class="table-secondary">
            <td scope="col">YYYY/MM</td>
            <td scope="col" style="text-align:right;">Montant Vente (CA HT + Mt TVA)</td>
            <td scope="col" style="text-align:right;">Montant Vente</td>
        </tr>');
    DECLARE
    v_date_mois     varchar2(2);
    v_date_annee    varchar2(2); 
    v_montant_mois  varchar2(20);
    v_montant_mois_meti varchar2(20);
    CURSOR c_ca IS
    select substr(dtrem,9,2), substr(dtrem,4,2), to_char(sum(mtvente),'999G999D99') from TMP_HISTO_VENTE
    group by substr(dtrem,9,2), substr(dtrem,4,2)
    order by substr(dtrem,9,2), substr(dtrem,4,2);
    BEGIN
        OPEN c_ca;
        LOOP
        FETCH c_ca INTO v_date_annee, v_date_mois, v_montant_mois;
        EXIT WHEN c_ca%NOTFOUND;
            select  to_char(sum(vam_mtvente),'999G999G999D99') into v_montant_mois_meti from MGVAMS where vam_aavt=to_number(concat('20',v_date_annee)) and vam_mmvt=to_number(v_date_mois);
            dbms_output.put_line('<tr><td>20'||v_date_annee||'/'||v_date_mois||'</td><td style="text-align:right;">'||v_montant_mois||' €</td><td style="text-align:right;">'||v_montant_mois_meti||' €</td></tr>');
        END LOOP;
        CLOSE c_ca;
    END;
dbms_output.put_line('</tbody>');
dbms_output.put_line('</table>');
dbms_output.put_line('<hr><h3 style="color:DarkRed;">Les Stocks</h3>');
dbms_output.put_line('
<table class="table">
    <thead class="thead-dark">
        <tr>
            <th colspan="2" scope="col">Données brutes SIGMA</th>
            <th colspan="1" scope="col">Données METI</th>
        </tr>
    </thead>
    <tbody>
    <tr class="table-secondary">
            <td scope="col">Article (au hasard)</td>
            <td scope="col" style="text-align:right;">Stock à date de bascule</td>
            <td scope="col" style="text-align:right;">Stock</td>
        </tr>');
    DECLARE
    v_nart     varchar2(8);
    v_quantite varchar2(5); 
    v_stock_meti NUMBER(10,3);
    CURSOR c_stock IS
    SELECT nart, quantite
    FROM   (
        SELECT nart, quantite
        FROM  TMP_IMP_STOCK
        ORDER BY DBMS_RANDOM.VALUE)
    WHERE  rownum <= 10 and quantite >0 and nart is not null
    order by nart;
    BEGIN
        OPEN c_stock;
        LOOP
        FETCH c_stock INTO v_nart, v_quantite;
        EXIT WHEN c_stock%NOTFOUND;
            SELECT ast_qtstock into v_stock_meti from mgast where ast_noart = v_nart;
            dbms_output.put_line('<tr><td>'||v_nart||'</td><td style="text-align:right;">'||v_quantite||'</td><td style="text-align:right;">'||v_stock_meti||'</td></tr>');
        END LOOP;
        CLOSE c_stock;
    END;
dbms_output.put_line('</tbody>');
dbms_output.put_line('</table>');
END;
/
quit