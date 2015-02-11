


**
** $VER:  Death v1.0
**        (c)1994 Sync/DreamDealers
**
** Startup Code pour Death
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
	include "libraries/iffparse_lib.i"
	include "intuition/intuition_lib.i"
	include "intuition/intuition.i"
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

	OUTPUT Death:Objects/MainDeath.o



*************************************************************************************************
*                             LES IMPORTS ET EXPORTS DE LABELS
*************************************************************************************************
	XREF Load_Extensions
	XREF Unload_Extensions
	XREF Execute_Script_Startup
	XREF Load_Death_Startup
	XREF Unload_Death_Startup



	section MainDeath,code
*************************************************************************************************
*                                  POINT D'ENTREE DE DEATH
*************************************************************************************************
	bra.s Death_Main
Version
	dc.b "$VER: Death Parser v1.2 - (c)1994 Sync/DreamDealers",0
	CNOP 0,4

Death_Main
	clr.b -1(a0,d0.w)			met un 0 à la fin de la ligne CLI
	move.l a0,a2

	lea LocalData(pc),a4
	lea DeathDataBase,a5
	move.l (_SysBase).w,a6

	move.l a6,_ExecBase(a5)
	move.l a2,DeathInitName(a5)

	lea IntuitionName(pc),a1		ouvre l'intuition.library
	moveq #0,d0
	CALL OpenLibrary
	move.l d0,_IntuitionBase(a5)
	beq.s no_intuition

	move.l #ErrorDos,DeathErrorString(a5)
	lea DosName(pc),a1			ouvre la dos.library
	moveq #0,d0
	CALL OpenLibrary
	move.l d0,_DosBase(a5)
	beq.s no_dos

	bsr Load_Death_Startup			execute la startup de DEATH
	cmp.l #DEATH_ERROR,d0
	beq.s no_startup

	bsr Load_Extensions			charge les extensions
	cmp.l #DEATH_ERROR,d0
	beq.s no_extension

	bsr Execute_Script_Startup

	bsr Unload_Extensions			libère les extensions
no_extension
	bsr Unload_Death_Startup		libère la startup
no_startup
	move.l _DosBase(a5),a1			ferme la dos.library
	CALL _ExecBase(a5),CloseLibrary
no_dos
	move.l DeathErrorString(a5),DeathRequest+es_TextFormat-LocalData(a4)
	beq.s .no_request
	sub.l a0,a0
	lea DeathRequest(pc),a1
	sub.l a2,a2
	sub.l a3,a3
	CALL _IntuitionBase(a5),EasyRequestArgs
.no_request
	move.l _IntuitionBase(a5),a1		ferme l'intuition.library
	CALL _ExecBase(a5),CloseLibrary
no_intuition
	moveq #0,d0
	rts




*************************************************************************************************
*                           LES DATAS LOCALES DE LA STARTUP DE DEATH
*************************************************************************************************
	CNOP 0,4
LocalData

DeathRequest
	dc.l es_SIZEOF
	dc.l 0
	dc.l DeathRequestTitle
	dc.l 0
	dc.l DeathRequestGadgets

DeathRequestTitle	dc.b "Death Request",0
DeathRequestGadgets	dc.b "OK",0

IntuitionName		dc.b "intuition.library",0
DosName			dc.b "dos.library",0

ErrorDos		dc.b "Can't open the",10
			dc.b "dos.library",0



*************************************************************************************************
*                                          LES DATAS GLOBALES
*************************************************************************************************
	section DeathDataBase,bss
DeathDataBase
	ds.b DeathData_SIZEOF
