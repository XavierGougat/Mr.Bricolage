declare
	v NUMBER(5);
	tot NUMBER(5);
	v_d number(5) :=0 ; 
	
	v_grv number(2):=null;
	v_arv number(2):=null;

	v_er_MGFOU_FOU_CDFO  VARCHAR2(200);
	v_er_MGFOU_INIT_CDFO VARCHAR2(200);
	v_er_gene  VARCHAR2(200);
	v_ERREUR  VARCHAR2(200);
begin
	/* Nous complètons les informations du fournisseur template avec les nouveaux GRV 2 et 3*/
	delete from tmp_imp_fournisseur where code is null;
	delete from tmp_imp_fournisseur where code like '%,%';
	commit;
	Insert into MGGRV (GRV_CDFO,GRV_CDGRVA,GRV_CDUNIBAR,GRV_LBGRVA,GRV_TYPORT,GRV_UNPORT,GRV_NBMINFRA,GRV_TYBASTRS,GRV_CDBARMTR,GRV_CDBARMQT,GRV_TYGESRQT,GRV_NBSEMAPR,GRV_DTPREMCD,GRV_NBSEMDEC,GRV_JJCDELUN,GRV_JJCDEMAR,GRV_JJCDEMER,GRV_JJCDEJEU,GRV_JJCDEVEN,GRV_JJCDESAM,GRV_JJCDEDIM,GRV_NBJRCOUV,GRV_DLMOYEN,GRV_DLRISQUE,GRV_NBJRCSMN,GRV_NOALGORI,GRV_DTARRCDE,GRV_DTFIN,GRV_CDACHET,GRV_CDUEXP,GRV_TYEDBC,GRV_TYTRICD,GVR_TYCALTRF,GRV_CDTABLFR,GRV_TYSEMCDE,GRV_CDMODCAD,GRV_HHLIMCDE,GRV_CDACTIV,GRV_FLCDAUTO,GRV_NBJRDCPP,GRV_FLZONELV,GRV_DTPRCHCD,GRV_DTPRCHLV,GRV_HHDEBCDE,GRV_CDADDSIA,GRV_CDSCTEUR,GRV_CDZNELV,GRV_FLRESQUAI,GRV_PTARRPAL,GRV_FLSAIPAC,GRV_PTARPAMS,GRV_FLTARPAL,GRV_HHLIMLIV,GRV_CDQUAILV,GRV_TYCALRMQ,GRV_CDCDECLI,GRV_TYGESAPP,GRV_FLDBRECP,GRV_FLCRETAR,GRV_CDARDQT,GRV_FLMODPCB,GRV_CDFORESD,GRV_TYRGRPLA,GRV_TXSERVICE,GRV_CFAMENDE,GRV_TYTRIMAG,GRV_TYTRICD2,GRV_TYSAISPAC,GRV_TYGSFRCO,GRV_FLCTRLPX,GRV_DLPROMO,GRV_NBJRLIVR,GRV_MDCLCCAP,GRV_MTFRPORT,GRV_FLRELI,GRV_TYRCPPAL,GRV_CDINCTRM,GRV_NBJVARCP,GRV_CDSOC,GRV_CDACTIVT,GRV_TYSTDEPO,GRV_TYRGDEPO,GRV_DTRGDEPO,GRV_FLPROPPX,GRV_FLPXRUNI,GRV_TYCTRRCP,GRV_CDFIAFOU,GRV_CPFIARCP,GRV_MDPREPPF,GRV_FLECLFAM) values ('1000000','2',null,'GRV LUCON                ','F','M',null,'A',null,'0','P',null,null,null,null,null,null,null,null,null,null,'0',null,null,null,'1',null,null,'1   ','DL','2','6','C',null,null,null,null,null,'46','0','46',null,null,null,null,null,null,'54',null,'54',null,'46',null,null,null,null,null,'46','46',null,'54',null,null,null,null,null,'6','T','1','0',null,null,'P',null,null,null,null,null,null,null,null,null,null,'0','0','0',null,null,null,'0');
	Insert into MGGRV (GRV_CDFO,GRV_CDGRVA,GRV_CDUNIBAR,GRV_LBGRVA,GRV_TYPORT,GRV_UNPORT,GRV_NBMINFRA,GRV_TYBASTRS,GRV_CDBARMTR,GRV_CDBARMQT,GRV_TYGESRQT,GRV_NBSEMAPR,GRV_DTPREMCD,GRV_NBSEMDEC,GRV_JJCDELUN,GRV_JJCDEMAR,GRV_JJCDEMER,GRV_JJCDEJEU,GRV_JJCDEVEN,GRV_JJCDESAM,GRV_JJCDEDIM,GRV_NBJRCOUV,GRV_DLMOYEN,GRV_DLRISQUE,GRV_NBJRCSMN,GRV_NOALGORI,GRV_DTARRCDE,GRV_DTFIN,GRV_CDACHET,GRV_CDUEXP,GRV_TYEDBC,GRV_TYTRICD,GVR_TYCALTRF,GRV_CDTABLFR,GRV_TYSEMCDE,GRV_CDMODCAD,GRV_HHLIMCDE,GRV_CDACTIV,GRV_FLCDAUTO,GRV_NBJRDCPP,GRV_FLZONELV,GRV_DTPRCHCD,GRV_DTPRCHLV,GRV_HHDEBCDE,GRV_CDADDSIA,GRV_CDSCTEUR,GRV_CDZNELV,GRV_FLRESQUAI,GRV_PTARRPAL,GRV_FLSAIPAC,GRV_PTARPAMS,GRV_FLTARPAL,GRV_HHLIMLIV,GRV_CDQUAILV,GRV_TYCALRMQ,GRV_CDCDECLI,GRV_TYGESAPP,GRV_FLDBRECP,GRV_FLCRETAR,GRV_CDARDQT,GRV_FLMODPCB,GRV_CDFORESD,GRV_TYRGRPLA,GRV_TXSERVICE,GRV_CFAMENDE,GRV_TYTRIMAG,GRV_TYTRICD2,GRV_TYSAISPAC,GRV_TYGSFRCO,GRV_FLCTRLPX,GRV_DLPROMO,GRV_NBJRLIVR,GRV_MDCLCCAP,GRV_MTFRPORT,GRV_FLRELI,GRV_TYRCPPAL,GRV_CDINCTRM,GRV_NBJVARCP,GRV_CDSOC,GRV_CDACTIVT,GRV_TYSTDEPO,GRV_TYRGDEPO,GRV_DTRGDEPO,GRV_FLPROPPX,GRV_FLPXRUNI,GRV_TYCTRRCP,GRV_CDFIAFOU,GRV_CPFIARCP,GRV_MDPREPPF,GRV_FLECLFAM) values ('1000000','3',null,'GRV FONTENAY             ','F','M',null,'A',null,'0','P',null,null,null,null,null,null,null,null,null,null,'0',null,null,null,'1',null,null,'1   ','DL','2','6','C',null,null,null,null,null,'46','0','46',null,null,null,null,null,null,'54',null,'54',null,'46',null,null,null,null,null,'46','46',null,'54',null,null,null,null,null,'6','T','1','0',null,null,'P',null,null,null,null,null,null,null,null,null,null,'0','0','0',null,null,null,'0');
	Insert into MGFOV (FOV_CDFO,FOV_NOVAR,FOV_CDUEXP,FOV_CDACHET,FOV_NOCI,FOV_CDGRVA,FOV_NOCI_MGACDE,FOV_CDDPRIST,FOV_NOCOMPTA,FOV_LBVA,FOV_TYCALTRF,FOV_DTFIN,FOV_NOVAREXT,FOV_FLTARBAR,FOV_MDGSPXCES) values ('1000000','20',null,null,'1','2','1',null,null,'VA LUCON par défaut           ','E',null,null,'46','V');
	Insert into MGFOV (FOV_CDFO,FOV_NOVAR,FOV_CDUEXP,FOV_CDACHET,FOV_NOCI,FOV_CDGRVA,FOV_NOCI_MGACDE,FOV_CDDPRIST,FOV_NOCOMPTA,FOV_LBVA,FOV_TYCALTRF,FOV_DTFIN,FOV_NOVAREXT,FOV_FLTARBAR,FOV_MDGSPXCES) values ('1000000','30',null,null,'1','3','1',null,null,'VA FONTENAY par défaut        ','E',null,null,'46','V');
	commit;
	
	/**************************************************************/
	/* ON FLAG LES FOURNISSEURS NATIONAUX CONNUS : connu_mbcen = 1*/
	/**************************************************************/
	for curs in (
		select to_number(code) as cdfo, 
		nom, 
		'p' as cdtypf,
		adr1,
		adr2,
		adr3,
		cp,
		ville,
		pays,
		tel,
		fax,
		mail
		from  TMP_IMP_FOURNISSEUR
		inner join MGFOU on fou_cdfo = to_number(code)
		where code is not null and to_number(code) < 90000
		order by to_number(code)
	)
	loop
		update TMP_IMP_FOURNISSEUR set connu_mbcen = 1 where to_number(code) = curs.cdfo;
		commit;
	end loop;

	/*****************************************************************/
	/* ON FLAG LES FOURNISSEURS NATIONAUX INCONNUS : connu_mbcen = 0 */ 
	/*****************************************************************/
	update TMP_IMP_FOURNISSEUR 
	set connu_mbcen = 0 
	where connu_mbcen is null and to_number(code) < 90000;
	commit;
	
	/* ...puis ON LES INSERE DANS LA TABLE MGFOU */
	FOR curs IN (
		select to_number(code) as cdfo, nom,
		'P' as cdtypf,
		adr1,
		adr2,
		adr3,
		cp,
		ville,
		pays,
		tel,
		fax,
		mail
		from  TMP_IMP_FOURNISSEUR
		where connu_mbcen = 0 and code is not null and to_number(code) < 90000
		order by to_number(code)
	)
	loop 
		insert into MGFOU (
			FOU_CDFO,
			fou_nm,
			fou_cdtypf,
			FOU_NVOI,
			FOU_BTQ,
			FOU_TVOI,
			FOU_LVOI,
			FOU_CVOI,
			FOU_CPOS2,
			FOU_DIST,
			FOU_CDPAYS,
			FOU_TLPH,
			FOU_FX,
			FOU_EMAI,
			fou_fltartrs
		) values (   
			curs.cdfo, 
			curs.nom,
			curs.cdtypf,
			null,
			null,
			null,
			null,
			null,
			curs.cp,
			curs.ville,
			curs.pays,
			curs.tel,
			curs.fax,
			curs.mail,
			'46'
		);
		commit;
		dbms_output.put_line('Fin integration MGFOU : '||curs.cdfo);
	end loop;	   
	/* *** ************************ *** */
	/* Début intégration des MGCIF */
	/* *** ************************ *** */
	for curs in (
		select to_number(code) as cdfo, nom,
		'P' as cdtypf,
		adr1,
		adr2,
		adr3,
		cp,
		ville,
		pays,
		tel,
		fax,
		mail
		from TMP_IMP_FOURNISSEUR
		where to_number(code) not in (select distinct cif_cdfo from mgcif) and to_number(code) < 90000 and code is not null
		order by to_number(code)
	)
	loop
		dbms_output.put_line('Debut integration MGCIF : '||curs.cdfo);	    
		REFE_FOUR_UTIL.PROC_INIT_MGCIF(
			pe_MGFOU_FOU_CDFO     => curs.cdfo,
			pe_MGFOU_INIT_CDFO    => util_param.RECUP_PARAM('FOU_INITIALISAT'),
			ps_er_MGFOU_FOU_CDFO  => v_er_MGFOU_FOU_CDFO,
			ps_er_MGFOU_INIT_CDFO => v_er_MGFOU_INIT_CDFO,
			ps_er_gene            => v_er_gene,
			ps_ERREUR             => v_ERREUR
		);
		dbms_output.put_line('Fin integration MGCIF : '||curs.cdfo); 
	end loop;

	for curs in (
		select to_number(code) as cdfo, nom,
		'P' as cdtypf,
		adr1,
		adr2,
		adr3,
		cp,
		ville,
		pays,
		tel,
		fax,
		mail
		from TMP_IMP_FOURNISSEUR
		where to_number(code) not in (select distinct grv_cdfo from mggrv) and to_number(code) < 90000 and code is not null
		order by to_number(code)
	)
	loop
		dbms_output.put_line('Debut integration MGGRV : '||curs.cdfo);	  
		/* Vérifier tables alimentées : MGGRV / MGFOV / MGARV ??? */  
		REFE_FOUR_UTIL.PROC_INIT_MGGRV( 
			pe_MGFOU_FOU_CDFO     => curs.cdfo,
			pe_MGFOU_INIT_CDFO    => util_param.RECUP_PARAM('FOU_INITIALISAT'),
			ps_er_MGFOU_FOU_CDFO  => v_er_MGFOU_FOU_CDFO,
			ps_er_MGFOU_INIT_CDFO => v_er_MGFOU_INIT_CDFO,
			ps_er_gene            => v_er_gene,
			ps_ERREUR             => v_ERREUR );
		dbms_output.put_line('Fin integration MGGRV : '||curs.cdfo); 
	end loop;
	commit;
	/* Le fournisseur template dispose d'un mode d'appro à 'DL' pour "direct local".
	Or pour les fournisseurs nationaux il faut que le mode d'appro soit initialisé à 'DI' pour "direct référencé" */
	/* attention mode d'appro sur 2 caractères */
	for curs in (
		select to_number(code) cdfo, 
		franco,
		unite_franco,
		mode_commande_edi,
		mode_commande_fax,
		tva_intracom,
		siret                    
		from  TMP_IMP_FOURNISSEUR
		inner join MGFOU on fou_cdfo = to_number(code)
		where code is not null and to_number(code) < 90000
		order by to_number(code)
	)
	loop                  
		/* mise à jour du CIF 	
		- siret
		- tva intracomm
		*/	
		update mgcif
		set cif_nosirt = curs.siret, cif_cdcee = curs.tva_intracom
		where cif_cdfo = curs.cdfo and cif_noci = 1;
		commit;
		/* mise à jour du CIF 	
		- mode de transmission de commande
		*/		
		update mgcif
		set cif_CDTRCDE = 'M'
		where cif_cdfo = curs.cdfo and cif_noci = 1;
		commit;	
		/* mise à jour de la GRV
		- franco
		*/		
		if trim(curs.unite_franco) = 'MON' then
			update mggrv
			set grv_typort = 'F', grv_unport = 'M', grv_nbminfra = to_number(curs.franco)
			where grv_cdfo = curs.cdfo and grv_cdgrva in (2,3);
			commit;
		end if;
		/* mise à jour de la GRV
		- mode d'appro
		*/
		update mggrv
		set grv_cduexp = 'D', grv_flreli ='F'
		where grv_cdfo = curs.cdfo and grv_cdgrva in (2,3);	
		commit;
	end loop;
	/* *** ************************** *** */
	/*Affiche la liste des fournisseurs pour lesquels l'adresse mail n'est pas renseignée*/
	/* *** ************************** *** */
	dbms_output.put_line('! - Fournisseurs sans email - !');
	select count(*) into v_d 
	from mgcif
	inner join mgfou on cif_cdfo = fou_cdfo
	inner join TMP_IMP_FOURNISSEUR on to_number(code) = fou_cdfo
	where fou_emai is null or cif_em is null;
	dbms_output.put_line('Nb fournisseurs sans email : '||v_d);
end;
/
quit