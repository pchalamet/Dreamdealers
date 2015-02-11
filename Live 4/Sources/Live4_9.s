
  
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
SAFETY_MARGIN=128
COUNT_GALLERY=39
TEST_LIVE=0

* Chargement de tous les EQU, STRUCTURES et MACROS de LIVE
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	include "Live.i"



* Point d'entrée de LIVE
* ~~~~~~~~~~~~~~~~~~~~~~
	section LiveMain,code
Live_EntryPoint
	bra.s skip_copyright
	dc.b "$VER:  Live v2.9 - Release 4 (9 March 94) - (c)1993-1994 DreamDealers",0
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
	lea Live_Port_Name(pc),a1		on a déja LIVE en mémoire ???
	CALL FindPort
	tst.l d0
	beq.s .do_live
	rts					Voui ! => cassos...

.do_live
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

	lea LivePowerpackerName(pc),a1		ouvre la powerpacker.library
	moveq #0,d0
	CALL OpenLibrary
	move.l d0,_PowerpackerBase-data_base(a5)
	beq LIVE_FAIL_POWERPACKER

	lea LiveVillageName(pc),a1		ouvre la village.library
	moveq #0,d0
	CALL OpenLibrary
	move.l d0,_VillageBase-data_base(a5)

	lea VblIntStruct(pc),a1			ajoute un server VBL
	moveq #INTB_VERTB,d0
	CALL AddIntServer

* Installation de l'input handler pour intuition
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nono
	jsr NEv_start				vire les events

* Installation des musiques
* ~~~~~~~~~~~~~~~~~~~~~~~~~
	IFNE ZIK
	lea Live_Start_Module(pc),a0
	bsr Load_Module
	sf mt_Enable
	jsr SetCIAInt
	ENDC

* Regarde le type d'écran si ya une picasso
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l _VillageBase(pc),d0		ya la picasso ?
	beq.s .no_picasso
	move.l d0,a6
	btst #4,$22(a6)				c'est koi le type d'écran ?
	lea data_base(pc),a5
	seq VillageFlag-data_base(a5)
	CALL SetAmigaDisplay			passe en mode AMIGA
	move.w #$8180,custom_base+dmacon	remet le dma bitplan + copper
.no_picasso

* Affichage du logo DRD
* ~~~~~~~~~~~~~~~~~~~~~
	lea data_base(pc),a5
	lea custom_base,a6

	lea Live_DRD_Name,a0			chargement du logo1
	move.l #Board_Middle1,d0
	bsr Load_Absolute
	tst.l d0
	beq LIVE_FAIL_LOGO
	lea Board_Middle1,a2
	bsr Decrunch_File

	lea Live_Titlepic_Name,a0		chargement du logo2
	move.l #Board_Middle2,d0
	bsr Load_Absolute
	tst.l d0
	beq LIVE_FAIL_LOGO
	lea Board_Middle2,a2
	bsr Decrunch_File

	move.l #Board_Middle1+SAFETY_MARGIN,d0
	move.w #80,d1
	moveq #4-1,d2
	lea DRD_Ptrs+2,a0
	bsr Init_BplPtrs

	move.w #50*4,Show_Wait-data_base(a5)
	move.l #DRD_Vbl,IT3_Vbl-data_base(a5)
	move.l #DRD_Coplist,cop1lc(a6)
	clr.w copjmp1(a6)
	st mt_Enable
	move.w #$0020,dmacon(a6)		vire les sprites

* Affichage de la titlepic
* ~~~~~~~~~~~~~~~~~~~~~~~~
	move.l #Board_Middle2+SAFETY_MARGIN,d0
	move.w #40,d1
	moveq #6-1,d2
	lea Titlepic_Ptrs+2,a0
	bsr Init_BplPtrs

.Wait1	tst.w Show_Wait-data_base(a5)
	bne.s .Wait1

	move.w #50*5,Show_Wait-data_base(a5)
	move.l #Titlepic_Vbl,IT3_Vbl-data_base(a5)
	move.l #Titlepic_Coplist,cop1lc(a6)

.Wait2	tst.w Show_Wait-data_base(a5)
	bne.s .Wait2
	bra Do_Live

DRD_Vbl
	lea data_base(pc),a5
	lea custom_base,a6
	subq.w #1,Show_Wait-data_base(a5)

	lea DRD_Table(pc),a0
	cmp.w #20,Show_Wait-data_base(a5)
	bge.s .ok
	lea ShowOut_Table1(pc),a0
.ok	lea DRD_Colors+2,a1
	moveq #16-1,d0
	bra ShowFade

Titlepic_Vbl
	lea data_base(pc),a5
	lea custom_base,a6
	subq.w #1,Show_Wait-data_base(a5)

	lea Titlepic_Table(pc),a0
	cmp.w #20,Show_Wait-data_base(a5)
	bge.s .ok
	lea ShowOut_Table2(pc),a0
	move.w #$5200,Titlepic_Coplist+2*3
.ok	lea Titlepic_Colors+2,a1
	moveq #32-1,d0
	bra ShowFade

DRD_Table
	dc.w $300,$EEE,$AAA,$344,$400,$601,$813,$923
	dc.w $A34,$C67,$555,$566,$667,$767,$967,$A78

Titlepic_Table
	dc.w $300,$767,$878,$989,$A9A,$BAB,$868,$720
	dc.w $820,$920,$744,$855,$966,$A77,$B88,$C99
	dc.w $DAA,$845,$A30,$B40,$634,$734,$834,$945
	dc.w $A55,$B66,$B77,$C88,$C9A,$CAB,$CBC,$CCC

ShowOut_Table1
	dcb.w 32,$300

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
	include "gestion_load.s"



*****************************************************************************
*********************************** LA VBL **********************************
*****************************************************************************
Live_Vbl
	lea data_base(pc),a5
	lea custom_base,a6


	move.w #$0400,dmacon(a6)		vire ca pri blitter... pourquoi ?? mystere...

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
VillageFlag		dc.b 0

			CNOP 0,4
DOS_Fib			dcb.b fib_SIZEOF,0
_ExecBase		dc.l 0
_DosBase		dc.l 0
_GfxBase		dc.l 0
_ReqBase		dc.l 0
_IntuitionBase		dc.l 0
_VillageBase		dc.l 0
_PowerpackerBase	dc.l 0
old_WindowPtr		dc.l 0
Live_Task		dc.l 0
save_SP			dc.l 0
Module_Adr		dc.l 0
Module_Size		dc.l 0
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

Sunthetics_Number	dc.w 1

VblIntStruct		dcb.l 2,0		ln_succ & ln_pred	
			dc.b NT_INTERRUPT	ln_type
			dc.b 127		ln_pri
			dc.l Live_Vbl_Name	ln_name
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

BackGround_Colors
	dc.w $234,$A89,$DBA,$345,$ABB,$534,$535,$EEE
	dc.w $345,$B9A,$ECB,$456,$BCC,$645,$646,$fff


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
LiveVillageName		dc.b "village.library",0
LivePowerpackerName	dc.b "powerpacker.library",0

Live_Req_Title		dc.b "SeLeCt A NeW MoDuLe FoR LiVe !",0
Live_Vbl_Name		dc.b "Oh da nice vbl for LIVE !",0
Live_Port_Name		dc.b "Live Dummy Port...",0

Live_Start_Module	dc.b "LIVE_1:music/mod.the.sideshow",0
Live_Module1		dc.b "LIVE_2:music/mod.the.sideshow",0
Live_Module2		dc.b "LIVE_2:music/mod.(-hanging fire-)",0
Live_Module3		dc.b "LIVE_2:music/mod.jump and run 2",0
Live_Module4		dc.b "LIVE_2:music/mod.nono",0
Live_Module5		dc.b "LIVE_2:music/mod.kinder",0
Live_Module6		dc.b "LIVE_2:music/mod.flagada",0
Live_Module7		dc.b "LIVE_2:music/mod.stand-by-kini",0
Live_Module8		dc.b "LIVE_2:music/mod.minidisco",0
Live_Module9		dc.b "LIVE_2:music/mod.between 2 waters",0
Live_Module10		dc.b "LIVE_2:music/mod.nesquik",0
Live_Module11		dc.b "LIVE_2:music/mod.madness",0
Live_Module12		dc.b "LIVE_2:music/mod.monsieur lampiste",0
Live_Module13		dc.b "LIVE_2:music/mod.solitary brotha",0
Live_Module14		dc.b "LIVE_2:music/mod.bamse i trollskogen",0

Live_DRD_Name		dc.b "LIVE_1:titlepic/DRD.PAK",0
Live_Titlepic_Name	dc.b "LIVE_1:titlepic/Titlepic.PAK",0

Live_Disk2_Name		dc.b "LIVE_2:",0

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
	dc.w $234,$345,$FBA,$7B9,$223,$334,$445,$567
	dc.w $678,$799,$AAA,$CCB,$DCC,$EDC,$EED,$FFF
	dc.w $234,$345,$FBA,$7B9,$223,$334,$445,$567
	dc.w $678,$799,$AAA,$CCB,$DCC,$EDC,$EED,$FFF


* DZign #1
* ~~~~~~~~
	dc.l DZign1_Top
	dc.l DZign1_Bottom
	dc.l DZign0_mouse
	dc.l DZign1_border_left0
	dc.l DZign1_border_left1
	dc.l DZign1_border_right0
	dc.l DZign1_border_right1
	dc.w $234,$445,$ACB,$BCA,$CBA,$DBB,$CBB,$EDC
	dc.w $AAA,$CAA,$667,$AA9,$ABA,$9BA,$556,$FFF
	dc.w $234,$445,$ACB,$BCA,$CBA,$DBB,$CBB,$EDC
	dc.w $AAA,$CAA,$667,$AA9,$ABA,$9BA,$556,$FFF


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
********************             ET SUNTHETICS             ******************
*****************************************************************************
Gallery_Msg
	dc.b 10,10,10,10,10,10,10,10,10
	dc.b "°3                  Can't find the picture!",10
	dc.b "°2          Please Insert Live Disk 2 In Any Drive",0

Sunthetics_Msg
	dc.b 10,10,10,10,10,10,10,10,10
	dc.b "°3                   Can't find the music!",10
	dc.b "°2          Please Insert Live Disk 2 In Any Drive",0




*****************************************************************************
*************************  TOUS LES CLIPARTS DE LIVE  ***********************
*****************************************************************************
	even
	include "ClipArts_List.s"



*****************************************************************************
************************  TOUTES LES ADVERTS DE LIVE  ***********************
*****************************************************************************
	even
HalfAdverts_List
	incbin "HAD_List.RAW"
	even
FullAdverts_List
	incbin "FAD_List.RAW"




*****************************************************************************
****************************** LES MENUS DE LIVE ****************************
*****************************************************************************
	even
MainMenu
	dc.l 0
	dc.l Main_Edito
	dc.l MainMenu_BarText
	dc.w 0
	dc.l %010111111111011101100
	dc.l %000110010000011101000
	dc.l 0
	dc.l 0
	dc.l FirstWordsArticle
	dc.l CreditsMenu
	dc.l 0
	dc.l MessageMenu
	dc.l AdvertMenu
	dc.l NewsAndRumoursMenu
	dc.l 0
	dc.l SexArticle
	dc.l FishAndTipsArticle
	dc.l BackStageArticle
	dc.l StupidSwappersArticle
	dc.l SuntheticsMenu
	dc.l HandleStoryArticle
	dc.l AboutSFArticle
	dc.l MovementStoryMenu
	dc.l PartyZoneMenu
	dc.l 0
	dc.l Gallery
	dc.l 0
	dc.l %1011011000000
	dc.l %0000000000000
	dcb.l 6,0
	dc.l HowToSupportArticle
	dc.l DesignItArticle
	dc.l 0
	dc.l AddressArticle
	dc.l OfficialSpreadersArticle
	dc.l 0
	dc.l LastWordsArticle
	dcb.l 8,0

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
	dc.l %101100111000000000		LMenu
	dc.l %000000000000000000
	dcb.l 9,0
	dc.l MenuFromName
	dc.l MenuFromGroup
	dc.l MenuFromCountry
	dc.l 0
	dc.l 0
	dc.l MenuForEverybody
	dc.l MenuForContacts
	dc.l 0
	dc.l StringSearch
	dcb.l 3,0
	dc.l %00000111000000000			RMenu
	dc.l %00000000000000000
	dcb.l 9,0
	dc.l MenuForName
	dc.l MenuForGroup
	dc.l MenuForCountry
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l 0
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
	dc.l NewsA_DArticle
	dc.l NewsE_PArticle
	dc.l NewsQ_ZArticle
	dcb.l 8,0

PartyZoneMenu
	dc.l 0
	dc.l PartyZone_Edito
	dc.l PartyZone_BarText
	dc.w 0
	dc.l %1111000000000000000
	dc.l %0000000000000000000
	dcb.l 15,0
	dc.l GatheringArticle
	dc.l PartyIIILiveArticle
	dc.l PartyIIIRepportArticle
	dc.l PartyIIIResultsArticle
	dcb.l 2,0
	dc.l %0000000000000000
	dc.l %0000000000000000
	dcb.l 21,0

SuntheticsMenu
	dc.l 0
	dc.l Sunthetics_Edito
	dc.l Sunthetics_BarText
	dc.w 0
	dc.l 0
	dc.l 0
	dcb.l 21,0
	dc.l %10000000000000
	dc.l %10000000000000
	dcb.l 13,0
	dc.l SuntheticsLoaderMenu
	dcb.l 7,0

SuntheticsLoaderMenu
	dc.l Sunthetics_Menu_Render
	dc.l SuntheticsLoader_Edito
	dc.l Sunthetics_BarText
	dc.w 0
	dc.l %111111100000
	dc.l %000000000000
	dcb.l 5,0
	dc.l Load_Sunthetics_Music2
	dc.l Load_Sunthetics_Music4
	dc.l Load_Sunthetics_Music6
	dc.l Load_Sunthetics_Music8
	dc.l Load_Sunthetics_Music10
	dc.l Load_Sunthetics_Music12
	dc.l Load_Sunthetics_Music14
	dcb.l 9,0
	dc.l %111111100000
	dc.l %000000000000
	dcb.l 5,0
	dc.l Load_Sunthetics_Music3
	dc.l Load_Sunthetics_Music5
	dc.l Load_Sunthetics_Music7
	dc.l Load_Sunthetics_Music9
	dc.l Load_Sunthetics_Music11
	dc.l Load_Sunthetics_Music13
	dc.l Load_Sunthetics_Music1
	dcb.l 9,0

MovementStoryMenu
	dc.l 0
	dc.l MovementStory_Edito
	dc.l History_BarText
	dc.w 0
	dc.l 0
	dc.l 0
	dcb.l 21,0
	dc.l %1010000000000
	dc.l %0000000000000
	dcb.l 10,0
	dc.l MovementStoryArticle1
	dc.l 0
	dc.l MovementStoryArticle2
	dcb.l 8,0


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
	dc.b "Da Movement Story",0
Sunthetics_BarText
	dc.b "The Fabulous Sunthetics Section !",0

Help_BarText
	dc.b "Heeeellllp !!!.........................................   1/   0",0
ReadMessage_BarText
	dc.b "Reading Messages.......................................   1/   0",0
CreditsIssue_BarText
	dc.b "The Credits For This Issue.............................   1/   0",0
LiveStaff_BarText
	dc.b "The Live Staff.........................................   1/   0",0
AdvertPart1_BarText
	dc.b "Adverts Part One.......................................   1/   0",0
AdvertPart2_BarText
	dc.b "Adverts Part Two.......................................   1/   0",0
NewsA_D_BarText
	dc.b "News And Rumours A-D...................................   1/   0",0
NewsE_P_BarText
	dc.b "News And Rumours E-P...................................   1/   0",0
NewsQ_Z_BarText
	dc.b "News And Rumours Q-Z...................................   1/   0",0
FirstWords_BarText
	dc.b "First Words............................................   1/   0",0
FishAndTips_BarText
	dc.b "Fish 'n' Tips..........................................   1/   0",0
BackStage_BarText
	dc.b "BackStage..............................................   1/   0",0
HandleStory_BarText
	dc.b "The Handles Story......................................   1/   0",0
Gallery_BarText
	dc.b "The Gallery............................................   1/   0",0
HowToSupport_BarText
	dc.b "How To Support LIVE....................................   1/   0",0
DesignIt_BarText
	dc.b "Design IT, Design LIVE !...............................   1/   0",0
Address_BarText
	dc.b "Useful Adresses........................................   1/   0",0
LastWords_BarText
	dc.b "Last Words.............................................   1/   0",0
Sex_BarText
	dc.b "Sex ?..................................................   1/   0",0
StupidSwappers_BarText
	dc.b "Stupid Swappers !......................................   1/   0",0
AboutSF_BarText
	dc.b "Sciences Fiction.......................................   1/   0",0
OfficialSpreaders_BarText
	dc.b "Official Live Spreaders................................   1/   0",0
Gathering_BarText
	dc.b "The Gathering Party Manual.............................   1/   0",0
Movement1_BarText
	dc.b "Once Upon A Time : Movement............................   1/   0",0
Movement2_BarText
	dc.b "Who Did What ?.........................................   1/   0",0
PartyIIILive_BarText
	dc.b "Party III Live Reaction................................   1/   0",0
PartyIIIRepport_BarText
	dc.b "Party III Repport......................................   1/   0",0
PartyIIIResults_BarText
	dc.b "Party III Results......................................   1/   0",0



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
	dc.b "                °1Sex!                               UsEfUl AdDrEsSeS",10
	dc.b "            FiSh 'n' TiPs                         OfFiCiAl SpReAdErS",10
	dc.b "              BaCkStAgE",10
	dc.b "         YoU StUpId SwApPeRs!                         °3LaSt WoRdS°1",10
	dc.b "             SuNtHeTiCs",10
	dc.b "          ThE HaNdLe StOrY",10
	dc.b "              About SF",10
	dc.b "         ThE MoVeMeNt StOrY",10
	dc.b "             PaRtY ZoNe",10
	dc.b 10
	dc.b "            °3ThE GaLleRy",0

Credits_Edito
	dc.b 10
	dc.b 10
	dc.b 10
	dc.b 10
	dc.b 10
	dc.b "      For this new release of LIVE, a lot of peoples have worked hard",10
	dc.b "      ( for your pleasure,we hope... ) so it's now time to greet them.",10
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
	dc.b "           °3FoR AlL CoNtAcTs",10
	dc.b 10
	dc.b "            °2StRiNg SeArCh",0

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
	dc.b "      °2GaThErInG  InFoRmAtIoNs",10
	dc.b "       PaRtY III LiVe ReAcTiOn",10
	dc.b "         PaRtY III RePpOrT",10
	dc.b "         PaRtY III ReSuLtS",0

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
	dc.b "°3                             Hi everybody !",10
	dc.b "Well let me introduce you to this musical part of LIVE.",10
	dc.b "°1This rubric is meant to be a kind of a 'mini' jukebox, if you see what I",10
	dc.b "mean. We will play here only tiny kilobytes music and everybody is free to",10
	dc.b "send his °3Tiny Tunes °1to me...",10
	dc.b 10
	dc.b "         °2 -  The only rules is no tunes heavier than 20 kb ! -",10
	dc.b "°3Please feel free to send a little description for the tunes you will send...",10
	dc.b 10
	dc.b "°1If nobody sends me any tunes, I will take in my own Tiny Tunes and you will",10
	dc.b "better have to be deaf for the next issue...(no not Leppard)!",10
	dc.b "You've been warned!",10
	dc.b 10
	dc.b "°3       SUN/DREAMDEALERS                      °2>>> TiNy TuNeS SeLeCtOr <<<",10
	dc.b "°3        AHNI DJAMYANG",10
	dc.b "°3   3.RUE DU BOUT DE LA VILLE",10
	dc.b "       27180 LES VENTES",10
	dc.b 10
	dc.b "°2   Hope you'll appreciate this first cocktail...",10
	dc.b "Your Tiny Tunes (c) Jukebox Editor -Sun- (no clouds)",10
	dc.b "Ps: Tiny Tune is copyrighted by LIVE.",0

SuntheticsLoader_Edito
	dc.b 10
	dc.b 10
	dc.b 10
	dc.b "°3                 Please, select the module you want to hear:°2",10
	dc.b 10
	dc.b "            HaNgInG FiRe                            JuMp AnD RuN 2",10
	dc.b "                NoNo                                    KiNdEr",10
	dc.b "              FlAgAdA                               StAnD-By-KiNi",10
	dc.b "             MiNiDiScO                             BeTwEeN 2 WaTeRs",10
	dc.b "              NeSqUiK                                  MaDnEsS",10
	dc.b "         MoNsIeUr LaMpIsTe                         SoLiTaRy BrOtHa",10
	dc.b "        BaMsE I TrOlLsKoGeN                          °1ThE SiDeShOw",10
	dc.b 10
	dc.b 10
	dc.b "        Module Informations",0

MovementStory_Edito
	dc.b 10
	dc.b 10
	dc.b "°2Grumpf... And now, a bit of history!!!      °2HAPPY BIRTHDAY MOVEMENT!",10
	dc.b 10
	dc.b "°1Yeah! This part is left for your group    °3Yep! It took only one year to this",10
	dc.b "°1You can tell here everything about YOUR  °3bunch of cool guys to reach the top!",10
	dc.b "°1crew: °2birth, members, demos, projects    °3So enjoy that trip thought MOVEMENT",10
	dc.b "and much much more °1!! Well...In fact          °3first year of existence",10
	dc.b "°1everything you'd like to say about it.      °1The great 911 welcomes you!",10
	dc.b 10
	dc.b "                                                 °2HiStOrY AnD MeMbErS",10
	dc.b "  °3If you are interested in such a thing",10
	dc.b "      °3then send an article to:                     °2WhO DiD WhAt!?",10
	dc.b 10
	dc.b "              LIVE WHQ",10
	dc.b "         10.BD LOUIS BLANC",10
	dc.b "            19100 BRIVE",10
	dc.b "               FRANCE",0


	section toto,data_c
*******************************************************************************
**************************  TOUS LES ARTICLES DE LIVE  ************************
*******************************************************************************
	include "Art_Macros.i"
	include "HandleStory.ART"
	include "FirstWords.ART"
	include "Credits.ART"
	include "FishAndTips.ART"
	include "BackStage.ART"
	include "NewsAndRumours.ART"
	include "HowToSupport.ART"
	include "DesignIt.ART"
	include "Address.ART"
	include "LastWords.ART"
	include "Sex.ART"
	include "StupidSwappers.ART"
	include "SF.ART"
	include "OfficialSpreaders.ART"
	include "Gathering.ART"
	include "MovementStory.ART"
	include "PartyIII.ART"
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
	dc.w bplcon3,$2				BRDSPR
	dc.w bplcon4,$11
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

BarreBack0
	incbin "Dzign0_BarreBack.RAW"
Barre0
	incbin "Dzign0_Barre.RAW"


* INCLUSION DU DZIGN #2
* ~~~~~~~~~~~~~~~~~~~~~
DZign1_Top
	incbin "DZign1_Top.RAW"

DZign1_Bottom
	incbin "DZign1_Bottom.RAW

DZign1_border_left0
	include "DZign1_border_left0.s"

DZign1_border_left1
	include "DZign1_border_left1.s"

DZign1_border_right0
	include "DZign1_border_right0.s"

DZign1_border_right1
	include "DZign1_border_right1.s"

BarreBack1
	incbin "Dzign1_BarreBack.RAW"
Barre1
	incbin "DZign1_Barre.RAW"


* Gfx pour le look de live
* ~~~~~~~~~~~~~~~~~~~~~~~~
BarreMask
	dcb.b SCREEN_WIDTH*2*SCREEN_DEPTH,$ff

BackGround
	incbin "BackGround.RAW"

DRD_Coplist
	dc.w fmode,$0
	dc.w bplcon0,$4200|$8000
	dc.w bplcon1,$0
	dc.w bplcon2,$0
	dc.w bplcon3,$0
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w ddfstrt,$003c
	dc.w ddfstop,$00d4
	dc.w bpl1mod,80*3
	dc.w bpl2mod,80*3
DRD_Ptrs
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.w bpl3ptH,0
	dc.w bpl3ptL,0
	dc.w bpl4ptH,0
	dc.w bpl4ptL,0
DRD_Colors
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

Titlepic_Coplist
	dc.w fmode,$0
	dc.w bplcon0,$6200
	dc.w bplcon1,$0
	dc.w bplcon2,$0
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w ddfstrt,$0038
	dc.w ddfstop,$00d0
	dc.w bpl1mod,40*5
	dc.w bpl2mod,40*5
Titlepic_Ptrs
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
	dc.w bpl6ptH,0
	dc.w bpl6ptL,0
Titlepic_Colors
	dc.w color00,$300
	dc.w color01,$300
	dc.w color02,$300
	dc.w color03,$300
	dc.w color04,$300
	dc.w color05,$300
	dc.w color06,$300
	dc.w color07,$300
	dc.w color08,$300
	dc.w color09,$300
	dc.w color10,$300
	dc.w color11,$300
	dc.w color12,$300
	dc.w color13,$300
	dc.w color14,$300
	dc.w color15,$300
	dc.w color16,$300
	dc.w color17,$300
	dc.w color18,$300
	dc.w color19,$300
	dc.w color20,$300
	dc.w color21,$300
	dc.w color22,$300
	dc.w color23,$300
	dc.w color24,$300
	dc.w color25,$300
	dc.w color26,$300
	dc.w color27,$300
	dc.w color28,$300
	dc.w color29,$300
	dc.w color30,$300
	dc.w color31,$300
	dc.l $fffffffe

	section fea,bss_c
Board_Top
	ds.b SCREEN_WIDTH*(PART2-PART1)*SCREEN_DEPTH
Board_Middle1
	ds.b SCREEN_WIDTH*SCREEN_Y*SCREEN_DEPTH
	ds.b SAFETY_MARGIN
Board_Middle2
	ds.b SCREEN_WIDTH*(PART3-PART2)*SCREEN_DEPTH
pp_space
	ds.b 25*1024				on decrunch les images ici
