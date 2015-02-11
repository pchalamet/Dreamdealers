

* dc.l $3f3		hunk_header
* dc.l 0		fin hunk_name
* dc.l 2		nombre de hunk
* dc.l 0		numero du premier hunk
* dc.l 1		numero du dernier hunk
* dc.l $0xxxxxxx	taille en LONG du hunk 0
* dc.l $4xxxxxxx	taille en LONG du hunk 1 + HUNK_CHIP

* dc.l $000003ea	HUNK_DATA
* dc.l $0xxxxxxx	taille en LONG du hunk 0
* dc.l ...		data du hunk 0
* dc.l $000003ec	HUNK_RELOC32
* dc.l 2		nombre de relocations
* dc.l 1		relocation sur le hunk 1
* dc.l 0		offset premiere relocation
* dc.l 0		offset deuxième relocation
* dc.l 0		fin du hunk relocation
* dc.l $000003f2	HUNK_END

* dc.l $400003ea	HUNK_DATA + HUNK_CHIP
* dc.l $0xxxxxxx	taille en LONG du hunk 1
* dc.l ...		data du hunk 1
* dc.l $000003f2	HUNK_END


	opt nodebug,noline
	output ram:X


	section hunk0,data
	rts
	dc.l boudin
	rts

	section hunk1,data_c
	rts
	rts
boudin
	rts
	rts
