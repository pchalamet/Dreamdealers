

*
*		Macros pour les messages de Live 2
*		-------------------------------------->
*

********************************************************************************
CLIPART	macro
	IIF CLIPART_FLAG		fail Double appel de CLIPART !!!
	IFNE (NARG=0)|(NARG=3)
		IIF MESS_FLAG dc.b 0
		IFEQ NARG
			dcb.b SKIP_CLIPART,NO_CLIPART
		ELSEIF
			dc.b \1,\2,\3
		ENDC
	ELSEIF
					fail Paramètres incorrects !!! ( CLIPART macro )
	ENDC
CLIPART_FLAG set 1
MESS_FLAG set 0
	endm


********************************************************************************
FROM	macro
	IIF FROM_FLAG			fail Double appel de FROM !!!
	IIF (CLIPART_FLAG=0)		CLIPART
	IIF (FROM_FLAG=1)		fail Appeller FROM avant FOR !!!
	IIF (MESS_FLAG=1)		fail Appeller FROM avant MESS !!!
	IFEQ NARG-3
		dc.b \1,0,\2,0,\3,0
	ELSEIF
					fail Paramètres incorrects !!! ( FROM macro )
	ENDC
FROM_FLAG set 1
	endm


********************************************************************************
FOR	macro
	IIF FOR_FLAG			fail Double appel de FOR !!!
	IIF (CLIPART_FLAG=0)		fail Appeller CLIPART avant FOR !!!
	IIF (FROM_FLAG=0)		fail Appeller FROM avant FOR !!!
	IIF (MESS_FLAG=1)		fail Appeller FOR avant MESS !!!
	IFEQ NARG-3
		dc.b \1,0,\2,0,\3,0
	ELSEIF
					fail Paramètres incorrects !!! ( FOR macro )
	ENDC
FOR_FLAG set 1
	endm


********************************************************************************
MESS	macro
	IFEQ MESS_FLAG
		IIF (CLIPART_FLAG=0)	fail Appeller CLIPART avant MESS
		IIF (FROM_FLAG=0)	fail Appeller FROM avant MESS
		IIF (FOR_FLAG=0)	fail Appeller FOR avant MESS
	ENDC
	IFEQ NARG-1
		IIF MESS_FLAG dc.b LF
		dc.b \1
	ELSEIF
					fail Paramètres incorrects !!! ( MESS macro )
	ENDC
CLIPART_FLAG set 0
FROM_FLAG set 0
FOR_FLAG set 0
MESS_FLAG set 1
	endm


********************************************************************************
BEGIN_MESS	macro
	dc.b 0
LiveMsg
	dcb.b SKIP_CLIPART,NO_CLIPART		met un mesage blanc afin de
	dcb.b 7,0				s'arreter dans la recherche

CLIPART_FLAG set 0
FROM_FLAG set 0
FOR_FLAG set 0
MESS_FLAG set 0
	endm


********************************************************************************
END_MESS	macro
EndLiveMsg
	dcb.b SKIP_CLIPART+1,0			pour arreter la recherche
	even
	endm
