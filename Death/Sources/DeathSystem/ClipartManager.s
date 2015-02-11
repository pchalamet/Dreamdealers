


**
** $VER:  Live AGA v1.0
**        (c)1994 Sync/DreamDealers
**
** LOAD_CLIPART "FileName"
**     Chargement d'un clipart ( FileName )
**
** DISPLAY_CLIPART "Name",PosX,PosY
**     Affiche le clipart Name à la position (PosX,PosY)
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
	include "intuition/intuition_lib.i"
	include "intuition/intuition.i"
	include "graphics/graphics_lib.i"
	include "dos/dos_lib.i"
	include "dos/dos.i"
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

	OUTPUT Live:LiveExtensions/ClipartManager




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
	dc.b "$VER: ClipartManager v1.1 - (c)1994 Sync/DreamDealers",0
	CNOP 0,4

Init_Point
	moveq #DEATH_OK,d0
	rts


Exit_Point
	SAVE_REGS

	move.l _DosBase(a5),a6
	move.l ClipartList(a5),a2
	bra.s .start
.purge
	move.l ca_Next(a2),a2

	subq.l #4,d1
	lsr.l #2,d1
	CALL UnLoadSeg

.start	move.l a2,d1
	bne.s .purge

	RESTORE_REGS
	rts



*************************************************************************************************
*                   INSTRUCTION PERMETTANT DE CHARGER UN CLIPART
*
* success=LOAD_CLIPART "FileName"
*
* en entrée: a5=DeathDataBase
*
* en sortie: a5=DeathDataBase
*
*************************************************************************************************
Load_Clipart
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
	move.l #ErrorLoadClipart,DeathErrorString(a5)

	move.l DeathArg0(a5),a1			regarde si on aurait pas par hazard
	bsr Search_ClipName			un clipart du meme nom
	beq.s no_already

	move.l DeathArg0(a5),d1			nom du fichier à charger
	move.l #MODE_OLDFILE,d2
	CALL _DosBase(a5),LoadSeg
	add.l d0,d0				\
	beq.s no_loadseg			 > BCPL -> APTR
	add.l d0,d0
	addq.l #4,d0
	move.l d0,a0

	move.l ClipartList(a5),ca_Next(a0)	insère le clipart dans la liste
	move.l a0,ClipartList(a5)

	move.l #DEATH_OK,ReturnCode-LocalData(a4)
no_loadseg
no_already
	move.l ReturnCode(pc),d0	
	RESTORE_REGS
	rts	




*************************************************************************************************
*                   INSTRUCTION PERMETTANT D'AFFICHER UN CLIPART
*
* success=DISPLAY_CLIPART "Name",PosX,PosY
*
* en entrée: a5=DeathDataBase
*
* en sortie: a5=DeathDataBase
*
*************************************************************************************************
Display_Clipart
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
	move.l #ErrorDisplay,DeathErrorString(a5)

	tst.l LiveScreen(a5)			ya au moins l'écran de live ?
	beq .not_found

	move.l DeathArg0(a5),a1			recherche le clipart
	bsr Search_ClipName
	bne .not_found

* Chargement des couleurs du clipart
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l a0,a3				charge les couleurs du clipart
	move.l LiveScreen(a5),a0
	lea sc_ViewPort(a0),a0
	lea ca_Colors(a3),a1
	move.w #192,2(a1)			offset couleurs=192
	CALL _GfxBase(a5),LoadRGB32

* Ouvre une fenetre de la dimension du clipart
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l DeathArg1(a5),d1			DstX
	move.l DeathArg2(a5),d2			DstY
	moveq #0,d3
	move.w ca_Image+ig_Width(a3),d3		SizeX
	moveq #0,d4
	move.w ca_Image+ig_Height(a3),d4	SizeY

	move.l d1,DeathArg0(a5)
	move.l d2,DeathArg1(a5)
	move.l d3,DeathArg2(a5)
	move.l d4,DeathArg3(a5)
	EXECUTE_INSTR DataOpenWindow,ProtoOpenWindow
	move.l d0,DeathArg0(a5)
	beq.s .no_window

* Balance l'image dans l'écran
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l d1,d0				DestX
	move.l d2,d1				DestY
	lea ca_Image(a3),a1
	move.l LiveScreen(a5),a0
	lea sc_RastPort(a0),a0
	CALL _IntuitionBase(a5),DrawImage

* Affichage du bord de la fenetre
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	EXECUTE_INSTR DataRenderWindow,ProtoRenderWindow

	lea LocalData(pc),a4
	move.l #DEATH_OK,ReturnCode-LocalData(a4)
.not_found
.no_window
	move.l ReturnCode(pc),d0
	RESTORE_REGS
	rts



*************************************************************************************************
*                                  RECHERCHE D'UN CLIPART DANS LA LISTE
*
* en entrée: a1=ClipName
*            a5=DeathDataBase
*
* en sortie: a0=Structure Clipart
*            Z ?
*
*************************************************************************************************
Search_ClipName
	move.l ClipartList(a5),d1
	bra.s .start
.start_cmp
	move.l d1,a0
	lea ca_Name(a0),a0
	move.l a1,a2
.cmp
	move.b (a0)+,d0
	beq.s .chk_end
	cmp.b (a2)+,d0
	beq.s .cmp
.next
	move.l d1,a0
	move.l ca_Next(a0),d1
.start
	bne.s .start_cmp
	moveq #1,d0
	rts

.chk_end
	tst.b (a2)
	bne.s .next
	move.l d1,a0
	rts




*************************************************************************************************
*                               LA TABLE D'INSTRUCTION DU MODULE
*************************************************************************************************
Tk
* LOAD_CLIPART "FileName"
	dc.l Load_Clipart
	dc.b "LOAD_CLIPART",0
	dc.b DEATH_STRING,0

* DISPLAY_CLIPART "Name",PosX,PosY
	dc.l Display_Clipart
	dc.b "DISPLAY_CLIPART",0
	dc.b DEATH_STRING,DEATH_INTEGER,DEATH_INTEGER,0

	dc.l 0



*************************************************************************************************
*                               DATAS POUR L'OUVERTURE D'UN ECRAN
*************************************************************************************************
	CNOP 0,4
LocalData

ReturnCode
	dc.l 0

ErrorLoadClipart
	dc.b "Instruction LOAD_CLIPART failed",0
ErrorDisplay
	dc.b "Instruction DISPLAY_CLIPART failed",0

DataOpenWindow
	dc.b "OPEN_WINDOW",0
ProtoOpenWindow
	dc.b DEATH_INTEGER,DEATH_INTEGER,DEATH_INTEGER,DEATH_INTEGER,0

DataRenderWindow
	dc.b "RENDER_WINDOW",0
ProtoRenderWindow
	dc.b DEATH_INTEGER,0

