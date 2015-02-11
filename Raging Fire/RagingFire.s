	
*			     Raging Fire pour la PARTY III !!
*			     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
*				Code......Sync/DreamDealers
*				Music.....Moby/Sanity
*				Graphics..Antony/DreamDealers
*					  Ra/Sanity
*



* Les includes
* ~~~~~~~~~~~~
	incdir "asm:sources/"
	incdir "hd1:RagingFire/"
	incdir "hd1:RagingFire/RAW/"
	incdir "ram:"
	include "registers.i"

* Options de compilation
* ~~~~~~~~~~~~~~~~~~~~~~
	OPT P=68020
	OPT O+,OW-,C+
	OPT NODEBUG,NOLINE

* EQU en vrac
* ~~~~~~~~~~~
PIC_X=320
PIC_Y=256
PIC_DEPTH=6
PIC_WIDTH=PIC_X/8
PIC_HEIGHT=PIC_Y

COP_MOVEX=48
COP_MOVEY1=24
COP_MOVEY2=31
COP_MOVEY3=13
COP_MOVEY=COP_MOVEY1+1+COP_MOVEY2+1+COP_MOVEY3
COP_LINE=4
COP_WIDTH=1+1+1+COP_MOVEX+1+1
COP_SIZE=4*(1+1+COP_WIDTH*(COP_MOVEY-2)+(1+COP_MOVEX)*COP_LINE*2+1)

	IFNE COP_MOVEX>COP_MOVEY
MAX_MOVE=COP_MOVEX
	ELSEIF
MAX_MOVE=COP_MOVEY
	ENDC

PIC_MARGIN=120
MAX_ANGLE=720
MARGIN_X=200
MARGIN_Y=150
INC_ZOOM1=2
INC_ZOOM2=5
ANGLE_COUNTER=500


*********************************************************************************
* Le point d'entrée c ici
* ~~~~~~~~~~~~~~~~~~~~~~~
	section rotation,code_c
	KILL_SYSTEM do_RagingFire
	moveq #0,d0
	rts

	dc.b "Nice Zik Or What ??  Hum...."
	dc.b "M.K.  hahaha..."
	CNOP 0,4

do_RagingFire
	moveq #0,d0
	movec d0,vbr
	move.l #$2001,d0
	movec d0,cacr

	jsr mt_init

	lea (data_base,pc),a5
	lea custom_base,a6

	lea Msg1,a0
	move.w #160,Msg_Wait-data_base(a5)
	bsr Display_Msg

	lea Msg2,a0
	move.w #160,Msg_Wait-data_base(a5)
	bsr Display_Msg

	lea Logo1,a0
	move.w #160,Logo_Wait-data_base(a5)
	bsr Display_Logo

	lea Msg3,a0
	move.w #160,Msg_Wait-data_base(a5)
	bsr Display_Msg

	lea Logo2,a0
	move.w #320,Logo_Wait-data_base(a5)
	bsr Display_Logo

	lea picture,a0
	move.w #320+290,Picture_Wait-data_base(a5)
	bsr Display_Picture

	bra do_Rotate


*********************************************************************************
Display_Msg
	move.l a0,Msg_Ptr-data_base(a5)

	lea Msg_Colors(pc),a0
	clr.l (a0)+
	move.l #$505050,(a0)+
	move.l #$a0a0a0,(a0)+
	move.l #$e0e0e0,(a0)
	clr.b FadeSpeed-data_base(a5)
	move.l #Display_Msg_Coplist,cop1lc(a6)
	move.l #Display_Msg_Vbl,$6c.w
	move.w #$8380,dmacon(a6)
	move.w #$c020,intena(a6)

Loop_Display_Msg
	tst.w Msg_Wait-data_base(a5)
	bne.s Loop_Display_Msg
	rts

Display_Msg_Vbl
	SAVE_REGS
	jsr mt_music

	lea data_base(pc),a5
	lea custom_base,a6

	move.l Msg_Ptr(pc),a0
	move.l a0,bpl1ptH(a6)
	lea 80(a0),a0
	move.l a0,bpl2ptH(a6)

	cmp.w #110,Msg_Wait-data_base(a5)
	bne.s .none
	move.b #2,FadeSpeed-data_base(a5)
.none

	lea Msg_Colors(pc),a0
	lea Msg_Coplist_ColorsH+2,a1
	lea Msg_Coplist_ColorsL+2,a2
	moveq #4-1,d0
	bsr FadeOut
	clr.w copjmp1(a6)

	subq.w #1,Msg_Wait-data_base(a5)
	move.w #$0020,intreq(a6)

	RESTORE_REGS
	rte

Msg_Colors
	dcb.l 4,0


*********************************************************************************
Display_Logo
	move.l a0,Logo_Ptr-data_base(a5)

	lea Logo_Colors(pc),a0
	clr.l (a0)+
	move.l #$403030,(a0)+
	move.l #$504040,(a0)+
	move.l #$706060,(a0)+
	move.l #$908080,(a0)+
	move.l #$b0a0a0,(a0)+
	move.l #$d0c0c0,(a0)+
	move.l #$f0e0e0,(a0)
	clr.b FadeSpeed-data_base(a5)
	move.l #Display_Logo_Coplist,cop1lc(a6)
	move.l #Display_Logo_Vbl,$6c.w
	move.w #$8380,dmacon(a6)
	move.w #$c020,intena(a6)

Loop_Display_Logo
	tst.w Logo_Wait-data_base(a5)
	bne.s Loop_Display_Logo
	rts

Display_Logo_Vbl
	SAVE_REGS
	jsr mt_music

	lea data_base(pc),a5
	lea custom_base,a6

	move.l Logo_Ptr(pc),a0
	move.w vposr(a6),d0
	bmi.s .lof
	lea 80*3(a0),a0
.lof
	move.l a0,bpl1ptH(a6)
	lea 80(a0),a0
	move.l a0,bpl2ptH(a6)
	lea 80(a0),a0
	move.l a0,bpl3ptH(a6)

	cmp.w #115,Logo_Wait-data_base(a5)
	bne.s .none
	move.b #2,FadeSpeed-data_base(a5)
.none

	lea Logo_Colors(pc),a0
	lea Logo_Coplist_ColorsH+2,a1
	lea Logo_Coplist_ColorsL+2,a2
	moveq #8-1,d0
	bsr FadeOut
	clr.w copjmp1(a6)

	subq.w #1,Logo_Wait-data_base(a5)
	move.w #$0020,intreq(a6)

	RESTORE_REGS
	rte

Logo_Colors
	dcb.l 8,0
	dc.l $00fc

*********************************************************************************
Display_Picture
	move.l a0,Picture_Ptr-data_base(a5)

	clr.b FadeSpeed-data_base(a5)
	move.l #Display_Picture_Coplist,cop1lc(a6)
	move.l #Display_Picture_Vbl,$6c.w
	move.w #$8380,dmacon(a6)
	move.w #$c020,intena(a6)

	bsr Build_Coplists

Loop_Display_Picture
	tst.w Picture_Wait-data_base(a5)
	bne.s Loop_Display_Picture
	rts

Display_Picture_Vbl
	SAVE_REGS
	jsr mt_music

	lea data_base(pc),a5
	lea custom_base,a6

	move.l Picture_Ptr(pc),a0
	move.l a0,bpl1ptH(a6)
	lea 40(a0),a0
	move.l a0,bpl2ptH(a6)
	lea 40(a0),a0
	move.l a0,bpl3ptH(a6)
	lea 40(a0),a0
	move.l a0,bpl4ptH(a6)
	lea 40(a0),a0
	move.l a0,bpl5ptH(a6)
	lea 40(a0),a0
	move.l a0,bpl6ptH(a6)

	cmp.w #128,Picture_Wait-data_base(a5)
	bne.s .none
	move.b #2,FadeSpeed-data_base(a5)
.none

	lea Picture_Colors(pc),a0
	lea Picture_Coplist_ColorsH+2,a1
	lea Picture_Coplist_ColorsL+2,a2
	moveq #32-1,d0
	bsr FadeOut
	clr.w copjmp1(a6)

	subq.w #1,Picture_Wait-data_base(a5)
	move.w #$0020,intreq(a6)

	RESTORE_REGS
	rte

Picture_Colors
	dc.l $000000
	dc.l $202010
	dc.l $B0B070
	dc.l $B0A060
	dc.l $B09050
	dc.l $B08040
	dc.l $B07030
	dc.l $A06020
	dc.l $905010
	dc.l $804010
	dc.l $704010
	dc.l $604000
	dc.l $504000
	dc.l $403000
	dc.l $805050
	dc.l $907060
	dc.l $C0C080
	dc.l $D0D080
	dc.l $E0E080
	dc.l $F0E0A0
	dc.l $F0F0C0
	dc.l $F0F0F0
	dc.l $A0A090
	dc.l $909070
	dc.l $809070
	dc.l $708070
	dc.l $607050
	dc.l $506050
	dc.l $405050
	dc.l $304040
	dc.l $A09080
	dc.l $203030

	dc.l "SKYT"

*********************************************************************************
* Routine de FadeOut
*  -->	a0=Table Couleurs
*	a1=Coplist colors High
*	a2=Coplist colors Low
*	d0=Nb Couleurs-1
FadeOut
	moveq #0,d1				HIGH
	moveq #0,d2				LOW
	addq.l #1,a0

	move.b (a0),d1
	beq.s .okr
	sub.b FadeSpeed(pc),d1
.okr
	move.b d1,(a0)+
	lsl.w #4,d1				R R0
	move.b d1,d2				R0
	lsl.w #4,d2				R 00

	move.b (a0),d1				R GG
	beq.s .okg
	sub.b FadeSpeed(pc),d1
.okg
	move.b d1,(a0)+
	lsl.w #4,d1				RG G0
	move.b d1,d2				R G0
	lsl.w #4,d2				RG 00

	move.b (a0),d1				RG BB
	beq.s .okb
	sub.b FadeSpeed(pc),d1
.okb
	move.b d1,(a0)+
	lsl.l #4,d1				R GB B0
	move.b d1,d2				RG B0
	lsr.l #8,d1				R GB   HIGH
	lsr.w #4,d2				R GB   LOW

	move.w d1,(a1)
	move.w d2,(a2)

	addq.l #4,a1
	addq.l #4,a2

	dbf d0,FadeOut
	rts

	dc.l "M.K."

*********************************************************************************
do_Rotate
	bsr Build_Coplists			calcule ca pour la rotation

	move.w #$0100,dmacon(a6)
	move.w #$1200|$8000,bplcon0(a6)
	move.l #$003800c8,ddfstrt(a6)
	clr.l bpl1mod(a6)
	move.w #$000,color00(a6)
	move.w #$fff,color01(a6)
	clr.w bplcon3(a6)
	move.w #$fff,color01(a6)

	move.l #Rotate_VBL,$6c.w
	move.l phy_coplist(pc),cop1lc(a6)

	move.w #$8280,dmacon(a6)		COPPER
	move.w #$c020,intena(a6)		et pis la VBL!

	bsr Expand_Picture

mouse
	btst #6,ciaapra
	bne.s mouse
	btst #2,potinp(a6)
	bne.s mouse
	btst #7,ciaapra
	beq.s mouse
	btst #6,potinp(a6)
	beq.s mouse

	jsr mt_end
	RESTORE_SYSTEM


* La nouvelle VBL
* ~~~~~~~~~~~~~~~
Rotate_VBL
	SAVE_REGS
	jsr mt_music

	lea data_base(pc),a5
	lea custom_base,a6

	move.w #$0100,dmacon(a6)
	move.l #Secret,bpl1ptH(a6)

	btst #6,ciaapra				bouton gauche souris ?
	bne.s .no_secret
	btst #2,potinp(a6)			bouton droit souris ?
	bne.s .no_secret
	btst #7,ciaapra				1er bouton joystick ?
	bne.s .no_secret
	btst #6,potinp(a6)			2ème bouton joystick ?
	bne.s .no_secret

	move.w #$8100,dmacon(a6)

.no_secret
	bsr.s Flip_Coplist
	bsr Move_Rotate
	bsr Build_Rotate
	bsr.s Rotate

	move.w #$0020,intreq(a6)		vire la request
	RESTORE_REGS
	rte

* Echange des coplists
* ~~~~~~~~~~~~~~~~~~~~
Flip_Coplist
	move.l log_coplist(pc),d0
	move.l phy_coplist(pc),log_coplist-data_base(a5)
	move.l d0,phy_coplist-data_base(a5)
	move.l d0,cop1lc(a6)
	clr.w copjmp1(a6)
	rts



* Rotation du bitmap et stockage dans la coplist
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Rotate
	move.l (log_coplist,pc),a0		pointe data du 1er COP_MOVE
	lea 5*4+2(a0),a0

	lea bitmap,a1				cherche un ptr sur l'image
	move.w (CentreY,pc),d0
	lsr.w #1,d0
	mulu #(PIC_X+PIC_MARGIN)*2,d0		table de WORD
	add.l d0,a1

	move.w CentreX(pc),d0			c'est là oû on regarde
	lsr.w #1,d0
	lea (a1,d0.w*2),a1			table de WORD

	lea Table_Rotate(pc),a2			la table de rotation
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



* Gestion du déplacement du zoom rotaté
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Move_Rotate
	move.w Inc_Angle(pc),d0
	add.w d0,Angle-data_base(a5)
	bge.s .ang
	add.w #MAX_ANGLE,Angle-data_base(a5)
	bra.s .zozo
.ang
	cmp.w #MAX_ANGLE,Angle-data_base(a5)
	blt.s .zozo
	sub.w #MAX_ANGLE,Angle-data_base(a5)
.zozo
	movem.w CentreX(pc),d0/d1
	add.w Inc_X(pc),d0
	add.w Inc_Y(pc),d1

	cmp.w #MARGIN_X,d0
	bgt.s .ok1
	neg.w Inc_X-data_base(a5)
	bra.s .ok2
.ok1
	cmp.w #PIC_X*2-MARGIN_X,d0
	blt.s .ok2
	neg.w Inc_X-data_base(a5)
.ok2
	cmp.w #MARGIN_Y,d1
	bgt.s .ok3
	neg.w Inc_Y-data_base(a5)
	bra.s .ok4
.ok3
	cmp.w #PIC_Y*2-MARGIN_Y,d1
	blt.s .ok4
	neg.w Inc_Y-data_base(a5)
.ok4
	movem.w d0/d1,CentreX-data_base(a5)

	subq.w #1,Angle_Counter-data_base(a5)
	bne.s .ok_boy
	neg.w Inc_Angle-data_base(a5)
	move.w #ANGLE_COUNTER,Angle_Counter-data_base(a5)
.ok_boy
	move.w Offset_Zoom1(pc),d0
	addq.w #INC_ZOOM1,d0
	cmp.w #MAX_ANGLE,d0
	blt.s .ok5
	sub.w #MAX_ANGLE,d0
.ok5	move.w d0,Offset_Zoom1-data_base(a5)

	move.w Offset_Zoom2(pc),d1
	addq.w #INC_ZOOM2,d1
	cmp.w #MAX_ANGLE,d1
	blt.s .ok6
	sub.w #MAX_ANGLE,d1
.ok6	move.w d1,Offset_Zoom2-data_base(a5)

	lea Table_Cosinus(pc),a0
	move.w (a0,d0.w*2),d0
	muls.w #$18*$10,d0
	move.w (a0,d1.w*2),d1
	muls.w #$14*$10,d1
	add.l d1,d0
	swap d0
	asr.w #1,d0
	add.w #$18,d0
	move.w d0,Zoom-data_base(a5)
	rts



* Fabrication de la table de rotation ( transcription directe de l'AMOS...)
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Build_Rotate
	move.w #(-COP_MOVEY/8),d0		B=(-COP_MOVEY/2)*Zoom
	muls.w Zoom(pc),d0

	moveq #0,d1
	move.w #(-COP_MOVEX/2),d1		A=(-COP_MOVEX/2)*Zoom
	muls.w Zoom(pc),d1

	moveq #MAX_MOVE-1,d2			M

	move.w Angle(pc),d7			ANGLE
	lea Table_Cosinus(pc),a1
	move.w (a1,d7.w*2),d3			Cos(ANGLE)
	lea Table_Sinus(pc),a1
	move.w (a1,d7.w*2),d4			Sin(ANGLE)

	lea 0.w,a0
	lea 0.w,a1
	lea Table_Rotate(pc),a2
	lea COP_MOVEX*4(a2),a3

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

	ext.l d5
	move.w d6,d7
	muls.w #(PIC_X+PIC_MARGIN),d7		Y*PIC_X
	add.l d5,d7
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
	add.w Zoom(pc),d1			Inc A
	dbf d2,for_M
	rts

no_change_center
	move.w d5,a0				UPDATE OLD_X & OLD_Y
	move.w d6,a1
.next_M
	add.w Zoom(pc),d1			Inc A
	dbf d2,for_M
	rts



* Transformation de l'image : chaque pixel devient un mot donnant sa couleur
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Expand_Picture
	lea picture_colors(pc),a0		construit d'abord les couleurs
	lea picture_colors+32*2(pc),a1		du half-bright...
	moveq #32-1,d0
loop_half
	move.w (a0)+,d1
	lsr.w #1,d1
	and.w #$777,d1
	move.w d1,(a1)+
	dbf d0,loop_half

	lea end_picture-1,a0			pointe l'image
	lea end_bitmap,a1			pointe le bitmap
	lea picture_colors,a2			pointe les couleurs
	move.w #PIC_Y-1,d0			répète pour toutes les lignes
expand_all
	move.w #PIC_X-1,d1			répète pour la ligne
	moveq #0,d2				# du bit à tester
	lea -(PIC_MARGIN*2)(a1),a1		la marge...
expand_line
	moveq #PIC_DEPTH-1,d3			répète pour chaque bpl
	moveq #0,d4				on stocke la couleur ici
	move.l a0,a3				err.. lit à partir d'ici
expand_bit
	btst d2,(a3)
	beq.s .clr
	addq.w #1,d4
.clr
	lea (-PIC_WIDTH,a3),a3
	add.w d4,d4
	dbf d3,expand_bit
	move.w (a2,d4.w),-(a1)			stocke sa couleur
	addq.w #1,d2				test le bit suivant
	and.w #$7,d2				reste dans la limite des 8
	beq.s end_byte				change de limite ?
	dbf d1,expand_line
	lea -PIC_WIDTH*(PIC_DEPTH-1)(a0),a0	saute les bpls entrelacés
	dbf d0,expand_all
	rts
end_byte
	subq.l #1,a0
	dbf d1,expand_line
	lea -PIC_WIDTH*(PIC_DEPTH-1)(a0),a0	saute les bpls entrelacés
	dbf d0,expand_all
	rts



* Fabrication des coplists
* ~~~~~~~~~~~~~~~~~~~~~~~~
Build_Coplists
	lea coplist1,a1
	move.l a1,log_coplist-data_base(a5)
	bsr build_one_coplist
	move.l a1,phy_coplist-data_base(a5)

build_one_coplist
	move.l #$002b80fe,d7
	move.l #$1ee3fffe,(a1)+			wait sur la ligne kon veut...
	move.l #(fmode<<16)|$3,(a1)+		move.w #$3,fmode
	move.l a1,d1
	add.l #2*4,d1				pour relancer la coplist

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
	add.l #2*4,d1
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
	add.l #2*4,d1
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

	move.l #$fffffffe,(a1)+
	rts


	dc.l "SNT!"

* Toutes les datas de Rotate
* ~~~~~~~~~~~~~~~~~~~~~~~~~~
	CNOP 0,4
data_base

Table_Rotate	ds.l COP_MOVEX
Table_Centre	ds.l COP_MOVEY-1

Msg_Ptr		dc.l 0
Logo_Ptr	dc.l 0
Picture_Ptr	dc.l 0
log_coplist	dc.l 0
phy_coplist	dc.l 0
CentreX		dc.w PIC_X
CentreY		dc.w PIC_Y
Angle		dc.w 0
Angle_Counter	dc.w ANGLE_COUNTER
Inc_X		dc.w 3
Inc_Y		dc.w 2
Inc_Angle	dc.w 6
Zoom		dc.w 0
Offset_Zoom1	dc.w 0
Offset_Zoom2	dc.w 0
Msg_Wait	dc.w 0
Logo_Wait	dc.w 0
Picture_Wait	dc.w 0
FadeSpeed	dc.b 0
		CNOP 0,4

picture_colors
	dc.w	$0000
	dc.w	$0221
	dc.w	$0BB7
	dc.w	$0BA6
	dc.w	$0B95
	dc.w	$0B84
	dc.w	$0B73
	dc.w	$0A62
	dc.w	$0951
	dc.w	$0841
	dc.w	$0741
	dc.w	$0640
	dc.w	$0540
	dc.w	$0430
	dc.w	$0855
	dc.w	$0976
	dc.w	$0CC8
	dc.w	$0DD8
	dc.w	$0EE8
	dc.w	$0FEA
	dc.w	$0FFC
	dc.w	$0FFF
	dc.w	$0AA9
	dc.w	$0997
	dc.w	$0897
	dc.w	$0787
	dc.w	$0675
	dc.w	$0565
	dc.w	$0455
	dc.w	$0344
	dc.w	$0A98
	dc.w	$0233
	dcb.w 32,0

Table_Cosinus	incbin "Table_Sinus.DAT"
Table_Sinus=Table_Cosinus+90*4

mt_patterns
	incbin "Patterns.dat"


* La replay et sa zik
* ~~~~~~~~~~~~~~~~~~~
	include "TMC_Replay.s"


**********************************************************************
* Source-Song Generated With  TMC v4.3  (c)1993 Sync of DreamDealers *
* From Module : mod.raging fire.(short)                              *
* SongName    : raging fire.(short)                                  *
**********************************************************************


		*****************************************************
		* THIS SECTION CAN BE EITHER IN FAST OR CHIP MEMORY *
		*****************************************************
	CNOP 0,4
mt_global_volume
	dc.w $64,$0
mt_restart
	dc.l mt_pos+4*$00
mt_samples_list
	dc.l mt_sample01
	dc.l mt_sample02
	dc.l mt_sample03
	dc.l mt_sample04
	dc.l mt_sample05
	dc.l mt_sample06
	dc.l mt_sample07
	dc.l mt_sample08
	dc.l mt_sample09
	dc.l mt_sample0A
	dc.l mt_sample0B
	dc.l mt_sample0C
	dc.l mt_sample0D
	dc.l mt_sample0E
	dc.l mt_sample0F
	dc.l mt_sample10
	dc.l mt_sample11
	dc.l mt_sample12
	dc.l mt_sample13
	dc.l mt_sample14
mt_pos
	dc.l mt_patterns+$0912
	dc.l mt_patterns+$0000
	dc.l mt_patterns+$0A9E
	dc.l mt_patterns+$0A9E
	dc.l mt_patterns+$05F0
	dc.l mt_patterns+$0428
	dc.l mt_patterns+$0780
	dc.l mt_patterns+$0A9E
	dc.l mt_patterns+$02AA
	dc.l mt_patterns+$018C
mt_pos_end

mt_FineTune0
	dc.w 856,808,762,720,678,640,604,570,538,508,480,453
	dc.w 428,404,381,360,339,320,302,285,269,254,240,226
	dc.w 214,202,190,180,170,160,151,143,135,127,120,113,0
mt_FineTune1
	dc.w 850,802,757,715,674,637,601,567,535,505,477,450
	dc.w 425,401,379,357,337,318,300,284,268,253,239,225
	dc.w 213,201,189,179,169,159,150,142,134,126,119,113,0



* Les samples de la zik en CHIP et images
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	section feelthebeat,data_c


**********************************************************************
* Source-Song Generated With  TMC v4.3  (c)1993 Sync of DreamDealers *
* From Module : mod.raging fire.(short)                              *
* SongName    : raging fire.(short)                                  *
**********************************************************************


		***************************************
		* THIS SECTION MUST BE IN CHIP MEMORY *
		***************************************
mt_sample01
	dc.w $7FC9
	dc.w $40
	dc.l *+10+2*$692A
	dc.w $169F
	dc.l mt_FineTune1
	incbin "Sample01.dat"
mt_sample02
	dc.w $03D5
	dc.w $30
	dc.l *+10+2*$02A4
	dc.w $0131
	dc.l mt_FineTune0
	incbin "Sample02.dat"
mt_sample0A
	dc.w $2627
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune1
	incbin "Sample0A.dat"
mt_sample0B
	dc.w $098E
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune1
	incbin "Sample0B.dat"
mt_sample0C
	dc.w $038C
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune1
	incbin "Sample0C.dat"
mt_sample0D
	dc.w $03DF
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune1
	incbin "Sample0D.dat"
mt_sample0E
	dc.w $1143
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune1
	incbin "Sample0E.dat"
mt_sample0F
	dc.w $0F06
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune1
	incbin "Sample0F.dat"
mt_sample14
	dc.w $073E
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune1
	incbin "Sample14.dat"

Display_Msg_Coplist
	dc.w fmode,$0
	dc.w bplcon0,$2200|$8000
	dc.w bplcon1,$0
	dc.w bplcon2,$0
	dc.w ddfstrt,$003c
	dc.w ddfstop,$00d4
	dc.w diwstrt,$9081
	dc.w diwstop,$b9c1
	dc.w bpl1mod,80
	dc.w bpl2mod,80
	dc.w bplcon3,$0
Msg_Coplist_ColorsH
	dc.w color00,0
	dc.w color01,$555
	dc.w color02,$aaa
	dc.w color03,$eee
	dc.w bplcon3,$0200
Msg_Coplist_ColorsL
	dc.w color00,0
	dc.w color01,0
	dc.w color02,0
	dc.w color03,0
	dc.l $fffffffe

Display_Logo_Coplist
	dc.w fmode,$0
	dc.w bplcon0,$3200|$8004
	dc.w bplcon1,$0
	dc.w bplcon2,$0
	dc.w ddfstrt,$003c
	dc.w ddfstop,$00d4
	dc.w diwstrt,$9081
	dc.w diwstop,$b8c1
	dc.w bpl1mod,80*5
	dc.w bpl2mod,80*5
	dc.w bplcon3,$0
Logo_Coplist_ColorsH
	dc.w color00,0
	dc.w color01,$433
	dc.w color02,$544
	dc.w color03,$766
	dc.w color04,$988
	dc.w color05,$baa
	dc.w color06,$dcc
	dc.w color07,$fee
	dc.w bplcon3,$0200
Logo_Coplist_ColorsL
	dc.w color00,0
	dc.w color01,0
	dc.w color02,0
	dc.w color03,0
	dc.w color04,0
	dc.w color05,0
	dc.w color06,0
	dc.w color07,0
	dc.l $fffffffe

mt_sample04
	dc.w $1E82
	dc.w $37
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune0
	incbin "Sample04.dat"
mt_sample05
	dc.w $14F5
	dc.w $40
	dc.l *+10+2*$09EA
	dc.w $0B0B
	dc.l mt_FineTune0
	incbin "Sample05.dat"
mt_sample06
	dc.w $05D1
	dc.w $30
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune0
	incbin "Sample06.dat"

Display_Picture_Coplist
	dc.w fmode,$0
	dc.w bplcon0,$6200
	dc.w bplcon1,$0
	dc.w bplcon2,$0
	dc.w ddfstrt,$0038
	dc.w ddfstop,$00d0
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w bpl1mod,40*5
	dc.w bpl2mod,40*5
	dc.w bplcon3,$0
Picture_Coplist_ColorsH
	dc.w color00,0
	dc.w color01,0
	dc.w color02,0
	dc.w color03,0
	dc.w color04,0
	dc.w color05,0
	dc.w color06,0
	dc.w color07,0
	dc.w color08,0
	dc.w color09,0
	dc.w color10,0
	dc.w color11,0
	dc.w color12,0
	dc.w color13,0
	dc.w color14,0
	dc.w color15,0
	dc.w color16,0
	dc.w color17,0
	dc.w color18,0
	dc.w color19,0
	dc.w color20,0
	dc.w color21,0
	dc.w color22,0
	dc.w color23,0
	dc.w color24,0
	dc.w color25,0
	dc.w color26,0
	dc.w color27,0
	dc.w color28,0
	dc.w color29,0
	dc.w color30,0
	dc.w color31,0
	dc.w bplcon3,$0200
Picture_Coplist_ColorsL
	dc.w color00,0
	dc.w color01,0
	dc.w color02,0
	dc.w color03,0
	dc.w color04,0
	dc.w color05,0
	dc.w color06,0
	dc.w color07,0
	dc.w color08,0
	dc.w color09,0
	dc.w color10,0
	dc.w color11,0
	dc.w color12,0
	dc.w color13,0
	dc.w color14,0
	dc.w color15,0
	dc.w color16,0
	dc.w color17,0
	dc.w color18,0
	dc.w color19,0
	dc.w color20,0
	dc.w color21,0
	dc.w color22,0
	dc.w color23,0
	dc.w color24,0
	dc.w color25,0
	dc.w color26,0
	dc.w color27,0
	dc.w color28,0
	dc.w color29,0
	dc.w color30,0
	dc.w color31,0
	dc.l $fffffffe

Msg1	incbin "Msg1.RAW"
Msg2	incbin "Msg2.RAW"
Msg3	incbin "Msg3.RAW"

mt_sample12
	dc.w $0942
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune1
	incbin "Sample12.dat"
mt_sample13
	dc.w $067F
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune1
	incbin "Sample13.dat"

Logo1	incbin "DreamDealers.RAW"
Logo2	incbin "RagingFire.RAW"

mt_sample10
	dc.w $1915
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune1
	incbin "Sample10.dat"
mt_sample11
	dc.w $1ABB
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune1
	incbin "Sample11.dat"

Secret	incbin "SecretScreen.RAW"

picture
	incbin "RotatePic.RAW"		=> PIC_WIDTH*PIC_HEIGHT*PIC_DEPTH
end_picture

mt_sample03
	dc.w $0D47
	dc.w $30
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune0
	incbin "Sample03.dat"
mt_sample07
	dc.w $0F7A
	dc.w $30
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune0
	incbin "Sample07.dat"
mt_sample08
	dc.w $2DC4
	dc.w $40
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune0
	incbin "Sample08.dat"
mt_sample09
	dc.w $042F
	dc.w $18
	dc.l *+10+2*$0000
	dc.w $0001
	dc.l mt_FineTune0
	incbin "Sample09.dat"



* Le buffer-chunky et les coplists
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	section chunky,bss_c
	ds.w (PIC_X+PIC_MARGIN)*PIC_MARGIN
bitmap	ds.w (PIC_X+PIC_MARGIN)*PIC_Y
end_bitmap
	ds.w (PIC_X+PIC_MARGIN)*PIC_MARGIN

coplist1	ds.b COP_SIZE
coplist2	ds.b COP_SIZE

