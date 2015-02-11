


*
* Death v1.0
* (c)1994 Sync/DreamDealers
*
* Le fichier d'EQU pour les extensions de DEATH pour Live
*



	incdir "Death:"
	incdir "include:"
	incdir "Death:Sources/"
	include "Death.i"
	include "intuition/intuition.i"


LIVE_DEBUG=0

SCREEN_X=640
SCREEN_Y=256
SCREEN_DEPTH=8
NB_COLORS=1<<SCREEN_DEPTH



	rsreset
ExtensionData_Struct	rs.b DeathData_SIZEOF
_GfxBase		rs.l 1
_GadToolsBase		rs.l 1
_DiskFontBase		rs.l 1
_IFFParseBase		rs.l 1
IFF_Handle		rs.l 1
TopazFont		rs.l 1
DiamondFont		rs.l 1
LiveScreen		rs.l 1
LiveScreen_VisualInfo	rs.l 1
LiveWindow		rs.l 1
LiveScreenColors	rs.l 2+NB_COLORS*3
ClipartList		rs.l 1
WindowList		rs.l 1
ModuleAdr		rs.l 1
ModuleSize		rs.l 1
ExtensionData_SIZEOF	rs.b 0



	rsreset
Clipart_Struct		rs.b 0
ca_Name			rs.b 32
ca_Image		rs.b ig_SIZEOF
ca_Colors		rs.l 2+32*3
ca_Next			rs.l 1
Clipart_SIZEOF		rs.b 0



	rsreset
Window_Struct		rs.b 0
win_X			rs.w 1
win_Y			rs.w 1
win_Width		rs.w 1
win_Height		rs.w 1
win_BackBitMap		rs.l 1
win_Next		rs.l 1
Window_SIZEOF		rs.b 0




WINDOW_BORDER_LEFT=2
WINDOW_BORDER_RIGHT=4
WINDOW_BORDER_TOP=1
WINDOW_BORDER_BOTTOM=2


EXECUTE_FORCE_EXIT	macro
	move.l DeathForceExit(a5),a0
	jmp (a0)
	endm

EXECUTE_INSTR	macro
	move.l DeathDataSpace(a5),-(sp)
	move.l DeathPrototype(a5),-(sp)
	move.l #\1,DeathDataSpace(a5)
	move.l #\2,DeathPrototype(a5)
	movem.l d1-d7/a0-a6,-(sp)
	move.l DeathExecute(a5),a0
	jsr (a0)
	movem.l (sp)+,d1-d7/a0-a6
	move.l (sp)+,DeathPrototype(a5)
	move.l (sp)+,DeathDataSpace(a5)
	endm


