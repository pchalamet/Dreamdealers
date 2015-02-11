
*					CORINNE !
*					~~~~~~~~~

*
*				Code........Sync/DreamDealers
*				Graphics....Fletch+Antony/DreamDealers
*				Music.......Doh/Cryptoburners
*



* les options de compilation
* ~~~~~~~~~~~~~~~~~~~~~~~~~~
	OPT O+,OW-
	OPT NODEBUG,NOLINE
	OPT P=68020
	OUTPUT ram:X




* les includes
* ~~~~~~~~~~~~
	incdir "asm:sources/"
	incdir "corinne:"
	incdir "corinne:sources/"
	incdir "corinne:gfx/"
	incdir "corinne:music/"
	incdir "corinne:samples/"
	include "registers.i"




* Quelques EQU
* ~~~~~~~~~~~~
MUSIC=1

FADE_SPEED=2
SCREEN_X=640
SCREEN_Y=256
BPL_OFFSET=50
BPL_X=SCREEN_X+320
BPL_Y=BPL_OFFSET+256+BPL_OFFSET
BPL_DEPTH=5
BPL_WIDTH=BPL_X/8


DELAY_DRD=220+140
DELAY_CORINNE=500+140
;DELAY_DRD=150
;DELAY_CORINNE=150

NB_BOBS=9
NO_SAMPLE=0
NB_FONT=26+10+4

* Structures des bobs
* ~~~~~~~~~~~~~~~~~~~
	rsreset
Bob_Struct	rs.b 0
bob_SampData	rs.l 1
bob_SampLen	rs.w 1
bob_Data	rs.l 1
bob_Mask	rs.l 1
bob_BltSize	rs.l 1
bob_Modulo	rs.w 1
bob_PosX	rs.w 1
bob_PosY	rs.w 1
bob_SizeX	rs.w 1
bob_SizeY	rs.w 1
bob_SIZEOF	rs.b 0



* Quelques macros
* ~~~~~~~~~~~~~~~
LOAD_BOB	MACRO
Bob_\1
	incbin "\1.RAW"
	incbin "\1.MSK"
	ENDM


LOAD_MVT	MACRO
	incbin "Move_\1.RAW"
	ENDM


LOAD_SAMPLE	MACRO
Sample_\1
	incbin "Sample_\1.RAW"
	ENDM


DEF_BOB		MACRO
BOB_SIZE set ((\2+15+16)/16)*\3*BPL_DEPTH*2
	IFNE \4
	dc.l Sample_\1					SampData
	dc.w \4/2
	ELSEIF
	dc.l 0
	dc.w 0
	ENDC
	dc.l Bob_\1					Data
	dc.l Bob_\1+BOB_SIZE				Mask
	dc.l ((\3*BPL_DEPTH)<<16)|((\2+15+16)/16)	BltSize
	dc.w BPL_WIDTH-((\2+15+16)/16)*2		Modulo
	dc.w 0						PosX
	dc.w 0						PosY
	dc.w \2						SizeX
	dc.w \3						SizeY

	ENDM

	



* le point d'entrée
* ~~~~~~~~~~~~~~~~~
	section copine,code

	KILL_SYSTEM do_Corinne
	moveq #0,d0
	rts

do_Corinne
	lea DataBase,a5
	lea _Custom,a6

	move.w #$8640,dmacon(a6)			go! go! blitter!

	IFNE MUSIC
	bsr mt_init
	ENDC
	bsr Init_Datas
	bsr Init_Display_Title
	bsr Init_Come_On_Les_Tetes
	bsr Init_Come_On_Les_Bobs
	bsr Init_Mouse
	bsr Init_Scroller

	move.w #$87c0,dmacon(a6)
	move.l #Fake_Vbl,$6c.w
	move.l #Fake_Coplist,cop1lc(a6)
	clr.w copjmp1(a6)

	move.w #$c020,intena(a6)

	bsr Display_Title
	bsr Come_On_Les_Tetes
	bsr Come_On_Les_Bobs
	bsr Come_On_Mouse

	IFNE MUSIC
	bsr mt_end
	ENDC
	RESTORE_SYSTEM



*************************************************************************************************
*************************************************************************************************
*                                   VBL D'INITIALISATION
*
* en entrée: a5=DataBase
*            a6=_Custom
*************************************************************************************************
*************************************************************************************************
Fake_Vbl
	SAVE_REGS

	IFNE MUSIC
	bsr mt_music
	ENDC

	RESTORE_REGS
	move.w #$0020,intreq(a6)
	rte








*************************************************************************************************
*************************************************************************************************
*                           INITIALISATION GLOBALES DES DATAS DANS x(a5)
*************************************************************************************************
*************************************************************************************************
Init_Datas
	move.l #Screen_space,d0
	addq.l #7,d0
	and.l #~7,d0
	add.l #BPL_WIDTH*BPL_OFFSET*BPL_DEPTH,d0
	move.l d0,Log_Screen(a5)
	add.l #BPL_WIDTH*BPL_Y*BPL_DEPTH,d0
	move.l d0,Phy_Screen(a5)

	add.l #-BPL_WIDTH*BPL_Y*BPL_DEPTH+BPL_WIDTH*(BPL_DEPTH-1),d0
	move.l d0,Scroll_Screen(a5)

	move.l #Back_space1,Log_Back(a5)
	move.l #Back_space2,Phy_Back(a5)
	rts






*************************************************************************************************
*************************************************************************************************
*                                  AFFICHAGE DU TITRE DE LA DEMO
*************************************************************************************************
*************************************************************************************************
Init_Display_Title
	move.w #$0100,bplcon2(a6)			lecture des reg couleurs
	move.w #0,bplcon3(a6)
	move.w color00(a6),d0				d0=xx|xx|0A|CE
	move.w #$0200,bplcon3(a6)
	move.w color00(a6),d1				d1=xx|xx|0B|DF

	moveq #0,d2
	move.w d0,d2					xx|xx|0A|CE
	clr.b d2					xx|xx|0A|00
	lsl.w #4,d2					xx|xx|A0|00
	or.w d1,d2					xx|xx|AB|DF
	move.b d0,d2					xx|xx|AB|CE
	lsl.l #4,d2					xx|xA|BC|E0
	move.b d1,d2					xx|xA|BC|DF
	lsl.l #4,d2					xx|AB|CD|F0
	lsr.b #4,d2					xx|AB|CD|0F
	lsl.b #4,d0					d0=xx|xx|0A|E0
	or.b d0,d2					xx|AB|CD|EF
	and.l #$00fefefe,d2

	lea Picture_Colors(pc),a0
	moveq #8-1,d0
.init	move.l d2,(a0)+
	dbf d0,.init
	rts


Display_Title
	lea Picture_Robeau,a0
	lea Colors_Robeau_In,a1
	lea Colors_Robeau_Out,a2
	move.w #DELAY_DRD,d0
	bsr Display_Picture

	lea Picture_Corinne,a0
	lea Colors_Corinne_In,a1
	lea Colors_Corinne_Out,a2
	move.w #DELAY_CORINNE,d0
	bra Display_Picture				bra + rts = bsr


*************************************************************************************************
*                                  AFFICHAGE D'UNE IMAGE
*
* en entrée: d0=Picture_Wait
*            a0=*Image
*            a1=*Palette Fade In
*            a2=*Palette Fade out
*            a5=DataBase
*            a6=_Custom
*************************************************************************************************
Display_Picture
	move.l a0,Picture_Ptr(a5)
	move.l a1,Picture_Colors_In(a5)
	move.l a2,Picture_Colors_Out(a5)
	move.w d0,Picture_Wait(a5)
	clr.w Picture_Scroll(a5)

	move.l #Display_Picture_Coplist,cop1lc(a6)
	move.l #Display_Picture_Vbl,$6c.w

Loop_Display_Picture
	tst.w Picture_Wait(a5)
	bne.s Loop_Display_Picture
	rts

* la vbl pour afficher l'image entrelacée
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* en entrée: a5=DataBase
*            a6=_Custom
*
Display_Picture_Vbl
	SAVE_REGS

	move.l Picture_Ptr(a5),a0
	move.w vposr(a6),d0
	bmi.s .lof
	lea 80*3(a0),a0
.lof
	move.l a0,bpl1ptH(a6)
	lea 80(a0),a0
	move.l a0,bpl2ptH(a6)
	lea 80(a0),a0
	move.l a0,bpl3ptH(a6)

	cmp.w #140,Picture_Wait(a5)
	bge.s .fade_in
.fade_out
	move.l Picture_Colors_Out(a5),a3
	addq.w #1,Picture_Scroll(a5)
	bra.s .fade
.fade_in
	move.l Picture_Colors_In(a5),a3
.fade
	lea Picture_Colors(pc),a0
	lea Picture_Coplist_ColorsH,a1
	lea Picture_Coplist_ColorsL,a2
	moveq #8-1,d0
	bsr Fade

	move.w Picture_Scroll(a5),d0
	lsr.w #1,d0

	move.w d0,d1
	lsr.w #2,d1
	and.w #$f,d1
	move.w d1,d2
	lsl.w #4,d2
	or.w d2,d1					$00FF

	move.w d0,d2
	and.w #$c0,d2
	lsl.w #4,d2
	or.w d2,d1
	lsl.w #4,d2
	or.w d2,d1

	and.w #$3,d0
	ror.w #4,d0
	or.w d0,d1

	lsr.w #4,d0
	or.w d0,d1

	move.w d1,Picture_Coplist_Scroll

	clr.w copjmp1(a6)

	subq.w #1,Picture_Wait(a5)

	IFNE MUSIC
	bsr mt_music
	ENDC

	RESTORE_REGS
	move.w #$0020,intreq(a6)
	rte

Picture_Colors
	dcb.l 8,0



*************************************************************************************************
*                                        ROUTINE DE FADE
* en entrée: a0=Table Couleurs
*            a1=Coplist colors High
*            a2=Coplist colors Low
*            a3=Table Couleurs à obtenir
*            d0=Nb Couleurs-1
*************************************************************************************************
Fade
	moveq #0,d1				HIGH
	moveq #0,d2				LOW
	addq.l #1,a0
	addq.l #1,a3

	move.b (a0),d1
	cmp.b (a3)+,d1
	beq.s .okr
	bhi.s .subr
.addr	addq.b #FADE_SPEED*2,d1
.subr	subq.b #FADE_SPEED,d1
.okr	move.b d1,(a0)+
	lsl.w #4,d1				R R0
	move.b d1,d2				R0
	lsl.w #4,d2				R 00

	move.b (a0),d1				R GG
	cmp.b (a3)+,d1
	beq.s .okg
	bhi.s .subg
.addg	addq.b #FADE_SPEED*2,d1
.subg	subq.b #FADE_SPEED,d1
.okg	move.b d1,(a0)+
	lsl.w #4,d1				RG G0
	move.b d1,d2				R G0
	lsl.w #4,d2				RG 00

	move.b (a0),d1				RG BB
	cmp.b (a3)+,d1
	beq.s .okb
	bhi.s .subb
.addb	addq.b #FADE_SPEED*2,d1
.subb	subq.b #FADE_SPEED,d1
.okb	move.b d1,(a0)+
	lsl.l #4,d1				R GB B0
	move.b d1,d2				RG B0
	lsr.l #8,d1				R GB   HIGH
	lsr.w #4,d2				R GB   LOW

	move.w d1,(a1)
	move.w d2,(a2)

	addq.l #4,a1
	addq.l #4,a2

	dbf d0,Fade
	rts





*************************************************************************************************
*************************************************************************************************
*                            ON FAIT VENIR LES TETES DU COTE GAUCHE
*************************************************************************************************
*************************************************************************************************
Init_Come_On_Les_Tetes
	move.w #180,Move_Tete_Pos(a5)

	move.l Log_Screen(a5),a0
	WAIT_BLITTER
	move.l #Picture_Tetes,bltapt(a6)
	move.l a0,bltdpt(a6)
	move.l #BPL_WIDTH*(BPL_DEPTH-1)+(BPL_WIDTH-40),bltamod(a6)
	move.l #$09f00000,bltcon0(a6)
	moveq #-1,d0
	move.l d0,bltafwm(a6)
	move.l #(256<<16)|(20),bltsizV(a6)

	add.l #BPL_WIDTH*BPL_Y*BPL_DEPTH,a0
	WAIT_BLITTER
	move.l #Picture_Tetes,bltapt(a6)
	move.l a0,bltdpt(a6)
	move.l #(256<<16)|(20),bltsizV(a6)
	rts


Come_On_Les_Tetes
	move.l #Move_Tetes_Vbl,$6c.w
	move.l #Move_Tetes_Coplist,cop1lc(a6)

.wait	tst.w Move_Tete_Pos(a5)
	bne.s .wait
	rts


Move_Tetes_Vbl
	SAVE_REGS

	move.l Log_Screen(a5),a0
	subq.l #2,a0
	move.w Move_Tete_Pos(a5),d0
	move.w d0,d1
	lsr.w #3,d0
	add.w d0,d0
	lea (a0,d0.w),a0
	not.w d1
	and.w #$f,d1
	move.w d1,bplcon1(a6)
	move.l a0,bpl1ptH(a6)

	subq.w #1,Move_Tete_Pos(a5)

	IFNE MUSIC
	bsr mt_music
	ENDC

	RESTORE_REGS
	move.w #$0020,intreq(a6)
	rte




*************************************************************************************************
*************************************************************************************************
*                              AFFICHAGE DU VERITABLE ECRAN DE CORINNE
*************************************************************************************************
*************************************************************************************************
Init_Come_On_Les_Bobs
	move.l Log_Screen(a5),d0
	lea Main_BplPtr,a0

	moveq #BPL_DEPTH-1,d1
.put	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	swap d0
	add.l #BPL_WIDTH,d0
	addq.l #8,a0
	dbf d1,.put
	rts



Come_On_Les_Bobs
	move.l #Move_Bobs_Vbl,$6c.w
	move.l #Main_Coplist,cop1lc(a6)

	lea Bob_Structures-bob_SIZEOF(pc),a0
	move.l a0,Curr_Move_Bob(a5)
	move.l #Bob_Movements,Curr_Move(a5)
	move.w #NB_BOBS+1,Curr_Bob(a5)
	clr.w Nb_Move(a5)

.more
	tst.w Curr_Bob(a5)
	bne.s .more
	rts


Move_Bobs_Vbl
	SAVE_REGS

	bsr Flip_Screen

	tst.w Nb_Move(a5)			on arrive à la fin du movement ?
	bne.s .paste

	tst.w Curr_Bob(a5)			voui => on passe au suivant
	beq.s .nothing				si yen a d'autres
	subq.w #1,Curr_Bob(a5)
	beq.s .nothing
.next
	move.l Curr_Move_Bob(a5),a0		structure bob suivante
	lea bob_SIZEOF(a0),a0
	move.l a0,Curr_Move_Bob(a5)

	move.l Curr_Move(a5),a0			init le movement
	move.w (a0)+,Nb_Move(a5)
	move.l a0,Curr_Move(a5)

	clr.l Log_BackScrAdr(a5)
	clr.l Phy_BackScrAdr(a5)
	
.paste
	move.l Curr_Move_Bob(a5),a0
	move.l Curr_Move(a5),a1
	move.l (a1)+,bob_PosX(a0)		bob_PosX & bob_PosY
	move.l a1,Curr_Move(a5)
	bsr Paste_Bob
	subq.w #1,Nb_Move(a5)

.nothing

	IFNE MUSIC
	bsr mt_music
	ENDC

	RESTORE_REGS
	move.w #$0020,intreq(a6)
	rte



Flip_Screen
	move.l Log_Screen(a5),d0
	move.l Phy_Screen(a5),Log_Screen(a5)
	move.l d0,Phy_Screen(a5)

	lea Main_BplPtr,a0
	moveq #BPL_DEPTH-2,d1
.put	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	swap d0
	add.l #BPL_WIDTH,d0
	addq.l #8,a0
	dbf d1,.put

	clr.w copjmp1(a6)

	move.l Log_Back(a5),d0
	move.l Phy_Back(a5),Log_Back(a5)
	move.l d0,Phy_Back(a5)

	move.l Log_BackScrAdr(a5),d0
	move.l Phy_BackScrAdr(a5),Log_BackScrAdr(a5)
	move.l d0,Phy_BackScrAdr(a5)

	rts
















*************************************************************************************************
*************************************************************************************************
*                                GESTION DE LA SOURIS
*************************************************************************************************
*************************************************************************************************
Init_Mouse
	lea Picture_Mouse(pc),a0
	lea Mouse_Sprite_Even+4*4,a1
	lea Mouse_Sprite_Odd+4*4,a2
	moveq #62-1,d0
.make
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a2)+
	move.l (a0)+,(a2)+
	move.l (a0)+,(a2)+
	move.l (a0)+,(a2)+
	dbf d0,.make

	lea Spr_Ptr,a0				met en place le sprite 0
	move.l #Mouse_Sprite_Even,d0
	bsr install_spr

	move.l #Mouse_Sprite_Odd,d0
	bsr install_spr

	move.l #Blank_Sprite,d0
	moveq #6-1-1,d1				becoz ruzzze...
.put	bsr install_spr
	dbf d1,.put	

install_spr
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	swap d0
	addq.l #8,a0
	rts


Come_On_Mouse
	move.w #$8020,dmacon(a6)		sprites
	move.l #Mouse_Vbl,$6c.w

.wait
	tst.l MouseX(a5)
	bne.s .wait

	btst #6,ciaapra
	bne.s .wait

	rts


Mouse_Vbl
	SAVE_REGS

	bsr Flip_Screen
	bsr Update_Mouse
	bsr Redraw_Mouse
	bsr Booze_Bob
	bsr Music_Bob
	bsr Scroller

	IFNE MUSIC
	bsr mt_music
	ENDC

	RESTORE_REGS
	move.w #$0020,intreq(a6)
	rte




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
	bge.s .ok1
	clr.w MouseX(a5)
	bra.s .ok2
.ok1
	cmp.w #SCREEN_X,MouseX(a5)
	ble.s .ok2
	move.w #SCREEN_X,MouseX(a5)
.ok2
	sub.w d2,MouseY(a5)
	bge.s .ok3
	clr.w MouseY(a5)
	bra.s .ok4
.ok3
	cmp.w #SCREEN_Y*2,MouseY(a5)
	ble.s .ok4
	move.w #SCREEN_Y*2,MouseY(a5)
.ok4

	move.w LeftPressed(a5),OldLeftPressed(a5)	Left & Right

	btst #6,ciaapra				regarde si les trucs sont tapotés
	seq LeftPressed(a5)
	btst #2,potinp(a6)
	seq RightPressed(a5)

	rts


Redraw_Mouse
	move.w MouseX(a5),d0
	sub.w #32,d0
	move.w MouseY(a5),d1
	lsr.w #1,d1
	sub.w #10,d1
	moveq #62,d2
	bsr Compute_Sprite_Control
	or.w #$80,d3				attache les sprites 0 et 1
	move.w d0,Mouse_Sprite_Even
	move.w d0,Mouse_Sprite_Odd
	move.w d3,Mouse_Sprite_Even+8
	move.w d3,Mouse_Sprite_Odd+8
	rts




Booze_Bob
	tst.b RightPressed(a5)			gauche enfoncé ?
	beq check_for_doublebuffer		nan...

	tst.b DoubleBuffer(a5)
	bne.s .skip

	tst.b OldRightPressed(a5)		on était déja dans le mode déplacement ?
	bne booge_this_one
.skip
	sf DoubleBuffer(a5)

* recherche le bob sur lequel l'utilisateur vient de clicker
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
get_new_bob
	move.w MouseX(a5),d0
	move.w MouseY(a5),d1
	lsr.w #1,d1

	lea Bob_Structures(pc),a0
	moveq #NB_BOBS-1,d7
.search
	movem.w bob_PosX(a0),d2/d3

	cmp.w d2,d0				regarde si la souris est sur le bob
	blt.s .next
	cmp.w d3,d1
	blt.s .next
	add.w bob_SizeX(a0),d2
	add.w bob_SizeY(a0),d3
	cmp.w d2,d0
	bge.s .next
	cmp.w d3,d1
	blt.s gotcha				on le tient !!
.next
	lea bob_SIZEOF(a0),a0
	dbf d7,.search
	clr.b RightPressed(a5)
	rts

* à partir d'ici on sait ke la souris est sur le bob pointé par A0
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*   -->	a0=Bob_Structure
gotcha
	move.l a0,Curr_Move_Bob(a5)
	clr.l Log_BackScrAdr(a5)
	clr.l Phy_BackScrAdr(a5)

	move.w bob_PosX(a0),d0			calcul le décalage entre le bob et la souris
	sub.w MouseX(a5),d0
	move.w MouseY(a5),d1
	lsr.w #1,d1
	sub.w bob_PosY(a0),d1
	neg.w d1
	move.w d0,DecalageX(a5)
	move.w d1,DecalageY(a5)

	move.l bob_PosX(a0),Start_PosX(a5)	PosX & PosY

booge_this_one
	move.l Curr_Move_Bob(a5),a0		calcule la nouvelle position du bob
	move.w MouseX(a5),d0			en fonction de la souris
	add.w DecalageX(a5),d0
	move.w d0,bob_PosX(a0)
	move.w MouseY(a5),d0
	lsr.w #1,d0
	add.w DecalageY(a5),d0
	move.w d0,bob_PosY(a0)

	movem.w bob_PosX(a0),d0/d1

	cmp.w #SCREEN_X/2,d0			coté gauche
	bge.s .ok1
	move.w #320,bob_PosX(a0)
.ok1
	tst.w d1				coté haut
	bge.s .ok2
	clr.w bob_PosY(a0)
.ok2
	add.w bob_SizeX(a0),d0
	add.w bob_SizeY(a0),d1

	cmp.w #SCREEN_X,d0			coté droit
	blt.s .ok3
	sub.w #SCREEN_X,d0
	sub.w d0,bob_PosX(a0)
.ok3
	cmp.w #SCREEN_Y,d1			coté bas
	blt.s .ok4
	sub.w #SCREEN_Y,d1
	sub.w d1,bob_PosY(a0)
.ok4
	bra Paste_Bob


check_for_doublebuffer
	tst.b OldRightPressed(a5)		on bougeait avant ?
	beq.s .nothing

	st DoubleBuffer(a5)

	move.l Curr_Move_Bob(a5),a0
	bsr Check_Overlapping			regarde si y se bouffent entre-eux
	beq Paste_Bob
	st RightPressed(a5)
	move.l Start_PosX(a5),bob_PosX(a0)	PosX & PosY
	bra Paste_Bob

.nothing
	rts



* verification de l'overlapping des bobs
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*   -->	a0=Bob_Structure à comparer aux autres
Check_Overlapping
	lea Bob_Structures(pc),a1

	movem.w bob_PosX(a0),d0/d1/d2/d3	PosX / PosY / SizeX / SizeY
	add.w d0,d2
	add.w d1,d3
	add.w #15-1,d2				car PosX+SizeX
	lsr.w #4,d0
	lsr.w #4,d2
	add.w d0,d0
	add.w d2,d2

	moveq #NB_BOBS-1,d7
loop_check_overlap
	move.w d7,a4				sauve ca quelque part

	cmp.l a0,a1
	beq.s no_intersection

* on a 2 bobs differents ici
* ~~~~~~~~~~~~~~~~~~~~~~~~~~
	movem.w bob_PosX(a1),d4/d5/d6/d7	PosX / PosY / SizeX / SizeY
	add.w d4,d6
	add.w d5,d7
	add.w #15-1,d6
	lsr.w #4,d4
	lsr.w #4,d6
	add.w d4,d4
	add.w d6,d6

* regarde si ya une intersection sur les Y
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp.w d3,d5
	bgt no_intersection
	cmp.w d7,d1
	bgt no_intersection

	cmp.w d2,d4
	bgt no_intersection
	cmp.w d6,d0
	bgt no_intersection

	moveq #1,d7				signale une intersection
	rts

no_intersection
	move.w a4,d7
	lea bob_SIZEOF(a1),a1
	dbf d7,loop_check_overlap
	moveq #0,d0				signale que ya pas d'overlap
	rts



*************************************************************************************************
*************************************************************************************************
*                           CALCUL DES MOTS DE CONTROL D'UN SPRITE
* en entrée: d0=PosX
*            d1=PosY
*            d2=Hauteur
*
* en sortie: d0=1er mot de controle
*            d3=2ème mot de controle
*************************************************************************************************
*************************************************************************************************
Compute_Sprite_Control
	moveq #0,d3
	add.w #$81*2,d0				recentre sur les X
	move.w d0,d5
	lsr.w #2,d0
	bcc.s put_sprite_pas_carryX
	moveq #1,d3
put_sprite_pas_carryX
	add.w #$2b,d1				recentre sur les Y
	move.w d1,d4
	lsl.w #8,d1
	bcc.s put_sprite_pas_carryY1
	or.w #4,d3
put_sprite_pas_carryY1
	or.w d1,d0
	add.w d2,d4
	lsl.w #8,d4
	bcc.s put_sprite_pas_carryY2
	or.w #2,d3
put_sprite_pas_carryY2
	or.w d4,d3
	and.w #$1,d5
	lsl.w #4,d5
	or.w d5,d3
	rts



* Affichage d'un bob avec sauvegarde du fond
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*   -->	a0=Bob_Structure
Paste_Bob
	movem.w bob_PosX(a0),d0/d1
	move.w d0,d2
	asr.w #4,d0
	add.w d0,d0
	muls.w #BPL_WIDTH*BPL_DEPTH,d1
	movem.l Log_Screen(a5),a1/a2
	lea (a1,d1.l),a1
	lea (a1,d0.w),a1
	lea (a2,d1.l),a2
	lea (a2,d0.w),a2
	and.w #$f,d2				décalage pour la source A

* Restaure le fond du bob
* ~~~~~~~~~~~~~~~~~~~~~~~
	move.l Log_BackScrAdr(a5),d1
	bne.s .ok_back
.no_back
	WAIT_BLITTER
	move.l a1,bltdpt(a6)
	move.l a2,Phy_BackScrAdr(a5)
	move.l #$01f00000,bltcon0(a6)
	bra.s .rebranch

.ok_back
	WAIT_BLITTER
	move.l Log_Back(a5),bltapt(a6)
	move.l d1,bltdpt(a6)
	moveq #-1,d0
	move.l d0,bltafwm(a6)
	clr.w bltamod(a6)
	move.l #$09f00000,bltcon0(a6)
.rebranch
	move.w bob_Modulo(a0),bltdmod(a6)
	move.l bob_BltSize(a0),bltsizV(a6)

* Sauve le fond du bob
* ~~~~~~~~~~~~~~~~~~~~
	WAIT_BLITTER
	move.l a1,Log_BackScrAdr(a5)
	move.l a1,bltapt(a6)
	move.l Log_Back(a5),bltdpt(a6)
	moveq #-1,d0
	move.l d0,bltafwm(a6)
	move.w bob_Modulo(a0),bltamod(a6)
	clr.w bltdmod(a6)
	move.l #$09f00000,bltcon0(a6)
	move.l bob_BltSize(a0),bltsizV(a6)

* Recopie le bob sur l'écran
* ~~~~~~~~~~~~~~~~~~~~~~~~~~
	WAIT_BLITTER
	ror.w #4,d2
	move.w d2,bltcon1(a6)
	or.w #$fca,d2
	move.w d2,bltcon0(a6)
	move.l bob_Mask(a0),bltapt(a6)		A masque
	move.l bob_Data(a0),bltbpt(a6)		B image
	move.l a1,bltcpt(a6)			C background
	move.l a1,bltdpt(a6)			D destination
	clr.w bltamod(a6)
	clr.w bltbmod(a6)
	move.w bob_Modulo(a0),bltcmod(a6)
	move.w bob_Modulo(a0),bltdmod(a6)
	moveq #-1,d0
	move.l d0,bltafwm(a6)
	move.l bob_BltSize(a0),bltsizV(a6)	lance le dma
	rts




*************************************************************************************************
*************************************************************************************************
*                              ICI ON FAIT COUINER LES BOBS
*************************************************************************************************
*************************************************************************************************
Music_Bob
	tst.b OldLeftPressed(a5)
	bne.s .nothing

	tst.b LeftPressed(a5)
	beq .nothing

* recherche le bob qui veut couiner
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.w MouseX(a5),d0
	move.w MouseY(a5),d1
	lsr.w #1,d1

	lea Bob_Structures(pc),a0
	moveq #NB_BOBS-1,d7
.search
	movem.w bob_PosX(a0),d2/d3

	cmp.w d2,d0				regarde si la souris est sur le bob
	blt.s .next
	cmp.w d3,d1
	blt.s .next
	add.w bob_SizeX(a0),d2
	add.w bob_SizeY(a0),d3
	cmp.w d2,d0
	bge.s .next
	cmp.w d3,d1
	blt.s couiner_found
.next
	lea bob_SIZEOF(a0),a0
	dbf d7,.search

.nothing
	rts

couiner_found
	lea mt_voice3(pc),a1
	move.l bob_SampData(a0),d0
	beq.s .skip

	move.l d0,aud3lcH(a6)			init le hardware
	move.w bob_SampLen(a0),aud3len(a6)
	move.w #64,aud3vol(a6)
	move.w #214,aud3per(a6)
	move.w #$8008,dmacon(a6)

	move.l d0,mt_samp_adr(a1)		init la structure de donnée
	move.w bob_SampLen(a0),mt_len(a1)
	move.w #64,mt_volume(a1)
	move.l bob_SampData(a0),mt_repeat(a1)
	move.w #1,mt_replen(a1)
	move.w #214,mt_period(a1)
.skip
	rts


*************************************************************
************************ scroller
*****************************************
Init_Scroller
	move.l #Scroller_Text,ScrollPtr(a5)
	move.w #-16,End_Line(a5)
	move.w #-16,Curr_Line(a5)
	rts

Scroller
	tst.w Scroll_Wait(a5)
	beq.s no_wait
	subq.w #1,Scroll_Wait(a5)
	rts

page_wait
	move.w #200,Scroll_Wait(a5)
	move.w #-16,End_Line(a5)
	move.w #-16,Curr_Line(a5)
	addq.l #1,a0
	tst.b (a0)
	bne.s .ok
	lea Scroller_Text(pc),a0
.ok
	move.l a0,ScrollPtr(a5)
	rts

no_wait
	move.w Curr_Line(a5),d0			la ligne est en haut ?
	cmp.w End_Line(a5),d0
	bne no_new_line

	move.l ScrollPtr(a5),a0
	move.b (a0),d0
	beq.s page_wait

	add.w #16,End_Line(a5)			ligne suivante
	move.w #256,Curr_Line(a5)

new_line
	move.l Scroll_Screen(a5),a3		affiche la ligne en bas
	add.l #256*BPL_WIDTH*BPL_DEPTH,a3
.loop_display_line
	move.b (a0)+,d0				fin de la ligne ?
	beq.s .exit_eol
	cmp.b #10,d0
	beq.s .exit_eol
	cmp.b #" ",d0
	bne.s .no_space

	move.l a3,a2				espace => clear
	moveq #16-1,d0
.clear
	clr.w (a2)
	lea BPL_WIDTH*BPL_DEPTH(a2),a2
	dbf d0,.clear
	addq.l #2,a3
	bra.s .loop_display_line

.no_space
	lea Font_Offset(pc),a1			recherche l'offset de la lettre
	moveq #-1,d1				dans la table
.search
	cmp.b (a1)+,d0
	dbeq d1,.search
	not.w d1

	lea (Picture_Font,pc,d1.w*2),a1		balance la lettre
	moveq #16-1,d0
	move.l a3,a2
.put
	move.w (a1),(a2)
	lea 80(a1),a1
	lea BPL_WIDTH*BPL_DEPTH(a2),a2
	dbf d0,.put
	addq.l #2,a3
	bra.s .loop_display_line
.exit_eol
	cmp.b #10,-1(a0)			retour de ligne ?
	beq.s .eol
	subq.l #1,a0
.eol
	move.l a0,ScrollPtr(a5)
	rts

no_new_line
	subq.w #4,d0
	move.w d0,Curr_Line(a5)

	mulu.w #BPL_WIDTH*BPL_DEPTH,d0
	add.l Scroll_Screen(a5),d0
	move.l d0,a0

	moveq #20-1,d0
.all
	move.l a0,a1
	moveq #16-1,d1
.booze
	move.w BPL_WIDTH*BPL_DEPTH*4(a1),(a1)
	lea BPL_WIDTH*BPL_DEPTH(a1),a1
	dbf d1,.booze
	clr.w (a1)
	clr.w BPL_WIDTH*BPL_DEPTH(a1)
	clr.w BPL_WIDTH*BPL_DEPTH*2(a1)
	clr.w BPL_WIDTH*BPL_DEPTH*3(a1)
	addq.l #2,a0
	dbf d0,.all
	rts



*************************************************************************************************
*************************************************************************************************
*                           TOUTES LES STRUCTURES DES BOBS
*************************************************************************************************
*************************************************************************************************
Bob_Structures
	DEF_BOB Code,121,50,NO_SAMPLE
	DEF_BOB Music,122,58,NO_SAMPLE
	DEF_BOB Graphics,194,78,NO_SAMPLE
	DEF_BOB Fille,23,46,45402
	DEF_BOB Spirale,30,25,14770
	DEF_BOB Waii,47,15,10844
	DEF_BOB Sun,36,31,22344
	DEF_BOB Head,24,32,44390
	DEF_BOB Raclette,36,41,37128

Bob_Movements
	LOAD_MVT Code
	LOAD_MVT Music
	LOAD_MVT Graphics
	LOAD_MVT Fille
	LOAD_MVT Spirale
	LOAD_MVT Waii
	LOAD_MVT Sun
	LOAD_MVT Head
	LOAD_MVT Raclette


Picture_Mouse
	incbin "Mouse.RAW"

Picture_Font
	incbin "Font.RAW"

Font_Offset
	dc.b "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?.:"

Scroller_Text
	dc.b "CORIIIINNNE !!!!! ",10
	dc.b "THE POOR GIRL WAS...",10
	dc.b "LOST IN THE JUNGLE",10
	dc.b "SCARED BY THE" ,10
        dc.b "BALOONS...",10
        dc.b "HOPEFULLY  DRD WERE",10
        dc.b "ABLE TO BRING HER",10
        dc.b "BACK TO FRANCE",10
        dc.b "DURING A FUNKY RIDE",10
        dc.b "IN THE SAVANNAH WITH",10
        dc.b "THEIR CUSTOMIZAIDE",10
        dc.b "MASSEY FERGUSSON",10
        dc.b "SHE IS CUTE...",10
        dc.b "HAIRY....",10
        dc.b "SAVAGE...",10
        dc.b "WILD...",0

        dc.b "SHE SMELLS LIKE MOBY",10
        dc.b "WHEN BACK FROM",10
        dc.b "HERNING !",10
        dc.b "AND SHE DOES...",10
        dc.b "WHATEVER YOU WANT IF",10
        dc.b "YOU KNOW HOW TO ASK!",10
        dc.b "CREDITS FOR CORINNE:",10
        dc.b "CODICS BY 5",10
        dc.b "MUCOVICIDOZ BY DOVE",10
        dc.b "OF CRYPTOFLANS..AND",10
        dc.b "GRAS FIX BY EN TONY",10
        dc.b "AND FLETSH SUR PC ",10
        dc.b "JE TABLE GILETTE",0

        dc.b "INSTRUCTIONS :",10
        dc.b "TAKE YOUR MOUSE..",10
        dc.b "AND MOVE IT AROUND !",10
        dc.b "MOVE THE LOGOS BY ",10
        dc.b "DEFONCING THE RIGHT",10
        dc.b "MAOUSSE BOUTONNE",10
        dc.b "IT WORKS ? GREAT !",10
        dc.b "NOW FUNNIER ...",10
        dc.b "SELECT THE 6 GADGETS",10
        dc.b "WITH THE LEFT BUTTON",10
        dc.b "AND HEAR OUR SCREAMS",10
        dc.b "OF PURE DEMANGEAISON",10
        dc.b "IT IS TYPICAL FRENCH",10
        dc.b "GANG BANG LADESH",0

        dc.b "WE ARE TODAY AT THE",10
        dc.b "SATURNE II PARTY..",10
        dc.b "CORINNE...",10
        dc.b "YOU CANNOT BEAT THE",10
        dc.b "LIFTING !! ",10
        dc.b "PARTY BISEES TO :",10
        dc.b "PIB OF SAINT TEKSE",10
        dc.b "NAM OF MOVEMENTALO",10
        dc.b "LES MELONS",10
        dc.b "LES CRYPTOPLAQUES",10
        dc.b "COMPLEKSE : ELOI ET",10
        dc.b "HARDCORETUNEBYCLAWZ",10
        dc.b "RANITY: PALAMOBI..",10
        dc.b "PELOUSE INTERDITE",0

        dc.b "LIVE 5 TELETHON",10
        dc.b "SPECIAL ISSUE",10
        dc.b "AUX JAMBONS BEURS",10
        dc.b "AUX MENTASM  BACKUP",10
        dc.b "CAEDESH ALALAMUTE!!",10
        dc.b "GRYZOR REGISTERIZED",10
        dc.b "DIS LIGHT: ARIOS ET",10
        dc.b "FEYD",0

	dc.b "PIB WANTS SUM CREDZ",10
	dc.b "4 DI SAMPLE.MUGLING",10
	dc.b "AT PUCES.LAND",10
	dc.b "WEIIZ ... WAIT FOR:",10
	dc.b "BOOLDE NEIGE SAPIN",10
	dc.b "NIBARS ET GIRLANDES",10
	dc.b "HUP U NJOY GOL DOH",10
	dc.b "AT ZE DMO COMPET.",10
	dc.b "PERSONNAL MESS TO",10
	dc.b "DOVE: AQUAFRESH",10
	dc.b "TRASH MAPPING",10
	dc.b "ROULEZZZ.",0
	
	dc.b "HAAAA WHO CAN BLAME",10
	dc.b "ME?  IT IS NOT MY",10
	dc.b "FAULT IF RACLETTE",10
	dc.b "RULEZZ MY LIFE...",10
	dc.b "D.YA LIKE THE SWEET",10
	dc.b "SUGAR CORRRINE.ELLE",10
	dc.b "EST TRES CON CETTE",10
	dc.b "CONNE... PIB I MUST",10
	dc.b "TOLD YOU NOW THAT",10
	dc.b "YOU ARE NOT MY ONLY",10
	dc.b "LOVE... I ALSO LOVE",10
	dc.b "SILURIDES...",0
 
 	dc.b "WELL HI HORDS OF ",10
 	DC.B "FELASS I AM AXEL ",10
 	dc.b "FROM O.ZONE AND ",10
 	dc.b "HERE ARE MY GREETS",10
 	dc.b "TO FEEL THE BLANK",10
 	dc.b "TITAN  HOF  ANTONY",10
 	dc.b "MADE  SYNC  CLAWZ",10
 	dc.b "ELOY XANN SCHMOOVY",10
 	dc.b ".DA HARDGORE. NICO",10
 	dc.b "GENGIS AND ALL THE ",10
 	dc.b "ZUULUZ I FORGOT...",0
 	     
 	dc.b "HILLO GUYZ ...",10
 	dc.b "JUST TYPIN IN SOME",10
 	dc.b "TEXT...",10
 	dc.b "TO SAY I WAZ HERE",10
 	dc.b "YOUR GOUROU NAMMED",10
 	dc.b "....... SUN .......",0
	dc.b 10
	dc.b 10
	dc.b " TEXT RESTARTS....",0,0

        
*************************************************************************************************
*************************************************************************************************
*                                  LA REPLAY POUR CORINNE
*************************************************************************************************
*************************************************************************************************
	even
	IFNE MUSIC
	include "TMC_Replay.s"
	include "song.s"
	ENDC



*************************************************************************************************
*************************************************************************************************
*                                TOUTES LES DATAS DE CORINNE
*************************************************************************************************
*************************************************************************************************
	section neant,bss
	rsreset
DataBase_Struct		rs.b 0
Picture_Ptr		rs.l 1
Picture_Colors_In	rs.l 1
Picture_Colors_Out	rs.l 1
Picture_Wait		rs.w 1
Picture_Scroll		rs.w 1
Log_Screen		rs.l 1
Phy_Screen		rs.l 1
Scroll_Screen		rs.l 1
Log_Back		rs.l 1
Phy_Back		rs.l 1
Log_BackScrAdr		rs.l 1
Phy_BackScrAdr		rs.l 1
Curr_Move_Bob		rs.l 1
Curr_Move		rs.l 1
Curr_Bob		rs.w 1
Nb_Move			rs.w 1
Move_Tete_Pos		rs.w 1
MouseX			rs.w 1
MouseY			rs.w 1
DecalageX		rs.w 1
DecalageY		rs.w 1
Start_PosX		rs.w 1
Start_PosY		rs.w 1
Scroll_Wait		rs.w 1
ScrollPtr		rs.l 1
End_Line		rs.w 1
Curr_Line		rs.w 1
LastX			rs.b 1
LastY			rs.b 1
LeftPressed		rs.b 1
RightPressed		rs.b 1
OldLeftPressed		rs.b 1
OldRightPressed		rs.b 1
DoubleBuffer		rs.b 1
DataBase_SIZEOF=__RS-DataBase_Struct

DataBase
	ds.b DataBase_SIZEOF








* stockage des coplists etc...
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	section ballon,data_c


Display_Picture_Coplist
	dc.w fmode,$3
	dc.w bplcon0,$3200|$8004
Picture_Coplist_Scroll=*+2
	dc.w bplcon1,$0
	dc.w bplcon2,$0
	dc.w bplcon3,0
	dc.w bplcon4,$11
	dc.w ddfstrt,$0038
	dc.w ddfstop,$00c8
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w bpl1mod,80*5
	dc.w bpl2mod,80*5
	dc.w bplcon3,$0
Picture_Coplist_ColorsH=*+2
	dc.w color00,0
	dc.w color01,0
	dc.w color02,0
	dc.w color03,0
	dc.w color04,0
	dc.w color05,0
	dc.w color06,0
	dc.w color07,0
	dc.w bplcon3,$0200
Picture_Coplist_ColorsL=*+2
	dc.w color00,0
	dc.w color01,0
	dc.w color02,0
	dc.w color03,0
	dc.w color04,0
	dc.w color05,0
	dc.w color06,0
	dc.w color07,0
Fake_Coplist
	dc.l $fffffffe



Move_Tetes_Coplist
	dc.w fmode,0
	dc.w bplcon0,$1200|$8000
	dc.w bplcon2,0
	dc.w ddfstrt,$34
	dc.w ddfstop,$d4
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w bpl1mod,BPL_WIDTH*(BPL_DEPTH-1)+(BPL_WIDTH-84)
	dc.w bpl2mod,BPL_WIDTH*(BPL_DEPTH-1)+(BPL_WIDTH-84)
	dc.w bplcon3,0
	dc.w color00,$234
	dc.w color01,$345
	dc.w bplcon3,$0200
	dc.w color00,$000
	dc.w color01,$000
	dc.l $fffffffe


Main_Coplist
	dc.w fmode,%1111			sprites 64 + burst 3
	dc.w bplcon0,$0201|$8000|(BPL_DEPTH<<12)	color + ecsena
	dc.w bplcon1,0
	dc.w bplcon2,%110110
	dc.w ddfstrt,$38
	dc.w ddfstop,$c8
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w bpl1mod,BPL_WIDTH*(BPL_DEPTH-1)+(BPL_WIDTH-80)
	dc.w bpl2mod,BPL_WIDTH*(BPL_DEPTH-1)+(BPL_WIDTH-80)
	dc.w bplcon3,0
	dc.w color00,$234
	dc.w color01,$345
	dc.w color02,$244
	dc.w color03,$555
	dc.w color04,$554
	dc.w color05,$864
	dc.w color06,$aaa
	dc.w color07,$eee
	dc.w color08,$545
	dc.w color09,$646
	dc.w color10,$346
	dc.w color11,$446
	dc.w color12,$647
	dc.w color13,$634
	dc.w color14,$735
	dc.w color15,$737
	dc.w color16,$fff
	dc.w color17,$abc

	dc.w bplcon3,$0200
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

	dc.w bplcon3,$2000
	dc.w color00,$000
	dc.w color01,$eee
	dc.w color02,$945
	dc.w color03,$e79
	dc.w color04,$e68
	dc.w color05,$e57
	dc.w color06,$d46
	dc.w color07,$c35
	dc.w color08,$b24
	dc.w color09,$a13
	dc.w color10,$902
	dc.w color11,$801
	dc.w color12,$700
	dc.w color13,$500
	dc.w color14,$a56
	dc.w color15,$b67
	dc.w bplcon3,$2200
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

Main_BplPtr=*+2
bpl set bpl1ptH
	REPT BPL_DEPTH*2
	dc.w bpl,0
bpl set bpl+2
	ENDR
	dc.w bplcon3,$82			sprites hi-res + border sprites
	dc.w bplcon4,$22			bank sprites odd & even = 1 ( 32 - 47 )
Spr_Ptr=*+2
spr set spr0ptH
	REPT 8*2
	dc.w spr,0
spr set spr+2
	ENDR

	dc.l $fffffffe


	CNOP 0,8
Picture_Robeau
	incbin "Robeau.RAW"
Colors_Robeau_In
	incbin "Robeau.PAL"
Colors_Robeau_Out
	dcb.l 8,$d0e0f0

	CNOP 0,8
Picture_Corinne
	incbin "Corinne.RAW"
Colors_Corinne_In
	incbin "Corinne.PAL"
Colors_Corinne_Out
	dcb.l 8,$203040

Picture_Tetes
	incbin "Tetes.RAW"

	LOAD_BOB Code
	LOAD_BOB Music
	LOAD_BOB Graphics
	LOAD_BOB Raclette
	LOAD_BOB Head
	LOAD_BOB Spirale
	LOAD_BOB Fille
	LOAD_BOB Waii
	LOAD_BOB Sun

	CNOP 0,16
Mouse_Sprite_Even
	dc.l 0,0,0,0
	ds.l 62*4
Blank_Sprite
Empty_Sample
	dc.l 0,0,0,0

Mouse_Sprite_Odd
	dc.l 0,0,0,0
	ds.l 62*4
	dc.l 0,0,0,0

	LOAD_SAMPLE Raclette
	LOAD_SAMPLE Head
	LOAD_SAMPLE Spirale
	LOAD_SAMPLE Fille
	LOAD_SAMPLE Waii
	LOAD_SAMPLE Sun

	IFNE MUSIC
	include "Samples.s"
	ENDC


	section slurp,bss_c
Screen_space
	ds.b BPL_WIDTH*BPL_Y*BPL_DEPTH*2+4
Back_space1
	ds.b 11000
Back_space2
	ds.b 11000

* end of file
