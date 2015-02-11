


**
** $VER:  Live AGA v1.0
**        (c)1994 Sync/DreamDealers
**
** OPEN_WINDOW X1,Y1,X2,Y2
**     Sauvegarde du fond du future fenetre
**
** DRAW_WINDOW_BORDER X1,Y1,X2,Y2
**     Tracage du bord d'une fenetre
**



*************************************************************************************************
*                                TOUS LES INCLUDES DE DEATH
*************************************************************************************************
	incdir "include:"
	incdir "Death:"
	incdir "Death:Sources/"
	incdir "Death:Includes/"

	include "exec/exec_lib.i"
	include "exec/memory.i"
	include "graphics/graphics_lib.i"
	include "intuition/screens.i"
	include "misc/macros.i"

	include "Extensions.i"




*************************************************************************************************
*                               LES OPTIONS DE COMPILATIONS
*************************************************************************************************
	OPT AMIGA
	OPT O+,OW-,OW1+,OW6+
	OPT INCONCE
	OPT EVEN
	IFEQ LIVE_DEBUG
	OPT NOLINE,NODEBUG
	ENDC

	OUTPUT Live:LiveExtensions/WindowManager




*************************************************************************************************
*                            ROUTINES D'INIT DE CETTE EXTENSION
* en entrée: a5=DeathDataBase
*
* en sortie: d0=DEATH_ERROR ou DEATH_OK
*
*************************************************************************************************
Extension_Tags
	dc.l Init_Point
	dc.l Exit_Point
	dc.l Tk
	dc.l 0
Version
	dc.b "$VER: WindowManager v1.0 - (c)1994 Sync/DreamDealers",0
	CNOP 0,4

Init_Point
	moveq #DEATH_OK,d0
	rts

Exit_Point
	SAVE_REGS

	move.l WindowList(a5),d2
	bra.s .start
.purge
	move.l d2,a2

	move.l win_BackBitMap(a2),a0		libère la BitMap
	CALL _GfxBase(a5),FreeBitMap

	move.l win_Next(a2),d2			libère la structure Window
	move.l #Window_SIZEOF,d0
	CALL _ExecBase(a5),FreeMem

	tst.l d2
.start
	bne.s .purge

	move.l #DEATH_OK,d0
	RESTORE_REGS
	rts




*************************************************************************************************
*                 INSTRUCTION PERMETTANT DE SAUVER LE FOND D'UNE FUTURE FENETRE
*
* success=OPEN_WINDOW X,Y,Width,Height
*
* en entrée: a5=DeathDataBase
*
* en sortie: a5=DeathDataBase
*
*************************************************************************************************
Open_Window
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
	move.l #ErrorOpenWindow,DeathErrorString(a5)

	tst.l LiveScreen(a5)			ya un ecran ?
	beq no_open

* Allocation d'une structure Window
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l #Window_SIZEOF,d0		alloue une structure Window
	move.l #MEMF_ANY,d1
	CALL _ExecBase(a5),AllocMem
	tst.l d0
	beq no_allocmem
	move.l d0,a3

* clipping de la fenetre
* ~~~~~~~~~~~~~~~~~~~~~~
	move.l DeathArg2(a5),d0			calcul win_Width
	add.w #WINDOW_BORDER_LEFT+WINDOW_BORDER_RIGHT,d0
	move.w d0,win_Width(a3)

	move.l DeathArg3(a5),d1			calcul win_Height
	add.w #WINDOW_BORDER_TOP+WINDOW_BORDER_BOTTOM,d1
	move.w d1,win_Height(a3)

	move.l DeathArg0(a5),d2			clipping de la fenetre
	subq.w #WINDOW_BORDER_LEFT,d2
	move.w d2,win_X(a3)
	blt.s clip_error

	add.w d0,d2
	cmp.w #SCREEN_X,d2
	bge.s clip_error

	move.l DeathArg1(a5),d2
	subq.w #WINDOW_BORDER_TOP,d2
	move.w d2,win_Y(a3)
	blt.s clip_error

	add.w d1,d2
	cmp.w #SCREEN_Y,d2
	bge.s clip_error

* allocation d'une BitMap pour sauver le fond
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq #SCREEN_DEPTH,d2			profondeur du BitMap
	moveq #0,d3				flags allocbitmap
	sub.l a0,a0
	CALL _GfxBase(a5),AllocBitMap
	move.l d0,win_BackBitMap(a3)
	beq.s no_allocbitmap

	move.l WindowList(a5),win_Next(a3)	link la window dans la liste
	move.l a3,WindowList(a5)

	move.l LiveScreen(a5),a0		recopie le fond de la futur Window
	move.l sc_RastPort+rp_BitMap(a0),a0
	move.l d0,a1
	sub.l a2,a2
	move.w win_X(a3),d0
	move.w win_Y(a3),d1
	moveq #0,d2
	moveq #0,d3
	move.w win_Width(a3),d4
	move.w win_Height(a3),d5
	move.b #$c0,d6
	moveq #-1,d7
	CALL BltBitMap

	move.l a3,ReturnCode-LocalData(a4)
	bra.s no_error

no_allocbitmap
clip_error
	move.l a3,a1				libère la mémoire pour la structure Window
	move.l #Window_SIZEOF,d0
	CALL _ExecBase(a5),FreeMem
no_error
no_allocmem
no_open
	move.l ReturnCode(pc),d0
	RESTORE_REGS
	rts	



*************************************************************************************************
*                 INSTRUCTION PERMETTANT DE TRACER LE BORD D'UNE WINDOW
*
* success=RENDER_WINDOW WindowStruct
*
* en entrée: a5=DeathDataBase
*
* en sortie: a5=DeathDataBase
*
*************************************************************************************************
Render_Window
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
	move.l #ErrorRenderWindow,DeathErrorString(a5)

	move.l LiveScreen(a5),d0
	beq .error
	move.l d0,a0
	lea sc_RastPort(a0),a2

	move.w #128,d0				couleur 128=blanc
	move.l a2,a1
	CALL _GfxBase(a5),SetAPen

	move.l DeathArg0(a5),a0
	move.w win_X(a0),d4			X1
	move.w win_Y(a0),d5			Y1
	move.w d4,d6
	add.w win_Width(a0),d6
	subq.w #WINDOW_BORDER_RIGHT,d6		X2
	move.w d5,d7
	add.w win_Height(a0),d7
	subq.w #WINDOW_BORDER_BOTTOM,d7		Y2

	move.w d4,d0
	move.w d5,d1
	move.l a2,a1
	CALL Move

	move.w d6,d0
	move.w d5,d1
	move.l a2,a1
	CALL Draw

	move.w d6,d0
	move.w d7,d1
	move.l a2,a1
	CALL Draw

	move.w d4,d0
	move.w d7,d1
	move.l a2,a1
	CALL Draw

	move.w d4,d0
	move.w d5,d1
	move.l a2,a1
	CALL Draw

	addq.w #1,d4				fabrication des doubles barres verticales
	addq.w #1,d6

	move.w d4,d0
	move.w d5,d1
	move.l a2,a1
	CALL Move

	move.w d4,d0
	move.w d7,d1
	move.l a2,a1
	CALL Draw

	move.w d6,d0
	move.w d5,d1
	move.l a2,a1
	CALL Move

	move.w d6,d0
	move.w d7,d1
	move.l a2,a1
	CALL Draw

	move.w #129,d0				Ombre du bord de la fenetre
	move.l a2,a1
	CALL SetAPen

	addq.w #1,d5
	addq.w #1,d6

	move.w d6,d0
	move.w d5,d1
	move.l a2,a1
	CALL Move

	move.w d6,d0
	move.w d7,d1
	move.l a2,a1
	CALL Draw

	addq.w #1,d6
	addq.w #1,d7

	move.w d6,d0
	move.w d5,d1
	move.l a2,a1
	CALL Move

	move.w d6,d0
	move.w d7,d1
	move.l a2,a1
	CALL Draw

	addq.w #1,d4

	move.w d4,d0
	move.w d7,d1
	move.l a2,a1
	CALL Draw

	move.l #DEATH_OK,ReturnCode-LocalData(a4)
.error
	move.l ReturnCode(pc),d0
	RESTORE_REGS
	rts




*************************************************************************************************
*               INSTRUCTION PERMETTANT DE RESTAURER LE FOND DE TOUTES LES WINDOWS
*
* success=CLOSE_ALL_WINDOWS
*
* en entrée: a5=DeathDataBase
*
* en sortie: a5=DeathDataBase
*
*************************************************************************************************
Close_All_Windows
	SAVE_REGS

	move.l WindowList(a5),d0
	bra.s .start
.redraw
	move.l d0,a3
	move.l win_Next(a3),a4

	move.l win_BackBitMap(a3),a0		remet le fond qu'yavait avant
	move.l LiveScreen(a5),a1
	move.l sc_RastPort+rp_BitMap(a1),a1
	sub.l a2,a2
	moveq #0,d0
	moveq #0,d1
	move.w win_X(a3),d2
	move.w win_Y(a3),d3
	move.w win_Width(a3),d4
	move.w win_Height(a3),d5
	move.b #$c0,d6
	moveq #-1,d7
	CALL _GfxBase(a5),BltBitMap

	move.l win_BackBitMap(a3),a0		libère la BitMap
	CALL FreeBitMap

	move.l a3,a1				libère la structure Window
	move.l #Window_SIZEOF,d0
	CALL _ExecBase(a5),FreeMem

	move.l a4,d0				yen a encore ?
.start
	bne.s .redraw
	clr.l WindowList(a5)

	move.l #DEATH_OK,d0
	RESTORE_REGS
	rts
	


*************************************************************************************************
*                               LA TABLE D'INSTRUCTION DU MODULE
*************************************************************************************************
Tk
* OPEN_WINDOW X1,Y1,X2,Y2
	dc.l Open_Window
	dc.b "OPEN_WINDOW",0
	dc.b DEATH_INTEGER,DEATH_INTEGER,DEATH_INTEGER,DEATH_INTEGER,0

* RENDER_WINDOW WinStruct
	dc.l Render_Window
	dc.b "RENDER_WINDOW",0
	dc.b DEATH_INTEGER,0

* CLOSE_ALL_WINDOWS
	dc.l Close_All_Windows
	dc.b "CLOSE_ALL_WINDOWS",0
	dc.b 0

	dc.l 0



*************************************************************************************************
*                               DATAS POUR L'OUVERTURE D'UN ECRAN
*************************************************************************************************
	CNOP 0,4
LocalData

ReturnCode
	dc.l 0

ErrorOpenWindow
	dc.b "Function OPEN_WINDOW failed",0

ErrorRenderWindow
	dc.b "Instruction RENDER_WINDOW failed",0

