
  
*
*			     Live Main Source
*			     ~~~~~~~~~~~~~~~~
*			  ©1993 Sync/DreamDealers



* Argggg!! Les includes
* ~~~~~~~~~~~~~~~~~~~~~
	incdir "Live:"
	incdir "Live:Adverts/"
	incdir "Live:ClipArts/"
	incdir "Live:ClipArts/PAK/"
	incdir "Live:Gallery/"
	incdir "Live:CodeArts/"
	incdir "Live:Fonts/"
	incdir "Live:Fonts/RAW/"
	incdir "Live:Gadgets/"
	incdir "Live:Gadgets/RAW/"
	incdir "Live:Gadgets/PAK/"
	incdir "Live:Layout&TitlePic/RAW"
	incdir "Live:Layout&TitlePic/PAK"
	incdir "Live:Menus/"
	incdir "Live:Messages/"
	incdir "Live:Music/"
	incdir "Live:Palettes/"
	incdir "Live:Sources/"
	incdir "Live:Zones/"
	incdir "Live:Articles/"

	incdir "ram:" 
	incdir "include:"
	include "exec/execbase.i"
	include "exec/exec_lib.i"
	include "exec/memory.i"
	include "dos/dos_lib.i"
	include "dos/dos.i"
	include "dos/dosextens.i"
	include "intuition/intuition_lib.i"
	include "graphics/graphics_lib.i"
	include "hardware/intbits.i"
	include "devices/input.i"
	include "devices/inputevent.i"
	include "misc/macros.i"
	include "Live_registers.i"



* Options de compilations
* ~~~~~~~~~~~~~~~~~~~~~~~
	OPT C+,O+,OW-
	OPT P=68000
	OPT NOLINE,NODEBUG
ZIK=ON
SAFETY_MARGIN=64
COUNT_GALLERY=21
TEST_LIVE=1

* Chargement de tous les EQU, STRUCTURES et MACROS de LIVE
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	include "Live.i"



* Point d'entrée de LIVE
* ~~~~~~~~~~~~~~~~~~~~~~
	section LiveMain,code
Live_EntryPoint
	bra.s skip_copyright
	dc.b "$VER: LiVe v2.6 - Release 4 - (c)1993-1994 DreamDealers",0
	even
skip_copyright
	lea data_base(pc),a5

	move.l (_SysBase).w,a6
	move.l a6,_ExecBase-data_base(a5)	copie d'ExecBase en FastRam!

	move.l ThisTask(a6),a3			recherche notre propre task
	move.l a3,Live_Task-data_base(a5)

	tst.l pr_CLI(a3)			on démarre du CLI ?
	bne.s _main

fromWorkbench
	lea pr_MsgPort(a3),a0			attend le WB message
	move.l a0,a3
	CALL WaitPort
	move.l a3,a0
	CALL GetMsg				va chercher le WB message
	move.l d0,-(sp)
	bsr.s _main	
	CALL _ExecBase(pc),Forbid
	move.l (sp)+,a1
	CALL ReplyMsg				retourne le WB message
	moveq #RETURN_OK,d0
	rts



* Le demarrage sous CLI/WB a été effectué
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_main
	move.l sp,save_SP-data_base(a5)

	move.l Live_Task(pc),a0
	move.l pr_WindowPtr(a0),old_WindowPtr-data_base(a5)
	moveq #-1,d0				pu de requester !!!
	move.l d0,pr_WindowPtr(a0)

	lea LiveDosName(pc),a1			ouvre la dos.library
	moveq #0,d0
	CALL OpenLibrary
	move.l d0,_DosBase-data_base(a5)
	beq LIVE_FAIL_DOS

	lea LiveGfxName(pc),a1			ouvre la graphics.library
	moveq #0,d0
	CALL OpenLibrary
	move.l d0,_GfxBase-data_base(a5)
	beq LIVE_FAIL_GFX

	lea LiveReqName(pc),a1			ouvre la req.library
	moveq #2,d0
	CALL OpenLibrary
	move.l d0,_ReqBase-data_base(a5)
	beq LIVE_FAIL_REQ

	lea LiveIntuitionName(pc),a1		ouvre l'intuition.library
	moveq #0,d0
	CALL OpenLibrary
	move.l d0,_IntuitionBase-data_base(a5)
	beq LIVE_FAIL_INTUITION

	lea VblIntStruct(pc),a1			ajoute un server VBL
	moveq #INTB_VERTB,d0
	CALL AddIntServer

nono
	jsr NEv_start				vire les events

	IFNE ZIK
	lea Live_Module1(pc),a0
	bsr Load_Module
	sf mt_Enable
	jsr SetCIAInt
	jsr mt_init				init la musique
	ENDC

* Affichage du logo de Tony
* ~~~~~~~~~~~~~~~~~~~~~~~~~
	lea data_base(pc),a5
	lea custom_base,a6

	lea Live_Start_Logo1,a0			chargement du logo1
	move.l #Board_Middle1,d0
	bsr Load_Absolute
	tst.l d0
	beq LIVE_FAIL_LOGO
	lea Board_Middle1,a2
	bsr Decrunch_File

	lea Live_Start_Logo2,a0			chargement du logo2
	move.l #Board_Middle2,d0
	bsr Load_Absolute
	tst.l d0
	beq LIVE_FAIL_LOGO
	lea Board_Middle2,a2
	bsr Decrunch_File

	move.l #Board_Middle1+SAFETY_MARGIN,d0
	move.w #80,d1
	moveq #4-1,d2
	lea Mistra_Ptrs+2,a0
	bsr Init_BplPtrs

	move.w #50*4,Show_Wait-data_base(a5)
	move.l #Mistra_Vbl,IT3_Vbl-data_base(a5)
	move.l #Mistra_Coplist,cop1lc(a6)
	clr.w copjmp1(a6)
	st mt_Enable
	move.w #$0020,dmacon(a6)		vire les sprites

* Affichage du clown de RA
* ~~~~~~~~~~~~~~~~~~~~~~~~
	move.l #Board_Middle2+SAFETY_MARGIN,d0
	move.w #40,d1
	moveq #5-1,d2
	lea Clown_Ptrs+2,a0
	bsr Init_BplPtrs

.Wait1	tst.w Show_Wait-data_base(a5)
	bne.s .Wait1

	move.w #50*5,Show_Wait-data_base(a5)
	move.l #Clown_Vbl,IT3_Vbl-data_base(a5)
	move.l #Clown_Coplist,cop1lc(a6)

.Wait2	tst.w Show_Wait-data_base(a5)
	bne.s .Wait2
	bra Do_Live

Mistra_Vbl
	lea data_base(pc),a5
	lea custom_base,a6
	subq.w #1,Show_Wait-data_base(a5)

	lea Mistra_Table(pc),a0
	cmp.w #20,Show_Wait-data_base(a5)
	bge.s .ok
	lea ShowOut_Table1(pc),a0
.ok	lea Mistra_Colors+2,a1
	moveq #16-1,d0
	bra ShowFade

Clown_Vbl
	lea data_base(pc),a5
	lea custom_base,a6
	subq.w #1,Show_Wait-data_base(a5)

	lea Clown_Table(pc),a0
	cmp.w #20,Show_Wait-data_base(a5)
	bge.s .ok
	lea ShowOut_Table2(pc),a0
.ok	lea Clown_Colors+2,a1
	moveq #32-1,d0
	bra ShowFade

Mistra_Table
	dc.w $000,$78A,$679,$568,$457,$346,$235,$124
	dc.w $89B,$9AC,$ABD,$BCE,$CDF,$DEF,$013,$002

Clown_Table
	dc.w $000,$223,$112,$FFF,$FDD,$FBC,$F8A,$F69
	dc.w $E38,$D27,$C16,$B05,$A04,$903,$803,$702
	dc.w $601,$500,$400,$300,$200,$334,$445,$556
	dc.w $667,$778,$889,$99A,$AAB,$BBD,$CCF,$DEF

ShowOut_Table1
	dcb.w 32,$000

ShowOut_Table2
	dcb.w 32,$234

ShowFade
	move.b (a0)+,d1				R
	move.b (a1),d2
	cmp.b d1,d2
	beq.s .okR
	bgt.s .subR
.addR	addq.b #$1,d2
	bra.s .okR
.subR	subq.b #$1,d2
.okR	move.b d2,(a1)+

	move.b (a0),d1				G
	and.w #$f0,d1
	move.b (a1),d2
	and.w #$f0,d2
	cmp.w d1,d2
	beq.s .okG
	bgt.s .subG
.addG	add.w #$10,d2
	bra.s .okG
.subG	sub.w #$10,d2
.okG
	move.b (a0)+,d1
	and.w #$0f,d1
	move.b (a1),d3
	and.w #$0f,d3
	cmp.w d1,d3
	beq.s .okB
	bgt.s .subB
.addB	addq.w #$1,d3
	bra.s .okB
.subB	subq.w #$1,d3
.okB	or.b d3,d2
	move.b d2,(a1)+

	addq.l #2,a1
	dbf d0,ShowFade
	rts


	
* LIVE COMMENCE REELEMENT ICI !!!
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Do_Live
	move.w #$0100,dmacon(a6)		vire dma bpl uniquement

	move.l #Board_Middle1,d0
	lea Middle_Ptrs+2,a0
	moveq #SCREEN_WIDTH,d1
	moveq #SCREEN_DEPTH-1,d2
	bsr Init_BplPtrs

	lea Sprites_Ptrs+2+8*(2+4),a0
	move.l #blank_sprite,d0
	move.w d0,4(a0)				gauche
	swap d0
	move.w d0,(a0)
	addq.l #8,a0
	move.l #blank_sprite,d0
	move.w d0,4(a0)				droite
	swap d0
	move.w d0,(a0)

	lea DZign_List(pc),a4
	moveq #NB_DZIGN-1,d7
Loop_Init_DZign_Spr
	moveq #0,d0				installe les sprites de gauche
	moveq #PART2,d1
	move.w #PART3-PART2+1,d2
	movem.l dz_Border0(a4),a0-a1		dz_Border0 et dz_Border1
	bsr put_sprite
	or.w #$0080,2(a0)
	move.l (a0),(a1)

	move.w #SCREEN_X/2-6,d0			installe les sprites de droite
	moveq #PART2,d1
	move.w #PART3-PART2+1,d2
	movem.l dz_Border2(a4),a0-a1		dz_Border2 et dz_Border3
	bsr put_sprite
	or.w #$0080,2(a0)
	move.l (a0),(a1)
	lea dz_SIZEOF(a4),a4			DZign suivant
	dbf d7,Loop_Init_DZign_Spr

	move.l #Board_Top,d0			init ce pointeur
	lea Top_Ptrs+2,a0
	moveq #SCREEN_WIDTH,d1
	moveq #SCREEN_DEPTH-1,d2
	bsr Init_BplPtrs

	move.l #Live_Vbl,IT3_Vbl-data_base(a5)
	move.l #Live_Coplist,cop1lc(a6)
	clr.w copjmp1(a6)

	move.w joy0dat(a6),LastY-data_base(a5)

	move.w #$8220,dmacon(a6)		sprites

	bsr Init_DZign				installe le DZign 0


* Gestion Globale des menus
* ~~~~~~~~~~~~~~~~~~~~~~~~~
Global_Menus
	bsr Display_NewMenu
	move.w #$8100,dmacon(a6)

Main_Loop
	WAIT_VBL
	bsr gestion_shortcuts
	bsr gestion_menus
	bsr gestion_gadgets
	bra.s Main_Loop



*****************************************************************************
*************************** GESTION DES MESSAGES ****************************
*****************************************************************************
	include "gestion_messages.s"



*****************************************************************************
*************************** GESTION DE LA GALLERY ***************************
*****************************************************************************
	include "gestion_gallery.s"



*****************************************************************************
*************************** GESTION DES ARTICLES ****************************
*****************************************************************************
	include "gestion_articles.s"



*****************************************************************************
***************************** GESTION DES WRITERS ***************************
*****************************************************************************
	include "gestion_sunthetics.s"



*****************************************************************************
***************************** GESTION DES WRITERS ***************************
*****************************************************************************
	include "gestion_print.s"



*****************************************************************************
**************************** GESTION DES ECRANS *****************************
*****************************************************************************
	include "gestion_ecran.s"



*****************************************************************************
****************************** GESTION DES MENUS ****************************
*****************************************************************************
	include "gestion_menus.s"



*****************************************************************************
***************************** GESTION DES GADGETS ***************************
*****************************************************************************
	include "gestion_gadgets.s"



*****************************************************************************
**************************** GESTION DES SHORTCUTS **************************
*****************************************************************************
	include "gestion_shortcuts.s"



*****************************************************************************
*********************** TOUTES LES ROUTINES DES MENUS ***********************
*****************************************************************************
	include "zone_utils.s"
	include "zone0.s"



*****************************************************************************
****************** TOUTES LES ROUTINES POUR LE CLAVIER **********************
*****************************************************************************
	include "gestion_clavier.s"



*****************************************************************************
******************* CHARGEMENT DU MODULE DE LIVE AVEC LE DOS ****************
*****************************************************************************
Select_Module
	move.l _GfxBase(pc),a0
	move.l $26(a0),cop1lc(a6)
	clr.w copjmp1(a6)

	bsr NEv_stop

	move.l Live_Task(pc),a0			remet les requesters
	move.l old_WindowPtr(pc),pr_WindowPtr(a0)

	lea Live_Requester(pc),a0		requester plizz!
	move.l _ReqBase(pc),a6
	jsr -84(a6)				FileRequester()
	tst.l d0				c bon ?
	beq.s .skip
	lea DOS_Module_Name(pc),a0
	bsr Load_Module				charge le module alors

.skip
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

	move.l (sp),d1				ouvre le fichier pour voir
	move.l #MODE_OLDFILE,d2			s'il est packé ou non avec
	CALL _DosBase(pc),Open			powerpacker
	move.l d0,Live_Handle-data_base(a5)
	beq .load_mod_error

	move.l d0,d1				lit 4 octets pour voir
	move.l #Module_Type,d2			si ya du PP20 dans l'air
	moveq #4,d3
	CALL Read
	cmp.l d0,d3
	bne .load_mod_error

	move.l Live_Handle(pc),d1		recherche l'eventuelle taille
	moveq.l #-4,d2				dépackée
	move.l #OFFSET_END,d3
	CALL Seek
	tst.l d0
	bmi .load_mod_error

	move.l Live_Handle(pc),d1		lit la taille
	move.l #Live_Buffer,d2
	moveq #4,d3
	CALL Read
	cmp.l d0,d3
	bne .load_mod_error

	move.l Live_Handle(pc),d1		revient au début
	moveq #0,d2
	move.l #OFFSET_BEGINNING,d3
	CALL Seek
	move.l d0,Module_Size-data_base(a5)
	bmi .load_mod_error

	move.l Module_Size(pc),Module_Size2-data_base(a5)

	cmp.l #"PP20",Module_Type-data_base(a5)	c'est du powerpacker ?
	bne.s .not_pp
	move.l Live_Buffer(pc),d0		taille dépacké
	lsr.l #8,d0
	add.l #SAFETY_MARGIN,d0
	move.l d0,Module_Size-data_base(a5)

.not_pp
	move.l Module_Size(pc),d0		alloue de la mémoire en CHIP
	move.l #MEMF_CHIP,d1			pour charger le module
	CALL _ExecBase(pc),AllocMem
	move.l d0,Module_Adr-data_base(a5)
	beq .load_mod_error

	move.l Live_Handle(pc),d1		lit le module entièrement
	move.l Module_Adr(pc),d2
	move.l Module_Size2(pc),d3
	CALL _DosBase(pc),Read
	cmp.l d0,d3
	bne.s .load_mod_error

	cmp.l #"PP20",Module_Type-data_base(a5)	y fo depacker ?
	bne.s .not_pp2

	move.l Module_Adr(pc),a2		début des datas packées
	lea SAFETY_MARGIN(a2),a1		on decrunch ici
	move.l a2,a0
	add.l Module_Size2(pc),a0		fin des datas ici
	bsr Decrunch_pp
	lea data_base(pc),a5
	move.l _DosBase(pc),a6

	cmp.l #"M.K.",1080(a1)			c'est du PT au moins ???
	bne.s .load_mod_error
	add.l #SAFETY_MARGIN,Module_Adr-data_base(a5)
	bra.s .load_ok

.not_pp2
	move.l Module_Adr(pc),a0		c'est du PT au moins ????
	cmp.l #"M.K.",1080(a0)
	bne.s .load_mod_error

* tout est ok => ferme le fichier
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.load_ok
	move.l Live_Handle(pc),d1
	CALL Close
	clr.l Live_Handle-data_base(a5)

	jsr mt_init				met la zik

	addq.l #4,sp
	lea custom_base,a6
	st HP_State-data_base(a5)		et retrace le HP
	bsr change_HP
	rts

.load_mod_error
	move.l Module_Adr(pc),d0
	beq.s .no_mod_mem
	move.l d0,a1				libère la mémoire du module
	move.l Module_Size(pc),d0
	CALL _ExecBase(pc),FreeMem
	clr.l Module_Adr-data_base(a5)
	clr.l Module_Size-data_base(a5)
.no_mod_mem
	move.l Live_Handle(pc),d1		ferme le fichier
	beq.s .no_mod_handle
	CALL _DosBase(pc),Close
	clr.l Live_Handle-data_base(a5)
.no_mod_handle
	addq.l #4,sp
	lea custom_base,a6
	moveq #0,d0
	rts



Free_Module
	move.l Module_Adr(pc),d0
	beq.s .no_module
	move.l d0,a1
	move.l Module_Size(pc),d0

	cmp.l #"PP20",Module_Type-data_base(a5)
	bne.s .no_pp
	lea -SAFETY_MARGIN(a1),a1
.no_pp
	CALL _ExecBase(pc),FreeMem
	clr.l Module_Size-data_base(a5)
	clr.l Module_Adr-data_base(a5)
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
	


*****************************************************************************
*********************************** LA VBL **********************************
*****************************************************************************
Live_Vbl
	lea data_base(pc),a5
	lea custom_base,a6

	bsr gestion_mouse

	tst.b Flip_Flag-data_base(a5)		on flip les ecrans ?
	beq.s no_Flip_Screen

	clr.b Flip_Flag-data_base(a5)

	move.l log_screen(pc),d0
	move.l phy_screen(pc),log_screen-data_base(a5)
	move.l d0,phy_screen-data_base(a5)
	lea Middle_Ptrs+2,a0			reinite les ptrs videos
	moveq #SCREEN_WIDTH,d1
	moveq #SCREEN_DEPTH-1,d2
	bsr Init_BplPtrs			dans la coplist

no_Flip_Screen
	bsr.s Fade_Middle_Screen

	clr.b Vbl_Flag-data_base(a5)		signal une vbl

	subq.b #1,Exit_Flag-data_base(a5)	minuterie pour la sortie de
	bpl.s .ok				Live
	sf Exit_Flag-data_base(a5)		met à 0...
.ok
	rts



fake_vbl
	movem.l d1-d7/a0-a6,-(sp)
	move.l IT3_Vbl(pc),a0
	jsr (a0)
	movem.l (sp)+,d1-d7/a0-a6
	moveq #0,d0
fake_IT
	rts


*****************************************************************************
************************ ROUTINE DE FADE PERMANENT **************************
*****************************************************************************
Fade_Middle_Screen
	lea FadeOUT_Table+2(pc),a0
	tst.b Fade_Flag-data_base(a5)		on va dans quel sens ?
	bne.s do_fade_out
do_fade_in
	move.l ColorMap_hook(pc),a0
	addq.l #2,a0
do_fade_out
	lea Middle_Colors+2+4,a1		pas touche color00
	moveq #NB_COLORS-1-1,d0
loop_fade
	move.b (a0)+,d1				R
	move.b (a1),d2
	cmp.b d1,d2
	beq.s .okR
	bgt.s .subR
.addR	addq.b #$2,d2
	cmp.b d1,d2
	ble.s .okR
	subq.b #$1,d2
	bra.s .okR
.subR	subq.b #$2,d2
	cmp.b d1,d2
	bge.s .okR
	addq.b #$1,d2
.okR	move.b d2,(a1)+

	move.b (a0),d1				G
	and.w #$f0,d1
	move.b (a1),d2
	and.w #$f0,d2
	cmp.w d1,d2
	beq.s .okG
	bgt.s .subG
.addG	add.w #$20,d2
	cmp.w d1,d2
	ble.s .okG
	sub.w #$10,d2
	bra.s .okG
.subG	sub.w #$20,d2
	cmp.w d1,d2
	bge.s .okG
	add.w #$10,d2
.okG
	move.b (a0)+,d1
	and.w #$0f,d1
	move.b (a1),d3
	and.w #$0f,d3
	cmp.w d1,d3
	beq.s .okB
	bgt.s .subB
.addB	addq.w #$2,d3
	cmp.w d1,d3
	ble.s .okB
	subq.w #$1,d3
	bra.s .okB
.subB	subq.w #$2,d3
	cmp.w d1,d3
	bge.s .okB
	addq.w #$1,d3
.okB	or.b d3,d2
	move.b d2,(a1)+

	addq.l #2,a1
	dbf d0,loop_fade

	tst.b Fade_Flag-data_base(a5)
	bne.s .opt_fade_out
.opt_fade_in
	subq.w #1,Fade_Offset-data_base(a5)
	bge.s .ok
	clr.w Fade_Offset-data_base(a5)
	bra.s .ok
.opt_fade_out
	addq.w #1,Fade_Offset-data_base(a5)
	move.w Fade_Offset(pc),d0
	cmp.w #9,d0
	ble.s .ok
	move.w #9,Fade_Offset-data_base(a5)
.ok
	rts
	

*****************************************************************************
**************************** GESTION DE LA SOURIS ***************************
*****************************************************************************
gestion_mouse
	movem.w MouseX(pc),d0-d1		affiche la souris
	lsr.w #1,d0				/2 à cause du Hires
	lsr.w #1,d1
	moveq #11,d2
	move.l Mouse_Sprite(pc),a0
	bsr.s put_sprite
	or.w #$0080,2(a0)

tst_left
	tst.b Left_Timer-data_base(a5)		timer sur LMB
	beq.s do_tst_left_button
	subq.b #1,Left_Timer-data_base(a5)
	bra.s tst_right
do_tst_left_button
	btst #6,ciaapra				LMB ?
	seq Left_Mousebutton-data_base(a5)
tst_right
	tst.b Right_Timer-data_base(a5)		timer sur RMB
	beq.s do_tst_right_button
	subq.b #1,Right_Timer-data_base(a5)
	bra.s end_tst_button
do_tst_right_button
	btst #2,potinp(a6)			RMB ?
	seq Right_Mousebutton-data_base(a5)
end_tst_button
	rts




*****************************************************************************
***************** CALCUL DES 2 MOTS DE CONTROLE D'UN SPRITE *****************
***************** EN ENTREE :  D0=COORD X		    *****************
*****************              D1=COORD Y		    *****************
*****************              D2=HAUTEUR DU SPRITE	    *****************
*****************              A0=ADR DU SPRITE		    *****************
*****************************************************************************
put_sprite
	moveq #0,d3
	add.w #$80,d0				recentre sur les X
	lsr.w #1,d0
	bcc.s put_sprite_pas_carryX
	moveq #1,d3
put_sprite_pas_carryX
	add.w #$2b,d1				recentre sur les Y
	move.w d1,d4
	lsl.w #8,d1
	bcc.s put_sprite_pas_carryY1
	or.w #4,d3
put_sprite_pas_carryY1
	or.w d1,d0
	add.w d2,d4
	lsl.w #8,d4
	bcc.s put_sprite_pas_carryY2
	or.w #2,d3
put_sprite_pas_carryY2
	or.w d4,d3
	movem.w d0/d3,(a0)
	rts



*****************************************************************************
******************    AFFICHAGE D'UN GADGET DANS UN ECRAN   *****************
****************** EN ENTREE : A0=ADR STRUCTURE BOB         *****************
******************             A1=ADR DE L'ECRAN            *****************
*****************************************************************************
put_gadget
	movem.l a0-a1/a5-a6,-(sp)
	move.l bs_PackedData(a0),d0
	lea (a0,d0.l),a2			début du PP20
	move.w ps_PackedSize(a2),d0
	lea (a2,d0.w),a0			fin du bob packé
	lea pp_space,a1
	bsr Decrunch_pp
	movem.l (sp)+,a0-a1/a5-a6

	movem.w bs_CoordX(a0),d0/d2		mais où c donc kon va le
	move.w d0,d1				foutre ce bob ??
	lsr.l #3,d0
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d2
	add.l d2,d0
	add.l a1,d0

	and.w #$f,d1				décalage des sources
	ror.w #4,d1

	move.l bs_PackedData(a0),d2		recherche l'adresse du mask
	move.w ps_UnpackedSize(a0,d2.l),d2
	lea pp_space,a1
	lea (a1,d2.w),a2

	move.w bs_BltSize(a0),d3		fabrication du mask pour
	and.w #%111111,d3			le gadget
	subq.w #1,d3
	move.w bs_BltSize(a0),d2
	lsr.w #6,d2
	move.l a2,a3				on ecrit là le mask
	bra.s start_make_mask
make_mask
	move.w d3,d4				efface d'abord une ligne
	move.l a3,a4				du mask
loop_clear
	clr.w (a4)+
	dbf d4,loop_clear

	moveq #SCREEN_DEPTH-1,d5		fabrique une ligne du mask
loop_bpl
	move.w d3,d4
	move.l a3,a4
loop_make_mask_line
	move.w (a1)+,d6
	or.w d6,(a4)+
	dbf d4,loop_make_mask_line
	dbf d5,loop_bpl	

	move.w d3,d4				bpl entrelacé => on duplique
	mulu #SCREEN_DEPTH-1,d4			le mask
	addq.w #SCREEN_DEPTH-1-1,d4
loop_dup
	move.w (a3)+,(a4)+
	dbf d4,loop_dup
	move.l a4,a3

start_make_mask
	dbf d2,make_mask

	ALLOC_BLITTER
	move.w d1,bltcon1(a6)
	or.w #$fca,d1
	move.w d1,bltcon0(a6)
	move.l a2,bltapt(a6)			A masque
	move.l #pp_space,bltbpt(a6)		B image (saute les couleurs)
	move.l d0,bltcpt(a6)			C background
	move.l d0,bltdpt(a6)			D destination
	clr.w bltamod(a6)
	clr.w bltbmod(a6)
	move.w bs_Modulo(a0),bltcmod(a6)
	move.w bs_Modulo(a0),bltdmod(a6)
	moveq #-1,d0
	move.l d0,bltafwm(a6)
	move.w bs_BltSize(a0),bltsize(a6)	lance le dma
	FREE_BLITTER
	rts	



*****************************************************************************
*****************   AFFICHAGE D'UN CLIPART DANS UN ECRAN    *****************
***************** EN ENTREE : A0=ADR STRUCTURE BOB          *****************
*****************             A1=ADR DE L'ECRAN             *****************
*****************************************************************************
put_clipart
	movem.l a0-a1/a5-a6,-(sp)
	move.l bs_PackedData(a0),d0
	lea (a0,d0.l),a2			début du PP20
	move.w ps_PackedSize(a2),d0
	lea (a2,d0.w),a0			fin du bob packé
	lea pp_space,a1
	bsr.s Decrunch_pp
	movem.l (sp)+,a0-a1/a5-a6

	movem.w bs_CoordX(a0),d0/d2		va chercher les coords X,Y
	add.w d0,d0				offset X = WORD
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d2
	add.l d2,d0			
	lea (a1,d0.l),a1			adresse destination

	ALLOC_BLITTER
	move.l #pp_space+pp_Datas,bltapt(a6)	copie toute bete avec
	move.l a1,bltdpt(a6)			A=D   sur la limite d'un mot !
	clr.w bltamod(a6)
	move.w bs_Modulo(a0),bltdmod(a6)
	moveq #-1,d0
	move.l d0,bltafwm(a6)
	move.l #$09f00000,bltcon0(a6)
	move.w bs_BltSize(a0),bltsize(a6)
	FREE_BLITTER
	rts	



*****************************************************************************
***************** ROUTINE DE DECOMPACTAGE POUR DATA FILE DE *****************
*****************            P.O.W.E.R.P.A.C.K.E.R          *****************
*****************   TRAFIQUE AVEC   CONVERTER.AMOS OU NON   *****************
*****************************************************************************
;EN ENTREE:
; a2=début datas packées
; a1=c'est là ou on decrunch
; a0=fin datas packées

; EN SORTIE
; a1=début datas dépackées

Decrunch_pp
	include "Live_Decrunch.s"



*****************************************************************************
******************************** INPUT HANDLER ******************************
*****************************************************************************
	include "Live_inputhandler.s"



*****************************************************************************
**************************** LES DATAS DE LIVE II ***************************
*****************************************************************************
data_base

Go_Left_Flag		dc.b 0
Go_Right_Flag		dc.b 0
Exit_Flag		dc.b 0
Vbl_Flag		dc.b 0
Flip_Flag		dc.b 0
Fade_Flag		dc.b 0			direction du fade : =0 => FadeIn
Barre_Flag		dc.b 0
HP_State		dc.b 0
Gadget_Key		dc.b 0
Load_Abs		dc.b 0

			CNOP 0,4
DOS_Fib			dcb.b fib_SIZEOF,0
_ExecBase		dc.l 0
_DosBase		dc.l 0
_GfxBase		dc.l 0
_ReqBase		dc.l 0
_PowerpackerBase	dc.l 0
_IntuitionBase		dc.l 0
old_WindowPtr		dc.l 0
Live_Task		dc.l 0
save_SP			dc.l 0
Module_Adr		dc.l 0
Module_Size		dc.l 0
Module_Size2		dc.l 0
Module_Type		dc.l 0
File_Adr		dc.l 0
File_Size		dc.l 0
Live_Lock		dc.l 0
Live_Handle		dc.l 0
Live_Buffer		dc.l 0

IT3_Vbl			dc.l fake_IT
Show_Wait		dc.w 0
vol_pos			dc.w 128
vol_pos_to_reach	dc.w 128
DZign_Number		dc.w 0
NbPages			dc.w 1
Barre_Result		dc.w 0
Fade_Offset		dc.w 12*2
MouseX			dc.w 0			position de la souris
MouseY			dc.w 0
LastY			dc.b 0
LastX			dc.b 0
Left_Mousebutton	dc.b 0			boutons de la souris
Right_Mousebutton	dc.b 0
Left_Timer		dc.b 0
Right_Timer		dc.b 0
Mouse_Sprite		dc.l 0
Board_Top_Back		dc.l 0
Board_Bottom		dc.l 0
ColorMap_hook		dc.l BackGround_Colors
Menu_hook		dc.l MainMenu
log_screen		dc.l Board_Middle1
phy_screen		dc.l Board_Middle2
Menu_SP			dc.l Menu_Stack+4
Menu_Stack		dcb.l 11*6,0		pas plus de 10 menus imbriqués !
ListPtr			dc.l 0
MessPtr			dc.l 0
Text_Margin		dc.l 0
Text_Font		dc.l Font_MicroKnight	MicroKnight par défaut
Text_Origin		dc.l 0
Text_Line_Offset	dc.l SCREEN_WIDTH*SCREEN_DEPTH*9
Text_Color		dc.w $566
SearchStr_Pos		dc.w 0
KB_Pos			dc.w 0			position dans le buffer
KB_Buffer		dcb.b KB_SIZE,0		on stocke ici les touches
KB_Mat			dcb.b 16,0		état des touches clavier

Text_Barre		dcb.b 128,0

VblIntStruct		dcb.l 2,0		ln_succ & ln_pred	
			dc.b NT_INTERRUPT	ln_type
			dc.b 127		ln_pri
			dc.l 0			ln_name
			dc.l 0			is_data
			dc.l fake_vbl		is_code

Live_Requester
	dc.w 2				frq_VersionNumber
	dc.l Live_Req_Title		Title
	dc.l DOS_Module_Path		Dir
	dc.l 0				File
	dc.l DOS_Module_Name		pathName
	dc.l 0				Window
	dc.w 0				MaxExtendedSelect
	dc.w 0				numlines
	dc.w 0				numcolumns
	dc.w 0				devcolumns
	dc.l 0				Flags
	dc.w 3				dirnamescolor
	dc.w 0				filenamescolor
	dc.w 3				devicenamescolor
	dc.w 0				fontnamescolor
	dc.w 0				fontsizecolor
	dc.w 0				detailcolor
	dc.w 0				blockcolor
	dc.w 0				gadgettextcolor
	dc.w 0				textmessagecolor
	dc.w 0				stringnamecolor
	dc.w 0				stringgadgetcolor
	dc.w 0				boxbordercolor
	dc.w 0				gadgetboxcolor
	dcb.b 36,0			RFU_Stuff
	dcb.b ds_SIZEOF,0		DirDateStamp
	dc.w 0				WindowLeftEdge
	dc.w 0				WindowTopEdge
	dc.w 0				FontYSize
	dc.w 0				FontStyle
	dc.l 0				ExtendedSelect
	dcb.b 30+2,0			Hide
	dcb.b 30+2,0			Show
	dc.w 0				FileBufferPos
	dc.w 0				FileDispPos
	dc.w 0				DirBufferPos
	dc.w 0				DirDispPos
	dc.w 0				HideBufferPos
	dc.w 0				HideDispPos
	dc.w 0				ShowBufferPos
	dc.w 0				ShowDispPos
	dc.l 0				Memory
	dc.l 0				Memory2
	dc.l 0				Lock
	dcb.b 130+2,0			PrivateDirBuffer
	dc.l 0				FileInfoBlock
	dc.w 0				NumEntries
	dc.w 0				NumHiddenEntries
	dc.w 0				filestartnumber
	dc.w 0				devicestartnumber

BackGround_Colors	dc.w $234,$A89,$DBA,$345,$ABB,$944,$999,$FEE
			dc.w $345,$B9A,$ECB,$456,$BCC,$A55,$AAA,$FFF

Temp_Colors		dcb.w NB_COLORS,0

FadeOUT_Table		dcb.w NB_COLORS,BACKGROUND_COLOR

Live_request_text	dc.b 2,0
			dc.b 0,0
			dc.w 18,6
			dc.l 0
			dc.l body_text
			dc.l 0

Live_right_text		dc.b 0,1
			dc.b 0,0
			dc.w 7,3
			dc.l 0
			dc.l rtext
			dc.l 0

body_text		dc.b "Back To Live !",0
rtext			dc.b "Click Me!",0

KeyBoard_ASCII		dc.b 0,"1234567890",0,0,0,0,0
			dc.b "QWERTYUIOP",0,0,0,0,0,0
			dc.b "ASDFGHJKL",0,0,0,0,0,0,0
			dc.b 0,"ZXCVBNM",0,0,0,0,0,0,0,0," "
			dcb.b $80-$41,0

LiveDosName		dc.b "dos.library",0
LiveGfxName		dc.b "graphics.library",0
LiveReqName		dc.b "req.library",0
LiveIntuitionName	dc.b "intuition.library",0

Live_Req_Title		dc.b "SeLeCt A NeW MoDuLe FoR LiVe !",0

Live_Module1		dc.b "LIVE_1:music/mod.1.2.3.jazz",0
Live_Module2		dc.b "LIVE_1:music/mod.jump and run 2",0
Live_Module3		dc.b "LIVE_1:music/mod.stand-by-kini",0
Live_Module4		dc.b "LIVE_1:music/mod.nono",0
Live_Module5		dc.b "LIVE_1:music/mod.madness",0
Live_Module6		dc.b "LIVE_1:music/mod.minidisco",0

Live_Start_Logo1	dc.b "LIVE_1:titlepic/MistraLogo.PAK",0
Live_Start_Logo2	dc.b "LIVE_1:titlepic/Clown.PAK",0

DOS_Module_Path		dcb.b 130+1,0
DOS_Module_Name		dcb.b 130+30+2,0



*****************************************************************************
***************************  GESTION DES MUSIQUES  **************************
*****************************************************************************
	even
	IFNE ZIK
	include "Live_Replay_PT.s"
	ENDC



********************************************************************************
*********************** INCLUSION DE TOUS LES DZIGNS ***************************
********************************************************************************
DZign_List

* DZIgn #0
* ~~~~~~~~
	dc.l DZign0_Top
	dc.l DZign0_Bottom
	dc.l DZign0_mouse
	dc.l DZign0_border_left0
	dc.l DZign0_border_left1
	dc.l DZign0_border_right0
	dc.l DZign0_border_right1
	dc.w $234,$445,$556,$566,$667,$678,$788,$889
	dc.w $89A,$9AA,$9AB,$AAB,$ABB,$BBB,$DEE,$FFF
	dc.w $234,$445,$556,$566,$667,$678,$788,$889
	dc.w $89A,$9AA,$9AB,$AAB,$ABB,$BBB,$DEE,$FFF

* DZign #1
* ~~~~~~~~
	dc.l DZign1_Top
	dc.l DZign1_Bottom
	dc.l DZign0_mouse
	dc.l DZign1_border_left0
	dc.l DZign1_border_left1
	dc.l DZign1_border_right0
	dc.l DZign1_border_right1
	dc.w $234,$334,$555,$777,$888,$AAA,$CCC,$EEE
	dc.w $E35,$900,$556,$AAB,$BCD,$DCC,$ECC,$CDD
	dc.w $eee,$eee,$eee,$eee,$eee,$eee,$eee,$eee
	dc.w $eee,$eee,$eee,$eee,$eee,$eee,$eee,$f85



********************************************************************************
********************* INCLUSION DES MESSAGES DE LIVE II ************************
********************************************************************************
	even
	include "Msg_All.s"



*****************************************************************************
**************************  INCLUSION DE LA GALLERY *************************
*****************************************************************************
	even
	include "Gallery_List.s"



*****************************************************************************
*************************  TOUTES LES FONTES DE LIVE  ***********************
*****************************************************************************
	even
	include "Fonts_List.s"



*****************************************************************************
********************  LE MESSAGE D'ERREUR POUR LA GALLERY  ******************
*****************************************************************************
Gallery_Msg
	dc.b 10
	dc.b 10
	dc.b "        Well... It's seems that there is a loading error",10
	dc.b "        In the °2Gallery section°1.",10
	dc.b "        Please, check out that the °3DISK 2 of LIVE",10
	dc.b "        is in one of your drive.",10
	dc.b "        If the loading error still continues to appear",10
	dc.b "        then you should have not enough memory...",10
	dc.b "           Thanx for your understanding !",0



*****************************************************************************
*************************  TOUS LES CLIPARTS DE LIVE  ***********************
*****************************************************************************
	include "ClipArts_List.s"



*****************************************************************************
************************  TOUTES LES ADVERTS DE LIVE  ***********************
*****************************************************************************
HalfAdverts_List
	incbin "HAD_List.RAW"
FullAdverts_List
	incbin "FAD_List.RAW"



*****************************************************************************
***************** LES CLIPARTS POUR LES REQUESTERS DE LIVE ******************
*****************************************************************************
Request_Disk
	DEF_GADGET (SCREEN_WIDTH-130)/2,(SCREEN_HEIGHT-63)/2,130,63,Bob_Request_Disk
Bob_Request_Disk
	incbin "Disk.PAK"

Request_Memory
	DEF_GADGET (SCREEN_WIDTH-115)/2,(SCREEN_HEIGHT-40)/2,115,40,Bob_Request_Memory	
Bob_Request_Memory
	incbin "Memory.PAK"



*****************************************************************************
****************************** LES MENUS DE LIVE ****************************
*****************************************************************************
	even
MainMenu
	dc.l 0
	dc.l Main_Edito
	dc.l MainMenu_BarText
	dc.w 0
	dc.l %001011111111011101100
	dc.l %000001011001011101000
	dc.l 0
	dc.l 0
	dc.l FirstWordsArticle
	dc.l CreditsMenu
	dc.l 0
	dc.l MessageMenu
	dc.l AdvertMenu
	dc.l NewsAndRumoursMenu
	dc.l 0
	dc.l DrdTestMenu
	dc.l FishAndTipsArticle
	dc.l BackStageArticle
	dc.l PartyZoneMenu
	dc.l DrdStoryMenu
	dc.l HandleStoryArticle
	dc.l SuntheticsMenu
	dc.l DreamLandsArticle
	dc.l 0
	dc.l Gallery
	dcb.l 2,0
	dc.l %101011000000
	dc.l %000000000000
	dcb.l 6,0
	dc.l HowToSupportArticle
	dc.l DesignItArticle
	dc.l 0
	dc.l AddressArticle
	dc.l 0
	dc.l LastWordsArticle
	dcb.l 9,0

CreditsMenu
	dc.l 0
	dc.l Credits_Edito
	dc.l Credits_BarText
	dc.w 0
	dc.l %1000000000000
	dc.l %0000000000000
	dcb.l 12,0
	dc.l CreditsArticle
	dcb.l 8,0
	dc.l %1000000000000
	dc.l %0000000000000
	dcb.l 12,0
	dc.l LiveStaffArticle
	dcb.l 8,0

MessageMenu
	dc.l 0
	dc.l Message_Edito
	dc.l Message_BarText
	dc.w 0
	dc.l %11100111000000000			LMenu
	dc.l %00000000000000000
	dcb.l 9,0
	dc.l MenuFromName
	dc.l MenuFromGroup
	dc.l MenuFromCountry
	dc.l 0
	dc.l 0
	dc.l MenuForEverybody
	dc.l MenuForMembers
	dc.l MenuForContacts
	dcb.l 4,0
	dc.l %01000111000000000			RMenu
	dc.l %00000000000000000
	dcb.l 9,0
	dc.l MenuForName
	dc.l MenuForGroup
	dc.l MenuForCountry
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l StringSearch
	dcb.l 0
	dcb.l 4,0

ListMenu
	dc.l 0
	dc.l ListMenuText
	dc.l Message_BarText
	dc.w 0
List_Flag1
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l List_LMenu0
	dc.l List_LMenu1
	dc.l List_LMenu2
	dc.l List_LMenu3
	dc.l List_LMenu4
	dc.l List_LMenu5
	dc.l List_LMenu6
	dc.l List_LMenu7
	dc.l List_LMenu8
	dc.l List_LMenu9
	dc.l List_LMenu10
	dc.l List_LMenu11
	dc.l List_LMenu12
	dc.l List_LMenu13
	dc.l List_LMenu14
	dc.l List_LMenu15
	dc.l List_LMenu16
	dc.l List_LMenu17
	dc.l List_LMenu18
	dc.l 0
List_Flag2
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l List_RMenu0
	dc.l List_RMenu1
	dc.l List_RMenu2
	dc.l List_RMenu3
	dc.l List_RMenu4
	dc.l List_RMenu5
	dc.l List_RMenu6
	dc.l List_RMenu7
	dc.l List_RMenu8
	dc.l List_RMenu9
	dc.l List_RMenu10
	dc.l List_RMenu11
	dc.l List_RMenu12
	dc.l List_RMenu13
	dc.l List_RMenu14
	dc.l List_RMenu15
	dc.l List_RMenu16
	dc.l List_RMenu17
	dc.l List_RMenu18
	dc.l 0

AdvertMenu
	dc.l 0
	dc.l Advert_Edito
	dc.l Advert_BarText
	dc.w 0
	dc.l 0				LMenu
	dc.l 0
	dcb.l 21,0
	dc.l %1001000000000		RMenu
	dc.l %0000000000000
	dcb.l 9,0
	dc.l Adverts_Part1
	dc.l 0
	dc.l 0
	dc.l Adverts_Part2
	dcb.l 8,0

NewsAndRumoursMenu
	dc.l 0
	dc.l NewsAndRumours_Edito
	dc.l NewsAndRumours_BarText
	dc.w 0
	dc.l 0
	dc.l 0
	dcb.l 21,0
	dc.l %1110000000000
	dc.l %0000000000000
	dcb.l 10,0
	dc.l NewsA_FArticle
	dc.l NewsG_MArticle
	dc.l NewsN_ZArticle
	dcb.l 8,0

DrdTestMenu
	dc.l 0
	dc.l DrdTest_Edito
	dc.l Psychotic_BarText
	dc.w 0
	dc.l %1000000000000000
	dc.l %0000000000000000
	dcb.l 15,0
	dc.l DrdTestArticle_Questions
	dcb.l 5,0
	dc.l %1000000000000000
	dc.l %0000000000000000
	dcb.l 15,0
	dc.l DrdTestArticle_Results
	dcb.l 5,0

PartyZoneMenu
	dc.l 0
	dc.l PartyZone_Edito
	dc.l PartyZone_BarText
	dc.w 0
	dc.l %1000000000000000
	dc.l %0000000000000000
	dcb.l 15,0
	dc.l SaturnePartyReportArticle
	dcb.l 5,0
	dc.l %1000000000000000
	dc.l %0000000000000000
	dcb.l 15,0
	dc.l SaturnePartyResultArticle
	dcb.l 5,0

DrdStoryMenu
	dc.l 0
	dc.l DrdStory_Edito
	dc.l History_BarText
	dc.w 0
	dc.l 0
	dc.l 0
	dcb.l 21,0
	dc.l %1111110000000
	dc.l %0000000000000
	dcb.l 7,0
	dc.l DrdStoryArticle1
	dc.l DrdStoryArticle2
	dc.l DrdStoryArticle3
	dc.l DrdStoryArticle4
	dc.l DrdStoryArticle5
	dc.l DrdStoryArticle6
	dcb.l 8,0

SuntheticsMenu
	dc.l 0
	dc.l Sunthetics_Edito
	dc.l Sunthetics_BarText
	dc.w 0
	dc.l 0
	dc.l 0
	dcb.l 21,0
	dc.l %111111000
	dc.l %000000000
	dcb.l 3,0
	dc.l Load_Sunthetics_Music1
	dc.l Load_Sunthetics_Music2
	dc.l Load_Sunthetics_Music3
	dc.l Load_Sunthetics_Music4
	dc.l Load_Sunthetics_Music5
	dc.l Load_Sunthetics_Music6
	dcb.l 12,0

MainMenu_BarText
	dc.b "Main Menu",0
Credits_BarText
	dc.b "Credits Menu",0
Message_BarText
	dc.b "Messages Menu",0
NewsAndRumours_BarText
	dc.b "News And Rumours",0
Advert_BarText
	dc.b "Adverts Menu",0
Psychotic_BarText
	dc.b "Psychotic Area",0
PartyZone_BarText
	dc.b "Party Zone Area",0
History_BarText
	dc.b "The DreamDealers' Story",0
Sunthetics_BarText
	dc.b "The Mega-Hyper Fabulous Sunthetics Section !",0

Help_BarText
	dc.b "Heeeellllp !!!...........................................  1/  0",0
ReadMessage_BarText
	dc.b "Reading Messages.........................................  1/  0",0
CreditsIssue_BarText
	dc.b "The Credits For This Issue...............................  1/  0",0
LiveStaff_BarText
	dc.b "The Live Staff...........................................  1/  0",0
AdvertPart1_BarText
	dc.b "Adverts Part One.........................................  1/  0",0
AdvertPart2_BarText
	dc.b "Adverts Part Two.........................................  1/  0",0
NewsA_F_BarText
	dc.b "News And Rumours A-F.....................................  1/  0",0
NewsG_M_BarText
	dc.b "News And Rumours G-M.....................................  1/  0",0
NewsN_Z_BarText
	dc.b "News And Rumours N-Z.....................................  1/  0",0
DrdTest_BarText
	dc.b "The Marvelous DreamTest..................................  1/  0",0
SaturneRepport_BarText
	dc.b "Saturne Party : The Repport..............................  1/  0",0
SaturneResults_BarText
	dc.b "Saturne Party : The Results..............................  1/  0",0
DrdStory_BarText
	dc.b "The DreamDealers' Story..................................  1/  0",0
FirstWords_BarText
	dc.b "First Words..............................................  1/  0",0
FishAndTips_BarText
	dc.b "Fish 'n' Tips............................................  1/  0",0
BackStage_BarText
	dc.b "BackStage................................................  1/  0",0
HandleStory_BarText
	dc.b "The Handles Story........................................  1/  0",0
DreamLands_BarText
	dc.b "About DreamLands.........................................  1/  0",0
Gallery_BarText
	dc.b "The Gallery..............................................  1/  0",0
HowToSupport_BarText
	dc.b "How To Support LIVE......................................  1/  0",0
DesignIt_BarText
	dc.b "Design IT, Design LIVE !.................................  1/  0",0
Address_BarText
	dc.b "Useful Adresses..........................................  1/  0",0
LastWords_BarText
	dc.b "Last Words...............................................  1/  0",0

MsgText_From
	dc.b "From: ",0
MsgText_For
	dc.b " For: ",0
MsgText_Slash
	dc.b "/",0

Main_Edito
	dc.b 10
	dc.b 10
	dc.b "             °2FiRsT WoRdS",10
	dc.b "             °1ThE CrEdItS",10
	dc.b 10
	dc.b "            °3MeSsAgEs MeNu",10
	dc.b "            AdVeRtS MeNu                            °2HoW To SuPpOrT°3",10
	dc.b "          NeWs AnD RuMoUrS                            °2DeSiGn It !",10
	dc.b 10
	dc.b "              °1DrEaMtEsT                            UsEfUl AdDrEsSeS",10
	dc.b "            FiSh 'N' TiPs",10
	dc.b "              BaCkStAgE                               °3LaSt WoRdS°1",10
	dc.b "             PaRtY ZoNe",10
	dc.b "         DrEaMdEaLeRS StOrY",10
	dc.b "         ThE HaNdLeS StOrY",10
	dc.b "             SuNtHeTiCs",10
	dc.b "             DrEaMLaNdS",10
	dc.b 10
	dc.b "            °3ThE GaLleRy",0

Credits_Edito
	dc.b 10
	dc.b 10
	dc.b 10
	dc.b 10
	dc.b "                  Well...Now, a bit of megalomania !!!",10
	dc.b "      For this new release of LIVE, a lot of peoples have worked hard",10
	dc.b "      ( for your pleasure,I hope... ) so it's now time to greet them.",10
	dc.b 10,10,10,10,10
	dc.b "       °2CrEdItS FoR ThIs IsSuE                       °3ThE LiVe StAfF",0

Message_Edito
	dc.b 10
	dc.b 10
	dc.b 10
	dc.b "                 °3Welcome in the LIVE's messages part !!!",10
	dc.b "            °1Select first the section you want to read and then",10
	dc.b "            use the arrow gadgets to browse through the messages",10
	dc.b 10,10,10
	dc.b "              °2FrOm NaMe                               °3FoR NaMe",10
	dc.b "              °2FrOm GrOuP                              °3FoR GrOuP",10
	dc.b "             °2FrOm CoUnTrY                            °3FoR CoUnTrY",10
	dc.b 10
	dc.b 10
	dc.b "            °3FoR EvErYBoDy",10
	dc.b "           °3FoR AlL MeMbErS                          °2StRiNg SeArCh",10
	dc.b "           °3FoR AlL CoNtaCtS",0

Advert_Edito
	dc.b 10
	dc.b " The main common point between scene magazines",10
	dc.b "     surely is the advertisements section.",10
	dc.b "    We won't be original and so here's the",10
	dc.b "         °2LIVE ADVERTISEMENTS SECTION.",10
	dc.b 10
	dc.b " °1If you want to place an advertisement here",10
	dc.b "  please use the following rules and sizes",10
	dc.b "          to make our work easier...",10
	dc.b "                                                   °2AdVeRtS PaRt OnE",10
	dc.b "  °3HALF PAGE ADVERTISEMENT : 38x21 chars",10
	dc.b "  FULL PAGE ADVERTISEMENT : 78x21 chars",10
	dc.b "                                                   °2AdVeRtS PaRt TwO",10
	dc.b " °2NOTE:",10
	dc.b "   °1- paper advertisements won't be published",10
	dc.b "   - don't colorize your add.",10
	dc.b "   - LIVE ADDS SECTION is totally free...",10
	dc.b 10
	dc.b "   °2Send your own made adds to the LIVE WHQ !!",0

NewsAndRumours_Edito
	dc.b "°2Yeah! You're about to enter the NEWS CORNER of",10
	dc.b "                 this mag !!",10
	dc.b 10
	dc.b " °1This News section is on under the hands of",10
	dc.b "the DREAMDEALERS vulcanologist called °2ANTONY°1.",10
	dc.b "This delightful guy is now ready to spend all",10
	dc.b "his free time collecting and group together",10
	dc.b "          all news you'll send.",10
	dc.b 10
	dc.b "       °3So let's burst his mail box !",10
	dc.b "                                                     °2NeWs A To F",10
	dc.b "         °1Send News and rumors to                     °2NeWs G To M",10
	dc.b "                                                     °2NeWs N To Z",10
	dc.b "             °3ANTONY SQUIZZATO",10
	dc.b "        4.IMPASSE PIERRE DEGEYTER",10
	dc.b "             15000 AURILLAC",10
	dc.b "                  FRANCE",10
	dc.b 10
	dc.b "°2Interested in becoming permanent NEWS DEALERS?! Great!",10
	dc.b " Then don't hesitate to contact ANTONY or drop a line",10
	dc.b "                 to the LIVE WHQ.",0

DrdTest_Edito
	dc.b 10
	dc.b 10
	dc.b "              °3Yeah! Welcome in the psychotic area of LIVE !!!",10
	dc.b 10
	dc.b 10
	dc.b "                 °2Are you worth being a Dreamdealer member ?",10
	dc.b 10
	dc.b "        °1Yes, it's obvious, this question already came to your mind!",10
	dc.b "               Today, we give you the opportunity to know.",10
	dc.b 10
	dc.b "                     °2First, take a pen and a paper...",10
	dc.b "               °1Begin by answering to the °3questions°1 and then",10
	dc.b "              look at your °3result°1...Be fair and have fun !!!",10
	dc.b 10
	dc.b 10
	dc.b "         °2DrEaMtEsT QuEsTiOnS                      DrEaMtEsT AnSwErS",0

PartyZone_Edito
	dc.b 10
	dc.b "                  °3Yabadabadadooo! You just reach it!",10
	dc.b 10
	dc.b "                      °2Welcome to the PARTY ZONE!",10
	dc.b 10
	dc.b "      °1Feel free to send your party reports,results,invitations or",10
	dc.b "          anything else concerning demos parties to this addy...",10
	dc.b 10
	dc.b 10
	dc.b "                                 °3LIVE WHQ",10
	dc.b "                            10.BD LOUIS BLANC",10
	dc.b "                               19100 BRIVE",10
	dc.b "                                  FRANCE",10
	dc.b 10
	dc.b 10
	dc.b "       °2SaTuRnE PaRtY RePpOrT                     SaTuRnE PaRtY ReSuLtS",0

DrdStory_Edito
	dc.b 10
	dc.b 10
	dc.b "°2Grumpf... And now, a bit of history!!!",10
	dc.b "                                             °3Well.. For this second issue",10
	dc.b "°1Yeah! This part is left for your group     °3of LIVE, we will begin with",10
	dc.b "°1You can tell here everything about YOUR      °3the story of DreamDealers!!!",10
	dc.b "°1crew: °2birth, members, demos, projects",10
	dc.b "and much much more °1!! Well...In fact              °2OnCe UpOn A TiMe",10
	dc.b "°1everything you'd like to say about it.         °2ThE FeLlOwS, ThE DeMoS",10
	dc.b "                                                  AbOuT DrD GeRmAnY",10
	dc.b "                                               DrEaMDeAleRs AnD FuTuRe",10
	dc.b "  °3If you are interested in such a thing         °2LiVe Vs Chit Chat",10
	dc.b "      °3then send an article to:                       °2DrEaMlAnDs",10
	dc.b 10
	dc.b "              °2LIVE WHQ",10
	dc.b "         10.BD LOUIS BLANC",10
	dc.b "            19100 BRIVE",10
	dc.b "               FRANCE",0

ListMenuText
	dc.b "°2"
	dcb.b (PAGE_X+1)*PAGE_Y+1,0

StringSearch_Edito
	dc.b 10
	dc.b 10
	dc.b 10
	dc.b "     °2AAaaarrrrgggg! Welcome in the Messages String Search section...",10
	dc.b 10
	dc.b 10
	dc.b "        °1Please, °2TYPE°1 the string to search through the messages",10
	dc.b "       then hit °3ENTER°1 to continue or °3RIGHT MOUSEBUTTON°1 to exit.",0

Sunthetics_Edito
	dc.b 10
	dc.b 10
	dc.b 10
	dc.b "   °2Welcome in the Sunthetics Area !!                  mod.1.2.3.jazz",10
	dc.b "   Please, select the module you want to              mod.jump and run 2",10
	dc.b "   hear                                               mod.stand-by-kini",10
	dc.b "                                                      mod.nono",10
	dc.b "                                                      mod.madness",10
	dc.b "                                                      mod.minidisco",0


*******************************************************************************
**************************  TOUS LES ARTICLES DE LIVE  ************************
*******************************************************************************
	include "Art_Macros.i"
	include "HandleStory.ART"
	include "FirstWords.ART"
	include "Credits.ART"
	include "LiveStaff.ART"
	include "DrdTest.ART"
	include "FishAndTips.ART"
	include "BackStage.ART"
	include "NewsAndRumours.ART"
	include "SaturnePartyReport.ART"
	include "SaturnePartyResult.ART"
	include "DrdStory.ART"
	include "HowToSupport.ART"
	include "DesignIt.ART"
	include "Address.ART"
	include "DreamLands.ART"
	include "LastWords.ART"
	include "Help.ART"




******************************************************************************
*********************  LES DATAS QUI DOIVENT ALLER EN CHIP  ******************
******************************************************************************
	section vazenchip,data_c
Live_Coplist
	dc.w fmode,$0				pas de Burst !!!!
	dc.w bplcon0,$4200!$8000		Hires - 4 Bpls
	dc.w bplcon1,$0000
	dc.w bplcon2,%100100			Sprites au dessus pliizzzz
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w ddfstrt,$003c
	dc.w ddfstop,$00d4
	dc.w bpl1mod,SCREEN_WIDTH*(SCREEN_DEPTH-1)	bpls entrelacés
	dc.w bpl2mod,SCREEN_WIDTH*(SCREEN_DEPTH-1)

Sprites_Colors
	dc.w color16,BACKGROUND_COLOR
	dc.w color17,BACKGROUND_COLOR
	dc.w color18,BACKGROUND_COLOR
	dc.w color19,BACKGROUND_COLOR
	dc.w color20,BACKGROUND_COLOR
	dc.w color21,BACKGROUND_COLOR
	dc.w color22,BACKGROUND_COLOR
	dc.w color23,BACKGROUND_COLOR
	dc.w color24,BACKGROUND_COLOR
	dc.w color25,BACKGROUND_COLOR
	dc.w color26,BACKGROUND_COLOR
	dc.w color27,BACKGROUND_COLOR
	dc.w color28,BACKGROUND_COLOR
	dc.w color29,BACKGROUND_COLOR
	dc.w color30,BACKGROUND_COLOR
	dc.w color31,BACKGROUND_COLOR
Sprites_Ptrs
	dc.w spr0ptH,0				les sprites
	dc.w spr0ptL,0
	dc.w spr1ptH,0
	dc.w spr1ptL,0
	dc.w spr2ptH,0
	dc.w spr2ptL,0
	dc.w spr3ptH,0
	dc.w spr3ptL,0
	dc.w spr4ptH,0
	dc.w spr4ptL,0
	dc.w spr5ptH,0
	dc.w spr5ptL,0
	dc.w spr6ptH,0
	dc.w spr6ptL,0
	dc.w spr7ptH,0
	dc.w spr7ptL,0

* COULEURS ET POINTEURS VIDEOS DE LA PARTIE DU HAUT
Top_Ptrs
	dc.w bpl1ptH,0				les pointeurs videos
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.w bpl3ptH,0
	dc.w bpl3ptL,0
	dc.w bpl4ptH,0
	dc.w bpl4ptL,0
Top_Colors
	dc.w color00,BACKGROUND_COLOR
	dc.w color01,BACKGROUND_COLOR
	dc.w color02,BACKGROUND_COLOR
	dc.w color03,BACKGROUND_COLOR
	dc.w color04,BACKGROUND_COLOR
	dc.w color05,BACKGROUND_COLOR
	dc.w color06,BACKGROUND_COLOR
	dc.w color07,BACKGROUND_COLOR
	dc.w color08,BACKGROUND_COLOR
	dc.w color09,BACKGROUND_COLOR
	dc.w color10,BACKGROUND_COLOR
	dc.w color11,BACKGROUND_COLOR
	dc.w color12,BACKGROUND_COLOR
	dc.w color13,BACKGROUND_COLOR
	dc.w color14,BACKGROUND_COLOR
	dc.w color15,BACKGROUND_COLOR

* COULEURS ET POINTEURS VIDEOS DE LA PARTIE DU MILIEU
	dc.w $3e01,$fffe			19 lignes pour Top_Part
Middle_Ptrs
	dc.w bpl1ptH,0				les pointeurs videos
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.w bpl3ptH,0
	dc.w bpl3ptL,0
	dc.w bpl4ptH,0
	dc.w bpl4ptL,0
Middle_Colors
	dc.w color00,BACKGROUND_COLOR
	dc.w color01,BACKGROUND_COLOR
	dc.w color02,BACKGROUND_COLOR
	dc.w color03,BACKGROUND_COLOR
	dc.w color04,BACKGROUND_COLOR
	dc.w color05,BACKGROUND_COLOR
	dc.w color06,BACKGROUND_COLOR
	dc.w color07,BACKGROUND_COLOR
	dc.w color08,BACKGROUND_COLOR
	dc.w color09,BACKGROUND_COLOR
	dc.w color10,BACKGROUND_COLOR
	dc.w color11,BACKGROUND_COLOR
	dc.w color12,BACKGROUND_COLOR
	dc.w color13,BACKGROUND_COLOR
	dc.w color14,BACKGROUND_COLOR
	dc.w color15,BACKGROUND_COLOR

* COULEURS ET POINTEURS VIDEOS DE LA PARTIE DU BAS
	dc.w $ffdf,$fffe
	dc.w $010f,$fffe			195 lignes pour Middle_Part
Bottom_Ptrs
	dc.w bpl1ptH,0				les pointeurs videos
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.w bpl3ptH,0
	dc.w bpl3ptL,0
	dc.w bpl4ptH,0
	dc.w bpl4ptL,0
Bottom_Colors
	dc.w color00,BACKGROUND_COLOR
	dc.w color01,BACKGROUND_COLOR
	dc.w color02,BACKGROUND_COLOR
	dc.w color03,BACKGROUND_COLOR
	dc.w color04,BACKGROUND_COLOR
	dc.w color05,BACKGROUND_COLOR
	dc.w color06,BACKGROUND_COLOR
	dc.w color07,BACKGROUND_COLOR
	dc.w color08,BACKGROUND_COLOR
	dc.w color09,BACKGROUND_COLOR
	dc.w color10,BACKGROUND_COLOR
	dc.w color11,BACKGROUND_COLOR
	dc.w color12,BACKGROUND_COLOR
	dc.w color13,BACKGROUND_COLOR
	dc.w color14,BACKGROUND_COLOR
	dc.w color15,BACKGROUND_COLOR

	dc.l $fffffffe


* INCLUSION DU DZIGN #0
* ~~~~~~~~~~~~~~~~~~~~~
DZign0_Top
	incbin "DZign0_Top.RAW"

DZign0_Bottom
	incbin "DZign0_Bottom.RAW"

DZign0_mouse
	dc.w 0
	dc.w 0
	dc.w	$FFE0,$FFE0
	dc.w	$FFC0,$FFC0
	dc.w	$FF80,$FF80
	dc.w	$FF00,$FF00
	dc.w	$FE00,$FE00
	dc.w	$FC00,$FC00
	dc.w	$F800,$F800
	dc.w	$F000,$F000
	dc.w	$E000,$E000
	dc.w	$C000,$C000
	dc.w	$8000,$8000
blank_sprite
	dc.l 0

DZign0_border_left0
	include "DZign0_border_left0.s"

DZign0_border_left1
	include "DZign0_border_left1.s"

DZign0_border_right0
	include "DZign0_border_right0.s"

DZign0_border_right1
	include "DZign0_border_right1.s"


* INCLUSION DU DZIGN #2
* ~~~~~~~~~~~~~~~~~~~~~
DZign1_Top
	incbin "DZign1_Top.RAW"

DZign1_Bottom
	incbin "DZign1_Bottom.RAW

DZign1_border_left0
	dc.w 0
	dc.w 0
	dcb.l PART3-PART2+1,$0000fc00
	dc.l 0

DZign1_border_left1
	dc.w 0
	dc.w 0
	dcb.l PART3-PART2+1,$fc00fc00
	dc.l 0

DZign1_border_right0
	dc.w 0
	dc.w 0
	dcb.l PART3-PART2+1,$0000fc00
	dc.l 0

DZign1_border_right1
	dc.w 0
	dc.w 0
	dcb.l PART3-PART2+1,$fc00fc00
	dc.l 0

BarreBack0
	incbin "Dzign0_BarreBack.RAW"
Barre0
	incbin "Dzign0_Barre.RAW"
BarreBack1
	incbin "Dzign1_BarreBack.RAW"
Barre1
	incbin "DZign1_Barre.RAW"

BarreMask
	dcb.b SCREEN_WIDTH*2*SCREEN_DEPTH,$ff

BackGround
	incbin "BackGround.RAW"

Mistra_Coplist
	dc.w fmode,$0
	dc.w bplcon0,$4200|$8000
	dc.w bplcon1,$0
	dc.w bplcon2,$0
	dc.w diwstrt,$7e81
	dc.w diwstop,$d8c1
	dc.w ddfstrt,$003c
	dc.w ddfstop,$00d4
	dc.w bpl1mod,80*3
	dc.w bpl2mod,80*3
Mistra_Ptrs
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.w bpl3ptH,0
	dc.w bpl3ptL,0
	dc.w bpl4ptH,0
	dc.w bpl4ptL,0
Mistra_Colors
	dc.w color00,0
	dc.w color01,0
	dc.w color02,0
	dc.w color03,0
	dc.w color04,0
	dc.w color05,0
	dc.w color06,0
	dc.w color07,0
	dc.w color08,0
	dc.w color09,0
	dc.w color10,0
	dc.w color11,0
	dc.w color12,0
	dc.w color13,0
	dc.w color14,0
	dc.w color15,0
	dc.l $fffffffe

Clown_Coplist
	dc.w fmode,$0
	dc.w bplcon0,$5200
	dc.w bplcon1,$0
	dc.w bplcon2,$0
	dc.w diwstrt,$2381
	dc.w diwstop,$33c1
	dc.w ddfstrt,$0038
	dc.w ddfstop,$00d0
	dc.w bpl1mod,40*4
	dc.w bpl2mod,40*4
Clown_Ptrs
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.w bpl3ptH,0
	dc.w bpl3ptL,0
	dc.w bpl4ptH,0
	dc.w bpl4ptL,0
	dc.w bpl5ptH,0
	dc.w bpl5ptL,0
Clown_Colors
	dc.w color00,0
	dc.w color01,0
	dc.w color02,0
	dc.w color03,0
	dc.w color04,0
	dc.w color05,0
	dc.w color06,0
	dc.w color07,0
	dc.w color08,0
	dc.w color09,0
	dc.w color10,0
	dc.w color11,0
	dc.w color12,0
	dc.w color13,0
	dc.w color14,0
	dc.w color15,0
	dc.w color16,0
	dc.w color17,0
	dc.w color18,0
	dc.w color19,0
	dc.w color20,0
	dc.w color21,0
	dc.w color22,0
	dc.w color23,0
	dc.w color24,0
	dc.w color25,0
	dc.w color26,0
	dc.w color27,0
	dc.w color28,0
	dc.w color29,0
	dc.w color30,0
	dc.w color31,0
	dc.l $fffffffe

	section fea,bss_c
Board_Top
	ds.b SCREEN_WIDTH*(PART2-PART1)*SCREEN_DEPTH
Board_Middle1
	ds.b SCREEN_WIDTH*(PART3-PART2)*SCREEN_DEPTH
Board_Middle2
	ds.b SCREEN_WIDTH*(PART3-PART2)*SCREEN_DEPTH
pp_space
	ds.b 25*1024				on decrunch les images ici
