Select_Module
	clr.w Sunthetics_Number-data_base(a5)

	move.l _GfxBase(pc),a0
	move.l $26(a0),cop1lc(a6)
	clr.w copjmp1(a6)

	bsr NEv_stop

	move.l Live_Task(pc),a0			remet les requesters
	move.l old_WindowPtr(pc),pr_WindowPtr(a0)

	move.l _VillageBase(pc),d0		ya la picasso ?
	beq.s .no_picasso1
	tst.b VillageFlag-data_base(a5)		c'était koi le type d'écran avant ?
	beq.s .no_picasso1
	CALL d0,SetPicassoDisplay
	move.w #$0180,custom_base+dmacon
.no_picasso1

	CALL _IntuitionBase(pc),WBenchToFront

	lea Live_Requester(pc),a0		requester plizz!
	move.l _ReqBase(pc),a6
	jsr -84(a6)				FileRequester()
	tst.l d0				c bon ?
	beq.s skip_yaoudi
	lea DOS_Module_Name(pc),a0
yaoudi
	bsr Load_Module				charge le module alors

skip_yaoudi
	move.l _VillageBase(pc),d0		ya la picasso ?
	beq.s .no_picasso2
	move.l d0,a6				c'est koi le type d'écran ?
	btst #4,$22(a6)
	seq VillageFlag-data_base(a5)
	CALL SetAmigaDisplay			ecran AMIGA plizzz
	move.w #$8180,custom_base+dmacon	remet dma bitplan + copper
.no_picasso2

	move.l Live_Task(pc),a0			vire les requesters
	move.l pr_WindowPtr(a0),old_WindowPtr-data_base(a5)
	moveq #-1,d0
	move.l d0,pr_WindowPtr(a0)

	bsr NEv_start

	lea custom_base,a6
	move.l #Live_Coplist,cop1lc(a6)		coplist de live
	clr.w copjmp1(a6)
	rts


Load_Module
	move.l a0,-(sp)				sauve le ptr sur le fichier

	jsr mt_end				vire tout !
	bsr Free_Module

	moveq #2,d0				col=DECR_POINTER
	move.l #MEMF_CHIP,d1			memtype
	move.l (sp)+,a0				*name
	lea Module_Adr(pc),a1			&buffer
	lea Module_Size(pc),a2			&len
	lea -1,a3				function ecrypt.. none
	move.l _PowerpackerBase(pc),a6
	jsr -$1e(a6)
	tst.l d0				erreur ?
	beq .no_load_mod_error
	clr.l Module_Adr-data_base(a5)		voui...
	clr.l Module_Size-data_base(a5)
.not_pt_module
	bsr Free_Module

	lea custom_base,a6
	sf HP_State-data_base(a5)		et retrace le HP
	bra change_HP

.no_load_mod_error
	move.l Module_Adr(pc),a0
	cmp.l #"M.K.",1080(a0)			c'est du PT au moins ???
	bne.s .not_pt_module

	jsr mt_init				met la zik

	lea custom_base,a6
	st HP_State-data_base(a5)		et retrace le HP
	bsr change_HP
	rts

Free_Module
	move.l Module_Adr(pc),d0
	beq.s .no_module
	move.l d0,a1
	move.l Module_Size(pc),d0
	CALL _ExecBase(pc),FreeMem
	clr.l Module_Adr-data_base(a5)
	clr.l Module_Size-data_base(a5)
.no_module
	rts



*****************************************************************************
************* CHARGEMENT D'UN FICHIER QUELCONQUE EN CHIP MEMORY *************
*****************************************************************************
* gueule de la pile
* ~~~~~~~~~~~~~~~~~
* 0(sp) : taille du fichier
* 4(sp) : adr de chargement
* 8(sp) : nom du fichier


* chargement tout bete en absolue
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*  -->	A0=Nom du fichier
*	D0=Adr de chargement
Load_Absolute
	movem.l d0/a0,-(sp)
	clr.l -(sp)

	move.l a0,d1				essait d'obtenir un Lock
	move.l #ACCESS_READ,d2			sur le fichier pour avoir
	CALL _DosBase(pc),Lock			sa taille
	move.l d0,Live_Lock-data_base(a5)
	beq .load_abs_error

	move.l d0,d1				Examine() le fichier
	move.l #DOS_Fib,d2
	CALL Examine
	tst.l d0
	beq .load_abs_error

	move.l d2,a0
	tst.l fib_DirEntryType(a0)		c'est un fichier au moins ?
	bge .load_abs_error

	move.l fib_Size(a0),(sp)		sauve la taille du fichier

	move.l 8(sp),d1				ouvre le fichier en lecture
	move.l #MODE_OLDFILE,d2
	CALL Open
	move.l d0,Live_Handle-data_base(a5)
	beq.s .load_abs_error

	move.l d0,d1				lit le module entièrement
	move.l (sp),d3				la taille du fichier
	move.l 4(sp),d2				adr de chargement
	CALL Read
	cmp.l d0,d3
	bne.s .load_abs_error

	move.l Live_Handle(pc),d1		tout est ok => on sort peinard!
	CALL Close
	clr.l Live_Handle-data_base(a5)

	move.l Live_Lock(pc),d1
	CALL UnLock
	clr.l Live_Lock-data_base(a5)

	lea 4*3(sp),sp

	lea custom_base,a6
	moveq #-1,d0
	rts

.load_abs_error
	move.l Live_Handle(pc),d1		ferme le fichier
	beq.s .no_abs_handle
	CALL Close
	clr.l Live_Handle-data_base(a5)
.no_abs_handle
	move.l Live_Lock(pc),d1			libère le lock
	beq.s .no_abs_lock
	CALL UnLock
	clr.l Live_Lock-data_base(a5)
.no_abs_lock
	lea 4*3(sp),sp

	lea custom_base,a6
	moveq #0,d0
	rts
	


* chargement avec depackage ensuite
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*  -->	A0=Nom du fichier
Load_Powerpacker
	move.l a0,-(sp)
	clr.l -(sp)
	clr.l -(sp)

	bsr Free_File

	move.l 8(sp),d1				ouvre d'abord le fichier en
	move.l #MODE_OLDFILE,d2			lecture
	CALL _DosBase(pc),Open
	move.l d0,Live_Handle-data_base(a5)
	beq .load_pp_error

	move.l d0,d1				lit 4 octets du fichier
	move.l #Live_Buffer,d2			pour connaitre sa taille
	moveq #4,d3				dépackée
	CALL Read
	cmp.l d0,d3
	bne.s .load_pp_error	

	move.l Live_Handle(pc),d1		revient en arriere...
	moveq #0,d2
	move.l #OFFSET_BEGINNING,d3
	CALL Seek
	tst.l d0
	bmi.s .load_pp_error

	moveq #0,d0				alloue de la mémoire maintenant
	move.w Live_Buffer+ps_UnpackedSize(pc),d0
	add.l #SAFETY_MARGIN,d0
	move.l d0,(sp)				sauve la taille allouée
	move.l #MEMF_CHIP,d1
	CALL _ExecBase(pc),AllocMem
	move.l d0,4(sp)
	beq.s .load_pp_error

	move.l Live_Handle(pc),d1		lit le fichier maintenant
	move.l d0,d2				on charge ici
	moveq #0,d3
	move.w Live_Buffer+ps_PackedSize(pc),d3	taille du fichier packé
	CALL _DosBase(pc),Read	
	cmp.l d0,d3
	bne.s .load_pp_error

	move.l Live_Handle(pc),d1		tout est ok => on sort peinard!
	CALL Close
	clr.l Live_Handle-data_base(a5)

	move.l (sp)+,File_Size-data_base(a5)
	move.l (sp)+,File_Adr-data_base(a5)
	addq.l #4,sp

* on decrunch le fichier maintenant
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l File_Adr(pc),a2			début des datas packées
	lea SAFETY_MARGIN(a2),a1		on decrunch ici
	move.w (a2),d0
	lea (a2,d0.w),a0			fin des datas ici
	bsr Decrunch_pp

	lea data_base(pc),a5
	lea custom_base,a6
	moveq #-1,d0
	rts

.load_pp_error
	move.l 4(sp),d0				libère la mémoire allouée
	beq.s .no_pp_mem
	move.l d0,a1
	move.l (sp),d0
	CALL _ExecBase(pc),FreeMem
.no_pp_mem
	move.l Live_Handle(pc),d1		ferme le fichier
	beq.s .no_pp_handle
	CALL _DosBase(pc),Close
	clr.l Live_Handle-data_base(a5)
.no_pp_handle
	lea 4*3(sp),sp

	lea custom_base,a6
	moveq #0,d0
	rts


* Decrunchage d'un fichier chargé
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*  -->	a2=File_Adr
Decrunch_File
	lea SAFETY_MARGIN(a2),a1		les datas commencent ici
	move.w (a2),d0
	lea (a2,d0.w),a0			fin des datas ici
	bsr Decrunch_pp

	lea data_base(pc),a5
	lea custom_base,a6
	rts


* Libération de la mémoire alloué par un fichier
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Free_File
	move.l File_Size(pc),d0			libère le fichier précédent
	beq.s .no_file				si yen avait un
	move.l File_Adr(pc),a1
	CALL _ExecBase(pc),FreeMem
	clr.l File_Size-data_base(a5)
	clr.l File_Adr-data_base(a5)
.no_file
	rts
	


* attend l'insertion du disk 2 de Live
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Insert_Disk2
	movem.l d0-d7/a0-a6,-(sp)

	move.l _DosBase,a6
.wait_loop
	moveq #25,d1				attend 1/2 vbl
	CALL Delay

	move.l #Live_Disk2_Name,d1		y est ?
	move.l #SHARED_LOCK,d2
	CALL Lock
	move.l d0,d1
	beq.s .wait_loop

	CALL UnLock				libère le lock

	movem.l (sp)+,d0-d7/a0-a6
	rts

