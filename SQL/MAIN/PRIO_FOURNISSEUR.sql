/* 
CREATION DES PRIORITES FOURNISSEURS
MGSYF
*/		
DECLARE
	CURSOR c_20 IS
		select distinct a.code_fournisseur
		from TMP_PRODUIT_FOURNISSEUR a
		where a.fourn_principal=1
		and not exists (
			select 1 from TMP_PRODUIT_FOURNISSEUR b 
			where a.code_fournisseur=b.code_fournisseur
			and b.fourn_principal=0
		);
		i_prio TMP_PRODUIT_FOURNISSEUR.code_fournisseur%TYPE;

	CURSOR c_40 IS
		select fam_cdr,fam_cdf,art_cds,code_fournisseur,fourn_principal,count(*) from TMP_PRODUIT_FOURNISSEUR x,mgart,mgfam 
		where code_anpf=art_noart
		and art_cdf=fam_cdf
		and code_anpf not in (select a.code_anpf from TMP_PRODUIT_FOURNISSEUR a where a.code_fournisseur=1880)
		and (select count(*) from TMP_PRODUIT_FOURNISSEUR b where b.code_anpf = x.code_anpf)>1
		and code_anpf not in (select b.code_anpf from mgarv a,TMP_PRODUIT_FOURNISSEUR b where b.code_anpf=a.arv_noart and a.arv_flprinci='O' and not exists (select 1 from mgarv b where a.arv_cdfo=b.arv_cdfo and b.arv_flprinci='N'))
		group by fam_cdr,fam_cdf,art_cds,code_fournisseur,fourn_principal
		order by code_fournisseur,fam_cdr,fam_cdf,art_cds;
		i_prio TMP_PRODUIT_FOURNISSEUR.code_fournisseur%TYPE;

	CURSOR c_30 IS
		select arv_cdfo, arv_noart from mgarv
		where arv_cdfo not in (select syf_cdfo from mgsyf);
		i_prio TMP_PRODUIT_FOURNISSEUR.code_fournisseur%TYPE;
BEGIN
	/* Gestion des priorités 10 */
	INSERT INTO MGSYF
	VALUES('    ','    ','2','  ','0','0','L',to_date('19/02/2019','DD/MM/YYYY'),to_date('31/12/2099','DD/MM/YYYY'),'1880','2','10',null,'0','0');
	INSERT INTO MGSYF
	VALUES('    ','    ','2','  ','0','0','L',to_date('19/02/2019','DD/MM/YYYY'),to_date('31/12/2099','DD/MM/YYYY'),'11283','2','10',null,'0','0');
	COMMIT;
	/* ------------------------ */
	
	/* Gestion des priorités 20 */
	OPEN c_20;
	LOOP
		FETCH c_20 INTO i_prio;
			INSERT INTO MGSYF
			VALUES('    ','    ','2','  ','0','0','L',to_date('19/02/2019','DD/MM/YYYY'),to_date('31/12/2099','DD/MM/YYYY'),i_prio.code_fournisseur,'2','20',null,'0','0');
			COMMIT;
		EXIT WHEN c_20%NOTFOUND;
	END LOOP;
	CLOSE c_20;
	/* ------------------------ */

	/* Gestion des priorités 40 */
	OPEN c_40;
	LOOP
		FETCH c_40 INTO i_prio;
			INSERT INTO MGSYF
			VALUES('    ','    ','2','  ',i_prio.fam_cdr,i_prio.fam_cdf,'L',to_date('19/02/2019','DD/MM/YYYY'),to_date('31/12/2099','DD/MM/YYYY'),i_prio.code_fournisseur,'2','40',null,i_prio.art_cds,'0');
			COMMIT;
		EXIT WHEN c_40%NOTFOUND;
	END LOOP;
	CLOSE c_40;
	/* ------------------------ */

	OPEN c_30;
	LOOP
		FETCH c_30 INTO i_prio;
			Insert into MGSYA (SYA_CDRESCEN,SYA_CDBASLOG,SYA_CDMAG,SYA_CDARTI,SYA_TYENREG,SYA_CDFO,SYA_CDGRVA,SYA_DTDEBFAP,SYA_DTFINFAP,SYA_INPRIOR,SYA_CDUEXP) 
			values ('    ','    ','2',i_prio.arv_noart,'L',i_prio.arv_cdfo,'2',to_date('26/02/2019','DD/MM/YYYY'),to_date('31/12/2099','DD/MM/YYYY'),'30',null);
			COMMIT;
		EXIT WHEN c_30%NOTFOUND;
	END LOOP;
	CLOSE c_30;
END;