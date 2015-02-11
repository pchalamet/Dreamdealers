


**
** $VER:  Live AGA v1.0
**        (c)1994 Sync/DreamDealers
**
** Fichier d'instruction par default de DEATH
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

	OUTPUT Live:LiveExtensions/EQU




*************************************************************************************************
*                                 ROUTINES D'INIT DE L'EXTENSION
* en entrée: a5=ExtensionDataBase
*
* en sortie: d0=DEATH_ERROR ou DEATH_OK
*            a5=ExtensionDataBase
*
*************************************************************************************************
Extension_Tags
	dc.l Init_Point
	dc.l Exit_Point
	dc.l Tk
	dc.l 0
Version
	dc.b "$VER: EQU v1.0 - (c)1994 Sync/DreamDealers",0
	CNOP 0,4

Init_Point
	move.l #DEATH_OK,d0
	rts

* routine de fin => libère toutes les variables
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Exit_Point
	SAVE_REGS

	move.l _ExecBase(a5),a6

	move.l IntegerList(a5),d0
	bra.s .start_int
.purge_int
	move.l d0,a1
	move.l var_Next(a1),a2
	move.l #Integer_SIZEOF,d0
	CALL FreeMem
	move.l a2,d0
.start_int
	bne.s .purge_int
	clr.l IntegerList(a5)

	move.l StringList(a5),d0
	bra.s .start_str
.purge_str
	move.l d0,a1
	move.l var_Next(a1),a2
	move.l #String_SIZEOF,d0
	CALL FreeMem
	move.l a2,d0
.start_str
	bne.s .purge_str
	clr.l StringList(a5)

	RESTORE_REGS
	rts







*************************************************************************************************
*                   INSTRUCTION PERMETANT DE FAIRE UN EQU AVEC UN INTEGER
*
* en entrée: a5=ExtensionDataBase
*
* en sortie: d0=DEATH_OK ou DEATH_ERROR
*            a5=ExtensionDataBase
*
*************************************************************************************************
Let_Integer
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
	move.l #ErrorLet,DeathErrorString(a5)

	move.l IntegerList(a5),a0		regarde si on a pas par hazard un EQU
	move.l DeathArg0(a5),a1			du meme nom
	bsr Search_EQU
	beq.s .no_mem

	move.l StringList(a5),a0
	move.l DeathArg0(a5),a1
	bsr Search_EQU
	beq.s .no_mem

	move.l #Integer_SIZEOF,d0		alloue de la mémoire pour la variable
	move.l #MEMF_ANY|MEMF_CLEAR,d1
	CALL _ExecBase(a5),AllocMem
	tst.l d0
	beq.s .no_mem

	move.l d0,a0

	move.l DeathArg0(a5),a1			recopie le label de l'integer
	lea var_Label(a0),a2
.name	move.b (a1)+,(a2)+
	bne.s .name

	move.l DeathArg1(a5),int_Value(a0)

	move.l IntegerList(a5),var_Next(a0)	link ca dans la liste
	move.l a0,IntegerList(a5)
	move.l #DEATH_OK,ReturnCode-LocalData(a4)
.no_mem
	move.l ReturnCode(pc),d0
	RESTORE_REGS
	rts



*************************************************************************************************
*                   INSTRUCTION PERMETANT DE FAIRE UN EQU AVEC UNE STRING 
*
* en entrée: a5=ExtensionDataBase
*
* en sortie: d0=DEATH_OK ou DEATH_ERROR
*            a5=ExtensionDataBase
*
*************************************************************************************************
Let_String
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
	move.l #ErrorLet,DeathErrorString(a5)

	move.l IntegerList(a5),a0		regarde si on a pas par hazard un EQU
	move.l DeathArg0(a5),a1			du meme nom
	bsr.s Search_EQU
	beq.s .no_mem

	move.l StringList(a5),a0
	move.l DeathArg0(a5),a1
	bsr.s Search_EQU
	beq.s .no_mem

	move.l #String_SIZEOF,d0		alloue de la mémoire
	move.l #MEMF_ANY|MEMF_CLEAR,d1
	CALL _ExecBase(a5),AllocMem
	tst.l d0
	beq.s .no_mem

	move.l d0,a0

	move.l DeathArg0(a5),a1			recopie le label de la string
	lea var_Label(a0),a2
.name	move.b (a1)+,(a2)+
	bne.s .name

	move.l DeathArg1(a5),a1			recopie la string
	lea str_Value(a0),a2
.dup	move.b (a1)+,(a2)+
	bne.s .dup

	move.l StringList(a5),var_Next(a0)	link tout ca
	move.l a0,StringList(a5)
	move.l #DEATH_OK,ReturnCode-LocalData(a4)
.no_mem
	move.l ReturnCode(pc),d0
	RESTORE_REGS
	rts



*************************************************************************************************
*                                  RECHERCHE D'UN EQU DANS UNE LISTE
*
* en entrée: a0=List
*            a1=EQU
*
* en sortie: a0=Structure
*            Z ?
*
*************************************************************************************************
Search_EQU
	move.l a0,d1
	bra.s .start
.start_cmp
	move.l d1,a0
	lea var_Label(a0),a0
	move.l a1,a2
.cmp
	move.b (a0)+,d0
	beq.s .chk_end
	cmp.b (a2)+,d0
	beq.s .cmp
.next
	move.l d1,a0
	move.l var_Next(a0),d1
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
*                                  LA TABLE DES INSTRUCTIONS
*************************************************************************************************
Tk
* LET "Name",integer
	dc.l Let_Integer
	dc.b "LET",0
	dc.b "SI",0

* LET "Name",string
	dc.l Let_String
	dc.b "LET",0
	dc.b "SS",0

	dc.l 0



*************************************************************************************************
*                                  LES VARIABLES LOCALES
*************************************************************************************************
LocalData

ReturnCode
	dc.l 0

ErrorLet
	dc.b "Instruction LET failed",0
