


**
** $VER:  Death v1.0
**        (c)1994 Sync/DreamDealers
**
** Parser pour le fichier startup de Death.
**



*************************************************************************************************
*                                TOUS LES INCLUDES DE DEATH
*************************************************************************************************
	incdir "include:"
	incdir "Death:"
	incdir "Death:Sources/"
	incdir "Death:Includes/"

	include "exec/exec_lib.i"
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

	OUTPUT Death:Objects/Parser.o



*************************************************************************************************
*                             LES IMPORTS ET EXPORTS DE LABELS
*************************************************************************************************
	XDEF Execute_Script_Startup

	XREF Execute_Exit_Routine



	section Parser,code
*************************************************************************************************
*                           EXECUTION DU FICHIER STARTUP DE DEATH
* en entrée: a5=ExtensionDataBase
*
*************************************************************************************************
Execute_Script_Startup
	SAVE_REGS

	lea LocalData(pc),a4

	move.l #ErrorInit,DeathErrorString(a5)

	move.l DeathStartupName(a5),d1		ouvre le fichier startup
	move.l #MODE_OLDFILE,d2
	CALL _DosBase(a5),Open
	move.l d0,StartupHandle-LocalData(a4)
	beq.s no_open_startup

	clr.w CurrDeathLine-LocalData(a4)
	clr.l DeathErrorString(a5)

	move.l #end_startup,DeathForceExit(a5)
	move.l #Parse_Line,DeathParseLine(a5)
	move.l #Execute,DeathExecute(a5)

loop_parse_startup
	addq.w #1,CurrDeathLine-LocalData(a4)
	move.l #DataSpace,DeathDataSpace(a5)
	move.l #ProtoSpace,DeathPrototype(a5)

	move.l StartupHandle(pc),d1		lit une ligne de la startup
	move.l #StartupLine,d2
	move.l #256,d3
	CALL _DosBase(a5),FGets
	tst.l d0				erreur ?
	beq.s error_read

parse_startup_line
	move.l d0,a0				a0=StartupLine
	bsr.s Parse_Line			execute la ligne

	tst.l d0				erreur ?
	bne.s loop_parse_startup
	bra.s error_extension

error_read
	CALL IoErr				fin de fichier startup ?
	tst.l d0
	beq.s end_startup
	move.l #ErrorInit,d0
end_startup
	move.l d0,DeathErrorString(a5)		installe le message d'erreur
error_extension
	move.l StartupHandle(pc),d1		ferme le fichier startup
	CALL Close
no_open_startup
	RESTORE_REGS
	rts




*************************************************************************************************
*                                   PARSING D'UNE LIGNE DEATH
* en entrée: a0=chaine C
*            a5=ExtensionDataBase
*
* en sortie: d0=DEATH_OK ou DEATH_ERROR
*            a5=ExtensionDataBase
*
*************************************************************************************************
Parse_Line
	moveq #0,d6				NbArgs
	move.l DeathDataSpace(a5),a1
	move.l DeathPrototype(a5),a2

* recherche l'instruction sur la ligne
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
search_instruction
	move.b (a0)+,d0
	beq Exit_Parse_Line			fin de ligne ?
	cmp.b #10,d0
	beq Exit_Parse_Line
	cmp.b #"*",d0				un commentaire ?
	beq Exit_Parse_Line
	cmp.b #" ",d0				espace ?
	beq.s search_instruction
	cmp.b #9,d0				tabulation ?
	beq.s search_instruction
	subq.l #1,a0				un de trop !

* lit l'instruction et on la stocke au passage
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dup_instrname
	move.b (a0)+,d0
	beq.s instr_dupped			fin de ligne ?
	cmp.b #10,d0
	beq.s instr_dupped
	cmp.b #" ",d0				espace ?
	beq.s instr_dupped
	cmp.b #9,d0				tabulation ?
	beq.s instr_dupped
	cmp.b #"*",d0				commentaire ?
	beq.s instr_dupped
	move.b d0,(a1)+
	bra.s dup_instrname
instr_dupped
	subq.l #1,a0
	clr.b (a1)+				met un 0 à la fin de l'instruction

* recherche les variables et les stockent dans la pile
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set_separator
	st d7					un separator un !
process_var
	move.b (a0)+,d0
	beq execute_instr			fin de la ligne ?
	cmp.b #10,d0
	beq execute_instr
	cmp.b #" ",d0				espace ?
	beq.s process_var
	cmp.b #9,d0				tabulation ?
	beq.s process_var
	cmp.b #"*",d0				commentaire ?
	beq execute_instr
	cmp.b #",",d0				separateur de variable ?
	beq.s set_separator
.no_separator
	tst.b d7				c'est autre chose : ya un separator ?
	beq missing_separator

***************
* les entiers *
***************
check_integer
	cmp.b #"0",d0				c'est un entier
	blt.s check_string
	cmp.b #"9",d0
	bgt.s check_string

	subq.l #1,a0
	bsr Read_Integer			lit l entier

	move.l d0,DeathArg0(a5,d6.w*4)		sauve l'argument
	move.b #DEATH_INTEGER,(a2)+
	addq.w #1,d6
	moveq #0,d7
	bra.s process_var

******************************
* les chaines de charactères *
******************************
check_string
	cmp.b #'"',d0				c'est une string ?
	bne.s check_program

	move.l a1,a3
	bsr Read_String

	move.l a3,DeathArg0(a5,d6.w*4)		sauve l'argument
	move.b #DEATH_STRING,(a2)+
	addq.w #1,d6
	moveq #0,d7
	bra.s process_var

******************
* les programmes *
******************
check_program
	cmp.b #"(",d0
	bne.s check_EQU

	move.l a1,a3
	bsr Read_Program

	move.l a3,DeathArg0(a5,d6.w*4)		sauve l'argument
	move.b #DEATH_PROGRAM,(a2)+
	addq.w #1,d6
	moveq #0,d7
	bra process_var

***********
* les EQU *
***********
check_EQU
	subq.l #1,a0
	move.l a1,a3
	bsr Read_EQU

	movem.l a0-a2,-(sp)

	move.l IntegerList(a5),a0		est-ce un integer ?
	move.l a3,a1
	bsr Search_EQU
	bne.s .not_int

	move.l a0,a3
	movem.l (sp)+,a0-a2

	move.l int_Value(a3),DeathArg0(a5,d6.w*4)	sauve l'argument
	move.b #DEATH_INTEGER,(a2)+
	addq.w #1,d6
	moveq #0,d7
	bra process_var

.not_int
	move.l StringList(a5),a0		est-ce une string ?
	move.l a3,a1
	bsr Search_EQU
	bne.s .error

	lea str_Value(a0),a3
	movem.l (sp)+,a0-a2

	move.l a3,DeathArg0(a5,d6.w*4)		sauve l'argument
	move.b #DEATH_STRING,(a2)+
	addq.w #1,d6
	moveq #0,d7
	bra process_var

.error
	movem.l (sp)+,a0-a2
	bra error_var_type


******************
* sortie normale *
******************
Exit_Parse_Line
	move.l #DEATH_OK,d0
	rts


*************************************************************************************************
*                                   LECTURE D'UN ENTIER DECIMAL
*
* en entrée: a0=*char
*            a5=ExtensionDataBase
*
* en sortie: d0=l'integer
*            
*************************************************************************************************
Read_Integer
	moveq #0,d0
	moveq #0,d1
.loop_read_integer
	move.b (a0)+,d1
	beq.s .recognized			fin de la ligne ?
	cmp.b #10,d1
	beq.s .recognized
	cmp.b #" ",d1				un espace ?
	beq.s .recognized
	cmp.b #9,d1				une tabulation ?
	beq.s .recognized
	cmp.b #",",d1				une autre variable ?
	beq.s .recognized
	cmp.b #"*",d1				commentaire ?
	beq.s .recognized
	cmp.b #"0",d1				verifie le type de la variable
	blt error_var_type
	cmp.b #"9",d1
	bgt error_var_type
	mulu.l #10,d0
	sub.b #"0",d1				passe au decimal
	add.l d1,d0
	bra.s .loop_read_integer
.recognized
	subq.l #1,a0				un de trop !
	rts




*************************************************************************************************
*                             LECTURE D'UNE CHAINE DE CHARACTERES
*
* en entrée: a0=*char
*            a1=Buffer de stockage
*            a5=ExtensionDataBase
*
* en sortie: le buffer est ok
*            
*************************************************************************************************
Read_String
	move.b (a0)+,d0
	beq.s .recognized			fin de la ligne ?
	cmp.b #10,d0
	beq.s .recognized
	cmp.b #'"',d0				fin de la string ?
	beq.s .recognized
	move.b d0,(a1)+
	bra.s Read_String
.recognized
	clr.b (a1)+				met un 0 à la fin
	rts




*************************************************************************************************
*                                 LECTURE D'UNE LIGNE DE PROGRAMME
*
* en entrée: a0=*char
*            a1=Buffer de stockage
*            a5=ExtensionDataBase
*
* en sortie: le buffer est ok
*            
*************************************************************************************************
Read_Program
	move.b (a0)+,d0
	beq.s .recognized			fin de la ligne ?
	cmp.b #10,d0
	beq.s .recognized
	cmp.b #")",d0				fin du program ?
	beq.s .recognized
	move.b d0,(a1)+
	bra.s Read_Program
.recognized
	clr.b (a1)+				met un 0 à la fin
	rts




*************************************************************************************************
*                                   LECTURE D'UN EQU
*
* en entrée: a0=*char
*            a1=Buffer de stockage
*            a5=ExtensionDataBase
*
* en sortie: le buffer est ok
*            
*************************************************************************************************
Read_EQU
	move.b (a0)+,d0
	beq.s .recognized			fin de la ligne ?
	cmp.b #10,d0
	beq.s .recognized
	cmp.b #" ",d0				espace ?
	beq.s .recognized
	cmp.b #9,d0				tabulation ?
	beq.s .recognized
	cmp.b #",",d0				autre variable ?
	beq.s .recognized
	cmp.b #"*",d0				commentaire ?
	beq.s .recognized
	cmp.b #"A",d0				c'est dans A-Z ?
	blt error_var_type
	cmp.b #"Z",d0
	ble.s .equ
	cmp.b #"a",d0				c'est dans a-z ?
	blt error_var_type
	cmp.b #"z",d0
	bgt error_var_type
.equ
	move.b d0,(a1)+
	bra.s Read_EQU
.recognized
	clr.b (a1)+				chaine C
	subq.l #1,a0				un en trop !
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
*                           EXECUTION DE L'INSTRUCTION SI POSSIBLE
* a5=DataBase
*************************************************************************************************
execute_instr
	clr.b (a2)+				met un 0 à la fin du prototype
Execute
	move.l ExtensionsList(a5),d0
	bra.s start_search_instr
search_into_all_extensions
	move.l d0,a0
	move.l ext_Tk(a0),a1			table Tk dans a1
search_into_Tk
	move.l (a1)+,d7				routine à appeller dans d7

* regarde si l'instruction est la meme
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l DeathDataSpace(a5),a2
.str_cmp
	move.b (a2)+,d0				Z=strcmp(a1,a2)
	beq.s .chk_end
	cmp.b (a1)+,d0
	beq.s .str_cmp
	bra.s go_next_instruction
.chk_end
	tst.b (a1)+
	bne.s go_next_instruction

* regarde si le prototype est le meme
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
chk_proto
	move.l DeathPrototype(a5),a2
.str_cmp
	move.b (a2)+,d0				Z=strcmp(a1,a2)
	beq.s .chk_end
	cmp.b (a1)+,d0
	beq.s .str_cmp
	bra.s go_next_prototype
.chk_end
	tst.b (a1)+
	bne.s go_next_prototype

* ca a marché !!
* ~~~~~~~~~~~~~~
	move.l d7,a1				execute l'instruction + rts
	jmp (a1)


* ca a foiré => passe à l'instruction suivante
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
go_next_instruction
	tst.b (a1)+				saute le reste de l'instruction
	bne.s go_next_instruction

go_next_prototype
	tst.b (a1)+				et saute aussi le prototype
	bne.s go_next_prototype

	move.l a1,d0				pointeur sur CNOP 0,2  non mais!
	addq.l #1,d0
	bclr #0,d0
	move.l d0,a1

	tst.l (a1)				yen a encore ?
	bne.s search_into_Tk

no_more_instr_in_extension
	move.l ext_Next(a0),d0
start_search_instr
	bne.s search_into_all_extensions



*************************************************************************************************
*                        TOUTES LES ERREURS POSSIBLES LORS DU PARSING
*************************************************************************************************
error_unknown_instr
	move.l #ErrorInstr,DeathErrorString(a5)
	bra.s error_while_parsing

error_prototype
	move.l #ErrorPrototype,DeathErrorString(a5)
	bra.s error_while_parsing

missing_separator
	move.l #ErrorSeparator,DeathErrorString(a5)
	bra.s error_while_parsing

error_var_type
	move.l #ErrorVarType,DeathErrorString(a5)

error_while_parsing
	move.l #DEATH_ERROR,d0
	rts




*************************************************************************************************
*                                 LES DATAS LOCALES DU PARSER
*************************************************************************************************
	CNOP 0,4
LocalData

StartupHandle	dc.l 0
CurrDeathLine	dc.w 0

StartupLine	dcb.b 256,0

DataSpace	dcb.b 256,0
ProtoSpace	dcb.b 16,0

ErrorInit	dc.b "DEATH error:",10
		dc.b "Can't execute the script",0

ErrorVarType	dc.b "DEATH error:",10
		dc.b "Unknown variable type at line %d",0

ErrorSeparator	dc.b "DEATH error:",10
		dc.b 'Expected "," at line %d',0

ErrorPrototype	dc.b "DEATH error:",10
		dc.b "Incorrect number of arguments at line %d",0

ErrorInstr	dc.b "DEATH error:",10
		dc.b "Unknown instruction at line %d",0

ErrorMemory	dc.b "DEATH error:",10
		dc.b "Not enough memory",10
