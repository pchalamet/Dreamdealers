


**
** $VER:  Death v1.0
**        (c)1994 Sync/DreamDealers
**
** Manager des extensions pour Death
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

	OUTPUT Death:Objects/Extensions.o



*************************************************************************************************
*                             LES IMPORTS ET EXPORTS DE LABELS
*************************************************************************************************
	XDEF Load_Extensions
	XDEF Unload_Extensions
	XDEF Execute_Extension_Init
	XDEF Execute_Extension_Exit




	section Extensions,code
*************************************************************************************************
*                                CHARGEMENT DE TOUTES LES EXTENSIONS
* en entrée: a5=DeathDataBase
*
* en sortie: d0=DEATH_OK ou DEATH_ERROR
*
*************************************************************************************************
Load_Extensions
	SAVE_REGS

	lea LocalData(pc),a4

	move.l #ErrorExtensions,DeathErrorString(a5)
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
;;	clr.l ExtensionsList(a5)

	move.l DeathExtensionsName(a5),d1	lock sur le dir d'extension
	move.l #SHARED_LOCK,d2
	CALL _DosBase(a5),Lock
	move.l d0,d1
	beq.s no_lock

	CALL CurrentDir				on se fixe dessus
	move.l d0,OldDir-LocalData(a4)

	move.l DeathExtensionsName(a5),a2
	bra.s .start_load_extensions

.load_extensions
	move.l a2,d1				charge l'extension
	CALL LoadSeg
	tst.l d0
	beq.s no_loadseg

	bsr.s Execute_Extension_Init
	cmp.l #DEATH_OK,d0			erreur dans l'init ?
	beq.s .init_ok

	move.l a0,d1				ca a foiré.. libère l'extension tout de
	subq.l #4,d1				suite
	lsr.l #2,d1
	CALL UnLoadSeg
	bra.s no_loadseg

.init_ok
	move.l ExtensionsList(a5),ext_Next(a0)
	move.l a0,ExtensionsList(a5)

.start_load_extensions
	tst.b (a2)+				passe à l'extension suivante
	bne.s .start_load_extensions
	tst.b (a2)				yen a d'autres ?
	bne.s .load_extensions

.no_more
	move.l #DEATH_OK,ReturnCode-LocalData(a4)
no_loadseg
	move.l OldDir(pc),d1			on se remet ou on était avant
	CALL CurrentDir
	move.l d0,d1
	CALL UnLock
no_lock
	move.l ReturnCode(pc),d0		code de retour
	RESTORE_REGS
	rts



*************************************************************************************************
*                         EXECUTE LE PREMIER SEGMENT D'UN EXECUTABLE
*
* en entrée: d0=Segment DOS BPTR
*
* en sortie: a0=Segment DOS APTR
*
*******************************$$****************************************************************
Execute_Extension_Init
	add.l d0,d0				saute à la routine d'init de l'extension
	add.l d0,d0
	addq.l #4,d0
	move.l d0,a0
	move.l ext_Init(a0),a1			saute à la routine d'init de l'extension
	jsr (a1)
	rts



*************************************************************************************************
*                         EXECUTE LE PREMIER SEGMENT D'UN EXECUTABLE
*
* en entrée: a0=Segment DOS APTR
*
* en sortie: d0=Segment DOS BPTR
*
*************************************************************************************************
Execute_Extension_Exit
	move.l ext_Exit(a0),a1			saute à la routine de fin de l'extension
	jsr (a1)
	move.l a0,d0
	subq.l #4,d0				conversion BPTR -> APTR
	lsr.l #2,d0
	rts




*************************************************************************************************
*                          ELIMINATION DE TOUTES LES EXTENSIONS CHARGEES
* en entrée: a4=LocalData
*            a5=DeathDataBase
*
*************************************************************************************************
Unload_Extensions
	SAVE_REGS

	move.l ExtensionsList(a5),d0
	bra.s .start_unload

.unload_more
	move.l d0,a0
	move.l d0,-(sp)
	bsr.s Execute_Extension_Exit

	move.l d0,d1				libère le segment de l'extension
	CALL _DosBase(a5),UnLoadSeg

	move.l (sp)+,a0
	move.l ext_Next(a0),d0			extension suivante
.start_unload
	bne.s .unload_more

	RESTORE_REGS
	rts





*************************************************************************************************
*                                   LES VARIABLES LOCALES
*************************************************************************************************
	CNOP 0,4
LocalData

ReturnCode		dc.l 0
OldDir			dc.l 0
;;ExtensionSegment	dc.l 0

StartupName		dc.b "Death-Startup",0

ErrorStartup		dc.b "DEATH error:",10
			dc.b "Can't load DEATH startup code",0

ErrorExtensions		dc.b "Can't load the",10
			dc.b "DEATH's extensions",0
