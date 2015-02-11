


*
* Death v1.0
* (c)1994 Sync/DreamDealers
*
* Le fichier d'EQU pour Death
*



DEATH_DEBUG=1

DEATH_ERROR=0
DEATH_OK=-1

DEATH_INTEGER="I"
DEATH_STRING="S"
DEATH_PROGRAM="P"


	rsreset
DeathData_Struct	rs.b 0
_ExecBase		rs.l 1
_IntuitionBase		rs.l 1
_DosBase		rs.l 1
DeathInitName		rs.l 1
DeathInitSegment	rs.l 1
DeathExtensionsName	rs.l 1
DeathStartupName	rs.l 1
DeathStack		rs.l 1
DeathForceExit		rs.l 1
DeathParseLine		rs.l 1
DeathExecute		rs.l 1
ExtensionsList		rs.l 1
IntegerList		rs.l 1
StringList		rs.l 1
ProgramList		rs.l 1
DeathErrorString	rs.l 1			*
DeathPrototype		rs.l 1			*
DeathDataSpace		rs.l 1			*
DeathArg0		rs.l 1			*
DeathArg1		rs.l 1			*
DeathArg2		rs.l 1			*
DeathArg3		rs.l 1			*
DeathArg4		rs.l 1			*
DeathArg5		rs.l 1			*
DeathArg6		rs.l 1			*
DeathArg7		rs.l 1			*
DeathArg8		rs.l 1			*
DeathArg9		rs.l 1			*
DeathArg10		rs.l 1			*
DeathArg11		rs.l 1			*
DeathArg12		rs.l 1			*
DeathArg13		rs.l 1			*
DeathArg14		rs.l 1			*
DeathArg15		rs.l 1			*
DeathData_SIZEOF	rs.b 0



	rsreset
Extension_Struct	rs.b 0
ext_Init		rs.l 1
ext_Exit		rs.l 1
ext_Tk			rs.l 1
ext_Next		rs.l 1
ext_Version		rs.b 0
Extension_SIZEOF	rs.b 0


	rsreset
Variable_Struct		rs.b 0
var_Next		rs.l 1
var_Label		rs.b 32
Variable_SIZEOF		rs.b 0


	rsreset
Integer_Struct		rs.b Variable_SIZEOF
int_Value		rs.l 1
Integer_SIZEOF		rs.b 0



	rsreset
String_Struct		rs.b Variable_SIZEOF
str_Value		rs.b 256
String_SIZEOF		rs.b 0



	rsreset
Program_Struct		rs.b Variable_SIZEOF
Prg_Value		rs.b 256
Program_SIZEOF		rs.b 0



SAVE_REGS	macro
	movem.l d1-d7/a0-a4/a6,-(sp)
	endm

RESTORE_REGS	macro
	movem.l (sp)+,d1-d7/a0-a4/a6
	endm
