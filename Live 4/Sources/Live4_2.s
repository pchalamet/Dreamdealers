  
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
ZIK=ON


* EQU pour les ecrans de LIVE
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~
NB_DZIGN=2
SCREEN_X=640
SCREEN_Y=256
SCREEN_WIDTH=SCREEN_X/8
SCREEN_DEPTH=4
NB_COLORS=1<<SCREEN_DEPTH
PART1=0
PART2=19
PART3=PART2+195
PAGE_X=76
PAGE_Y=21
NUMBER_END=61
NUMBER_POS=57

* Définitions des structures utilisées dans LIVE
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	rsreset
GadgetStruct	rs.b 0
gs_Left		rs.w 1
gs_Top		rs.w 1
gs_Right	rs.w 1
gs_Bottom	rs.w 1
gs_Button	rs.w 1
gs_Type		rs.w 1
gs_Routine	rs.l 1			/GadgetStruct
gs_SIZEOF	rs.b 0

	rsreset
ShortCutStruct	rs.b 0
scs_Code	rs.b 1
scs_Type	rs.b 1
scs_Routine	rs.l 1			/ShortCutStruct
scs_SIZEOF	rs.b 0

	rsreset
BobStruct	rs.b 0
bs_CoordX	rs.w 1			* CoordX réelle pour un Gadget mais
bs_CoordY	rs.w 1			* CoordX pointant sur un mot pour ClipArt
bs_BltSize	rs.w 1
bs_Modulo	rs.w 1
bs_PackedData	rs.l 1			/BobStruct
bs_SIZEOF	rs.b 0

	rsreset
PackStruct	rs.b 0
ps_PackedSize	rs.w 1
ps_UnpackedSize	rs.w 1
ps_Data		rs.b 0

	rsreset
MenuStruct	rs.b 0
ms_ExtraRender	rs.l 1			en retour: d0=ColorMap
ms_Text		rs.l 1
ms_BarText	rs.l 1
ms_MenuPos	rs.w 1
ms_DefLMenu	rs.l 1			le menu existe ?
ms_DefLMenuType	rs.l 1			type du menu  1=SubMenu  0=Routine
ms_LPtrs	rs.l 21			ptrs pour le type de menu
ms_DefRMenu	rs.l 1
ms_DefRMenuType	rs.l 1
ms_RPtrs	rs.l 21
ms_SIZEOF	rs.b 0

	rsreset
DZign_Struct	rs.b 0			*** TOUT pointe vers la CHIP ***
dz_Top		rs.l 1			ptr sur le haut
dz_Bottom	rs.l 1			ptr sur le bas
dz_Mouse	rs.l 1			ptr sur la souris
dz_Border0	rs.l 1			ptr sprite gauche pair
dz_Border1	rs.l 1			ptr sprite gauche impair
dz_Border2	rs.l 1			ptr sprite droit pair
dz_Border3	rs.l 1			ptr sprite droit impair
dz_Colors0	rs.w NB_COLORS		table des couleurs ecrans
dz_Colors1	rs.w 16			table des couleurs sprites
dz_SIZEOF	rs.b 0

	rsreset
pp_Struct	rs.b 0
pp_Colors	rs.w NB_COLORS		valable uniquement pour le cliparts
pp_Datas	rs.b 0

	rsreset
Font_Struct	rs.b 0
fs_Size		rs.w 1			la taille de la fonte
fs_Chars	rs.b 94*8		datas des lettres
fs_SIZEOF	rs.b 0

* EQU en tous genres
* ~~~~~~~~~~~~~~~~~~
LEFT_MB=$ff00
RIGHT_MB=$00ff
DEFERED=-1
IMMEDIATE=0
BACKGROUND_COLOR=$234
NO_SHORTCUT=$f0


* Définitions des macros
* ~~~~~~~~~~~~~~~~~~~~~~
START_HITBOX	macro
	dc.w (.end_hitbox-*-2)/gs_SIZEOF-1
	endm

END_HITBOX	macro
.end_hitbox
	endm

* DEF_HITBOX coordX1,coordY1,LargeX,HautY,buttons,type,routine
DEF_HITBOX	macro
.gadget\@
	dc.w \1,\2,\1+\3-1,\2+\4-1,\5,\6
	dc.l \7-.gadget\@
	endm

START_SHORTCUT	macro
	dc.w (.end_shortcut-*-2)/scs_SIZEOF-1
	endm

END_SHORTCUT	macro
.end_shortcut
	endm

* DEF_SHORTCUT key_code,type,routine
DEF_SHORTCUT	macro
.shortcut\@
	dc.b \1,\2
	dc.l \3-.shortcut\@
	endm

* DEF_GADGET coordX,coordY,sizeX,sizeY,ClipArt
DEF_GADGET	macro
.bob\@
	dc.w \1,\2
	dc.w (\4*SCREEN_DEPTH<<6)!((\3+16+15)>>4)
	dc.w SCREEN_WIDTH-((\3+16+15)>>3)&$fffe
	dc.l \5-.bob\@
	endm

* DEF_CLIPART NAME,sizeX,sizeY
DEF_CLIPART	macro
COUNT_CLIPART set COUNT_CLIPART+1
\1=COUNT_CLIPART
.bob\@
	dc.w 0,0
	dc.w (\3*SCREEN_DEPTH<<6)!((\2+15)>>4)
	dc.w SCREEN_WIDTH-((\2+15)>>3)&$fffe
	dc.l Bob_\1-.bob\@
	endm

WAIT_VBL	macro
	st Vbl_Flag-data_base(a5)
.wait_vbl\@
	tst.b Vbl_Flag-data_base(a5)
	bne.s .wait_vbl\@
	endm

WAIT_FADE_OUT	macro
.wait_fade\@
	WAIT_VBL
	cmp.w #9,Fade_Offset-data_base(a5)
	bne.s .wait_fade\@
	endm

WAIT_FADE_IN	macro
.wait_fade\@
	WAIT_VBL
	tst.w Fade_Offset-data_base(a5)
	bne.s .wait_fade\@
	endm

ALLOC_BLITTER	macro
	move.l a6,-(sp)
	move.l _GfxBase(pc),a6
	CALL OwnBlitter
	CALL WaitBlit
	move.l (sp)+,a6
	ENDM

FREE_BLITTER	macro
	move.l a6,-(sp)
	move.l _GfxBase(pc),a6
	CALL WaitBlit
	CALL DisownBlitter
	move.l (sp)+,a6
	ENDM


* Point d'entrée de LIVE
* ~~~~~~~~~~~~~~~~~~~~~~
	section LiveMain,code

Live_Entry_Point

	lea data_base(pc),a5
	move.l (_SysBase).w,a6
	move.l a6,_ExecBase-data_base(a5)	ExecBase en FAST !!
	move.l sp,save_SP-data_base(a5)

	move.l ThisTask(a6),a1			recherche notre tache
	move.l a1,Live_Task-data_base(a5)

	move.l pr_WindowPtr(a1),old_WindowPtr-data_base(a5)
	moveq #-1,d0				pu de requester !!!
	move.l d0,pr_WindowPtr(a1)

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

	lea LivePowerpackerName(pc),a1		ouvre la powerpacker.library
	moveq #0,d0
	CALL OpenLibrary
	move.l d0,_PowerpackerBase-data_base(a5)
	beq LIVE_FAIL_POWERPACKER

	lea Live_Requester(pc),a0
	move.w #2,(a0)				frq_VersionNumber
	move.l #Live_Req_Title,2(a0)		frq_Title
	move.l #DOS_Module_Path,6(a0)		frq_Dir
	move.l #DOS_Module_Name,14(a0)		frq_PathName
	move.w #2,$22(a0)			frq_dirnamescolor

	lea LiveIntuitionName(pc),a1		ouvre l'intuition.library
	moveq #0,d0
	CALL OpenLibrary
	move.l d0,_IntuitionBase-data_base(a5)
	beq LIVE_FAIL_INTUITION

	lea VblIntStruct(pc),a1			ajoute un server VBL
	moveq #INTB_VERTB,d0
	CALL AddIntServer

	jsr NEv_start				vire les events

	IFNE ZIK
	lea Live_Start_Module(pc),a0
	bsr Load_Module
	jsr SetCIAInt
	jsr mt_init				init la musique
	ENDC


* decrunchage du MistraLogo de Tony
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Do_Show
	lea MistraLogo_End,a0
	lea Board_Middle1,a1
	lea MistraLogo,a2
	bsr Decrunch_pp

	lea data_base(pc),a5
	lea custom_base,a6

	move.l #Board_Middle1,d0
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

* Decrunch le Clown de RA pendant kon affiche le MistraLogo
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea Clown_End,a0
	lea Board_Middle2,a1
	lea Clown,a2
	bsr Decrunch_pp

	lea data_base(pc),a5
	lea custom_base,a6

	move.l #Board_Middle2,d0
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



* Gestion des pages cyclantes pour les Name/Pays...
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MenuFromName
	move.w #FROM_NAME,OptionNumber-data_base(a5)
	bra.s Menu_Messages_start
MenuFromGroup
	move.w #FROM_GROUP,OptionNumber-data_base(a5)
	bra.s Menu_Messages_start
MenuFromCountry
	move.w #FROM_COUNTRY,OptionNumber-data_base(a5)
	bra.s Menu_Messages_start
MenuForName
	move.w #FOR_NAME,OptionNumber-data_base(a5)
	bra.s Menu_Messages_start
MenuForGroup
	move.w #FOR_GROUP,OptionNumber-data_base(a5)
	bra.s Menu_Messages_start
MenuForCountry
	move.w #FOR_COUNTRY,OptionNumber-data_base(a5)
Menu_Messages_start
	move.l #MsgPtr,ListPtr-data_base(a5)
	bsr Clear_HighLight

	st Fade_Flag-data_base(a5)		fade out demandé !
	sf Flip_Flag-data_base(a5)
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)
	clr.b OptionStr-data_base(a5)		efface ces chaines C !!!
	clr.b SearchStr-data_base(a5)
	bsr BackGround_Middle_Screen

	move.w OptionNumber(pc),d0
	bsr Get_MsgPtr

	lea MsgPtr(pc),a0			installation de la barre
	moveq #-1,d0
.count
	tst.l (a0)+
	dbeq d0,.count
	not.l d0
	add.w #(PAGE_Y-2+PAGE_Y-2-4)-1,d0
	divu #(PAGE_Y-2+PAGE_Y-2-4),d0
	move.w d0,NbPages-data_base(a5)
	clr.w Barre_Result-data_base(a5)
	bsr Render_Barre
	bra.s Display_Menu_Messages

Next_Menu_Page
	bsr Clear_HighLight
	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)
	bsr Render_Barre
	bsr BackGround_Middle_Screen

Display_Menu_Messages
	bsr Build_ListText
	lea ListMenuText,a0
	moveq #2,d0
	bsr Display_Text_Menu

	WAIT_FADE_OUT
	move.l #BackGround_Colors,ColorMap_hook-data_base(a5)
	sf Fade_Flag-data_base(a5)
	st Flip_Flag-data_base(a5)
	move.l #ListMenu,Menu_hook-data_base(a5)
	WAIT_FADE_IN
MenuMessageLoop
	WAIT_VBL
	tst.b Go_Left_Flag-data_base(a5)
	beq.s .no_left
	move.l ListPtr(pc),a0
	cmp.l #MsgPtr,a0
		bls.s .no_right
	lea -(PAGE_Y-2+PAGE_Y-2-4)*4(a0),a0
	move.l a0,ListPtr-data_base(a5)
	subq.w #1,Barre_Result-data_base(a5)
	bra Next_Menu_Page
.no_left
	tst.b Go_Right_Flag-data_base(a5)
	beq.s .no_right
	move.l ListPtr(pc),a0
	moveq #(PAGE_Y-2+PAGE_Y-2-4)-1,d0
.gogo
	tst.l (a0)+
	dbeq d0,.gogo
	beq.s .no_right
	move.l a0,ListPtr-data_base(a5)
	addq.w #1,Barre_Result-data_base(a5)
	bra Next_Menu_Page
.no_right
	clr.w Go_Left_Flag-data_base(a5)
	tst.b Barre_Flag-data_base(a5)
	beq.s .no_barre
	move.w Barre_Result(pc),d0
	mulu #(PAGE_Y-2+PAGE_Y-2-4)*4,d0
	lea MsgPtr(pc),a0
	add.l d0,a0
	move.l a0,ListPtr-data_base(a5)
	bra Next_Menu_Page
.no_barre
	bsr gestion_shortcuts
	bsr gestion_menus
	bsr gestion_gadgets
	bra.s MenuMessageLoop

* Construction de la page de texte pour les menus Name etc...
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Build_ListText
	lea ListMenuText+2,a0			efface le text PAGE_X*PAGE_Y
	move.w #(PAGE_X+1)*PAGE_Y-1,d0
	move.b #" ",d1
.clear
	move.b d1,(a0)+
	dbf d0,.clear

	lea ListMenuText+2+PAGE_X+1,a0		met des chr$(10) en fin de ligne!
	moveq #PAGE_Y-1,d0
	moveq #10,d1
.return
	move.b d1,(a0)
	lea PAGE_X+1(a0),a0
	dbf d0,.return
	clr.b -(PAGE_X+1)(a0)			met un 0 à la fin

	lea ListMenuText+2+PAGE_X+1+1,a0	construit la partie de gauche
	move.l ListPtr(pc),a1
	moveq #PAGE_Y-2,d7
	bsr.s Build_Part
	move.l d1,List_Flag1
	lea ListMenuText+2+PAGE_X+1+PAGE_X/2+3,a0	puis la partie de droite
	moveq #PAGE_Y-2-4,d7
	bsr.s Build_Part
	move.l d1,List_Flag2
	rts

Build_Part
	moveq #0,d0				nbre de menu
.build_all
	move.l (a1)+,d1				pointeur nom
	beq.s .end				c'est la fin de la liste ?
	cmp.w d7,d0				nombre de menu
	beq.s .end				en bas de l'écran ??
	addq.w #1,d0				et ho! encore une nouvelle entrée

	move.l d1,a3				*nom du menu

	move.l d1,a4
	moveq #PAGE_X/2,d1
.size
	tst.b (a4)+
	dbeq d1,.size
	lsr.w #1,d1
	lea (a0,d1.w),a2			*text
.dup
	move.b (a3)+,(a2)+
	bne.s .dup
	move.b #" ",-1(a2)
	lea PAGE_X+1(a0),a0			ligne suivante
	bra.s .build_all
.end
	moveq #0,d1
.make
	bset d0,d1
	dbf d0,.make
	bclr #0,d1				vire le bit 0... arf!!!
	subq.l #4,a1				revient en arrière...
	rts




* gestion des accés directs aux messages
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MenuForEverybody
	move.w #FOR_NAME,OptionNumber-data_base(a5)
	lea EverybodyStr(pc),a0
	clr.b SearchStr-data_base(a5)
	bra Read_Selected_branch
MenuForMembers
	move.w #FOR_NAME,OptionNumber-data_base(a5)
	lea MembersStr(pc),a0
	clr.b SearchStr-data_base(a5)
	bra Read_Selected_branch
MenuForContacts
	move.w #FOR_NAME,OptionNumber-data_base(a5)
	lea ContactsStr(pc),a0
	clr.b SearchStr-data_base(a5)
	bra Read_Selected_branch

EverybodyStr
	dc.b "EVERYBODY",0
MembersStr
	dc.b "ALL MEMBERS",0
ContactsStr
	dc.b "ALL CONTACTS",0
	even



******************************************************************************
************** REQUESTER D'UNE CHAINE DE CHAR DANS LES MESSAGES **************
******************************************************************************
StringSearch
	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)
	bsr BackGround_Middle_Screen

	lea StringSearch_Edito,a0
	moveq #2,d0
	bsr Display_Text_Menu

	clr.b OptionStr-data_base(a5)
	clr.b SearchStr-data_base(a5)		efface cette chaine C !!!
	clr.w SearchStr_Pos-data_base(a5)
	move.w #SEARCH_WHOLE,OptionNumber-data_base(a5)

	WAIT_FADE_OUT
	move.l #BackGround_Colors,ColorMap_hook-data_base(a5)
	sf Fade_Flag-data_base(a5)
	st Flip_Flag-data_base(a5)
	WAIT_FADE_IN

StringSearch_Loop
	WAIT_VBL
	bsr gestion_gadgets

	bsr GetKey				lit une touche
	bmi.s StringSearch_Loop

	cmp.b #$41,d0				backspace ?
	bne.s .not_backspace
	subq.w #1,SearchStr_Pos-data_base(a5)
	bge.s .ok
	clr.w SearchStr_Pos-data_base(a5)
.ok	move.w SearchStr_Pos(pc),d0
	lea SearchStr,a0
	clr.b (a0,d0.w)
	bra.s .display_string
.not_backspace
	cmp.b #$44,d0				enter ?
	bne.s .not_enter

	lea LiveMsg(pc),a0			regarde voir si ya des messages
	lea Next_Rout(pc),a1
	bsr Get_Msg
	bne Read_Selected_branch		oui ?
	bra.s StringSearch_Loop			nan...

.not_enter
	lea KeyBoard_ASCII,a0			met la touche en ASCII
	move.b (a0,d0.w),d0			ou 0 si pas bonne
	beq.s StringSearch_Loop

	move.w SearchStr_Pos(pc),d1		met la touche dans le buffer
	lea SearchStr,a0			de chaine
	move.b d0,(a0,d1.w)
	clr.b 1(a0,d1.w)

	addq.w #1,d1
	cmp.w #MAXSTR,d1
	beq.s .display_string
	move.w d1,SearchStr_Pos-data_base(a5)
.display_string
	move.l phy_screen(pc),a2
	add.l #SCREEN_WIDTH*SCREEN_DEPTH*98+30+SCREEN_WIDTH,a2
	ALLOC_BLITTER
	WAIT_VBL
	move.l a2,bltdpt(a6)
	move.w #SCREEN_WIDTH*(SCREEN_DEPTH-1)+(SCREEN_WIDTH-20),bltdmod(a6)
	move.l #$01000000,bltcon0(a6)
	move.w #(8<<6)|(20/2),bltsize(a6)
	FREE_BLITTER

	lea SearchStr,a0
	moveq #"1",d7
	bsr Display_Text_Message

	bra StringSearch_Loop


* Gestion des clicks menus pour les pages Name etc...
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
List_LMenu0
	moveq #0,d0
	bra Read_Selected
List_LMenu1
	moveq #1*4,d0
	bra Read_Selected
List_LMenu2
	moveq #2*4,d0
	bra Read_Selected
List_LMenu3
	moveq #3*4,d0
	bra Read_Selected
List_LMenu4
	moveq #4*4,d0
	bra Read_Selected
List_LMenu5
	moveq #5*4,d0
	bra Read_Selected
List_LMenu6
	moveq #6*4,d0
	bra Read_Selected
List_LMenu7
	moveq #7*4,d0
	bra Read_Selected
List_LMenu8
	moveq #8*4,d0
	bra.s Read_Selected
List_LMenu9
	moveq #9*4,d0
	bra.s Read_Selected
List_LMenu10
	moveq #10*4,d0
	bra.s Read_Selected
List_LMenu11
	moveq #11*4,d0
	bra.s Read_Selected
List_LMenu12
	moveq #12*4,d0
	bra.s Read_Selected
List_LMenu13
	moveq #13*4,d0
	bra.s Read_Selected
List_LMenu14
	moveq #14*4,d0
	bra.s Read_Selected
List_LMenu15
	moveq #15*4,d0
	bra.s Read_Selected
List_LMenu16
	moveq #16*4,d0
	bra.s Read_Selected
List_LMenu17
	moveq #17*4,d0
	bra.s Read_Selected
List_LMenu18
	moveq #18*4,d0
	bra.s Read_Selected

List_RMenu0
	moveq #19*4,d0
	bra.s Read_Selected
List_RMenu1
	moveq #20*4,d0
	bra.s Read_Selected
List_RMenu2
	moveq #21*4,d0
	bra.s Read_Selected
List_RMenu3
	moveq #22*4,d0
	bra.s Read_Selected
List_RMenu4
	moveq #23*4,d0
	bra.s Read_Selected
List_RMenu5
	moveq #24*4,d0
	bra.s Read_Selected
List_RMenu6
	moveq #25*4,d0
	bra.s Read_Selected
List_RMenu7
	moveq #26*4,d0
	bra.s Read_Selected
List_RMenu8
	moveq #27*4,d0
	bra.s Read_Selected
List_RMenu9
	moveq #28*4,d0
	bra.s Read_Selected
List_RMenu10
	moveq #29*4,d0
	bra.s Read_Selected
List_RMenu11
	moveq #30*4,d0
	bra.s Read_Selected
List_RMenu12
	moveq #31*4,d0
	bra.s Read_Selected
List_RMenu13
	move.w #32*4,d0
	bra.s Read_Selected
List_RMenu14
	move.w #33*4,d0
	bra.s Read_Selected
List_RMenu15
	move.w #34*4,d0
	bra.s Read_Selected
List_RMenu16
	move.w #35*4,d0
	bra.s Read_Selected
List_RMenu17
	move.w #36*4,d0
	bra.s Read_Selected
List_RMenu18
	move.w #37*4,d0

* Lecture d'une série de messages
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Read_Selected
	move.l ListPtr(pc),a0
	move.l (a0,d0.w),a0			pointe le nom du menu
Read_Selected_branch
	lea OptionStr(pc),a1
.dup	move.b (a0)+,(a1)+			recopie le nom du menu
	bne.s .dup

	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)

	bsr Count_Msg
	move.w d7,NbPages-data_base(a5)
	clr.w Barre_Result-data_base(a5)

	lea ReadMessage_BarText,a0
	bsr Dup_Text_Barre

	moveq #0,d0				écrit le nombre de messages
	move.w d7,d0
	lea Text_Barre+NUMBER_END(pc),a0
	bsr Write_Number

	lea LiveMsg(pc),a0			cherche le 1er message.. il
	lea Next_Rout(pc),a1			existe toujours !!!
	bsr Get_Msg

TeufTeuf
	move.l a0,MessPtr-data_base(a5)

	lea Text_Barre+NUMBER_POS(pc),a0	affiche la barre
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre

	bsr Render_Barre
	bsr Clear_Middle_Screen
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)

	pea BackGround_Colors(pc)

	lea ClipArts_List,a0			ptr sur la liste des ClipArts
	move.l MessPtr(pc),a1			ptr sur le message
	moveq #0,d0
	move.b (a1)+,d0
	subq.w #NO_CLIPART+1,d0			ya un clipart ?
	blt.s .no_clipart
	
	mulu #bs_SIZEOF,d0			choppe la structure ClipArt
	lea (a0,d0.l),a0
	move.b (a1)+,bs_CoordX+1(a0)
	move.b (a1)+,bs_CoordY+1(a0)
	move.l log_screen(pc),a1
	bsr put_clipart

	lea pp_space+2,a0			recopie les couleurs
	lea Temp_Colors,a1
	move.l a1,(sp)				ecrase BackGround_Colors
	move.w #BACKGROUND_COLOR,(a1)+		pas touche color 0
	moveq #NB_COLORS-1-1,d0
.dup	move.w (a0)+,(a1)+
	dbf d0,.dup
.no_clipart

* Affiche de FROM: Name/Group/Country
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea MsgText_From,a0
	move.l log_screen(pc),a2
	lea SCREEN_WIDTH*SCREEN_DEPTH*(4+4)+20(a2),a2
	moveq #"1",d7
	bsr Display_Text_Message

	move.l MessPtr(pc),a0
	lea SKIP_CLIPART(a0),a0
	lea SCREEN_WIDTH(a2),a2
	moveq #"2",d7
	bsr Display_Text_Message

	pea (a0)
	lea MsgText_Slash,a0
	bsr Display_Text_Message

	move.l (sp)+,a0
	bsr Display_Text_Message

	pea (a0)
	lea MsgText_Slash,a0
	bsr Display_Text_Message

	move.l (sp)+,a0
	bsr Display_Text_Message

* Affiche de FOR: Name/Group/Country
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	pea (a0)
	lea MsgText_For,a0
	move.l log_screen(pc),a2
	lea SCREEN_WIDTH*SCREEN_DEPTH*(4+4+8)+20(a2),a2
	moveq #"1",d7
	bsr Display_Text_Message

	move.l (sp)+,a0
	lea SCREEN_WIDTH(a2),a2
	moveq #"2",d7
	bsr Display_Text_Message

	pea (a0)
	lea MsgText_Slash,a0
	bsr Display_Text_Message

	move.l (sp)+,a0
	bsr Display_Text_Message

	pea (a0)
	lea MsgText_Slash,a0
	bsr Display_Text_Message

	move.l (sp)+,a0
	bsr Display_Text_Message
	
* Affichage du message lui-même
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l log_screen(pc),a2
	lea SCREEN_WIDTH*SCREEN_DEPTH*(4+4+8+8+16)+4(a2),a2
	moveq #"1",d7
	bsr Display_Text_Message

	WAIT_FADE_OUT
	move.l (sp)+,ColorMap_hook-data_base(a5)

	sf Fade_Flag-data_base(a5)
	st Flip_Flag-data_base(a5)
	WAIT_FADE_IN
Main
	WAIT_VBL
	bsr gestion_shortcuts
	bsr gestion_gadgets

	tst.b Go_Left_Flag-data_base(a5)	gestion des toutouches
	beq.s .no_left
	move.l MessPtr(pc),a0
	lea Previous_Rout(pc),a1
	bsr Get_Msg
	beq.s .no_right
	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)
	subq.w #1,Barre_Result-data_base(a5)
	bra TeufTeuf
.no_left
	tst.b Go_Right_Flag-data_base(a5)
	beq.s .no_right
	move.l MessPtr(pc),a0
	lea Next_Rout(pc),a1
	bsr Get_Msg
	beq.s .no_right
	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)
	addq.w #1,Barre_Result-data_base(a5)
	bra TeufTeuf
.no_right
	clr.w Go_Left_Flag-data_base(a5)
	tst.b Barre_Flag-data_base(a5)
	beq Main

	move.w Barre_Result(pc),d7
	bsr Get_Msg_X
	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)
	bra TeufTeuf


******************************************************************************
********************************* LA GALLERY *********************************
******************************************************************************
Gallery
	lea Gallery_BarText,a0
	bsr Dup_Text_Barre

	lea Gallery_List+1,a0
	move.l a0,Gallery_Ptr-data_base(a5)
	moveq #-1,d0
.count
	addq.w #1,d0
	tst.b (a0)+
	bne.s .count
	move.w d0,NbPages-data_base(a5)
	clr.w Barre_Result-data_base(a5)

	lea Text_Barre+NUMBER_END(pc),a0	ecrit le nombre de page
	ext.l d0
	bsr Write_Number

Display_Gallery
	sf Flip_Flag-data_base(a5)
	st Fade_Flag-data_base(a5)
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)
	bsr Clear_Middle_Screen

	lea Text_Barre+NUMBER_POS(pc),a0	écrit le numero de la page
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre			affiche la barre du haut
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre
	
	move.l Gallery_Ptr(pc),a0
	moveq #0,d0
	move.b (a0),d0
	subq.w #NO_CLIPART+1,d0
	lea ClipArts_List,a0
	mulu #bs_SIZEOF,d0
	lea (a0,d0.l),a0
	move.w bs_BltSize(a0),d0
	and.w #%111111,d0
	sub.w #SCREEN_WIDTH/2,d0
	neg.w d0
	lsr.w #1,d0
	move.w d0,bs_CoordX(a0)

	move.w bs_BltSize(a0),d0
	lsr.w #6,d0				vire SizeX, SizeY*4, divise par 2
	lsr.w #3,d0
	sub.w #(PART3-PART2)/2,d0
	neg.w d0
	move.w d0,bs_CoordY(a0)

	move.l log_screen(pc),a1
	bsr put_clipart

	bsr Render_Barre
	WAIT_FADE_OUT
	lea pp_space+2,a0
	lea Temp_Colors(pc),a1
	move.l a1,ColorMap_hook-data_base(a5)
	move.w #BACKGROUND_COLOR,(a1)+
	moveq #NB_COLORS-1-1,d0
.dup
	move.w (a0)+,(a1)+
	dbf d0,.dup

	st Flip_Flag-data_base(a5)
	sf Fade_Flag-data_base(a5)
	WAIT_FADE_IN

Gallery_Events
	WAIT_VBL
	bsr gestion_shortcuts
	bsr gestion_gadgets

	tst.b Go_Right_Flag-data_base(a5)
	beq.s .no_right
	clr.b Go_Right_Flag-data_base(a5)
	move.l Gallery_Ptr(pc),a0
	tst.b 1(a0)
	beq.s Gallery_Events
	addq.l #1,Gallery_Ptr-data_base(a5)
	addq.w #1,Barre_Result-data_base(a5)
	bra Display_Gallery
	
.no_right
	tst.b Go_Left_Flag-data_base(a5)
	beq.s .no_left
	clr.b Go_Left_Flag-data_base(a5)
	move.l Gallery_Ptr(pc),a0
	tst.b -1(a0)
	beq.s Gallery_Events
	subq.l #1,Gallery_Ptr-data_base(a5)
	subq.w #1,Barre_Result-data_base(a5)
	bra Display_Gallery

.no_left
	tst.b Barre_Flag-data_base(a5)
	beq.s Gallery_Events
	clr.b Barre_Flag-data_base(a5)

	move.w Barre_Result(pc),d0
	lea Gallery_List+1,a0
	lea (a0,d0.w),a0
	move.l a0,Gallery_Ptr-data_base(a5)
	bra Display_Gallery


* Gestion Adverts ( HAD & FAD )
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Adverts_Part1
	move.l #HalfAdverts_List+2,First_Page_Ptr-data_base(a5)
	lea AdvertPart1_BarText,a0
	bra Manage_Half_Pages

Adverts_Part2
	move.l #FullAdverts_List+2,First_Page_Ptr-data_base(a5)
	lea AdvertPart2_BarText,a0
	bra Manage_Full_Pages


* Tous les articles de LIVE
* ~~~~~~~~~~~~~~~~~~~~~~~~~
FirstWordsArticle
	move.l #FirstWords_Article+2,First_Page_Ptr-data_base(a5)
	lea FirstWords_BarText,a0
	bra Manage_Full_Pages

CreditsArticle
	move.l #Credits_Article+2,First_Page_Ptr-data_base(a5)
	lea CreditsIssue_BarText,a0
	bra Manage_Full_Pages

LiveStaffArticle
	move.l #LiveStaff_Article+2,First_Page_Ptr-data_base(a5)
	lea LiveStaff_BarText,a0
	bra Manage_Full_Pages

NewsA_FArticle
	move.l #NewsA_F_Article+2,First_Page_Ptr-data_base(a5)
	lea NewsA_F_BarText,a0
	bra Manage_Full_Pages

NewsG_MArticle
	move.l #NewsG_M_Article+2,First_Page_Ptr-data_base(a5)
	lea NewsG_M_BarText,a0
	bra Manage_Full_Pages

NewsN_ZArticle
	move.l #NewsN_Z_Article+2,First_Page_Ptr-data_base(a5)
	lea NewsN_Z_BarText,a0
	bra Manage_Full_Pages

DrdTestArticle_Questions
	move.l #DrdTest_Article_Questions+2,First_Page_Ptr-data_base(a5)
	lea DrdTest_BarText,a0
	bra Manage_Full_Pages

DrdTestArticle_Results
	move.l #DrdTest_Article_Results+2,First_Page_Ptr-data_base(a5)
	lea DrdTest_BarText,a0
	bra Manage_Full_Pages

FishAndTipsArticle
	move.l #FishAndTips_Article+2,First_Page_Ptr-data_base(a5)
	lea FishAndTips_BarText,a0
	bra Manage_Full_Pages

BackStageArticle
	move.l #BackStage_Article+2,First_Page_Ptr-data_base(a5)
	lea BackStage_BarText,a0
	bra Manage_Full_Pages

SaturnePartyReportArticle
	move.l #SaturnePartyReport_Article+2,First_Page_Ptr-data_base(a5)
	lea SaturneRepport_BarText,a0
	bra Manage_Full_Pages

SaturnePartyResultArticle
	move.l #SaturnePartyResult_Article+2,First_Page_Ptr-data_base(a5)
	lea SaturneResults_BarText,a0
	bra Manage_Full_Pages

DrdStoryArticle1
	move.l #DrdStory_Article1+2,First_Page_Ptr-data_base(a5)
	lea DrdStory_BarText,a0
	bra Manage_Full_Pages

DrdStoryArticle2
	move.l #DrdStory_Article2+2,First_Page_Ptr-data_base(a5)
	lea DrdStory_BarText,a0
	bra Manage_Full_Pages

DrdStoryArticle3
	move.l #DrdStory_Article3+2,First_Page_Ptr-data_base(a5)
	lea DrdStory_BarText,a0
	bra Manage_Full_Pages

DrdStoryArticle4
	move.l #DrdStory_Article4+2,First_Page_Ptr-data_base(a5)
	lea DrdStory_BarText,a0
	bra Manage_Full_Pages

DrdStoryArticle5
	move.l #DrdStory_Article5+2,First_Page_Ptr-data_base(a5)
	lea DrdStory_BarText,a0
	bra Manage_Full_Pages

DrdStoryArticle6
	move.l #DrdStory_Article6+2,First_Page_Ptr-data_base(a5)
	lea DrdStory_BarText,a0
	bra Manage_Full_Pages

HandleStoryArticle
	move.l #HandleStory_Article+2,First_Page_Ptr-data_base(a5)
	lea HandleStory_BarText,a0
	bra Manage_Full_Pages

SuntheticsArticle
	move.l #Sunthetics_Article+2,First_Page_Ptr-data_base(a5)
	lea Sunthetics_BarText,a0
	bra Manage_Full_Pages

HowToSupportArticle
	move.l #HowToSupport_Article+2,First_Page_Ptr-data_base(a5)
	lea HowToSupport_BarText,a0
	bra Manage_Full_Pages

DesignItArticle
	move.l #DesignIt_Article+2,First_Page_Ptr-data_base(a5)
	lea DesignIt_BarText,a0
	bra Manage_Full_Pages

AddressArticle
	move.l #Address_Article+2,First_Page_Ptr-data_base(a5)
	lea Address_BarText,a0
	bra Manage_Full_Pages

DreamLandsArticle
	move.l #DreamLands_Article+2,First_Page_Ptr-data_base(a5)
	lea DreamLands_BarText,a0
	bra Manage_Full_Pages

LastWordsArticle
	move.l #LastWords_Article+2,First_Page_Ptr-data_base(a5)
	lea LastWords_BarText,a0
	bra Manage_Full_Pages

HelpArticle
	move.l #Help_Article+2,First_Page_Ptr-data_base(a5)
	lea Help_BarText,a0
	bra Manage_Full_Pages


* Gestion des pages moitié écran
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Manage_Half_Pages
	bsr Dup_Text_Barre

	bsr Clear_HighLight
	move.l First_Page_Ptr(pc),Page_Ptr-data_base(a5)

	move.l Page_Ptr(pc),a0			compte les adverts
	moveq #0,d0
.count	addq.w #1,d0
	bsr Find_Next_Advert
	bne.s .count
	subq.w #1,d0
	move.w d0,NbPages-data_base(a5)
	clr.w Barre_Result-data_base(a5)

	lea Text_Barre+NUMBER_END(pc),a0	ecrit le nombre de page
	ext.l d0
	bsr Write_Number

HAD_Barre_Move
	sf Flip_Flag-data_base(a5)
	st Fade_Flag-data_base(a5)
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)
	bsr Clear_Middle_Screen

	lea Text_Barre+NUMBER_POS(pc),a0	écrit le numero de la page
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre			affiche la barre du haut
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre

	move.l Page_Ptr(pc),a0
	moveq #2,d0
	bsr Display_Text
	move.l Page_Ptr(pc),a0
	bsr Find_Next_Advert
	beq.s .one
	moveq #41,d0
	bsr Display_Text
.one
	bsr Render_Barre
	WAIT_FADE_OUT
	st Flip_Flag-data_base(a5)
	sf Fade_Flag-data_base(a5)
	WAIT_FADE_IN

gestion_HAD
	WAIT_VBL
	bsr gestion_shortcuts
	bsr gestion_gadgets

	tst.b Go_Left_Flag-data_base(a5)
	beq HAD_NoLeft

	clr.b Go_Left_Flag-data_base(a5)
	move.l Page_Ptr(pc),a0			recherche déja l'advert
	bsr Find_Previous_Advert		d'avant
	beq gestion_HAD
	pea (a0)
	bsr Find_Previous_Advert
	pea (a0)
	bne.s .display
	addq.w #1,Barre_Result-data_base(a5)
	move.l 4(sp),(sp)			met sur le coté gauche
	move.l Page_Ptr(pc),4(sp)		met sur coté droit
.display
	subq.w #2,Barre_Result-data_base(a5)
	sf Flip_Flag-data_base(a5)
	st Fade_Flag-data_base(a5)
	bsr Clear_Middle_Screen

	move.l (sp)+,a0
	move.l a0,Page_Ptr-data_base(a5)
	moveq #2,d0
	bsr Display_Text
	move.l (sp)+,a0
	moveq #41,d0
	bsr Display_Text

	lea Text_Barre+NUMBER_POS(pc),a0	écrit le numero de la page
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre			affiche la barre du haut
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre

	bsr Render_Barre
	WAIT_FADE_OUT
	st Flip_Flag-data_base(a5)
	sf Fade_Flag-data_base(a5)
	WAIT_FADE_IN
	bra gestion_HAD
	
HAD_NoLeft
	tst.b Go_Right_Flag-data_base(a5)
	beq HAD_NoRight

	clr.b Go_Right_Flag-data_base(a5)
	move.l Page_Ptr(pc),a0			recherche déja l'advert
	bsr Find_Next_Advert			d'apres
	beq gestion_HAD
	pea (a0)
	bsr Find_Next_Advert
	pea (a0)
	bne.s .ok
	addq.l #8,sp				nan => on se casse
	bra gestion_HAD
.ok
	bsr Find_Next_Advert
	beq.s .display
	move.l (sp),4(sp)
	move.l a0,(sp)
	addq.w #1,Barre_Result-data_base(a5)
.display
	addq.w #1,Barre_Result-data_base(a5)
	sf Flip_Flag-data_base(a5)
	st Fade_Flag-data_base(a5)
	bsr Clear_Middle_Screen

	move.l (sp)+,a0
	moveq #41,d0
	bsr Display_Text
	move.l (sp)+,a0
	move.l a0,Page_Ptr-data_base(a5)
	moveq #2,d0
	bsr Display_Text

	lea Text_Barre+NUMBER_POS(pc),a0	écrit le numero de la page
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre			affiche la barre du haut
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre

	bsr Render_Barre
	WAIT_FADE_OUT
	st Flip_Flag-data_base(a5)
	sf Fade_Flag-data_base(a5)
	WAIT_FADE_IN
	bra gestion_HAD

HAD_NoRight
	tst.b Barre_Flag-data_base(a5)
	beq gestion_HAD
	move.w Barre_Result(pc),d0
	move.l First_Page_Ptr(pc),a0
	bra.s .start
.search	bsr Find_Next_Advert
.start	dbf d0,.search
	move.l a0,Page_Ptr-data_base(a5)
	bra HAD_Barre_Move


Manage_Full_Pages
	bsr Dup_Text_Barre

	bsr Clear_HighLight
	move.l First_Page_Ptr(pc),Page_Ptr-data_base(a5)

	move.l Page_Ptr(pc),a0				compte les adverts
	moveq #0,d0
.count	addq.w #1,d0
	bsr Find_Next_Advert
	bne.s .count
	move.w d0,NbPages-data_base(a5)
	clr.w Barre_Result-data_base(a5)

	lea Text_Barre+NUMBER_END(pc),a0	ecrit le nombre de page
	ext.l d0
	bsr Write_Number

FAD_Barre_Move
	sf Flip_Flag-data_base(a5)
	st Fade_Flag-data_base(a5)
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)
	bsr Clear_Middle_Screen

	lea Text_Barre+NUMBER_POS(pc),a0	écrit le numero de la page
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre			affiche la barre du haut
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre

	move.l Page_Ptr(pc),a0			affiche l'article
	moveq #2,d0
	bsr Display_Text

	bsr Render_Barre

	WAIT_FADE_OUT
	st Flip_Flag-data_base(a5)
	sf Fade_Flag-data_base(a5)
	WAIT_FADE_IN

gestion_FAD
	WAIT_VBL
	bsr gestion_shortcuts
	bsr gestion_gadgets

	tst.b Go_Left_Flag-data_base(a5)
	beq.s FAD_NoLeft

	clr.b Go_Left_Flag-data_base(a5)
	move.l Page_Ptr(pc),a0			recherche déja l'advert
	bsr Find_Previous_Advert		d'avant
	beq gestion_FAD

	move.l a0,Page_Ptr-data_base(a5)
	subq.w #1,Barre_Result-data_base(a5)
	bra FAD_Barre_Move
	
FAD_NoLeft
	tst.b Go_Right_Flag-data_base(a5)
	beq.s FAD_NoRight

	clr.b Go_Right_Flag-data_base(a5)
	move.l Page_Ptr(pc),a0			recherche déja l'advert
	bsr Find_Next_Advert			d'apres
	beq gestion_FAD

	move.l a0,Page_Ptr-data_base(a5)
	addq.w #1,Barre_Result-data_base(a5)
	bra FAD_Barre_Move

FAD_NoRight
	tst.b Barre_Flag-data_base(a5)
	beq gestion_FAD
	move.w Barre_Result(pc),d0
	move.l First_Page_Ptr(pc),a0
	bra.s .start
.search	bsr.s Find_Next_Advert
.start	dbf d0,.search
	move.l a0,Page_Ptr-data_base(a5)
	bra FAD_Barre_Move

Page_Ptr
	dc.l 0
First_Page_Ptr
	dc.l 0


*****************************************************************************
************************* RECHERCHE DE L'ADVERT D'AVANT *********************
************************* en entrée: a0=ptr advert      *********************
************************* en sortie: a0=ptr advert      *********************
*****************************************************************************
Find_Previous_Advert
	subq.l #1,a0				pointe le 0 de fin d'advert
	tst.b -1(a0)				ya encore un 0 ?
	beq.s .no_previous
.loop_find_previous
	tst.b -(a0)				recherche l'advert d'avant
	bne.s .loop_find_previous
	addq.l #1,a0				saute le 0 trouvé
	moveq #-1,d0
.no_previous
	rts



*****************************************************************************
************************* RECHERCHE DE L'ADVERT D'APRES *********************
************************* en entrée: a0=ptr advert      *********************
************************* en sortie: a0=ptr advert      *********************
*****************************************************************************
Find_Next_Advert
	tst.b (a0)+				cherche le 0 suivant
	bne.s Find_Next_Advert
	tst.b (a0)				yen a un juste après ?
	rts





*****************************************************************************
*************************** GESTION DES MESSAGES ****************************
*****************************************************************************
	include "gestion_messages.s"


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
*************************     AFFICHAGE D'UN TEXT      **********************
************************* en entrée : a0=Text          **********************
*************************   messages: a2=*Ecran        **********************
*************************   messages: d7=couleur       **********************
*************************             d0=Offset ecran  **********************
*****************************************************************************
Display_Text
	move.l log_screen(pc),a2
	add.w #SCREEN_WIDTH*SCREEN_DEPTH*4,d0	saute qq lignes au début
	lea (a2,d0.w),a2			on écrit à partir d'ici
	move.w #"1",d7				couleur 1 par défaut
Display_Text_Message
	lea Fonts_List,a1			fonte par defaut
	move.l a1,Text_Font-data_base(a5)
	move.w fs_Size(a1),d1
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d1
	move.l d1,Text_Line_Offset-data_base(a5)
	move.l a2,Text_Origin-data_base(a5)
	move.l a2,Text_Margin-data_base(a5)
	move.l #SCREEN_WIDTH*SCREEN_DEPTH*9,Text_Line_Offset-data_base(a5)
loop_display_Text
	moveq #0,d0
	move.b (a0)+,d0				lit un char de l'advert
	beq.s .display_Text_exit		on sort ?
	cmp.b #10,d0				char return ?
	beq.s .Return
	cmp.b #"°",d0				on change de couleurs ?
	beq.s .Color
	cmp.b #"£",d0				on fait un locate ?
	beq.s .Locate
	cmp.b #9,d0				une tabulation ?
	beq .Tab
	cmp.b #"§",d0				changement de fonte ?
	beq .SetFont

	sub.b #"!",d0				! est la base des fontes
	blt.s .space				espace ?

	lsl.w #3,d0				mulu #8,d0
	lea fs_Chars(a1,d0.w),a3		pointe la bonne lettre
	move.b (a3)+,(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH*2(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH*3(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH*4(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH*5(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH*6(a2)
	move.b (a3),SCREEN_WIDTH*SCREEN_DEPTH*7(a2)
.space	addq.l #1,a2
	bra.s loop_display_Text
.display_Text_exit
	rts

.Return
	move.l Text_Margin(pc),a2
	add.l Text_Line_Offset(pc),a2
	move.l a2,Text_Margin-data_base(a5)
	bra.s loop_display_Text

.Color
	move.b (a0)+,d0				lit la couleur
	sub.w d7,d0
	beq.s loop_display_Text
	add.w d0,d7
	muls #SCREEN_WIDTH,d0			nouvel offset couleur
	add.l d0,a2
	add.l d0,Text_Margin-data_base(a5)
	bra loop_display_Text

.Locate
	move.l Text_Origin(pc),a2		SYNTAXE: £XX-YYY
	move.b (a0)+,d0				lit d'abord la position XX
	sub.b #"0",d0
	mulu.w #10,d0
	add.b (a0)+,d0
	sub.b #"0",d0
	lea (a2,d0.w),a2			LOCATE fait sur les X
	addq.l #1,a0				saute le '-'
	move.b (a0)+,d0				lit ensuite la position YYY
	sub.b #"0",d0
	mulu #100,d0
	moveq #0,d1
	move.b (a0)+,d1
	sub.b #"0",d1
	mulu #10,d1
	add.w d1,d0
	add.b (a0)+,d0
	sub.b #"0",d0
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d0
	move.w d7,d1
	sub.w #"0",d1
	mulu #SCREEN_WIDTH,d1
	add.l d1,d0
	lea (a2,d0.l),a2			locate fait sur les Y
	move.l a2,Text_Margin-data_base(a5)
	bra loop_display_Text

.Tab
	addq.l #8,a2
	bra loop_display_Text

.SetFont
	moveq #0,d0				lit le numero de la fonte
	move.b (a0)+,d0
	sub.b #"1",d0
	mulu #fs_SIZEOF,d0
	lea Fonts_List,a1
	lea (a1,d0.l),a1			datas de la fonte
	move.w fs_Size(a1),d0			calcule la taille de la fonte
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d0
	move.l d0,Text_Line_Offset-data_base(a5)
	bra loop_display_Text



*****************************************************************************
*************************      AFFICHAGE D'UN TEXT     **********************
*************************        pour les menus        **********************
************************* en entrée : a0=Text          **********************
*************************             d0=Offset ecran  **********************
*****************************************************************************
Display_Text_Menu
	lea Fonts_List,a1			fonte par defaut
	move.l a1,Text_Font-data_base(a5)
	move.w fs_Size(a1),d1
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d1
	move.l d1,Text_Line_Offset-data_base(a5)
	move.l log_screen(pc),a2
	add.w #SCREEN_WIDTH*SCREEN_DEPTH*4,d0	saute qq lignes au début
	lea (a2,d0.w),a2			on écrit à partir d'ici
	move.l a2,Text_Origin-data_base(a5)
	move.l a2,Text_Margin-data_base(a5)
	move.l #SCREEN_WIDTH*SCREEN_DEPTH*9,Text_Line_Offset-data_base(a5)
	move.w #"1",d7				couleur 1 par défaut
loop_display_Text_Menu
	moveq #0,d0
	move.b (a0)+,d0				lit un char de l'advert
	beq .display_Text_exit			on sort ?
	cmp.b #10,d0				char return ?
	beq .Return
	cmp.b #"°",d0				on change de couleurs ?
	beq .Color
	cmp.b #"£",d0				on fait un locate ?
	beq .Locate
	cmp.b #9,d0				une tabulation ?
	beq .Tab
	cmp.b #"§",d0				changement de fonte ?
	beq .SetFont

	sub.b #"!",d0				! est la base des fontes
	blt.s .space				espace ?

	lsl.w #3,d0				mulu #8,d0
	lea fs_Chars(a1,d0.w),a3		pointe la bonne lettre
	move.b (a3)+,d0
	or.b d0,(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*2(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*3(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*4(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*5(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*6(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*7(a2)

	move.b d7,d1				couleur actuelle
	sub.b #"1",d1
	moveq #-1,d0
	bclr d1,d0				BPL non utilisés par la couleur

	lea SCREEN_WIDTH*SCREEN_DEPTH*7(a2),a4	recherche le BPL 1
	tst.b d1				couleur 1 ?
	beq.s .do_not
	lea -SCREEN_WIDTH+SCREEN_WIDTH*SCREEN_DEPTH*7(a2),a4
	subq.b #1,d1				couleur 2 ?
	beq.s .do_not				sinon couleur 3
	lea -SCREEN_WIDTH*2+SCREEN_WIDTH*SCREEN_DEPTH*7(a2),a4
.do_not
	moveq #8-1,d1				8 lignes pour une lettre
.not_char
	move.b -(a3),d2				lit un octet de la lettre
	not.b d2				fabrication du mask de la lettre
	move.b d0,d3				mask BPL actuel

	moveq #3-1,d4				ya 3 BPL à masker
.not_line
	lsr.b #1,d3				il faut masker le bpl ?
	bcc.s .skip				nan...
	and.b d2,(a4)				bon.. on mask
.skip	lea SCREEN_WIDTH(a4),a4
	dbf d4,.not_line			boucle pour les 3 BPL
	lea -SCREEN_WIDTH*(SCREEN_DEPTH+3)(a4),a4
	dbf d1,.not_char			boucle pour tout la lettre

.space	addq.l #1,a2
	bra loop_display_Text_Menu
.display_Text_exit
	rts

.Return
	move.l Text_Margin(pc),a2
	add.l Text_Line_Offset(pc),a2
	move.l a2,Text_Margin-data_base(a5)
	bra loop_display_Text_Menu

.Color
	move.b (a0)+,d0				lit la couleur
	sub.w d7,d0
	beq loop_display_Text_Menu
	add.w d0,d7
	muls #SCREEN_WIDTH,d0			nouvel offset couleur
	add.l d0,a2
	add.l d0,Text_Margin-data_base(a5)
	bra loop_display_Text_Menu

.Locate
	move.l Text_Origin(pc),a2		SYNTAXE: £XX-YYY
	move.b (a0)+,d0				lit d'abord la position XX
	sub.b #"0",d0
	mulu.w #10,d0
	add.b (a0)+,d0
	sub.b #"0",d0
	lea (a2,d0.w),a2			LOCATE fait sur les X
	addq.l #1,a0				saute le '-'
	move.b (a0)+,d0				lit ensuite la position YYY
	sub.b #"0",d0
	mulu #100,d0
	moveq #0,d1
	move.b (a0)+,d1
	sub.b #"0",d1
	mulu #10,d1
	add.w d1,d0
	add.b (a0)+,d0
	sub.b #"0",d0
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d0
	move.w d7,d1
	sub.w #"0",d1
	mulu #SCREEN_WIDTH,d1
	add.l d1,d0
	lea (a2,d0.l),a2			locate fait sur les Y
	move.l a2,Text_Margin-data_base(a5)
	bra loop_display_Text_Menu

.Tab
	addq.l #8,a2
	bra loop_display_Text_Menu

.SetFont
	moveq #0,d0
	move.b (a0)+,d0
	mulu #fs_SIZEOF,d0
	lea Fonts_List,a1
	lea (a1,d0.l),a1
	move.w fs_Size(a1),d0
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d0
	move.l d0,Text_Line_Offset-data_base(a5)
	bra loop_display_Text_Menu



*****************************************************************************
*************** ECRITURE D'UNE LIGNE DANS LA BARRE DU HAUT ******************
*************** en entrée : a0=Text                        ******************
*****************************************************************************
Display_Text_Barre
	bsr Dup_Text_Barre

	lea Text_Barre(pc),a0
	lea Font_MicroKnight,a1
	lea Board_Top+SCREEN_WIDTH*SCREEN_DEPTH*6+8,a2
.loop_display_Text_Barre
	moveq #0,d0
	move.b (a0)+,d0
	beq.s .exit				on sort ?

	sub.b #"!",d0				! est la base des fontes
	blt.s .space				espace ?
	lsl.w #3,d0				mulu #8,d0
	lea fs_Chars(a1,d0.w),a3
	tst.w DZign_Number-data_base(a5)
	bne.s .DZign1
.DZign0
	moveq #0,d1
	move.w #SCREEN_WIDTH*2,d2
	moveq #8-1,d3
.put0	move.b (a3),(a2,d1.w)
	move.b (a3)+,(a2,d2.w)
	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d1
	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d2
	dbf d3,.put0
	bra.s .space

.DZign1
	moveq #0,d1
	moveq #SCREEN_WIDTH,d2
	move.w #SCREEN_WIDTH*2,d3
	move.w #SCREEN_WIDTH*3,d4
	moveq #8-1,d5
.put1	move.b (a3)+,d6
	not.b d6
	and.b d6,(a2,d1.w)
	and.b d6,(a2,d2.w)
	and.b d6,(a2,d3.w)
	and.b d6,(a2,d4.w)
	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d1
	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d2
	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d3
	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d4
	dbf d5,.put1

.space	addq.l #1,a2
	bra.s .loop_display_Text_Barre
.exit	rts


Dup_Text_Barre
	lea Text_Barre(pc),a1
.dup	move.b (a0)+,(a1)+
	bne.s .dup
	rts


Clear_Text_Barre
	move.l a0,-(sp)
	ALLOC_BLITTER
	WAIT_VBL
	move.l Board_Top_Back(pc),a0
	lea SCREEN_WIDTH*SCREEN_DEPTH*6(a0),a0
	move.l a0,bltapt(a6)
	move.l #Board_Top+SCREEN_WIDTH*SCREEN_DEPTH*6,bltdpt(a6)
	move.l #-1,bltafwm(a6)
	clr.l bltamod(a6)
	move.l #$09f00000,bltcon0(a6)
	move.w #(8*SCREEN_DEPTH<<6)|(SCREEN_WIDTH/2),bltsize(a6)
	FREE_BLITTER
	move.l (sp)+,a0
	rts

*****************************************************************************
***************** EFFACAGE DE L'ECRAN LOGIQUE MIDDLE SCREEN *****************
*****************************************************************************
Clear_Middle_Screen
	ALLOC_BLITTER
	move.l log_screen(pc),bltdpt(a6)
	clr.w bltdmod(a6)
	move.l #$01000000,bltcon0(a6)
	move.w #((PART3-PART2)*SCREEN_DEPTH<<6)!(SCREEN_WIDTH/2),bltsize(a6)
	FREE_BLITTER
	rts



*****************************************************************************
************ REMPLISSAGE DE L'ECRAN LOGIQUE AVEC LE BACKGROUND **************
*****************************************************************************
BackGround_Middle_Screen
	ALLOC_BLITTER
	move.l #BackGround,bltapt(a6)
	move.l log_screen(pc),bltdpt(a6)
	move.l #-1,bltafwm(a6)
	clr.l bltamod(a6)
	move.l #$09f00000,bltcon0(a6)
	move.w #((PART3-PART2)*SCREEN_DEPTH<<6)|(SCREEN_WIDTH/2),bltsize(a6)
	FREE_BLITTER
	rts



*****************************************************************************
********************** MET DES PTRS VIDEOS DANS LA COPLIST ******************
**********************   En entrée: D0=ecran  A0=Coplist   ******************
**********************              D1=SCREEN_WIDTH        ******************
**********************              D2=SCREEN_DEPTH-1      ******************
*****************************************************************************
Init_BplPtrs
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	swap d0
	add.l d1,d0
	addq.l #8,a0
	dbf d2,Init_BplPtrs
	rts


*****************************************************************************
*********************** INSTALLATION D'UN NOUVEAU DZIGN *********************
*****************************************************************************
Init_DZign
	move.w DZign_Number(pc),d0		recherche un ptr sur la
	mulu.w #dz_SIZEOF,d0			structure DZign
	lea DZign_List(pc),a4
	lea (a4,d0.l),a4

	move.l (a4)+,d0				recopie le board dans l'écran
	move.l d0,Board_Top_Back-data_base(a5)
	ALLOC_BLITTER
	WAIT_VBL
	move.l d0,bltapt(a6)
	move.l #Board_Top,bltdpt(a6)
	move.l #-1,bltafwm(a6)
	clr.l bltamod(a6)
	move.l #$09f00000,bltcon0(a6)
	move.w #((PART2-PART1)*SCREEN_DEPTH<<6)|(SCREEN_WIDTH/2),bltsize(a6)
	FREE_BLITTER

	move.l (a4)+,d0				installe le bas
	move.l d0,Board_Bottom-data_base(a5)
	lea Bottom_Ptrs+2,a0
	moveq #SCREEN_WIDTH,d1
	moveq #SCREEN_DEPTH-1,d2
	bsr Init_BplPtrs

	lea Sprites_Ptrs+2,a0
	move.l (a4)+,d0				init le pointeur souris
	move.l d0,Mouse_Sprite-data_base(a5)
	move.w d0,4(a0)
	move.w d0,4+8(a0)
	swap d0
	move.w d0,(a0)
	move.w d0,8(a0)
	lea 8*2(a0),a0
	move.l (a4)+,d0				init bordure gauche spr0
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	addq.l #8,a0
	move.l (a4)+,d0				init bordure gauche spr1
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	addq.l #8,a0
	move.l (a4)+,d0				init bordure droite spr2
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	addq.l #8,a0
	move.l (a4)+,d0				init bordure droite spr3
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)

	lea Top_Colors+2,a0			installe les couleurs
	lea Bottom_Colors+2,a1			des écrans
	moveq #NB_COLORS-1,d0
.put_colors0
	move.w (a4),(a0)
	move.w (a4)+,(a1)
	addq.l #4,a0
	addq.l #4,a1
	dbf d0,.put_colors0

	lea Sprites_Colors+2,a0			installe les couleurs
	moveq #16-1,d0				des sprites
.put_colors1
	move.w (a4)+,(a0)
	addq.l #4,a0
	dbf d0,.put_colors1

	move.w bs_CoordY+Bob_volume_tile(pc),d0
	sub.w #225-PART3,d0
	bsr Render_Volume			retrace la tile du volume
	bsr Render_Barre			retrace la barre

	lea Text_Barre(pc),a0			reaffiche le texte de la barre
	bra Display_Text_Barre



*****************************************************************************
********************** ECRITURE D'UN NOMBRE EN DECIMAL **********************
********************** en entrée : a0=ou on l'écrit    **********************
**********************             d0.l=Nbre           **********************
*****************************************************************************
Write_Number
	divu #100,d0				calcule les centaines
	move.b d0,d1				sauve le nbr pour plus tard
	bne.s .write1				egal à 0 ?
	move.b #" "-"0",d0
.write1	add.b #"0",d0
	move.b d0,(a0)+
	clr.w d0
	swap d0
	divu #10,d0				calcule les dizaines
	bne.s .write2				égal à 0 ?
	tst.b d1				c'est un 0 => on a koi avant ?
	bne.s .write2
	move.b #" "-"0",d0
.write2	add.b #"0",d0
	move.b d0,(a0)+
.skip2	swap d0					calcule les unités
	add.b #"0",d0
	move.b d0,(a0)
	rts



*****************************************************************************
******************* CHARGEMENT DU MODULE DE LIVE AVEC LE DOS ****************
*****************************************************************************
Select_Module
	move.l _GfxBase(pc),a0			remet la coplist system
	move.l $26(a0),cop1lc(a6)
	clr.w copjmp1(a6)

	jsr NEv_stop				remet les events

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
	moveq #-1,d0
	move.l d0,pr_WindowPtr(a0)

	jsr NEv_start				vire les events

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
	jsr -$1e(a6)				ppLoadData()
	tst.l d0				erreur ?
	bne.s .pp_error

	move.l Module_Adr(pc),a0		c'est du PT au moins ????
	cmp.l #"M.K.",1080(a0)
	bne.s .type_error

	jsr mt_init				met la zik

	lea custom_base,a6
	st HP_State-data_base(a5)		et retrace le HP
	bra change_HP

.type_error
	move.l Module_Adr(pc),a1		libère la mémoire
	move.l Module_Size(pc),d0
	CALL _ExecBase(pc),FreeMem

.pp_error
	clr.l Module_Size-data_base(a5)
	clr.l Module_Adr-data_base(a5)

	lea custom_base,a6
	sf HP_State-data_base(a5)		retrace le HP
	bra change_HP


Free_Module
	move.l Module_Size(pc),d0		libère le module précédent
	beq.s .no_module			si yen avait un
	move.l Module_Adr(pc),a1
	CALL _ExecBase(pc),FreeMem
	clr.l Module_Size-data_base(a5)
	clr.l Module_Adr-data_base(a5)
.no_module
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
	bsr Gfx_Decrunch
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
	bsr.s Gfx_Decrunch
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
; a1= ** éventuellement ** c'est là ou on decrunch
; a0=fin datas packées

; EN SORTIE
; a1=début datas dépackées

Gfx_Decrunch
	lea pp_space,a1
	bra.s Decrunch_pp
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
Mouse_Flag		dc.b 0
Trash_Flag		dc.b 0

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
Live_Handle		dc.l 0
Live_Lock		dc.l 0

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
Gallery_Ptr		dc.l 0
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

Live_Requester		dcb.b $164,0		frq_SIZEOF

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
LivePowerpackerName	dc.b "powerpacker.library",0
LiveIntuitionName	dc.b "intuition.library",0

Live_Req_Title		dc.b "SeLeCt A NeW MoDuLe FoR LiVe !",0

Live_Start_Module	dc.b "LIVE:music/mod.1.2.3.jazz",0

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
	include "Msg_All.s"



*****************************************************************************
*************************  TOUS LES CLIPARTS DE LIVE  ***********************
*****************************************************************************
	include "ClipArts_List.s"


*****************************************************************************
*************************  TOUTES LES FONTES DE LIVE  ***********************
*****************************************************************************
	include "Fonts_List.s"


*****************************************************************************
************************  TOUTES LES ADVERTS DE LIVE  ***********************
*****************************************************************************
HalfAdverts_List
	incbin "HAD_List.RAW"
FullAdverts_List
	incbin "FAD_List.RAW"


*****************************************************************************
**************************  INCLUSION DE LA GALLERY *************************
*****************************************************************************
	include "Gallery_List.s"




*****************************************************************************
****************************** LES MENUS DE LIVE ****************************
*****************************************************************************

* Tous les menus de LIVE
* ~~~~~~~~~~~~~~~~~~~~~~
MainMenu
	dc.l 0
	dc.l Main_Edito
	dc.l MainMenu_BarText
	dc.w 0
	dc.l %001011111111011101100
	dc.l %000000011001011101000
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
	dc.l SuntheticsArticle
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
Sunthetics_BarText
	dc.b "Sunthetics Area..........................................  1/  0",0
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

* Une ame solitaire...
* ~~~~~~~~~~~~~~~~~~~~
	include "Art_Macros.i"
	include "HandleStory.ART"



*****************************************************************************
********************  DATAS QUI SERONT STOCKES EN CHIP  *********************
*****************************************************************************

	section hgtg,data
* Articles
* ~~~~~~~~
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
	include "Sunthetics.ART"
	include "HowToSupport.ART"
	include "DesignIt.ART"
	include "Address.ART"
	include "DreamLands.ART"
	include "LastWords.ART"
	include "Help.ART"

	even
MistraLogo
	incbin "MistraLogo.PAK"
MistraLogo_End
Clown
	incbin "Clown.PAK"
Clown_End

	section feemal,data_c
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
