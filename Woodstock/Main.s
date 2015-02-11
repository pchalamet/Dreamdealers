
*			40 Ko intro pour la gasp
*			~~~~~~~~~~~~~~~~~~~~~~~~


ROUND	MACRO
	ENDM


DRD_TIME=503
CODE_TIME=96
GFX_TIME=96
MUSIC_TIME=96
WOODSTOCK_TIME=480
	


	incdir "asm:sources"
	incdir "Music/Bouba/"
	incdir "RAW/"
	incdir "PAL/"
;;	incdir "asm:songs/small"
	include "registers.i"

	SET_OPTS
;;	OPT DEBUG





	section 40KO,code
Entry_Point
	KILL_SYSTEM Main

	moveq #0,d0
	rts



Main
	lea _Main_DataBase,a5
	lea _CustomBase,a6

	lea Quick_Exit(pc),a0
	move.l a0,Exit_PC(a5)

	move.l sp,Exit_SP(a5)

	movec cacr,d0
	move.l d0,Old_Cache(a5)
	move.l #$3111,d0			Write Allocate + Burst + Caches On
	movec d0,cacr

	movec vbr,d0
	move.l d0,Old_VBR(a5)
	moveq #0,d0
	movec d0,vbr

	movem.l d0-d7/a0-a6,-(sp)
	moveq #0,d0
	lea P61_Data,a0
	sub.l a1,a1
	lea P61_Samples,a2
	jsr P61_Init
	tst.l d0
	movem.l (sp)+,d0-d7/a0-a6
	bne.s Quick_Exit


	bsr.s Affiche_Parachute
	bsr Affiche_Texte

	lea Blur_Init,a0
	lea Msg1(pc),a1
	bsr Affiche_Fond			le cochon
	jsr Blur_Initial_PC

	sub.l a0,a0
	lea Msg2(pc),a1
	bsr Affiche_Fond			le tmap
	jsr Tmap_Initial_PC

	lea Blur_Init,a0
	lea Msg3(pc),a1
	bsr Affiche_Fond			la vache
	jsr Blur_Initial_PC

	lea End_Msg(pc),a0
	lea Msg_Bidon(pc),a1
	bsr Affiche_Fond			la fin

.wait	bra.s .wait


Quick_Exit
	lea _Main_DataBase,a5
	lea _CustomBase,a6

	move.l Exit_SP(a5),sp

	jsr P61_End

	move.l Old_VBR(a5),d0
	movec d0,vbr

	move.l Old_Cache(a5),d0
	movec d0,cacr

Song_Error
	RESTORE_SYSTEM







*********************************************************************************
*			Affichage d'un parachute qui descend			*
*	a5=_Main_DataBase							*
*	a6=_CustomBase								*
*********************************************************************************
Affiche_Parachute

* efface déja tout
	lea Cloud_space,a0
	lea End_Parachute_space,a1
.clear
	clr.w (a0)+
	cmp.l a0,a1
	bne.s .clear


* zoome déja le nuage
	lea Cloud,a0				adr du dessin
	lea Cloud_space,a1			adr destination du zoom
	moveq #51,d0				taille X
	moveq #24,d1				taille Y
	moveq #2,d2				nb bitplan
	moveq #40,d3				largeur du bitplan dest
	bsr Zoom_x4

* met le nuage sous forme de sprites
	lea Cloud_space,a0
	lea Cloud_Sprite1_space,a1
	lea Cloud_Sprite5_space,a2
	moveq #4-1,d0				4 sprites en tout
.put
	clr.l (a1)+
	clr.l (a1)+
	clr.l (a1)+
	clr.l (a1)+
	clr.l (a2)+
	clr.l (a2)+
	clr.l (a2)+
	clr.l (a2)+

	move.l a0,a3
	move.w #24*4-1,d1			nb de lignes
.loop
	move.l (a3),(a1)+			bitplan 1
	move.l 4(a3),(a1)+
	move.l 40(a3),(a1)+			bitplan 2
	move.l 44(a3),(a1)+

	move.l (a3),(a2)+
	move.l 4(a3),(a2)+
	move.l 40(a3),(a2)+
	move.l 44(a3),(a2)+

	lea 40*2(a3),a3				ligne suivante
	dbf d1,.loop
	addq.l #8,a0

	clr.l (a1)+
	clr.l (a1)+
	clr.l (a1)+
	clr.l (a1)+
	clr.l (a2)+
	clr.l (a2)+
	clr.l (a2)+
	clr.l (a2)+
	dbf d0,.put
	
* installe les sprites dans la coplist
	lea Para_Cop_Spr+2,a0
	move.l #Cloud_Sprite1_space,d0
	move.l #Cloud_Sprite2_space-Cloud_Sprite1_space,d1
	moveq #8-1,d2
	bsr Init_Bpl

* zoome ensuite le parachute
	lea Parachute,a0
	lea Parachute_space+50*256*4,a1
	moveq #61,d0
	moveq #94,d1
	moveq #4,d2
	moveq #50,d3
	bsr.s Zoom_x4

* zoome le dealers pour plus tard
	lea Dealers,a0
	lea Dealers_space,a1
	moveq #57,d0
	moveq #26,d1
	moveq #3,d2
	moveq #30,d3
	bsr.s Zoom_x4

* joue l'animation
	sf End_Routine(a5)
	move.w #650,Compteur(a5)
	move.w #-$30*2,Cloud_PosX(a5)
	clr.w Parachute_PosX(a5)
	move.w #650,Parachute_PosY(a5)


	move.l #Para_Cop,cop1lc(a6)
	clr.w copjmp1(a6)

	lea Parachute_VBL(pc),a0
	move.l a0,$6c.w
	move.w #$83a0,dmacon(a6)		sprites + bpl + copper
	move.w #$c020,intena(a6)

.wait	tst.b End_Routine(a5)
	beq.s .wait
	move.w #$0020,dmacon(a6)		vire les sprites
	rts



* a0=adr du dessin ( bitplans entrelardés )
* a1=adr de destination pour le zoom
* d0=taille X du dessin
* d1=taille Y du dessin
* d2=profondeur du dessin
* d3=taille X du bitplan destination ( en octets )
Zoom_x4
	movem.l d1/d2/d3/a1,-(sp)

******************
* Zoom sur les X *
******************
* calcul du nombre de lignes à traiter
	mulu.w d2,d1

* calcul du modulo à ajouter lorsqu'on aura fini une ligne zoomée
	move.w d0,d4
	add.w #15,d4
	lsr.w #4,d4				nb de mots
	lsl.w #3,d4				passe en octet + zoom x4
	sub.w d4,d3

* calcul du nombre de mot qu'il y a sur une ligne de src
	lsr.w #4,d0

* zoom
	bra.s start_zoom_x
loop_zoom_all
	move.w d0,d4
loop_zoom_line
	move.b (a0)+,d5				lit un octet pour le zoomer
	bsr.s zoom_byte

	move.b (a0)+,d5
	bsr.s zoom_byte

	dbf d4,loop_zoom_line

	lea (a1,d3.w),a1			ligne suivante
start_zoom_x
	dbf d1,loop_zoom_all


******************
* Zoom sur les Y *
******************
	movem.l (sp)+,d1/d2/d3/a1
	move.w d1,d4
	mulu.w d2,d4
	mulu.l d3,d4				taille du dessin

	move.l d4,d0
	lsl.l #2,d0				taille zommé x4

	lea (a1,d4.l),a0			source
	lea (a1,d0.l),a1			destination

	lsr.w #1,d3				nb de mot sur une ligne
	mulu.w d2,d3

	bra.s start_zoom_y
loop_zoom_y
	moveq #4-1,d4				on zoom par 4
loop_zoom_bpl_y
	move.l a0,a2
	move.w d3,d5				zoom une ligne
	bra.s start_zoom_line_y
loop_zoom_line_y
	move.w -(a2),-(a1)			recopie
start_zoom_line_y
	dbf d5,loop_zoom_line_y
	dbf d4,loop_zoom_bpl_y
	move.l a2,a0
start_zoom_y
	dbf d1,loop_zoom_y
	rts

* d5= octet à zoomer
* a1=destination
zoom_byte
	moveq #8-1,d6				8 bits dans un octet
	moveq #32-1,d7				32 sur le destination
	moveq #0,d2
loop_zoom_byte
	btst d6,d5				test le bit
	beq.s .clear
.set
	bset d7,d2
	subq.w #1,d7
	bset d7,d2
	subq.w #1,d7
	bset d7,d2
	subq.w #1,d7
	bset d7,d2
	subq.w #1,d7
	dbf d6,loop_zoom_byte
	move.l d2,(a1)+
	rts

.clear
	subq.w #4,d7
	dbf d6,loop_zoom_byte
	move.l d2,(a1)+
	rts





Parachute_VBL
	SAVE_REGS

	jsr P61_Music

	lea _Main_DataBase,a5
	lea _CustomBase,a6

	bsr Positionne_Parachute

	WAIT_VHSPOS $05000
	bsr.s Positionne_Cloud

	subq.w #1,Compteur(a5)
	bne.s .skip
	st End_Routine(a5)
.skip


	bsr Check_Quick_Exit

	move.w #$0020,intreq(a6)
	RESTORE_REGS
	rte


* positionne les sprites
* d4=PosX
* d5=PosY
Positionne_Cloud
	move.w Cloud_PosX(a5),d6
	add.w #$30*2,d6
	muls.w #3,d6
	asr.w #1,d6
	sub.w #140+$60*2,d6
	addq.w #1,Cloud_PosX(a5)
	lea Cloud_Sprite1_space,a4
	moveq #4-1,d7
.positionne1
	move.w d6,d0
	move.w #$30,d1
	move.w #24*4,d2
	jsr Compute_Sprite_Control
	move.w d0,(a4)
	move.w d3,8(a4)
	add.w #64*2,d6
	add.l #Cloud_Sprite2_space-Cloud_Sprite1_space,a4
	dbf d7,.positionne1

	move.w Cloud_PosX(a5),d6
	lea Cloud_Sprite5_space,a4
	moveq #4-1,d7
.positionne2
	move.w d6,d0
	move.w #$62,d1
	move.w #24*4,d2
	jsr Compute_Sprite_Control
	move.w d0,(a4)
	move.w d3,8(a4)
	add.w #64*2,d6
	add.l #Cloud_Sprite6_space-Cloud_Sprite5_space,a4
	dbf d7,.positionne2
	rts



Positionne_Parachute
	lea Para_Cop_Bpl+2,a0			bitplans 1,2,3,4
	move.l #Parachute_space,d0

	moveq #0,d1
	move.w Parachute_PosX(a5),d1
	addq.w #1,Parachute_PosX(a5)
	lea Parachute_Mvt,a1
	move.w (a1,d1.w*2),d1

	move.w d1,d2
	lsr.w #4,d1
	add.w d1,d1
	add.l d1,d0
	sub.l #20,d0

	not.w d2
	and.w #$f,d2
	move.w d2,d3
	lsl.w #4,d3
	or.w d3,d2
	move.b d2,Para_Pos

	move.w Parachute_PosY(a5),d1
	subq.w #1,Parachute_PosY(a5)
	muls.w #50*4,d1
	add.l d1,d0
	
	moveq #50,d1
	moveq #4-1,d2
	bra Init_Bpl




*********************************************************************************
*               Affichage des textes : Code/Gfx/Music/Woodstock		   	*
*										*
*   -->	a5=_Main_DataBase							*
*	a6=_CustomBase								*
*********************************************************************************
Affiche_Texte
	move.w #1,Compteur(a5)
	clr.w Number(a5)
	sf End_Routine(a5)

	lea Texte_VBL(pc),a0
	move.l a0,$6c.w

	jsr Tmap_Init

.wait
	tst.b End_Routine(a5)
	beq.s .wait
	rts


Texte_VBL
	SAVE_REGS

	jsr P61_Music
	bsr Check_Quick_Exit

	lea _Main_DataBase,a5
	lea _CustomBase,a6

	bsr.s Gestion_Texte

	move.w #$0020,intreq(a6)
	RESTORE_REGS
	rte


* Gestion de l'affichage des textes
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Gestion_Texte
	subq.w #1,Compteur(a5)
	bne.s .no_next

	bsr.s Install_New_Text
	clr.w copjmp1(a6)
	addq.w #1,Number(a5)
	bra.s .end

.no_next
	nop


.end
	rts



* Installation d'une nouvelle page de texte
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Install_New_Text
	tst.w Number(a5)		affichage Drd present
	bne.s not_Present

	move.l #Dream,d0
	moveq #28,d1
	moveq #3-1,d2
	lea Cop0_Bpl1+2,a0
	bsr Init_Bpl

	move.l #Dealers_space,d0
	moveq #30,d1
	moveq #3-1,d2
	lea Cop0_Bpl2+2,a0
	bsr Init_Bpl

	move.l #Present,d0
	moveq #12,d1
	moveq #3-1,d2
	lea Cop0_Bpl3+2,a0
	bsr Init_Bpl

	move.w #DRD_TIME,Compteur(a5)
	move.l #Cop0,cop1lc(a6)
	rts

not_Present
	cmp.w #1,Number(a5)		affichage credits CODE
	bne.s not_Code

	move.l #Sync,d0
	moveq #12,d1
	moveq #2-1,d2
	lea Cop1_Bpl1+2,a0
	bsr Init_Bpl

	move.l #Code,d0
	moveq #6,d1
	moveq #2-1,d2
	lea Cop1_Bpl2+2,a0
	bsr Init_Bpl

	move.w #CODE_TIME,Compteur(a5)
	move.l #Cop1,cop1lc(a6)
	rts

not_Code
	cmp.w #2,Number(a5)		affichage credits GFX
	bne.s not_Gfx

	move.l #Antony,d0
	moveq #20,d1
	moveq #2-1,d2
	lea Cop2_Bpl1+2,a0
	bsr Init_Bpl

	move.l #Graphics,d0
	moveq #12,d1
	moveq #2-1,d2
	lea Cop2_Bpl2+2,a0
	bsr.s Init_Bpl

	move.w #CODE_TIME,Compteur(a5)
	move.l #Cop2,cop1lc(a6)
	rts

not_Gfx
	cmp.w #3,Number(a5)		affichage credits MUSIC
	bne.s not_Music

	move.l #Doh,d0
	moveq #12,d1
	moveq #2-1,d2
	lea Cop3_Bpl1+2,a0
	bsr.s Init_Bpl

	move.l #Music,d0
	moveq #8,d1
	moveq #2-1,d2
	lea Cop3_Bpl2+2,a0
	bsr.s Init_Bpl

	move.w #CODE_TIME,Compteur(a5)
	move.l #Cop3,cop1lc(a6)
	rts	

not_Music
	cmp.w #4,Number(a5)		affichage WOODSTOCK
	bne.s not_woodstock

	move.l #Woodstock,d0
	moveq #40,d1
	moveq #2-1,d2
	lea Cop4_Bpl1+2,a0
	bsr.s Init_Bpl

	move.w #WOODSTOCK_TIME,Compteur(a5)
	move.l #Cop4,cop1lc(a6)
	rts

not_woodstock
	st End_Routine(a5)
	rts

Init_Bpl
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	addq.l #8,a0
	swap d0
	add.l d1,d0
	dbf d2,Init_Bpl
	rts




*********************************************************************************
*			Affichage du fond					*
*   -->	a5=_Main_DataBase							*
*	a6=_CustomBase								*
*	a0=Routine à appeller pour l'init d'un truc ou NULL			*
*	a1=Texte								*
*********************************************************************************
Affiche_Fond
	move.l a0,-(sp)
	move.l a1,-(sp)

	move.l #Fond,d0
	lea Fond_Bpl,a0
	move.w d0,4+2(a0)
	swap d0
	move.w d0,2(a0)

	move.l #Fond_Writer,d0
	move.w d0,8+4+2(a0)
	swap d0
	move.w d0,8+2(a0)
	swap d0

	move.l d0,a0				effacage de l'écran
	lea 40*256(a0),a1
.clear
	clr.l (a0)+
	cmp.l a0,a1
	bne.s .clear

* balance le texte
* ~~~~~~~~~~~~~~~~
	move.l (sp)+,a1
	bsr.s Display_Text

	move.w #350,Compteur(a5)
	sf End_Routine(a5)

	move.l #Fond_VBL,$6c.w
	
	move.l #Fond_Cop,cop1lc(a6)
	clr.w copjmp1(a6)

********************************
* appelle de la routine d'init *
********************************
	move.l (sp)+,d0
	beq.s .wait

	move.l d0,a0
	jsr (a0)

.wait	tst.b End_Routine(a5)
	beq.s .wait

	rts



End_Msg
	lea Msg,a1
	lea Fond_Writer,a0
.loop
	move.l a0,-(sp)
	bsr.s Boum
	move.l (sp)+,a0
	lea 40*8(a0),a0
	tst.b -1(a1)
	bne.s .loop
	rts



Fond_VBL
	SAVE_REGS

	bsr P61_Music
	bsr Check_Quick_Exit

	lea _Main_DataBase,a5
	lea _CustomBase,a6

	subq.w #1,Compteur(a5)
	bne.s .skip
	st End_Routine(a5)
.skip
	move.w #$0020,intreq(a6)
	RESTORE_REGS
	rte


* a1=texte
Display_Text
	movem.w (a1)+,d0/d1
	mulu.w #40,d1
	add.l d1,d0
	add.l #Fond_Writer,d0
	move.l d0,a0
Boum
	lea Font,a2

.put	moveq #0,d0
	move.b (a1)+,d0
	beq.s .exit
	cmp.b #10,d0
	beq.s .exit

	lea (a2,d0.w*8),a3

	moveq #8-1,d1
	move.l a0,a4
.lettre
	move.b (a3)+,(a4)
	lea 40(a4),a4
	dbf d1,.lettre
	addq.l #1,a0
	bra.s .put
.exit
	rts


Msg_Bidon
	dc.w 0
	dc.w 0
	dc.b 0

Msg1	dc.w 10
	dc.w 100
	dc.b "NUCLEAR TRIES...AGRICOL BLUR",0

Msg2	dc.w 5
	dc.w 200
	dc.b "REFRESHING DAEMON [...........]",0

Msg3	dc.w 6
	dc.w 150
	dc.b "MINOS! LANCEZ GOLGOTH 61 !",0

Msg
;;;	dc.b "****************************************"
	dc.b "Be Agricol. Woodstock greetings to",10
	dc.b "Greenpeace and to my friend",10
	dc.b "Pablo Picasso. Write me,I need floppies.",10
	dc.b "SQUIZZATO Antony. 4 impasse DEGEYTER.",10
	dc.b "15000 AURILLAC. France.",10
	dc.b 10
	dc.b "Before leaving DreamDealers in peace and",10
	dc.b "love, I (Napoleon) wanna thank some cool",10
	dc.b "friends in Axis, Absolute!, Eremation,",10
	dc.b "Gods, Polka B., Lemon., Oxygene, Essence",10
	dc.b "Sanity and the rest!",10
	dc.b "To BlueSilence: Stop spreading bullshit!",10
	dc.b "Ciao da fools... Enjoy life and girls?",10
	dc.b 10
	dc.b "Sync Kisses Movement, Melon Dezign,",10
	dc.b "Jumelles ...",10
	dc.b 10
	dc.b "Hi Your Doh awakes for a while to wish",10
	dc.b "you a merry christmas, and don't forget",10
	dc.b "to vote for number 10 Cyber Gilbert at",10
	dc.b "the music compo... Hello to: Sim . Adamo",10 
	dc.b "Carlos . Danielle Evenou & Pierre Mondy.",10
	dc.b 10
	dc.b "DARKNESS POUR NOUS AVOIR TANT AMUSE",10
	dc.b "DURANT CETTE SUPERBE PARTY",10
	dc.b "    Movement-Sanity-Melon-Drd-Oxygene",10
	dc.b 10
	dc.b "        Woodstock - DreamDealers 1995",0
	even


*********************************************************************************
*                  Verification pour la sortie de la demo			*
*********************************************************************************
Check_Quick_Exit
	btst #6,ciaapra
	bne.s .no_exit
	
* modification du PC de retour pour le RTE et arrete les ITs et les DMAs
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l _Main_DataBase+Exit_PC,(8+7+1)*4+2(sp)
.no_exit
	rts




*********************************************************************************
*				La replay et sa zik				*
*********************************************************************************
	even
	include "Replay.s"

	even
Parachute_Mvt
	incbin "Parachute_Mvt.RAW"

Font
	incbin "Font.RAW"



	ROUND
	section main_database,bss

	rsreset
Main_DataBase_Struct	rs.b 0
Exit_PC			rs.l 1
Exit_SP			rs.l 1
Old_Cache		rs.l 1
Old_VBR			rs.l 1
Cloud_PosX		rs.w 1
Parachute_PosX		rs.w 1
Parachute_PosY		rs.w 1
Number			rs.w 1
Compteur		rs.w 1
End_Routine		rs.b 1
Main_DataBaseSizeOF	rs.b 0

_Main_DataBase
	ds.b Main_DataBaseSizeOF





	ROUND
	section samp,data_c


Para_Cop
	dc.w fmode,%1100
	dc.w bplcon0,$4200
Para_Pos=*+2+1
	dc.w bplcon1,0
	dc.w bplcon2,%010010
	dc.w bplcon4,$0011

	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w ddfstrt,$30
	dc.w ddfstop,$d0
	
	dc.w bpl1mod,8+50*3
	dc.w bpl2mod,8+50*3
	
Para_Cop_Bpl
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.w bpl3ptH,0
	dc.w bpl3ptL,0
	dc.w bpl4ptH,0
	dc.w bpl4ptL,0

Para_Cop_Spr
	dc.w spr0ptH,0
	dc.w spr0ptL,0
	dc.w spr1ptH,0
	dc.w spr1ptL,0
	dc.w spr2ptH,0
	dc.w spr2ptL,0
	dc.w spr3ptH,0
	dc.w spr4ptL,0
	dc.w spr4ptH,0
	dc.w spr4ptL,0
	dc.w spr5ptH,0
	dc.w spr5ptL,0
	dc.w spr6ptH,0
	dc.w spr6ptL,0
	dc.w spr7ptH,0
	dc.w spr7ptL,0

Para_Cop_Colors
	dc.w bplcon3,0
	dc.w color00,$305			pour le parachute
	dc.w color01,$821
	dc.w color02,$560
	dc.w color03,$555
	dc.w color04,$000
	dc.w color05,$778
	dc.w color06,$700
	dc.w color07,$900
	dc.w color08,$b33
	dc.w color09,$840
	dc.w color10,$971
	dc.w color11,$c83
	dc.w color12,$ea5
	dc.w color13,$aaa
	dc.w color14,$d99
	dc.w color15,$fff

	dc.w color17,$778			pour le nuage
	dc.w color18,$aaa
	dc.w color19,$fff
	dc.w color21,$778
	dc.w color22,$aaa
	dc.w color23,$fff	
	dc.w color25,$777
	dc.w color26,$999
	dc.w color27,$fff	
	dc.w color29,$777
	dc.w color30,$999
	dc.w color31,$fff	

	dc.w bplcon3,$200
	dc.w color00,$000			pour le parachute
	dc.w color01,$587
	dc.w color02,$d30
	dc.w color03,$66c
	dc.w color04,$000
	dc.w color05,$bc0
	dc.w color06,$100
	dc.w color07,$f00
	dc.w color08,$dff
	dc.w color09,$f81
	dc.w color10,$853
	dc.w color11,$735
	dc.w color12,$a9f
	dc.w color13,$124
	dc.w color14,$e33
	dc.w color15,$fff

	dc.w color17,$bc0			pour le nuage
	dc.w color18,$124
	dc.w color19,$fff
	dc.w color21,$bc0
	dc.w color22,$124
	dc.w color23,$fff	
	dc.w color25,$348
	dc.w color26,$9ac
	dc.w color27,$777	
	dc.w color29,$348
	dc.w color30,$9ac
	dc.w color31,$777	

	dc.l $fffffffe


Cop0
	dc.w bplcon0,$3200

	dc.w bplcon3,$0000
	dc.w color00,$305
	dc.w color01,$fff
	dc.w color02,$ccc
	dc.w color03,$888
	dc.w color04,$000
	dc.w color05,$cbf
	dc.w color06,$a6f
	dc.w color07,$93e
	dc.w bplcon3,$200
	dc.w color00,$000
	dc.w color01,$fff
	dc.w color02,$555
	dc.w color03,$ddd
	dc.w color04,$000
	dc.w color05,$d76
	dc.w color06,$ec2
	dc.w color07,$26f

	dc.w diwstrt,$5381
	dc.w diwstop,$22c1
	dc.w ddfstrt,$50
	dc.w ddfstop,$b8
	dc.w bpl1mod,28*2
	dc.w bpl2mod,28*2
	dc.w bplcon1,$77
Cop0_Bpl1
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.w bpl3ptH,0
	dc.w bpl3ptL,0

	dc.w $6a01,$fffe
	dc.w dmacon,$0100
	dc.w ddfstrt,$48
	dc.w ddfstop,$b8
	dc.w bpl1mod,30*2
	dc.w bpl2mod,30*2
	dc.w bplcon1,$ee
	dc.w $7101,$fffe
	dc.w dmacon,$8100
Cop0_Bpl2
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.w bpl3ptH,0
	dc.w bpl3ptL,0

	dc.w $d901,$fffe
	dc.w dmacon,$0100
	dc.w ddfstrt,$70
	dc.w ddfstop,$98
	dc.w bpl1mod,12*2
	dc.w bpl2mod,12*2
	dc.w bplcon1,$00
	dc.w $f001,$fffe
	dc.w dmacon,$8100
Cop0_Bpl3
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.w bpl3ptH,0
	dc.w bpl3ptL,0

	dc.l $fffffffe



Cop1
	dc.w bplcon0,$2200
Cop1_Col1
	dc.w bplcon3,$0000
	dc.w color00,$305
	dc.w color01,$665
	dc.w color02,$cba
	dc.w color03,$fff
	dc.w bplcon3,$200
	dc.w color00,$000
	dc.w color01,$000
	dc.w color02,$000
	dc.w color03,$000

	dc.w diwstrt,$9081
	dc.w diwstop,$a8c1
	dc.w ddfstrt,$70
	dc.w ddfstop,$98
	dc.w bpl1mod,12
	dc.w bpl2mod,12
	dc.w bplcon1,$44
Cop1_Bpl1
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0

	dc.w $af01,$fffe
	dc.w diwstrt,$b081
	dc.w diwstop,$bbc1
	dc.w ddfstrt,$78
	dc.w ddfstop,$88
	dc.w bpl1mod,6
	dc.w bpl2mod,6
	dc.w bplcon1,$99
Cop1_Bpl2
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.l $fffffffe


Cop2
	dc.w diwstrt,$9081
	dc.w diwstop,$a7c1
	dc.w ddfstrt,$60
	dc.w ddfstop,$a8
	dc.w bpl1mod,20
	dc.w bpl2mod,20
	dc.w bplcon1,$11
Cop2_Bpl1
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0

	dc.w $af01,$fffe
	dc.w diwstrt,$b081
	dc.w diwstop,$bcc1
	dc.w ddfstrt,$70
	dc.w ddfstop,$98
	dc.w bpl1mod,12
	dc.w bpl2mod,12
	dc.w bplcon1,$33
Cop2_Bpl2
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.l $fffffffe


Cop3
	dc.w diwstrt,$9081
	dc.w diwstop,$a6c1
	dc.w ddfstrt,$70
	dc.w ddfstop,$98
	dc.w bpl1mod,12
	dc.w bpl2mod,12
	dc.w bplcon1,$11
Cop3_Bpl1
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0

	dc.w $af01,$fffe
	dc.w diwstrt,$b081
	dc.w diwstop,$bbc1
	dc.w ddfstrt,$78
	dc.w ddfstop,$90
	dc.w bpl1mod,8
	dc.w bpl2mod,8
	dc.w bplcon1,$44
Cop3_Bpl2
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.l $fffffffe


Cop4
	dc.w diwstrt,$8081
	dc.w diwstop,$d1c1
	dc.w ddfstrt,$38
	dc.w ddfstop,$d0
	dc.w bpl1mod,40
	dc.w bpl2mod,40
	dc.w bplcon1,$00
Cop4_Bpl1
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.l $fffffffe


Fond_Cop
	dc.w fmode,0
	dc.w bplcon0,$2200
	dc.w bplcon1,0
	dc.w bplcon2,0
	dc.w bplcon4,0
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w ddfstrt,$38
	dc.w ddfstop,$d0
	dc.w bpl1mod,0
	dc.w bpl2mod,0

	dc.w bplcon3,$0000
	dc.w color00,$305
	dc.w color01,$204
	dc.w color02,$fff
	dc.w color03,$fff
	dc.w bplcon3,$0200
	dc.w color00,$000
	dc.w color01,$000
	dc.w color02,$fff
	dc.w color03,$fff
Fond_Bpl
	dc.w bpl1ptH,0
	dc.w bpl1ptL,0
	dc.w bpl2ptH,0
	dc.w bpl2ptL,0
	dc.l $fffffffe


Cloud
	incbin "Cloud.RAW"
Parachute
	incbin "Parachute.RAW"
	ds.w 4*4*2
Dream
	incbin "Dream.RAW"
Dealers
	incbin "Dealers.RAW"
Present
	incbin "Present.RAW"
Sync
	incbin "Sync.RAW"
Code
	incbin "Code.RAW"
Antony
	incbin "Antony.RAW"
Graphics
	incbin "Graphics.RAW"
Doh
	incbin "Doh.RAW"
Music
	incbin "Music.RAW"
Woodstock
	incbin "Woodstock.RAW"
Fond
	incbin "Fond.RAW"

P61_Data
	incbin "hd1:40ko_gasp/music/p61.thermostat"



	ROUND
	section pumpkin,bss_c
Cloud_space
	ds.b 40*24*4*2
Parachute_space
	ds.b 50*(256+94*4+256+50)*4
Dealers_space
	ds.b 30*26*4*3
End_Parachute_space

Cloud_Sprite1_space
	ds.l 4+4*24*4+4
Cloud_Sprite2_space
	ds.l 4+4*24*4+4
Cloud_Sprite3_space
	ds.l 4+4*24*4+4
Cloud_Sprite4_space
	ds.l 4+4*24*4+4
Cloud_Sprite5_space
	ds.l 4+4*24*4+4
Cloud_Sprite6_space
	ds.l 4+4*24*4+4
Cloud_Sprite7_space
	ds.l 4+4*24*4+4
Cloud_Sprite8_space
	ds.l 4+4*24*4+4

Fond_Writer
	ds.b 40*256


P61_Samples
	ds.b $6524




	ROUND





	include "Tmap.s"

	include "MotionBlur.s"
