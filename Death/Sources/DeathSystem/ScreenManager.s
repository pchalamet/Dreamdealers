


**
** $VER:  Live AGA v1.0
**        (c)1994 Sync/DreamDealers
**
** OPEN_LIVE_SCREEN
**     Ouverture de l'écran de Live
**
** CLOSE_LIVE_SCREEN
**     Fermeture de l'écran de Live
**
** LOAD_LIVE_PALETTE
**     Extension Death pour charger la palette courante
**     dans l'écran de Live.
**
** LIVE_SCREEN_TO_FRONT
**     Met l'écran de Live devant tous les autres
**
** LIVE_SCREEN_TO_BACK
**     Met l'écran de Live derrière tous les autres
**



*************************************************************************************************
*                                TOUS LES INCLUDES DE DEATH
*************************************************************************************************
	incdir "include:"
	incdir "Death:"
	incdir "Death:Sources/"
	incdir "Death:Includes/"

	include "graphics/graphics_lib.i"
	include "graphics/modeid.i"
	include "intuition/intuition_lib.i"
	include "intuition/intuition.i"
	include "intuition/screens.i"
	include "libraries/gadtools_lib.i"
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

	OUTPUT Live:LiveExtensions/ScreenManager




*************************************************************************************************
*                            ROUTINES D'INIT DE CETTE EXTENSION
* en entrée: a5=ExtensionDataBase
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
	dc.b "$VER: ScreenManager v1.0 - (c)1994 Sync/DreamDealers",0
	CNOP 0,4

Init_Point
	move.l #DEATH_OK,d0
	rts

Exit_Point
	bra.s Close_Live_Screen





*************************************************************************************************
*                                  OUVERTURE DE L'ECRAN DE LIVE
* en entrée: a5=ExtensionDataBase
*
* en sortie: d0=DEATH_OK ou DEATH_ERROR
*            a5=ExtensionDataBase
*
*************************************************************************************************
Open_Live_Screen
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)

* Ouverture de l'écran
* ~~~~~~~~~~~~~~~~~~~~
	move.l #ErrorOpenScreen,DeathErrorString(a5)
	sub.l a0,a0				ouvre l'écran
	lea OpenLiveScreen_Tags(pc),a1
	CALL _IntuitionBase(a5),OpenScreenTagList
	move.l d0,LiveScreen(a5)
	move.l d0,Tag_Window_Screen-LocalData(a4)
	beq.s .error

	move.l d0,a0				ouvre la fenetre
	lea sc_BitMap(a0),a0
	move.l a0,Tag_Window_BitMap-LocalData(a4)
	sub.l a0,a0				
	lea OpenLiveWindow_Tags(pc),a1
	CALL OpenWindowTagList
	move.l d0,LiveWindow(a5)
	beq.s .error

	move.l LiveScreen(a5),a0		visual info pour gadtools
	sub.l a1,a1
	CALL _GadToolsBase(a5),GetVisualInfoA
	move.l d0,LiveScreen_VisualInfo(a5)
	beq.s .error
	move.l #DEATH_OK,ReturnCode-LocalData(a4)
.error
	move.l ReturnCode(pc),d0
	RESTORE_REGS
	rts



*************************************************************************************************
*                                  FERMETURE DE L'ECRAN DE LIVE
* en entrée: a5=ExtensionDataBase
*
* en sortie: d0=DEATH_OK ou DEATH_ERROR
*            a5=ExtensionDataBase
*
*************************************************************************************************
Close_Live_Screen
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_OK,ReturnCode-LocalData(a4)

	CALL _GfxBase(a5),WaitBlit

	move.l LiveScreen_VisualInfo(a5),d0	libère le visual info
	beq.s no_visual
	move.l d0,a0
	CALL _GadToolsBase(a5),FreeVisualInfo
	clr.l LiveScreen_VisualInfo(a5)
no_visual
	move.l LiveScreen(a5),d0		met l'écran en arrière
	beq.s no_openscreen
	move.l d0,a0
	CALL _IntuitionBase(a5),ScreenToBack
no_visualinfo
	move.l LiveWindow(a5),d0		ferme la fenetre
	beq.s no_openwindow
	move.l d0,a0
	CALL CloseWindow
	clr.l LiveWindow(a5)
no_openwindow
	move.l LiveScreen(a5),d0		ferme l'écran
	beq.s no_openscreen
	move.l d0,a0
	CALL CloseScreen
	clr.l LiveScreen(a5)
no_openscreen
	move.l ReturnCode(pc),d0
	RESTORE_REGS
	rts




*************************************************************************************************
*                 INSTRUCTION PERMETTANT DE METTRE L'ECRAN DE LIVE DANS LE FOND
*
* success=LIVE_SCREEN_TO_FRONT
*
* en entrée: a5=ExtensionDataBase
*
* en sortie: a5=ExtensionDataBase
*
*************************************************************************************************
Live_Screen_To_Front
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
	move.l #ErrorLiveScreenToFront,DeathErrorString(a5)

	move.l LiveWindow(a5),d0
	beq.s .no_window
	move.l d0,a0
	CALL _IntuitionBase(a5),ActivateWindow

	move.l LiveScreen(a5),d0
	beq.s .no_screen
	move.l d0,a0
	CALL ScreenToFront

	move.l #DEATH_OK,ReturnCode-LocalData(a4)
.no_screen
.no_window
	moveq #DEATH_OK,d0
	RESTORE_REGS
	rts



*************************************************************************************************
*                  INSTRUCTION PERMETTANT DE METTRE L'ECRAN DE LIVE DEVANT
*
* success=LIVE_SCREEN_TO_BACK
*
* en entrée: a5=ExtensionDataBase
*
* en sortie: a5=ExtensionDataBase
*
*************************************************************************************************
Live_Screen_To_Back
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
	move.l #ErrorLiveScreenToBack,DeathErrorString(a5)

	move.l LiveScreen(a5),d0
	beq.s .no_screen
	move.l d0,a0
	CALL _IntuitionBase(a5),ScreenToBack

	move.l #DEATH_OK,ReturnCode-LocalData(a4)
.no_screen
	moveq #DEATH_OK,d0
	RESTORE_REGS
	rts



*************************************************************************************************
*                     INSTRUCTION PERMETTANT DE REGLER UNE COULEUR
*
* success=SET_COLOR ColorOffset,Red,Green,Blue
*
* en entrée: a5=ExtensionDataBase
*
* en sortie: a5=ExtensionDataBase
*
*************************************************************************************************
Set_Color
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
	move.l #ErrorSetColor,DeathErrorString(a5)

	move.l LiveScreen(a5),d0
	beq.s .error

	lea LiveScreenColors(a5),a0		recherche la couleur dans la table
	move.l DeathArg0(a5),d0
	cmp.w #256,d0
	bge.s .error
	mulu.w #3,d0
	lea 4(a0,d0.w*4),a0

	move.b DeathArg1+3(a5),d0		écrit la couleur
	move.b d0,(a0)
	move.b d0,1(a0)
	move.b d0,2(a0)
	move.b d0,3(a0)
	move.b DeathArg2+3(a5),d0
	move.b d0,4(a0)
	move.b d0,5(a0)
	move.b d0,6(a0)
	move.b d0,7(a0)
	move.b DeathArg3+3(a5),d0
	move.b d0,8(a0)
	move.b d0,9(a0)
	move.b d0,10(a0)
	move.b d0,11(a0)

	move.l DeathArg0(a5),d0			et hop.. charge la couleur !
	movem.l (a0),d1/d2/d3
	move.l LiveScreen(a5),a0
	move.l sc_ViewPort+vp_ColorMap(a0),a0
	CALL _GfxBase(a5),SetRGB32CM

	move.l #DEATH_OK,ReturnCode-LocalData(a4)
.error
	move.l ReturnCode(pc),d0
	RESTORE_REGS
	rts




Wait_Mouse_Down
	btst #6,$bfe001
	bne.s Wait_Mouse_Down
	moveq #DEATH_OK,d0
	rts

Wait_Mouse_Up
	btst #6,$bfe001
	beq.s Wait_Mouse_Up
	moveq #DEATH_OK,d0
	rts


*************************************************************************************************
*                            LA TABLE D'INSTRUCTION DE L'EXTENSION
*************************************************************************************************
Tk

* OPEN_LIVE_SCREEN
	dc.l Open_Live_Screen
	dc.b "OPEN_LIVE_SCREEN",0
	dc.b 0

* CLOSE_LIVE_SCREEN
	dc.l Close_Live_Screen
	dc.b "CLOSE_LIVE_SCREEN",0
	dc.b 0

* LIVE_SCREEN_TO_FRONT
	dc.l Live_Screen_To_Front
	dc.b "LIVE_SCREEN_TO_FRONT",0
	dc.b 0

* LIVE_SCREEN_TO_BACK
	dc.l Live_Screen_To_Back
	dc.b "LIVE_SCREEN_TO_BACK",0
	dc.b 0

* SET_COLOR color_offset,Red,Green,Blue
	dc.l Set_Color
	dc.b "SET_COLOR",0
	dc.b DEATH_INTEGER,DEATH_INTEGER,DEATH_INTEGER,DEATH_INTEGER,0

* WAIT_MOUSE_DOWN
	dc.l Wait_Mouse_Down
	dc.b "WAIT_MOUSE_DOWN",0
	dc.b 0

* WAIT_MOUSE_UP
	dc.l Wait_Mouse_Up
	dc.b "WAIT_MOUSE_UP",0
	dc.b 0

	dc.l 0




*************************************************************************************************
*                               DATAS POUR L'OUVERTURE D'UN ECRAN
*************************************************************************************************
	CNOP 0,4
LocalData

ReturnCode
	dc.l 0

OpenLiveScreen_Tags
	dc.l SA_DisplayID,HIRES_KEY
	dc.l SA_Width,SCREEN_X
	dc.l SA_Height,SCREEN_Y
	dc.l SA_Depth,SCREEN_DEPTH
	dc.l SA_Font,LiveScreenFont
	dc.l SA_Interleaved,TAG_TRUE
	dc.l SA_Behind,TAG_TRUE
	dc.l SA_Quiet,TAG_TRUE
	dc.l SA_Title,LiveScreenTitle
Screen_Colors=*+4
	dc.l SA_Colors32,0
	dc.l TAG_DONE

OpenLiveWindow_Tags
	dc.l WA_Left,0
	dc.l WA_Top,0
	dc.l WA_Width,SCREEN_X
	dc.l WA_Height,SCREEN_Y
Tag_Window_BitMap=*+4
	dc.l WA_SuperBitMap,0
	dc.l WA_Activate,TAG_TRUE
	dc.l WA_Flags,WFLG_BACKDROP!WFLG_BORDERLESS!WFLG_REPORTMOUSE!WFLG_RMBTRAP!WFLG_SUPER_BITMAP
	dc.l WA_IDCMP,IDCMP_MOUSEMOVE!IDCMP_MOUSEBUTTONS!IDCMP_RAWKEY
Tag_Window_Screen=*+4
	dc.l WA_CustomScreen,0
	dc.l TAG_DONE	

LiveScreenFont
	dc.l TopazName
	dc.w 8
	dc.b FS_NORMAL
	dc.b FPF_ROMFONT

TopazName
	dc.b "topaz.font",0

LiveScreenTitle
	dc.b ".oO LiVe AGA ScReEn Oo.",0

ErrorOpenScreen
	dc.b "Instruction OPEN_LIVE_SCREEN failed",0
ErrorLiveScreenToFront
	dc.b "Instruction LIVE_SCREEN_TO_FRONT failed",0
ErrorLiveScreenToBack
	dc.b "Instruction LIVE_SCREEN_TO_BACK failed",0
ErrorSetColor
	dc.b "Instruction SET_COLOR failed",0
