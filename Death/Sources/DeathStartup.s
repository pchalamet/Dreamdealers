


**
** $VER:  Death v1.0
**        (c)1994 Sync/DreamDealers
**
** Chargeur et dechargeur du fichier startup de DEATH
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
	include "dos/dos_lib.i"
	include "dos/dos.i"
	include "dos/dosextens.i"
	include "misc/macros.i"

	include "Death.i"



*************************************************************************************************
*                               LES OPTIONS DE COMPILATIONS
*************************************************************************************************
	OPT ALINK
	OPT O+,OW-,OW1+,OW6+
	OPT INCONCE
	OPT EVEN
	IFEQ DEATH_DEBUG
	OPT NOLINE,NODEBUG
	ENDC

	OUTPUT Death:Objects/DeathStartup.o



*************************************************************************************************
*                             LES IMPORTS ET EXPORTS DE LABELS
*************************************************************************************************
	XDEF Load_Death_Startup
	XDEF Unload_Death_Startup

	XREF Execute_Extension_Init
	XREF Execute_Extension_Exit


	section DeathStartup,code
*************************************************************************************************
*                                CHARGEMENT DU FICHIER STARTUP DE DEATH
* en entrée: a5=DeathDataBase
*
* en sortie: d0=DEATH_OK ou DEATH_ERROR
*
*************************************************************************************************
Load_Death_Startup
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
	move.l #ErrorDeathStartup,DeathErrorString(a5)

	move.l DeathInitName(a5),d1		le startup code de DEATH
	CALL _DosBase(a5),LoadSeg
	move.l d0,d1
	beq.s no_startup

	move.l d0,a0
	bsr Execute_Extension_Init
	move.l a0,DeathInitSegment(a5)
	move.l #DEATH_OK,ReturnCode-LocalData(a4)
no_startup
	move.l ReturnCode(pc),d0
	RESTORE_REGS
	rts



*************************************************************************************************
*                              DECHARGEMENT DU FICHIER STARTUP DE DEATH
* en entrée: a5=DeathDataBase
*
* en sortie: d0=DEATH_OK ou DEATH_ERROR
*
*************************************************************************************************
Unload_Death_Startup
	SAVE_REGS

	move.l DeathInitSegment(a5),d0		yest au moins ?
	beq.s .exit
	move.l d0,a0				routine de fin de la startup
	bsr Execute_Extension_Exit
	move.l d0,d1				libère la startup
	CALL _DosBase(a5),UnLoadSeg

.exit
	RESTORE_REGS
	rts



*************************************************************************************************
*                                     LES DATAS LOCALES
*************************************************************************************************
	CNOP 0,4
LocalData

ReturnCode		dc.l 0

ErrorDeathStartup	dc.b "DEATH error:",10
			dc.b "Can't load DEATH startup",0
