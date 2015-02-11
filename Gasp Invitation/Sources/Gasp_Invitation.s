
*			Demo Invitation pour la GASP
*			~~~~~~~~~~~~~~~~~~~~~~~~~~~~





	incdir "Asm:Sources/"
	incdir "Gasp:"
	incdir "Gasp:Sources/"
	incdir "Gasp:RAW/"
	incdir "Gasp:PAL/"
	incdir "Gasp:Text/"
	incdir "Gasp:music/"
;	incdir "asm:songs/small"
	include "registers.i"
	include "gasp.i"


MUSIC=1
MENU=1
	
	OPT P=68020
	OPT NODEBUG	
;;	OPT DEBUG,HCLN
	OPT O+,OW-
	OUTPUT hd1:X



	rsreset
DB_Struct		rs.l 0
Text			rs.l 12
TextBoxBottom		rs.w 12
Cop_Data		rs.l 1
Src_Fade		rs.l 1
Dst_Fade		rs.l 1
Nb_Fade			rs.w 1
Timer			rs.w 1
LastX			rs.b 1
LastY			rs.b 1
MouseX			rs.w 1
MouseY			rs.w 1
Menu_Number		rs.w 1
Exit			rs.b 1
Roto			rs.b 1
Menu			rs.b 1
DB_SizeOF		rs.l 0




	section code

Entry_Point
	KILL_SYSTEM Main
	moveq #0,d0
	rts


Main
	lea _DB(pc),a5
	lea _CustomBase,a6

	IFNE MUSIC
	jsr mt_init
	ENDC

	bsr Init_Datas
	bsr Init_Menu

	move.l #INTRO_VBL,$6c.w

	move.l #Coplist_Even,cop1lc(a6)
	move.l #Coplist_Odd,cop2lc(a6)

	move.w #$83c0,dmacon(a6)
	move.w #$c020,intena(a6)

wait
	tst.b Menu(a5)
	beq.s .no_menu
	bsr Prepare_RotoZoom
	sf Menu(a5)
	bra.s wait
.no_menu
	tst.b Exit(a5)
	bne.s .exit
	tst.b Roto(a5)
	beq.s wait
	jsr do_Rotate
	sf Roto(a5)
	bra.s wait
.exit
	IFNE MUSIC
	jsr mt_end
	ENDC

	RESTORE_SYSTEM


Init_Menu

* initialisation des bitplans
	move.l #MrDada_Logo_Bitmap,d0
	lea Menu_Bitplan+2,a0
	moveq #8-1,d1
.loop
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	swap d0
	add.l #40,d0
	addq.l #8,a0
	dbf d1,.loop

* met en place les couleurs 128-255
	lea MrDada_Logo_Palette,a0
	move.l a0,a1
	lea 128*4(a0),a2
	moveq #128-1,d0
.init
	move.l (a1)+,d1
	lsr.l #1,d1
	and.l #$7f7f7f,d1
	move.l d1,(a2)+
	dbf d0,.init

* initialisations des couleurs
	lea Menu_Palette_Lo+2,a1
	lea Menu_Palette_Hi+2,a2
	bsr Init_Colors

	lea Menu_Palette_Hi+4*(1+32)*4+2,a1
	lea Menu_Colors_Reset+4*2+2,a2
	moveq #4-1,d0
.put1
	moveq #32-1,d1
.put2
	move.w (a1),(a2)
	addq.l #4,a1
	addq.l #4,a2
	dbf d1,.put2
	addq.l #4,a1
	addq.l #4,a2
	dbf d0,.put1

* met en place le menu
	lea TextInfo_Txt,a0
	moveq #24,d0
	moveq #4,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #5,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #6,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #7,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #8,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #9,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #10,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #11,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #12,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #13,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #14,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #15,d1
	bsr Print_Dada

	moveq #24,d0
	moveq #16,d1
	bra Print_Dada


Prepare_RotoZoom
* efface le buffer pour le rotozoom
	lea Chunky16-(PIC_X+PIC_MARGIN)*PIC_MARGIN*2,a0
	lea Chunky16+(PIC_X+PIC_MARGIN)*PIC_Y*2+(PIC_X+PIC_MARGIN)*PIC_MARGIN*2,a1
.clear
	clr.l (a0)+
	cmp.l a0,a1
	bgt.s .clear

	lea _DataBase,a5	
	jsr Init_DataBase
	jsr Build_Coplists
	jsr Expand_Picture
	jsr Build_InfoScreen

	lea _DB(pc),a5
	rts



* a0=texte
* d0.w=X
* d1.w=Y
Print_Dada
	lea Font(pc),a1
	lea MrDada_Logo_Bitmap+40*7,a2
	lea (a2,d0.w),a2
	mulu.w #40*8*9,d1
	lea (a2,d1.l),a2
	moveq #0,d0
.print
	move.b (a0)+,d0
	beq.s .end

	lea (a1,d0.w*8),a3

	move.b (a3)+,(a2)+
	move.b (a3)+,40*8*1-1(a2)
	move.b (a3)+,40*8*2-1(a2)
	move.b (a3)+,40*8*3-1(a2)
	move.b (a3)+,40*8*4-1(a2)
	move.b (a3)+,40*8*5-1(a2)
	move.b (a3)+,40*8*6-1(a2)
	move.b (a3),40*8*7-1(a2)
	bra.s .print
.end
	rts


Font	incbin "Font.RAW"
TextInfo_Txt
	dc.b "CrEdItS",0
	dc.b "WhEn AnD WhErE ?",0
	dc.b "FaCiLiTiEs",0
	dc.b "ReAcH ThE PlAcE",0
	dc.b "CoMpEtItIoNs",0
	dc.b "ExClUsIvE !!",0
	dc.b "FeAtUrEs",0
	dc.b "OuR PaRtNeRs",0
	dc.b "ReSeRvAtIoNs",0
	dc.b "CoNtAcTs Us !",0
	dc.b "BBS SuPpOrTeRs",0
	dc.b "LaSt WoRdS",0
	dc.b "ExIt",0


	CNOP 0,4


********************************************************************************
*************                                                       ************
*************        GESTION DES DEPLACEMENTS DE LA SOURIS          ************
*************                                                       ************
********************************************************************************
Update_Mouse
	move.w joy0dat(a6),d1
	moveq #-1,d3				d3=255
	
	move.b LastX(a5),d0			etat précédent
	move.b d1,LastX(a5)			etat actuel
	sub.b d1,d0				différence=précédent-actuel
	bvc.s test_Y				Overflow clear ?
	bge.s pas_depassementX_right
	addq.b #1,d0				-255+différence
	bra.s test_Y
pas_depassementX_right
	add.b d3,d0				255+différence
test_Y
	lsr.w #8,d1				récupère les Y
	move.b LastY(a5),d2
	move.b d1,LastY(a5)
	sub.b d1,d2				idem
	bvc.s fin_testY
	bge.s pas_depassementY_down
	addq.b #1,d2
	bra.s fin_testY
pas_depassementY_down
	add.b d3,d2
fin_testY
	ext.w d0
	ext.w d2
	sub.w d0,MouseX(a5)
	sub.w d2,MouseY(a5)
	rts


Update_Menu
	tst.w MouseY(a5)
	bge.s .ok
	clr.w MouseY(a5)
.ok
	cmp.w #13*20,MouseY(a5)
	blt.s .ok2
	move.w #13*20-1,MouseY(a5)
.ok2

	moveq #0,d0
	move.w MouseY(a5),d0

	divu.l #20,d0
	move.w d0,Menu_Number(a5)

	mulu.w #9,d0
	add.w #$2a+9*4,d0
	move.w d0,d1
	addq.w #8,d1

	move.b d0,Menu_Colors_Init
	move.b d1,Menu_Colors_Reset
	rts


Check_Menu
	btst #6,ciaapra
	bne.s .nothing

	cmp.w #13-1,Menu_Number(a5)
	beq.s .exit

	st.b Roto(a5)
.nothing
	rts

.exit
	st Exit(a5)
	rts


*****************************************************************************
*****************************************************************************
INTRO_VBL
	SAVE_REGS

	IFNE MUSIC
	jsr mt_music
	ENDC

	lea _DB(pc),a5
	lea _CustomBase,a6

	move.w vposr(a6),d0
	bmi.s .lof
	clr.w copjmp2(a6)		lignes impaires
	bra.s .cont
.lof
	clr.w copjmp1(a6)		lignes paires

.cont
	bsr Manage_Display

	WAIT_VHSPOS $a000
	move.l Src_Fade(a5),a0
	move.l Dst_Fade(a5),a1
	move.w Nb_Fade(a5),d1
	bsr Fade

	move.l Src_Fade(a5),a0
	move.w vposr(a6),d0
	bmi.s .lof2
	lea Cop_Odd_Palette_Lo+2,a1
	lea Cop_Odd_Palette_Hi+2,a2
	bsr Init_Colors
	bra.s .done
.lof2
	lea Cop_Even_Palette_Lo+2,a1
	lea Cop_Even_Palette_Hi+2,a2
	bsr Init_Colors

.done
	move.w #$0020,intreq(a6)
	RESTORE_REGS
	rte


*****************************************************************************
*****************************************************************************
MENU_VBL
	SAVE_REGS

	IFNE MUSIC
	jsr mt_music
	ENDC

	lea _DB(pc),a5
	lea _CustomBase,a6

	move.l #Menu_Coplist,cop1lc(a6)
	clr.w copjmp1(a6)

	bsr Update_Mouse
	bsr Update_Menu
	bsr Check_Menu

	move.w #$0020,intreq(a6)
	RESTORE_REGS
	rte



*****************************************************************************
************************** INITIALISATION DES DATAS *************************
*****************************************************************************
Init_Datas
	move.l #Drd_Coplist,Cop_Data(a5)
	clr.b Exit(a5)
	clr.b Menu(a5)
	clr.b Roto(a5)
	move.w #1,Timer(a5)

; Credits
	move.w #0,TextBoxBottom+0*2(a5)
; When and where ??
	move.w #0,TextBoxBottom+1*2(a5)
; facilities
	move.w #0,TextBoxBottom+2*2(a5)
; how to reach the place
	move.w #0,TextBoxBottom+4*2(a5)
; competitions
	move.w #(98-32)*8,TextBoxBottom+4*2(a5)
; exclusive !!
	move.w #0,TextBoxBottom+5*2(a5)
; features
	move.w #0,TextBoxBottom+6*2(a5)
; our partners
	move.w #0,TextBoxBottom+7*2(a5)
; reservations
	move.w #0,TextBoxBottom+8*2(a5)
; contacts
	move.w #0,TextBoxBottom+9*2(a5)
; bbs supports
	move.w #(130-32)*8,TextBoxBottom+10*2(a5)
; last words
	move.w #0,TextBoxBottom+11*2(a5)
	rts



*****************************************************************************
************************* GESTION DES IMAGES DU DEPART **********************
*****************************************************************************
Manage_Display
	subq.w #1,Timer(a5)
	bne.s .no_change

	move.l Cop_Data(a5),a4
	cmp.l #Fin_Coplist,a4
	bne.s .do

	move.l #MENU_VBL,$6c.w
	rts

.do
	lea Coplist_Even,a0
	lea Coplist_Odd,a1
	move.w (a4),Cop_bplcon0(a0)
	move.w (a4)+,Cop_bplcon0(a1)
	move.w (a4),Cop_ddfstrt(a0)
	move.w (a4)+,Cop_ddfstrt(a1)
	move.w (a4),Cop_ddfstop(a0)
	move.w (a4)+,Cop_ddfstop(a1)
	move.w (a4),Cop_bpl1mod(a0)
	move.w (a4)+,Cop_bpl1mod(a1)
	move.w (a4),Cop_bpl2mod(a0)
	move.w (a4)+,Cop_bpl2mod(a1)

	move.l (a4)+,d0
	move.l (a4)+,d1
	move.l (a4)+,d2
	bsr Init_Bitplan

	move.l (a4)+,Src_Fade(a5)
	move.l (a4)+,Dst_Fade(a5)
	move.w (a4)+,Nb_Fade(a5)
	move.w (a4)+,Timer(a5)
	move.l a4,Cop_Data(a5)

	cmp.l #Fin_Coplist,a4
	bne.s .no_change
	st Menu(a5)

.no_change
	rts


* Initialisation des bitplans dans la coplist
*   -->	d0=1er bitplan
*	d1=modulo
*	d2=offset
Init_Bitplan
	lea Cop_Even_Bitplan+2,a0
	sub.l d2,d1
	moveq #8-1,d3
.loop
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	swap d0

	add.l d2,d0
	move.w d0,Coplist_Size+4(a0)
	swap d0
	move.w d0,Coplist_Size(a0)
	swap d0

	add.l d1,d0
	addq.l #8,a0
	dbf d3,.loop
	rts

* Initialisation des couleurs dans la coplist
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*   -->	a0=pointeur table des couleurs
*	a1=coplist low
*	a2=coplist hi
Init_Colors
	moveq #8-1,d0
.loop2
	moveq #32-1,d1
.loop1
	move.l (a0)+,d2
	move.l d2,d3
	and.l #$0f0f0f,d2			$0a0b0c
	lsl.b #4,d2				$0a0bc0
	lsl.w #4,d2				$0abc00
	lsr.l #8,d2				$000abc
	move.w d2,(a1)

	and.l #$f0f0f0,d3			$a0b0c0
	lsr.l #4,d3				$0a0b0c
	lsl.b #4,d3				$0a0bc0
	lsl.w #4,d3				$0abc00
	lsr.l #8,d3				$000abc
	move.w d3,(a2)

	addq.l #4,a1
	addq.l #4,a2
	dbf d1,.loop1

	addq.l #4,a1
	addq.l #4,a2
	dbf d0,.loop2
	rts


* Routine de Fade
* ~~~~~~~~~~~~~~~
*   -->	a0=source table
*	a1=destination table
*	d1=nb de couleurs
Fade
	subq.w #1,d1
loop_fade

* vérification de la composante rouge
doR
	addq.l #1,a0
	addq.l #1,a1
	cmpm.b (a1)+,(a0)+
	beq.s doG
	bls.s .incR
.decR
	subq.b #1,-1(a0)
	bra.s doG
.incR
	addq.b #1,-1(a0)

* verification de la composante	verte
doG
	cmpm.b (a1)+,(a0)+
	beq.s doB
	bls.s .incG
.decG
	subq.b #1,-1(a0)
	bra.s doB
.incG
	addq.b #1,-1(a0)

* vérification de la composante bleue
doB
	cmpm.b (a1)+,(a0)+
	beq.s doNext
	bls.s .incB
.decB
	subq.b #1,-1(a0)
	bra.s doNext
.incB
	addq.b #1,-1(a0)

doNext
	dbf d1,loop_fade

	rts


* structure:
* bplcon0
* ddfstrt,ddfstop
* bpl1mod,bpl2mod
* bitmap, modulo
* src_palette,dst_palette,nb_couleurs,timer
Drd_Coplist
	IFNE MENU
	dc.w $8210
	dc.w $38,$d8
	dc.w 80*7-8,80*7-8
	dc.l Drd_Logo_Bitmap,80,0
	dc.l Temp_Palette1,Drd_Logo_Palette
	dc.w 256,256

	dc.w $8210
	dc.w $38,$d8
	dc.w 80*7-8,80*7-8
	dc.l Drd_Logo_Bitmap,80,0
	dc.l Temp_Palette1,Temp_Palette2
	dc.w 256,256

Erm_Coplist
	dc.w $8214
	dc.w $38,$d8
	dc.w 80*15-8,80*15-8
	dc.l Erm_Logo_Bitmap,80,80*8
	dc.l Temp_Palette1,Erm_Logo_Palette
	dc.w 256,256

	dc.w $8214
	dc.w $38,$d8
	dc.w 80*15-8,80*15-8
	dc.l Erm_Logo_Bitmap,80,80*8
	dc.l Temp_Palette1,Temp_Palette2
	dc.w 256,256

Meuh5_Coplist
	dc.w $3200
	dc.w $38,$a0
	dc.w 40*2,40*2
	dc.l Meuh5_Logo_Bitmap,40,0
	dc.l Temp_Palette1,Meuh5_Logo_Palette
	dc.w 256,256

	dc.w $3200
	dc.w $38,$a0
	dc.w 40*2,40*2
	dc.l Meuh5_Logo_Bitmap,40,0
	dc.l Temp_Palette1,Temp_Palette2
	dc.w 256,256

Meuh6_Coplist
	dc.w $4200
	dc.w $38,$a0
	dc.w 40*3,40*3
	dc.l Meuh6_Logo_Bitmap,40,0
	dc.l Temp_Palette1,Meuh6_Logo_Palette
	dc.w 256,256

	dc.w $4200
	dc.w $38,$a0
	dc.w 40*3,40*3
	dc.l Meuh6_Logo_Bitmap,40,0
	dc.l Temp_Palette1,Temp_Palette2
	dc.w 256,256
	ENDC

MrDada_Coplist
	dc.w $0210
	dc.w $38,$a0
	dc.w 40*7,40*7
	dc.l MrDada_Logo_Bitmap,40,0
	dc.l Temp_Palette1,MrDada_Logo_Palette
	dc.w 256,256
Fin_Coplist


	IFNE MUSIC
	include "TMC_Replay.s"
	include "song.s"
	ENDC




_DB
	ds.b DB_SizeOF



	section bouba,data_c


Menu_Coplist
	dc.w fmode,%11
	dc.w bplcon0,$0210
	dc.w bplcon1,$0
	dc.w bplcon2,$0
	dc.w ddfstrt,$38
	dc.w ddfstop,$a0
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w bpl1mod,40*7
	dc.w bpl2mod,40*7

	MAKE_BITPLAN Menu_Bitplan
	MAKE_PALETTE Menu_Palette

Menu_Colors_Init
	dc.w $aa0f,$fffe
Palette set $2000*4
	REPT 4
	dc.w bplcon3,Palette
	dc.w color00,$fff
	dc.w color01,$fff
	dc.w color02,$fff
	dc.w color03,$fff
	dc.w color04,$fff
	dc.w color05,$fff
	dc.w color06,$fff
	dc.w color07,$fff
	dc.w color08,$fff
	dc.w color09,$fff
	dc.w color10,$fff
	dc.w color11,$fff
	dc.w color12,$fff
	dc.w color13,$fff
	dc.w color14,$fff
	dc.w color15,$fff
	dc.w color16,$fff
	dc.w color17,$fff
	dc.w color18,$fff
	dc.w color19,$fff
	dc.w color20,$fff
	dc.w color21,$fff
	dc.w color22,$fff
	dc.w color23,$fff
	dc.w color24,$fff
	dc.w color25,$fff
	dc.w color26,$fff
	dc.w color27,$fff
	dc.w color28,$fff
	dc.w color29,$fff
	dc.w color30,$fff
	dc.w color31,$fff
Palette set Palette+$2000
	ENDR

Menu_Colors_Reset
	dc.w $b10f,$fffe
Palette set $2000*4
	REPT 4
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


	dc.w color00,$000
	dc.l $fffffffe

Coplist_Even
	dc.w fmode,%11
Cop_bplcon0=*+2-Coplist_Even
	dc.w bplcon0,0
	dc.w bplcon1,0
	dc.w bplcon2,0
Cop_ddfstrt=*+2-Coplist_Even
	dc.w ddfstrt,0
Cop_ddfstop=*+2-Coplist_Even
	dc.w ddfstop,0
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
Cop_bpl1mod=*+2-Coplist_Even
	dc.w bpl1mod,0
Cop_bpl2mod=*+2-Coplist_Even
	dc.w bpl2mod,0

	MAKE_BITPLAN Cop_Even_Bitplan
	MAKE_PALETTE Cop_Even_Palette

	dc.l $fffffffe
Coplist_Size=*-Coplist_Even


Coplist_Odd
	dc.w fmode,%11
	dc.w bplcon0,0
	dc.w bplcon1,0
	dc.w bplcon2,0
	dc.w ddfstrt,0
	dc.w ddfstop,0
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w bpl1mod,0
	dc.w bpl2mod,0

	MAKE_BITPLAN Cop_Odd_Bitplan
	MAKE_PALETTE Cop_Odd_Palette

	dc.l $fffffffe


******** pas terrible...
Hack
********

	CNOP 0,8
Drd_Logo_Bitmap
	incbin "DRDLOGO8.RAW"
Drd_Logo_Palette
	incbin "DRDLOGO8.PAL"

	CNOP 0,8
Erm_Logo_Bitmap
	incbin "Erm.RAW"
Erm_Logo_Palette
	incbin "Erm.PAL"


	CNOP 0,8
Meuh5_Logo_Bitmap
	incbin "Meuh5.RAW"
Meuh5_Logo_Palette
	incbin "Meuh5.PAL"
	dcb.l 256-8,$000000

	CNOP 0,8
Meuh6_Logo_Bitmap
	incbin "Meuh6.RAW"
Meuh6_Logo_Palette
	incbin "Meuh6.PAL"
	dcb.l 256-16,$000000

	CNOP 0,8
MrDada_Logo_Bitmap
	incbin "MrDada.RAW"
MrDada_Logo_Palette
	incbin "MrDada.PAL"

Temp_Palette1
	dcb.l 256,$000000
Temp_Palette2
	dcb.l 256,$000000



	IFNE MUSIC
	include "Samples.s"
	ENDC








	CNOP 0,4


*			Zoom et Rotation d'une image / 68020 et +
*			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*				(c)1993 Sync/DreamDealers



* Options de compilation
* ~~~~~~~~~~~~~~~~~~~~~~
	OPT P=68020
	OPT O+,OW-,C+
	OPT NODEBUG,NOLINE
	OUTPUT asm:bin/RotoZoom

* EQU en vrac
* ~~~~~~~~~~~
PIC_X=320
PIC_Y=256
PIC_DEPTH=8

COP_MOVEX=48
COP_MOVEY1=24
COP_MOVEY2=31
COP_MOVEY3=13
COP_MOVEY=COP_MOVEY1+1+COP_MOVEY2+1+COP_MOVEY3
COP_LINE=4
COP_WIDTH=1+1+1+COP_MOVEX+1+1
COP_SIZE=4*(1+11+1+1+COP_WIDTH*(COP_MOVEY-2)+(1+COP_MOVEX)*COP_LINE*2+1+1)

	IFNE COP_MOVEX>COP_MOVEY
MAX_MOVE=COP_MOVEX
	ELSEIF
MAX_MOVE=COP_MOVEY
	ENDC

PIC_MARGIN=120
MARGIN_X=100
MARGIN_Y=100
MAX_ANGLE=720
INC_ZOOM1=3
INC_ZOOM2=1
ANGLE_COUNTER=500

MAX_SPEED=4
DELTA_SPEED=2

DISTORT_SIZE_X=$15
DISTORT_SIZE_Y=$20
INC_DISTORT=1
DELTA_DISTORT=10



;		ds.w (PIC_X+PIC_MARGIN)*PIC_MARGIN
;Chunky16	ds.w (PIC_X+PIC_MARGIN)*PIC_Y
;		ds.w (PIC_X+PIC_MARGIN)*PIC_MARGIN

coplist1=Hack
coplist2=coplist1+COP_SIZE
Chunky16=coplist2+COP_SIZE+(PIC_X+PIC_MARGIN)*PIC_MARGIN*2

do_Rotate
	SAVE_REGS

	clr.w _DB+MouseY

	lea _DataBase,a5
	lea _CustomBase,a6

	lea VBL_RotoZoom(pc),a0
	move.l a0,$6c.w
	move.l phy_coplist(a5),cop1lc(a6)

	move.w dmaconr(a6),d0
	or.w #$8000,d0
	move.l d0,-(sp)
	move.w #$7df0,dmacon(a6)
	move.w #$8380,dmacon(a6)		COPPER | BITPLAN

.wait
	btst #2,potinp(a6)
	bne.s .wait
	move.l (sp)+,d0
	move.w d0,dmacon(a6)
	move.l #MENU_VBL,$6c.w

	RESTORE_REGS
	rts



* La nouvelle VBL
* ~~~~~~~~~~~~~~~
VBL_RotoZoom
	SAVE_REGS

	IFNE MUSIC
	jsr mt_music				hop! la zizik!!
	ENDC

	lea _DataBase,a5
	lea _CustomBase,a6

	lea _DB,a0
	move.w Menu_Number(a0),d0
	move.l Text(a0,d0.w*4),d0
	move.w MouseY(a0),d1
	mulu.w #80,d1
	add.l d1,d0
	move.l d0,bpl1ptH(a6)

	bsr.s Flip_Coplist			echange les coplists
	bsr.s Move_Rotate			deplacement du zoom-rotatif
	bsr Build_Rotate			calcule d'une ligne de zoom
	bsr Rotate				construit le zoom

	lea _DB,a5
	jsr Update_Mouse
	move.w Menu_Number(a5),d1
	move.w MouseY(a5),d0
	bge.s .ok
	clr.w MouseY(a5)
.ok
	cmp.w TextBoxBottom(a5,d1.w*2),d0
	blt.s .ok2
	move.w TextBoxBottom(a5,d1.w*2),MouseY(a5)
.ok2

	move.w #$0020,intreq(a6)		vire la request
	RESTORE_REGS
	rte

* Echange des coplists
* ~~~~~~~~~~~~~~~~~~~~
Flip_Coplist
	move.l log_coplist(a5),d0
	move.l phy_coplist(a5),log_coplist(a5)
	move.l d0,phy_coplist(a5)
	move.l d0,cop1lc(a6)
	clr.w copjmp1(a6)
	rts



* Gestion du déplacement du zoom rotaté
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Move_Rotate

* Modification de l'angle de la rotation
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
modify_angle
	move.w Inc_Angle(a5),d0
	add.w d0,Angle(a5)
	bge.s .ang
	add.w #MAX_ANGLE,Angle(a5)
	bra.s modify_inc_angle
.ang
	cmp.w #MAX_ANGLE,Angle(a5)
	blt.s modify_inc_angle
	sub.w #MAX_ANGLE,Angle(a5)

* Modification du sens de la rotation
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
modify_inc_angle
	tst.w Angle_Counter(a5)			on va vers un autre Inc_Angle?
	bne.s .tralala

	move.w Inc_Angle(a5),d0			on est bon ?
	cmp.w Save_Inc_Angle(a5),d0
	beq.s .plus_tralala
	blt.s .inc
.dec
	subq.w #1,Inc_Angle(a5)
	bra.s modify_center
.inc
	addq.w #1,Inc_Angle(a5)
	bra.s modify_center

.plus_tralala
	move.w #ANGLE_COUNTER,Angle_Counter(a5)
	bra.s modify_center

.tralala
	subq.w #1,Angle_Counter(a5)
	bne.s modify_center
	move.w Inc_Angle(a5),Save_Inc_Angle(a5)
	neg.w Save_Inc_Angle(a5)
	subq.w #DELTA_SPEED,Save_Inc_Angle(a5)

* modification des coordonnées du rotozoom
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
modify_center
	movem.w CentreX(a5),d0/d1
	add.w Inc_X(a5),d0
	add.w Inc_Y(a5),d1

	cmp.w #MARGIN_X,d0
	bgt.s .ok1
	neg.w Inc_X(a5)
	bra.s .ok2
.ok1
	cmp.w #PIC_X*2-MARGIN_X,d0
	blt.s .ok2
	neg.w Inc_X(a5)
.ok2
	cmp.w #MARGIN_Y,d1
	bgt.s .ok3
	neg.w Inc_Y(a5)
	bra.s .ok4
.ok3
	cmp.w #PIC_Y*2-MARGIN_Y,d1
	blt.s .ok4
	neg.w Inc_Y(a5)
.ok4
	movem.w d0/d1,CentreX(a5)

* Modification du zoom
* ~~~~~~~~~~~~~~~~~~~~
modify_zoom
	move.w Offset_Zoom1(a5),d0
	addq.w #INC_ZOOM1,d0
	cmp.w #MAX_ANGLE,d0
	blt.s .ok5
	sub.w #MAX_ANGLE,d0
.ok5	move.w d0,Offset_Zoom1(a5)

	move.w Offset_Zoom2(a5),d1
	addq.w #INC_ZOOM2,d1
	cmp.w #MAX_ANGLE,d1
	blt.s .ok6
	sub.w #MAX_ANGLE,d1
.ok6	move.w d1,Offset_Zoom2(a5)

	lea Table_Cosinus(pc),a0
	move.w (a0,d0.w*2),d0
	muls.w #$20*$10,d0
	move.w (a0,d1.w*2),d1
	muls.w #$14*$10,d1
	add.l d1,d0
	swap d0
	asr.w #1,d0
	add.w #$18,d0
	move.w d0,Zoom(a5)

* Modification de la distortion
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	add.w #INC_DISTORT,Save_Distort_Angle(a5)
	bge.s .ang
	add.w #MAX_ANGLE,Save_Distort_Angle(a5)
	bra.s .ok
.ang
	cmp.w #MAX_ANGLE,Save_Distort_Angle(a5)
	blt.s .ok
	sub.w #MAX_ANGLE,Save_Distort_Angle(a5)
.ok
	rts



* Fabrication de la table de rotation ( transcription directe de l'AMOS...)
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Build_Rotate
	move.w #(-COP_MOVEY/2),d0		B=(-COP_MOVEY/2)*Zoom
	muls.w Zoom(a5),d0

	moveq #0,d1
	move.w #(-COP_MOVEX/4),d1		A=(-COP_MOVEX/2)*Zoom
	muls.w Zoom(a5),d1

	moveq #MAX_MOVE-1,d2			M

	move.w Angle(a5),d7			ANGLE
	lea Table_Cosinus(pc),a1
	move.w (a1,d7.w*2),d3			Cos(ANGLE)
	lea Table_Sinus(pc),a2
	move.w (a2,d7.w*2),d4			Sin(ANGLE)

	lea 0.w,a0
	lea 0.w,a1
	lea Table_Rotate(a5),a2
	lea COP_MOVEX*4(a2),a3			pointe les chgts de centre

	move.w Save_Distort_Angle(a5),Distort_Angle(a5)

for_M
	move.w d1,d5
	muls.w d3,d5				A*Cos(ANGLE)
	move.w d0,d6
	muls.w d4,d6				B*Sin(ANGLE)
	add.l d6,d5
	swap d5					X=A*Cos(ANGLE)+B*Sin(ANGLE)

	move.w d0,d6
	muls.w d3,d6				B*Cos(ANGLE)
	move.w d1,d7
	muls.w d4,d7				A*Sin(ANGLE)
	sub.l d7,d6
	swap d6					Y=B*Cos(ANGLE)-A*Sin(ANGLE)

	cmp.w #MAX_MOVE-1-COP_MOVEX,d2		0<=M<=COP_MOVEX-1 version dbf
	ble.s .no_more

** calcul de la distortion
	movem.l d5-d7/a1-a2,-(sp)

	move.w Inc_Distort(a5),d5
	add.w d5,Distort_Angle(a5)
	bge.s .ang
	add.w #MAX_ANGLE,Distort_Angle(a5)
	bra.s .calc_distort
.ang
	cmp.w #MAX_ANGLE,Distort_Angle(a5)
	blt.s .calc_distort
	sub.w #MAX_ANGLE,Distort_Angle(a5)

.calc_distort
	lea Table_Cosinus(pc),a1
	lea Table_Sinus(pc),a2
	move.w Distort_Angle(a5),d7		DISTORT_ANGLE
	move.w (a1,d7.w*2),d5			Cos(DISTORT_ANGLE)
	muls.w #DISTORT_SIZE_X*$10,d5
	swap d5
	ext.l d5
	move.w (a2,d7.w*2),d6			Sin(DISTORT_ANGLE)
	muls.w #DISTORT_SIZE_Y*$10,d6
	swap d6
	muls.w #(PIC_X+PIC_MARGIN),d6		Y*PIC_X
	add.l d6,d5
	move.l d5,a4				distortion
	movem.l (sp)+,d5-d7/a1-a2

	ext.l d5
	move.w d6,d7
	muls.w #(PIC_X+PIC_MARGIN),d7		Y*PIC_X
	add.l d5,d7
	add.l a4,d7				ajout de la distortion
	add.l d7,d7				(X+Y*PIC_X)*2
	move.l d7,(a2)+

.no_more
	cmp.w #MAX_MOVE-1,d2			1<M<=COP_MOVEY version dbf
	beq.s no_change_center
	cmp.w #MAX_MOVE-1-COP_MOVEY,d2
	ble.s no_change_center

	sub.w a0,d5				DX=X-OLD_X
	add.w d5,a0				OLD_X=X
	sub.w a1,d6				DY=Y-OLD_Y
	add.w d6,a1				OLD_Y=Y

	muls.w #(PIC_X+PIC_MARGIN),d5		DX*PIC_X
	ext.l d6
	sub.l d6,d5				-DY+DX*PIC_X
	add.l d5,d5				(-DY+DX*PIC_X)*2
	move.l d5,(a3)+

.next_M
	add.w Zoom(a5),d1			Inc A
	dbf d2,for_M
	rts

no_change_center
	move.w d5,a0				UPDATE OLD_X & OLD_Y
	move.w d6,a1
.next_M
	add.w Zoom(a5),d1			Inc A
	dbf d2,for_M
	rts



* Rotation du bitmap et stockage dans la coplist
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Rotate
	move.l log_coplist(a5),a0		pointe data du 1er COP_MOVE
	lea 17*4+2(a0),a0

	move.l Chunky16Map(a5),a1		cherche un ptr sur l'image
	move.w CentreY(a5),d0
	lsr.w #1,d0
	mulu #(PIC_X+PIC_MARGIN)*2,d0		table de WORD
	add.l d0,a1

	move.w CentreX(a5),d0			c'est là où on regarde
	lsr.w #1,d0
	lea (a1,d0.w*2),a1			table de WORD

	lea Table_Rotate(a5),a2			la table de rotation
	lea COP_MOVEX*4(a2),a3			pointe les changements de Centre

*********************************************************************************
	moveq #COP_MOVEY1-1,d0			traite la première partie
rotate1
	move.l a2,a4
	moveq #COP_MOVEX-1,d1			on se fait toute la ligne
rotate_line1
	move.l (a4)+,d2				va chercher l'offset du point
	move.w (a1,d2.l),(a0)
	addq.l #4,a0
	dbf d1,rotate_line1
	lea (COP_WIDTH-COP_MOVEX)*4(a0),a0	ligne suivante
	add.l (a3)+,a1				change la position du Centre
	dbf d0,rotate1

*********************************************************************************
	subq.l #8,a0				c pas une ligne normale...
	move.l a2,a4
	moveq #COP_MOVEX-1,d1
rotate_fake1
	move.l (a4)+,d2
	move.w (a1,d2.l),d2
depl set 0
	REPT COP_LINE
	move.w d2,depl(a0)
depl set depl+(1+COP_MOVEX)*4
	ENDR
	addq.l #4,a0
	dbf d1,rotate_fake1
	lea (1+COP_MOVEX)*(COP_LINE-1)*4+3*4(a0),a0
	add.l (a3)+,a1				change la position du Centre

*********************************************************************************
	moveq #COP_MOVEY2-1,d0			traite la deuxième partie
rotate2
	move.l a2,a4
	moveq #COP_MOVEX-1,d1			on se fait toute la ligne
rotate_line2
	move.l (a4)+,d2				va chercher l'offset du point
	move.w (a1,d2.l),(a0)
	addq.l #4,a0
	dbf d1,rotate_line2
	lea (COP_WIDTH-COP_MOVEX)*4(a0),a0	ligne suivante
	add.l (a3)+,a1				change la position du Centre
	dbf d0,rotate2

*********************************************************************************
	subq.l #8,a0				c pas une ligne normale...
	move.l a2,a4
	moveq #COP_MOVEX-1,d1
rotate_fake2
	move.l (a4)+,d2
	move.w (a1,d2.l),d2
depl set 0
	REPT COP_LINE
	move.w d2,depl(a0)
depl set depl+(1+COP_MOVEX)*4
	ENDR
	addq.l #4,a0
	dbf d1,rotate_fake2
	lea (1+COP_MOVEX)*(COP_LINE-1)*4+3*4(a0),a0
	add.l (a3)+,a1				change la position du Centre

*********************************************************************************
	moveq #COP_MOVEY3-1,d0			traite la deuxième partie
rotate3
	move.l a2,a4
	moveq #COP_MOVEX-1,d1			on se fait toute la ligne
rotate_line3
	move.l (a4)+,d2				va chercher l'offset du point
	move.w (a1,d2.l),(a0)
	addq.l #4,a0
	dbf d1,rotate_line3
	lea (COP_WIDTH-COP_MOVEX)*4(a0),a0	ligne suivante
	add.l (a3)+,a1				change la position du Centre
	dbf d0,rotate3
	rts



* Transformation de l'image : chaque pixel devient un mot donnant sa couleur
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Expand_Picture
	lea picture(pc),a0
	move.l Chunky16Map(a5),a1
	lea picture_colors(pc),a2
	moveq #0,d2
	move.w #PIC_Y-1,d0
expand_all
	move.w #PIC_X-1,d1
expand_line
	move.b (a0)+,d2				lit un chunky pixel
	move.w (a2,d2.w*2),(a1)+		et met en couleur
	dbf d1,expand_line
	lea PIC_MARGIN*2(a1),a1
	dbf d0,expand_all
	rts



* Fabrication des coplists
* ~~~~~~~~~~~~~~~~~~~~~~~~
Build_Coplists
	lea coplist1,a1
	move.l a1,log_coplist(a5)
	bsr.s build_one_coplist
	move.l a1,phy_coplist(a5)

build_one_coplist
	move.l #(fmode<<16)|$3,(a1)+		move.w #$3,fmode
	move.l #(color00<<16),(a1)+
	move.l #(color01<<16)|$fff,(a1)+
	move.l #(bplcon0<<16)|$1200|$8000,(a1)+
	move.l #(bplcon1<<16),(a1)+
	move.l #(bplcon2<<16),(a1)+
	move.l #(bplcon3<<16),(a1)+
	move.l #(ddfstrt<<16)|$38,(a1)+
	move.l #(ddfstop<<16)|$d8,(a1)+
	move.l #(diwstrt<<16)|$2b81,(a1)+
	move.l #(diwstop<<16)|$2bc1,(a1)+
	move.l #(bpl1mod<<16)|(-8&$ffff),(a1)+
	move.l #(bpl2mod<<16)|(-8&$ffff),(a1)+
	move.l #$1ee3fffe,(a1)+			wait sur la ligne kon veut...
	move.l a1,d1
	addq.l #2*4,d1				pour relancer la coplist
	move.l #$002b80fe,d7

*********************************************************************************
	moveq #COP_MOVEY1-1,d0
build_all1
	move.w #cop1lc,(a1)+			move.l #coplist_move,cop1lc
	swap d1
	move.w d1,(a1)+
	move.w #cop1lc+2,(a1)+
	swap d1
	move.w d1,(a1)+
	move.l d7,(a1)+				wait sur les X uniquement
	moveq #COP_MOVEX-1,d2
build_line1
	move.l #color00<<16,(a1)+		move.w #$xyz,color00
	dbf d2,build_line1
	move.l #$03018301,(a1)+			on skip toutes les 8 lignes
	move.l #copjmp1<<16,(a1)+		relance la coplist
	add.l #COP_WIDTH*4,d1			coplist suivante
	dbf d0,build_all1

*********************************************************************************
	moveq #COP_LINE-1,d5
	move.l #$7f2bfffe,d6			le wait
build_fake1
	move.l d6,(a1)+				place le wait
	moveq #COP_MOVEX-1,d0
build_fake_line1
	move.l #color00<<16,(a1)+		move.w #$xyz,color00
	dbf d0,build_fake_line1
	add.l #$100<<16,d6			wait suivant
	dbf d5,build_fake1

*********************************************************************************
	moveq #COP_MOVEY2-1,d0
	or.l #$80000000,d7
	move.l a1,d1
	addq.l #2*4,d1
build_all2
	move.w #cop1lc,(a1)+			move.l #coplist_move,cop1lc
	swap d1
	move.w d1,(a1)+
	move.w #cop1lc+2,(a1)+
	swap d1
	move.w d1,(a1)+
	move.l d7,(a1)+				wait sur les X uniquement
	moveq #COP_MOVEX-1,d2
build_line2
	move.l #color00<<16,(a1)+		move.w #$xyz,color00
	dbf d2,build_line2
	move.l #$83018301,(a1)+			on skip toutes les 8 lignes
	move.l #copjmp1<<16,(a1)+		relance la coplist
	add.l #COP_WIDTH*4,d1			coplist suivante
	dbf d0,build_all2

*********************************************************************************
	moveq #COP_LINE-1,d5
	move.l #$ff2bfffe,d6			le wait
build_fake2
	move.l d6,(a1)+				place le wait
	moveq #COP_MOVEX-1,d0
build_fake_line2
	move.l #color00<<16,(a1)+		move.w #$xyz,color00
	dbf d0,build_fake_line2
	add.l #$100<<16,d6			wait suivant
	dbf d5,build_fake2

*********************************************************************************
	moveq #COP_MOVEY3-1,d0
	and.l #$7fffffff,d7
	move.l a1,d1
	addq.l #2*4,d1
build_all3
	move.w #cop1lc,(a1)+			move.l #coplist_move,cop1lc
	swap d1
	move.w d1,(a1)+
	move.w #cop1lc+2,(a1)+
	swap d1
	move.w d1,(a1)+
	move.l d7,(a1)+				wait sur les X uniquement
	moveq #COP_MOVEX-1,d2
build_line3
	move.l #color00<<16,(a1)+		move.w #$xyz,color00
	dbf d2,build_line3
	move.l #$03018301,(a1)+			on skip toutes les 8 lignes
	move.l #copjmp1<<16,(a1)+		relance la coplist
	add.l #COP_WIDTH*4,d1			coplist suivante
	dbf d0,build_all3

*********************************************************************************
	move.l #(color00<<16),(a1)+		houba.. ya plus rien !
	move.l #$fffffffe,(a1)+
	rts


* Intialisation de DataBase
* ~~~~~~~~~~~~~~~~~~~~~~~~~
Init_DataBase
	move.w #PIC_X,CentreX(a5)
	move.w #PIC_Y,CentreY(a5)
	move.w #ANGLE_COUNTER,Angle_Counter(a5)
	move.w #3,Inc_X(a5)
	move.w #2,Inc_Y(a5)
	move.w #MAX_SPEED,Inc_Angle(a5)
	move.w #DELTA_DISTORT,Inc_Distort(a5)
	move.l #Chunky16,Chunky16Map(a5)
	rts




* Fabrication du message à afficher
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Build_InfoScreen

* effacage du buffer sur 550 lignes
	lea Zoli_Buffer,a0
	move.l a0,a1
	lea ((80*8*550).l,a1),a2
	moveq #0,d1
.clear
	clr.l (a1)+
	cmp.l a1,a2
	bgt.s .clear


	move.l a5,-(sp)

	lea Zoli_Buffer,a0
	lea Font,a2
	lea _DB+Text,a5

	lea Info_Text1,a1
	bsr Print_Text
	lea Info_Text2,a1
	bsr Print_Text
	lea Info_Text3,a1
	bsr Print_Text
	lea Info_Text4,a1
	bsr Print_Text
	lea Info_Text5,a1
	bsr Print_Text
	lea Info_Text6,a1
	bsr Print_Text
	lea Info_Text7,a1
	bsr Print_Text
	lea Info_Text8,a1
	bsr Print_Text
	lea Info_Text9,a1
	bsr Print_Text
	lea Info_Text10,a1
	bsr Print_Text
	lea Info_Text11,a1
	bsr Print_Text
	lea Info_Text12,a1
	bsr Print_Text

	move.l (sp)+,a5
	rts


Print_Text
* affichage du texte dans le Zoli_Buffer
	move.l a0,(a5)+
	move.l a0,a3
	moveq #0,d0
	moveq #0,d1
.print
	move.b (a1)+,d0			lecture d'une lettre
	beq.s .fin

	cmp.b #9,d0			tabulation ?
	beq.s .tab
	
	cmp.b #10,d0			retour chariot ?
	bne.s .not_eol
	lea 80*8(a0),a0			oui => saute la ligne
	move.l a0,a3
	moveq #0,d1
	bra.s .print	
.not_eol
	cmp.w #80,d1			fin de la ligne ?
	beq.s .print

	lea (a2,d0.w*8),a4		recherche la lettre

	move.b (a4)+,(a3)+		balance la lettre dans l'écran
	move.b (a4)+,80*1-1(a3)
	move.b (a4)+,80*2-1(a3)
	move.b (a4)+,80*3-1(a3)
	move.b (a4)+,80*4-1(a3)
	move.b (a4)+,80*5-1(a3)
	move.b (a4)+,80*6-1(a3)
	move.b (a4),80*7-1(a3)
	addq.w #1,d1
	bra.s .print
.tab
	lea 8(a3),a3
	addq.w #8,d1
	bra.s .print
.fin
	rts



* Datas constantes
* ~~~~~~~~~~~~~~~~
picture_colors	incbin "MrDada.PAL12"

Table_Cosinus	incbin "Table_Sinus.DAT"
Table_Sinus=Table_Cosinus+90*4

picture		incbin "MrDada.CHK"		=> PIC_WIDTH*PIC_HEIGHT*PIC_DEPTH


	even
Info_Text1
	incbin "Credits.txt"
	dc.b 0
	even
Info_Text2
	incbin "When.txt"
	dc.b 0
	even
Info_Text3
	incbin "Facilities.txt"
	dc.b 0
	even
Info_Text4
	incbin "Reach.txt"
	dc.b 0
	even
Info_Text5
	incbin "Competitions.txt"
	dc.b 0
	even
Info_Text6
	incbin "Exclusive.txt"
	dc.b 0
	even
Info_Text7
	incbin "Features.txt"
	dc.b 0
	even
Info_Text8
	incbin "Partners.txt"
	dc.b 0
	even
Info_Text9
	incbin "Reservations.txt"
	dc.b 0
	even
Info_Text10
	incbin "Contacts.txt"
	dc.b 0
	even
Info_Text11
	incbin "BBS.txt"
	dc.b 0
	even
Info_Text12
	incbin "LastWord.txt"
	dc.b 0
	even


* Toutes les datas du RotoZoom
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	section database,bss

Zoli_Buffer
	ds.b 80*8*550

DATA_OFFSET=$7ffe

	rsset -DATA_OFFSET
DataBase_Struct		rs.w 0
Table_Rotate		rs.l COP_MOVEX
Table_Centre		rs.l COP_MOVEY-1
log_coplist		rs.l 1
phy_coplist		rs.l 1
CentreX			rs.w 1
CentreY			rs.w 1
Angle			rs.w 1
Angle_Counter		rs.w 1
Distort_Angle		rs.w 1
Save_Distort_Angle	rs.w 1
Inc_X			rs.w 1
Inc_Y			rs.w 1
Inc_Angle		rs.w 1
Inc_Distort		rs.w 1
Save_Inc_Angle		rs.w 1
Zoom			rs.w 1
Offset_Zoom1		rs.w 1
Offset_Zoom2		rs.w 1
Chunky16Map		rs.l 1
DataBase_SizeOF=__RS-DataBase_Struct

_DataBase=*+DATA_OFFSET
	ds.b DataBase_SizeOF

