
*			Font Converter pour Live II
*			------------------------------>

NB_CHAR=94

	lea Font(pc),a0
	lea FontStart(pc),a1
	moveq #0,d0				NB_CHAR à convertir
Convert_All
	moveq #8-1,d1
	move.l a0,a2
loop_convert_lettre
	move.b (a2),(a1)+
	lea 80(a2),a2
	dbf d1,loop_convert_lettre
	addq.l #1,a0				signe suivant dans l'image
	addq.w #1,d0

	cmp.w #80,d0				on change de ligne ?
	bne.s NEOF
	lea -80+80*10(a0),a0			ligne suivante dans l'image
NEOF
	cmp.w #NB_CHAR,d0
	bne.s Convert_All
	rts

Font
	incbin "Live2:Fonts/Font.RAW"
FontStart
	dcb.b NB_CHAR*8,0
FontEnd=*-1
