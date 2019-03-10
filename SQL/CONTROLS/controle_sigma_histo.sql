SET SERVEROUTPUT ON;
declare
    v_nb_cde VARCHAR2(10);

BEGIN
/* controles produits*/
select count(distinct code_nomenclature) into v_nb_cde from TMP_IMP_PRODUIT;

/* TABLEAU PRODUITS */
dbms_output.put_line('<h3 style="color:DarkRed;">Les Produits</h3>
<table class="table">
    <thead class="thead-dark">
        <tr>
            <th colspan="2" scope="col">Données brutes SIGMA</th>
        </tr>
    </thead>
    <tbody>
    <tr>');
dbms_output.put_line('<td><strong>Nomenclature RFSF</strong></td><td style="text-align:right;">'||v_nb_rfsf||'</td>');
dbms_output.put_line('</tr><br><tr>');
dbms_output.put_line('<td><strong>Codes à barres</strong></td><td style="text-align:right;">'||v_nb_ean||'</td>');
dbms_output.put_line('</tr><br><tr>');
dbms_output.put_line('<td><strong>Produits nationaux</strong></td><td style="text-align:right;">'||v_nb_produits_nationaux||'</td>');
dbms_output.put_line('</tr><tr>');
dbms_output.put_line('<td><strong>Produits locaux</strong></td><td style="text-align:right;">'||v_nb_produits_locaux||'</td>');
dbms_output.put_line('</tr><tr class="table-success">');
dbms_output.put_line('<td><strong>Total Produits</strong></td><td style="text-align:right;"><strong>'||v_nb_produits||'</strong></td>');
dbms_output.put_line('</tr><br>');
dbms_output.put_line('<tr class="table-secondary"><td colspan="2"><strong>Typologie articles</strong></td></tr>');
FOR res IN (select type_pdt, CASE WHEN type_pdt='N' THEN 'Normal' WHEN type_pdt='S' THEN 'Service' ELSE 'Normal' END as lib_type, count(distinct code_anpf) as nb from TMP_IMP_PRODUIT group by type_pdt order by type_pdt) 
LOOP  
    dbms_output.put_line('<tr><td><strong>'||res.type_pdt||' ('||res.lib_type||')</strong></td><td style="text-align:right;">'||res.nb||'</td></tr>');
END LOOP;
dbms_output.put_line('<tr class="table-secondary"><td colspan="2"><strong>Unité mesure articles</strong></td></tr><tr>');
FOR res IN (select unite_mesure, CASE WHEN unite_mesure='05 ' THEN 'M²' ELSE unite_mesure END as lib_unite, count(distinct code_anpf) as nb from TMP_IMP_PRODUIT group by unite_mesure order by unite_mesure) 
LOOP  
    dbms_output.put_line('<tr><td><strong>'||res.unite_mesure||' ('||res.lib_unite||')</strong></td><td style="text-align:right;">'||res.nb||'</td></tr>');
END LOOP;
dbms_output.put_line('<tr class="table-secondary"><td><strong>Unités dérivées</strong></td><td style="text-align:right;">'||v_nb_unites_derivees||'</td></tr>');
dbms_output.put_line('</table>');

/* TABLEAU FOURNISSEURS */
dbms_output.put_line('<hr><h3 style="color:DarkRed;">Les Fournisseurs</h3>');
dbms_output.put_line('
<table class="table">
    <thead class="thead-dark">
        <tr>
            <th colspan="2" scope="col">Données brutes SIGMA</th>
        </tr>
    </thead>
    <tbody>
        <tr>');
dbms_output.put_line('<td><strong>Fournisseurs nationaux</strong></td><td style="text-align:right;">'||v_nb_fournisseurs_nationaux||'</td>');
dbms_output.put_line('</tr><tr>');
dbms_output.put_line('<td><strong>Fournisseurs locaux</strong></td><td style="text-align:right;">'||v_nb_fournisseurs_locaux||'</td>');
dbms_output.put_line('</tr><tr  class="table-success">');
dbms_output.put_line('<td><strong>Total Fournisseurs</strong></td><td style="text-align:right;"><strong>'||v_nb_fournisseurs||'</strong></td>');
dbms_output.put_line('</tr></tbody></table>');

dbms_output.put_line('<hr>');

/* TABLEAU COMPARATIF AVEC REFERENTIEL CENTRALISE */
dbms_output.put_line('<h3 style="color:DarkRed;">Analyse du référentiel produit</h3>');

dbms_output.put_line('<table class="table">
<thead class="thead-dark">
        <tr>
            <th colspan="3" scope="col">Données identifiées et enrichies</th>
        </tr>
    </thead>
    <tbody>
    <tr class="table-secondary">');
dbms_output.put_line('<td colspan="2"><strong>CAS #1 : Articles nationaux et locaux connus en Centrale (critère "ANPF+EAN")</strong></td><td style="text-align:right;"><strong>'||v_nb_communs_anpf_ean||'</strong></td>');
dbms_output.put_line('</tr><tr>');
dbms_output.put_line('<td></td><td style="text-align:right;">nationaux </td><td style="text-align:right;">'||v_nb_communs_anpf_ean_nat||'</td>');
dbms_output.put_line('</tr><tr>');
dbms_output.put_line('<td></td><td style="text-align:right;">locaux </td><td style="text-align:right;">'||v_nb_communs_anpf_ean_loc||'</td>');
dbms_output.put_line('</tr><tr class="table-secondary">');
dbms_output.put_line('<td colspan="2"><strong>CAS #2 : Articles nationaux connus en Centrale (critère "ANPF uniquement")</strong></td><td style="text-align:right;"><strong>'||v_nb_communs_anpf||'</strong></td>');
dbms_output.put_line('</tr><tr class="table-secondary">');
dbms_output.put_line('<td colspan="2"><strong>CAS #3 : Articles nationaux et locaux connus en Centrale (crtière "EAN uniquement") (nouvel ANPF)</strong></td><td style="text-align:right;"><strong>'||v_nb_communs_ean||'</strong></td>');
dbms_output.put_line('</tr><tr>');
dbms_output.put_line('<td></td><td style="text-align:right;">nationaux </td><td style="text-align:right;">'||v_nb_communs_ean_nat||'</td>');
dbms_output.put_line('</tr><tr>');
dbms_output.put_line('<td></td><td style="text-align:right;">locaux </td><td style="text-align:right;">'||v_nb_communs_ean_loc||'</td>');
dbms_output.put_line('</tr><tr class="table-secondary">');
dbms_output.put_line('<td colspan="2"><strong>CAS #4 : Articles nationaux inconnus</strong></td><td style="text-align:right;"><strong>'||v_nb_inconnus||'</strong></td>');
dbms_output.put_line('</tr><tr class="table-secondary">');
dbms_output.put_line('<td colspan="2"><strong>CAS #5 : Articles locaux inconnus</strong></td><td style="text-align:right;"><strong>'||v_nb_inconnus_locaux||'</strong></td>');
dbms_output.put_line('</tr><tr class="table-warning">');
dbms_output.put_line('<td colspan="2"><strong>Total articles analysés</strong></td><td style="text-align:right;"><strong style="text-decoration:underline;">'||(v_nb_communs_anpf_ean+v_nb_communs_anpf+v_nb_communs_ean+v_nb_inconnus+v_nb_inconnus_locaux)||'</strong></td>');
dbms_output.put_line('</tr><tr class="table-success">');
dbms_output.put_line('<td colspan="2"><strong>Ecart entre SIGMA et Analyse METI</strong></td><td style="text-align:right;"><strong style="text-decoration:underline;">'||(v_nb_produits-(v_nb_communs_anpf_ean+v_nb_communs_anpf+v_nb_communs_ean+v_nb_inconnus+v_nb_inconnus_locaux))||'</strong></td>');
dbms_output.put_line('</tr></table>');
dbms_output.put_line('<hr>');

dbms_output.put_line('<h3 style="color:DarkRed;">Intégration flux RAR</h3>');

dbms_output.put_line('<p><strong>'||v_nb_attention||' articles ne peuvent être intégrés</strong></p><p><a href="#" onclick="return show();">Afficher</a></p>');
dbms_output.put_line('<div id="attention" style="display:none;">');
dbms_output.put_line('<p><a href="#" onclick="return hide();">Cacher</a></p>');
dbms_output.put_line('<table><tr><th>N° ligne</th><th>ANPF</th><th>Commentaire</th></tr>');
DECLARE
v_noligne       tmp_imp_produit.noligne%TYPE;   
v_code_anpf     tmp_imp_produit.noligne%TYPE;
v_commentaire   tmp_imp_produit.commentaire%TYPE;
CURSOR c_attention IS
SELECT noligne, code_anpf, commentaire FROM tmp_imp_produit WHERE commentaire IS NOT NULL ORDER BY noligne;
BEGIN
    OPEN c_attention;
    LOOP
    FETCH c_attention INTO v_noligne, v_code_anpf, v_commentaire;
        dbms_output.put_line('<tr><td>'||v_noligne||'</td><td>'||v_code_anpf||'</td><td>'||v_commentaire||'</td></tr>');
    EXIT WHEN c_attention%NOTFOUND;
    END LOOP;
    CLOSE c_attention;
END;
dbms_output.put_line('</table></div>');


END;
/
quit