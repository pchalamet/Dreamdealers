


**
** $VER:  Live AGA v1.0
**        (c)1994 Sync/DreamDealers
**
** Fichier d'init pour DEATH
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
	include "diskfont/diskfont_lib.i"
	include "graphics/text.i"
	include "libraries/iffparse_lib.i"
	include "libraries/iffparse.i"
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

	OUTPUT Live:Live-Startup




*************************************************************************************************
*                                 ROUTINES D'INIT DE LA STARTUP
* en entrée: a5=ExtensionDataBase
*
* en sortie: d0=DEATH_ERROR ou DEATH_OK
*            a5=ExtensionDataBase
*
*************************************************************************************************
Extension_Tags
	dc.l Init_Point
	dc.l Exit_Point
	dc.l 0
	dc.l 0
Version
	dc.b "$VER: Live-Startup v1.0 - (c)1994 Sync/DreamDealers",0
	CNOP 0,4

Init_Point
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #ErrorInitDeath,DeathErrorString(a5)
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)

* alloue une nouvelle base pour LIVE
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l #ExtensionData_SIZEOF,d0
	move.l #MEMF_ANY|MEMF_CLEAR,d1
	CALL _ExecBase(a5),AllocMem
	tst.l d0
	beq no_allocmem

	move.l a5,Old_DataBase-LocalData(a4)
	move.l a5,a0
	move.l d0,a1
	move.l d0,a5

	move.l #DeathData_SIZEOF-1,d0
.dup_deathbase
	move.b (a0)+,(a1)+
	dbf d0,.dup_deathbase

	move.l #LiveExtensionsName,DeathExtensionsName(a5)
	move.l #LiveStartupName,DeathStartupName(a5)

* ouverture des libraries
* ~~~~~~~~~~~~~~~~~~~~~~~
	lea GfxName(pc),a1
	moveq #39,d0
	CALL OpenLibrary
	move.l d0,_GfxBase(a5)
	beq no_gfx

	lea GadToolsName(pc),a1
	moveq #39,d0
	CALL OpenLibrary
	move.l d0,_GadToolsBase(a5)
	beq no_gadtools

	lea DiskFontName(pc),a1
	moveq #39,d0
	CALL OpenLibrary
	move.l d0,_DiskFontBase(a5)
	beq no_diskfont

	lea IFFParseName(pc),a1
	moveq #39,d0
	CALL OpenLibrary
	move.l d0,_IFFParseBase(a5)
	beq.s no_iffparse

* ouverture des fonts
* ~~~~~~~~~~~~~~~~~~~
	lea TopazFontAttr(pc),a0
	CALL _GfxBase(a5),OpenFont
	move.l d0,TopazFont(a5)
	beq.s no_topaz

	lea DiamondFontAttr(pc),a0
	CALL _DiskFontBase(a5),OpenDiskFont
	move.l d0,DiamondFont(a5)
	beq.s no_diamond

* bidules pour charger des IFF
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	CALL _IFFParseBase(a5),AllocIFF		allocation d'une structure IFF
	move.l d0,IFF_Handle(a5)
	beq.s no_allociff

	move.l d0,a0				passe ca par le DOS
	CALL InitIFFasDOS

	move.l #DEATH_OK,d0
	RESTORE_REGS
	rts


*************************************************************************************************
*                                 ROUTINE DE SORTIE DE LA STARTUP
*
* en entrée: a5=ExtensionDataBase
*
*************************************************************************************************
Exit_Point
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_OK,ReturnCode-LocalData(a4)

	move.l IFF_Handle(a5),a0		libère la structure IFF
	CALL _IFFParseBase(a5),FreeIFF
no_allociff
	move.l DiamondFont(a5),a1		ferme la diamond.font
	CALL _GfxBase(a5),CloseFont
no_diamond
	move.l TopazFont(a5),a1			ferme la topaz.font
	CALL CloseFont
no_topaz
	move.l _IFFParseBase(a5),a1		ferme l'iffparse.library
	CALL _ExecBase(a5),CloseLibrary
no_iffparse
	move.l _DiskFontBase(a5),a1		ferme la diskfont.library
	CALL CloseLibrary
no_diskfont
	move.l _GadToolsBase(a5),a1		ferme la gadtools.library
	CALL CloseLibrary
no_gadtools
	move.l _GfxBase(a5),a1			ferme la graphics.library
	CALL CloseLibrary
no_gfx
	move.l Old_DataBase(pc),a0		recopie l'erreur
	move.l DeathErrorString(a5),DeathErrorString(a0)

	move.l a5,a1				libère l'ExtensionDataBase
	move.l #ExtensionData_SIZEOF,d0
	CALL FreeMem

	move.l Old_DataBase(pc),a5
no_allocmem
	move.l ReturnCode(pc),d0

	RESTORE_REGS
	rts


*************************************************************************************************
*                                         LES DATAS LOCALES
*************************************************************************************************
	CNOP 0,4
LocalData

ReturnCode	dc.l 0
Old_DataBase	dc.l 0

TopazFontAttr
	dc.l TopazName
	dc.w 8
	dc.b FS_NORMAL
	dc.b FPF_ROMFONT

DiamondFontAttr
	dc.l DiamondName
	dc.w 12
	dc.b FS_NORMAL
	dc.b FPF_DISKFONT

TopazName
	dc.b "topaz.font",0
DiamondName
	dc.b "diamond.font",0


LiveExtensionsName	dc.b "Live:LiveExtensions",0
			dc.b "EQU",0
			dc.b "ScreenManager",0
			dc.b "WindowManager",0
			dc.b "ClipartManager",0
			dc.b "ZoomBackGround",0
;;;;;			dc.b "MusicManager",0
			dc.b 0

LiveStartupName		dc.b "Live:Live-Script",0

GfxName			dc.b "graphics.library",0
GadToolsName		dc.b "gadtools.library",0
DiskFontName		dc.b "diskfont.library",0
IFFParseName		dc.b "iffparse.library",0

ErrorInitDeath		dc.b "Live-Startup initialization error.",0
