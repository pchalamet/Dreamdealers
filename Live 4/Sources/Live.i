

* EQU pour les ecrans de LIVE
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~
NB_DZIGN=2
SCREEN_X=640
SCREEN_Y=256
SCREEN_WIDTH=SCREEN_X/8
SCREEN_DEPTH=4
NB_COLORS=1<<SCREEN_DEPTH
BACKGROUND_COLOR=$234
PART1=0
PART2=19
PART3=PART2+195
PAGE_X=76
PAGE_Y=21
NUMBER_END=60
NUMBER_POS=55
NB_LEFT=PAGE_Y-2
NB_RIGHT=PAGE_Y-2-6
GALLERY_NAMESIZE=40

* Définitions des structures utilisées dans LIVE
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	rsreset
GadgetStruct	rs.b 0
gs_Left		rs.w 1
gs_Top		rs.w 1
gs_Right	rs.w 1
gs_Bottom	rs.w 1
gs_Button	rs.w 1
gs_Type		rs.w 1
gs_Routine	rs.l 1			/GadgetStruct
gs_SIZEOF	rs.b 0

	rsreset
ShortCutStruct	rs.b 0
scs_Code	rs.b 1
scs_Type	rs.b 1
scs_Routine	rs.l 1			/ShortCutStruct
scs_SIZEOF	rs.b 0

	rsreset
BobStruct	rs.b 0
bs_CoordX	rs.w 1			* CoordX réelle pour un Gadget mais
bs_CoordY	rs.w 1			* CoordX pointant sur un mot pour ClipArt
bs_BltSize	rs.w 1
bs_Modulo	rs.w 1
bs_PackedData	rs.l 1			/BobStruct
bs_SIZEOF	rs.b 0

	rsreset
GalleryStruct	rs.b 0
grs_BltSize	rs.w 1
grs_Modulo	rs.w 1
grs_Name	rs.b GALLERY_NAMESIZE
grs_SIZEOF	rs.b 0

	rsreset
PackStruct	rs.b 0
ps_PackedSize	rs.w 1
ps_UnpackedSize	rs.w 1
ps_Data		rs.b 0

	rsreset
MenuStruct	rs.b 0
ms_ExtraRender	rs.l 1			en retour: d0=ColorMap
ms_Text		rs.l 1
ms_BarText	rs.l 1
ms_MenuPos	rs.w 1
ms_DefLMenu	rs.l 1			le menu existe ?
ms_DefLMenuType	rs.l 1			type du menu  1=SubMenu  0=Routine
ms_LPtrs	rs.l 21			ptrs pour le type de menu
ms_DefRMenu	rs.l 1
ms_DefRMenuType	rs.l 1
ms_RPtrs	rs.l 21
ms_SIZEOF	rs.b 0

	rsreset
DZign_Struct	rs.b 0			*** TOUT pointe vers la CHIP ***
dz_Top		rs.l 1			ptr sur le haut
dz_Bottom	rs.l 1			ptr sur le bas
dz_Mouse	rs.l 1			ptr sur la souris
dz_Border0	rs.l 1			ptr sprite gauche pair
dz_Border1	rs.l 1			ptr sprite gauche impair
dz_Border2	rs.l 1			ptr sprite droit pair
dz_Border3	rs.l 1			ptr sprite droit impair
dz_Colors0	rs.w NB_COLORS		table des couleurs ecrans
dz_Colors1	rs.w 16			table des couleurs sprites
dz_SIZEOF	rs.b 0

	rsreset
pp_Struct	rs.b 0
pp_Colors	rs.w NB_COLORS		valable uniquement pour le cliparts
pp_Datas	rs.b 0

	rsreset
Font_Struct	rs.b 0
fs_Size		rs.w 1			la taille de la fonte
fs_Chars	rs.b 94*8		datas des lettres
fs_SIZEOF	rs.b 0

* EQU en tous genres
* ~~~~~~~~~~~~~~~~~~
LEFT_MB=$ff00
RIGHT_MB=$00ff
DEFERED=-1
IMMEDIATE=0
NO_SHORTCUT=$f0


* Définitions des macros
* ~~~~~~~~~~~~~~~~~~~~~~
START_HITBOX	macro
	dc.w (.end_hitbox-*-2)/gs_SIZEOF-1
	endm

END_HITBOX	macro
.end_hitbox
	endm

* DEF_HITBOX coordX1,coordY1,LargeX,HautY,buttons,type,routine
DEF_HITBOX	macro
.gadget\@
	dc.w \1,\2,\1+\3-1,\2+\4-1,\5,\6
	dc.l \7-.gadget\@
	endm

START_SHORTCUT	macro
	dc.w (.end_shortcut-*-2)/scs_SIZEOF-1
	endm

END_SHORTCUT	macro
.end_shortcut
	endm

* DEF_SHORTCUT key_code,type,routine
DEF_SHORTCUT	macro
.shortcut\@
	dc.b \1,\2
	dc.l \3-.shortcut\@
	endm

* DEF_GADGET coordX,coordY,sizeX,sizeY,ClipArt
DEF_GADGET	macro
.bob\@
	dc.w \1,\2
	dc.w (\4*SCREEN_DEPTH<<6)|((\3+16+15)>>4)
	dc.w SCREEN_WIDTH-((\3+16+15)>>3)&$fffe
	dc.l \5-.bob\@
	endm

* DEF_CLIPART NAME,sizeX,sizeY
DEF_CLIPART	macro
COUNT_CLIPART set COUNT_CLIPART+1
\1=COUNT_CLIPART
.bob\@
	dc.w 0,0
	dc.w (\3*SCREEN_DEPTH<<6)|((\2+15)>>4)
	dc.w SCREEN_WIDTH-((\2+15)>>3)&$fffe
	dc.l .bob_\1-.bob\@
	endm

* LOAD_CLIPDATA NAME
LOAD_CLIPDATA	macro
.bob_\1
	incbin "CLIP_\1.PAK"
	endm

* DEF_GALLERY NAME,sizeX,sizeY
DEF_GALLERY	macro
	dc.w (\3*SCREEN_DEPTH<<6)|((\2+15)>>4)
	dc.w SCREEN_WIDTH-((\2+15)>>3)&$fffe
.gallery\@
	dc.b "LIVE_2:gallery/GAL_\1.PAK"
	dcb.b GALLERY_NAMESIZE-(*-.gallery\@),0
	endm

WAIT_VBL	macro
	movem.l d0-d1/a0-a1/a6,-(sp)
	CALL _GfxBase(pc),WaitTOF
	movem.l (sp)+,d0-d1/a0-a1/a6

;	st Vbl_Flag-data_base(a5)
;.wait_vbl\@
;	tst.b Vbl_Flag-data_base(a5)
;	bne.s .wait_vbl\@
	endm

WAIT_FADE_OUT	macro
.wait_fade\@
	WAIT_VBL
	cmp.w #9,Fade_Offset-data_base(a5)
	bne.s .wait_fade\@
	endm

WAIT_FADE_IN	macro
.wait_fade\@
	WAIT_VBL
	tst.w Fade_Offset-data_base(a5)
	bne.s .wait_fade\@
	endm

ALLOC_BLITTER	macro
	movem.l d0/d1/a0/a1/a6,-(sp)
	move.l _GfxBase(pc),a6
	CALL OwnBlitter
	CALL WaitBlit
	movem.l (sp)+,d0/d1/a0/a1/a6
	ENDM

FREE_BLITTER	macro
	move.l a6,-(sp)
	move.l _GfxBase(pc),a6
	CALL WaitBlit
	CALL DisownBlitter
	move.l (sp)+,a6
	ENDM
