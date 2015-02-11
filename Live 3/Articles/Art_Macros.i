
*			macros pour les articles
*			~~~~~~~~~~~~~~~~~~~~~~~~

BEGIN_ARTICLE	macro
	dc.b 0,0
LINE_NUM set 0
	endm

LINE	macro
	IFEQ NARG=1
		fail missing parameters ( LINE macro )
	ENDC
	dc.b \1,10
LINE_NUM set LINE_NUM+1
	IFNE LINE_NUM=21
LINE_NUM set 0
	dc.b 0
	ENDC
	endm

END_PAGE	macro
LINE_NUM set 0
	dc.b 0
	endm

END_ARTICLE	macro
	dc.b 0
	IFNE LINE_NUM
	dc.b 0
	ENDC
	endm
