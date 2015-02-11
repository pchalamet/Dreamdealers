

MAKE_PALETTE	macro
Palette set $0000
\1_Hi=*+4
	REPT 8
	dc.w bplcon3,Palette
	dc.w color00,$000
	dc.w color01,$000
	dc.w color02,$000
	dc.w color03,$000
	dc.w color04,$000
	dc.w color05,$000
	dc.w color06,$000
	dc.w color07,$000
	dc.w color08,$000
	dc.w color09,$000
	dc.w color10,$000
	dc.w color11,$000
	dc.w color12,$000
	dc.w color13,$000
	dc.w color14,$000
	dc.w color15,$000
	dc.w color16,$000
	dc.w color17,$000
	dc.w color18,$000
	dc.w color19,$000
	dc.w color20,$000
	dc.w color21,$000
	dc.w color22,$000
	dc.w color23,$000
	dc.w color24,$000
	dc.w color25,$000
	dc.w color26,$000
	dc.w color27,$000
	dc.w color28,$000
	dc.w color29,$000
	dc.w color30,$000
	dc.w color31,$000

Palette set Palette+$2000
	ENDR

Palette set $0000
\1_Lo=*+4
	REPT 8
	dc.w bplcon3,Palette|$200
	dc.w color00,$000
	dc.w color01,$000
	dc.w color02,$000
	dc.w color03,$000
	dc.w color04,$000
	dc.w color05,$000
	dc.w color06,$000
	dc.w color07,$000
	dc.w color08,$000
	dc.w color09,$000
	dc.w color10,$000
	dc.w color11,$000
	dc.w color12,$000
	dc.w color13,$000
	dc.w color14,$000
	dc.w color15,$000
	dc.w color16,$000
	dc.w color17,$000
	dc.w color18,$000
	dc.w color19,$000
	dc.w color20,$000
	dc.w color21,$000
	dc.w color22,$000
	dc.w color23,$000
	dc.w color24,$000
	dc.w color25,$000
	dc.w color26,$000
	dc.w color27,$000
	dc.w color28,$000
	dc.w color29,$000
	dc.w color30,$000
	dc.w color31,$000

Palette set Palette+$2000
	ENDR

	ENDM
	

MAKE_BITPLAN	macro
Bitplan set bpl1ptH
\1=*
	REPT 8
	dc.w Bitplan,0
	dc.w Bitplan+2,0
Bitplan set Bitplan+4
	ENDR
	
	ENDM