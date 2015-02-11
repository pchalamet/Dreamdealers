
	section samantafox,code

cacolac
	dc.l text1
	dc.w $89b
	dc.w 2,2
	dc.w 14,-8,10
	dc.w $f80,$f08,$8f8,$f0f,$88f,$ff0

	dc.l text2
	dc.w $856
	dc.w 4,2
	dc.w 8,-8,4
	dc.w $8f0,$af0,$8f0,$af0,$cf0,$cf0

	dc.l text3
	dc.w $db9
	dc.w 2,3
	dc.w 10,-8,-6
	dc.w $f0f,$f0f,$fff,$fff,$fff,$f0f

	dc.l text4
	dc.w $787
	dc.w 4,2
	dc.w 8,10,16
	dc.w $fff,$fff,$fff,$fff,$ccc,$ccc

	dc.l text5
	dc.w $f98
	dc.w 1,2
	dc.w 8,-2,14
	dc.w $7ff,$7ff,$7ff,$7ff,$ddd,$ddd

text1
	DC.B "WELCOME IN THIS BBS",10
	DC.B "INTRO DONE BY THE",10
	DC.B "DREAMDEALERS STAFF !!",10
	DC.B 10
	DC.B "RELEASE DATE",10
	DC.B "28.06.93@="

	DC.B "THE CREDITS",10
	DC.B 10
	DC.B ".....CODE.....",10
	DC.B "SYNC",10
	DC.B ".....MUSIC.....",10
	DC.B "CHRYLIAN",10
	DC.B ".....GFX 'N DEZIGN.....",10
	DC.B "ANTONY@="

	DC.B "LET'S START",10
	DC.B "WITH SOME OLD",10
	DC.B "CRAP BUT STILL",10
	DC.B "NICE AT MY EYES....@=",0
*** DRAGON BALL

text2
	DC.B "AND NOW SUM INFOS!!",10
	DC.B "THE BBS IS RUNNING ON",10
	DC.B "CNET REGISTRED VERSION",10
	DC.B "68040 - 33 MHZ",10
	DC.B "USR 16.8 - 2 NODES",10
	DC.B "-1.2 GIGABYTES ONLINE!!-",10
	DC.B "CALL DREAMLANDS AT",10
	DC.B "+33   32 39 79 23@="

	DC.B "24 HOURS A DAY",10
	DC.B "7 DAYS A WEEK",10
	DC.B "THE OPERATING TEAM",10
	DC.B "WILL WELCOME YOU!",10
	DC.B "SYSOP IS GELFLING",10
	DC.B "COSYSOPS ARE KOUGAR",10
	DC.B "SUN . ANTONY . YRAGAEL",10
	DC.B "AND HAL@="

	DC.B "AND NOW, WHAT",10
	DC.B "ABOUT A LITTLE",10
	DC.B "JOURNEY IN A TUNNEL",10
	DC.B "CONSTITUED OF 1296",10
	DC.B "DOTS IN 2 BITPLANS?@=",0
*** TUNNEL

text3
	DC.B "YA CAN FOUND ON",10
	DC.B "- DREAMLANDS -",10
	DC.B "MANY DP SECTIONS...",10
	DC.B "AMIGA",10
	DC.B "PC",10
	DC.B "HP",10
	DC.B "POCKET RADIO",10
	DC.B "MACINTOSH (SOON)@="

	DC.B "THERE ARE ALSO",10
	DC.B "MANY CONFERENCES...",10
	DC.B 10
	DC.B "LIVE",10
	DC.B "BINARY BALS",10
	DC.B "HARDWARE SHOPPING",10
	DC.B "AND MANY OTHERS...@="

	DC.B "SO LET'S CALL",10
	DC.B "--- DREAMLANDS ---",10
	DC.B "AT",10
	DC.B 10
	DC.B "-----------",10
	DC.B "+33   32 39 79 23",10
	DC.B "-----------@="

	DC.B "COMING NEXT IS...",10
	DC.B 10
	DC.B "HO NO!   YOU WILL",10
	DC.B "DISCOVER IT BY",10
	DC.B "YOURSELF...@=",0
*** BIGBALLS

text4
	DC.B "ALSO DO NOT FORGET",10
	DC.B "TO SUPPORT LIVE!!",10
	DC.B "SEND YOUR MESSY TO:",10
	dc.b 10
	DC.B "LIVE",10
	DC.B "10 BVD LOUIS BLANC",10
	DC.B "19100 BRIVE",10
	dc.B "FRANCE@="

	DC.B "D'YA WANT LOT'ZA",10
	DC.B "GREETS AND ADDY?",10
	DC.B 10
	DC.B "'OH YES!'  I HEAR YOU",10
	DC.B "SAY!!... SO WATCH THIS",10
	DC.B "...VERY VERY... EUH?",10
	DC.B "USUAL",10
	DC.B "PART!@=",0
*** 3D INCONVEX

text5
	DC.B "OH NO!! YOU HAVE",10
	DC.B "NEARLY REACHED THE",10
	DC.B "END OF THE",10
	DC.B "- LIPTON BBS INTRO -",10
	DC.B "HOPE YOU ENJOYED IT!!",10
	DC.B 10
	DC.B "AND REMEMBER TO CALL",10
	DC.B "--- DREAMLANDS ---@="

	DC.B "AND FOR THE ONES",10
	DC.B "WHO HAVE ALREADY",10
	DC.B "FORGOTTEN THE",10
	DC.B "DREAMLANDS NUMBER",10
	DC.B "HERE IS A NICE",10
	DC.B "PICTURE FROM TONY...@=",0
*** MONSTRE


*		Damier pour la lipton
*		---------------------
*		coded by Sync/Drd


	XREF screen_area
	XREF mt_music
	XREF clear_screen_area
	XDEF do_writer

	incdir "asm:sources/"
	incdir "asm:datas/"
	incdir "dh1:Lipton/RAW/"
	incdir "dh1:Lipton/PAK/"
	include "registers.i"

* structure d'une face d'un cube
	rsreset
point1	rs.w 1				offset point 1
point2	rs.w 1				offset point 2
point3	rs.w 1				offset point 3
point4	rs.w 1				offset point 4
bpl	rs.w 1				ds quel bpl se trouve la face
Red	rs.w 1				composantes RGB de la face
Green	rs.w 1
Blue	rs.w 1
face_SIZEOF	rs.w 0

ZOOM=1200
MAX=$2643
OFFSET=155
COLOR_DAMIER=$89b

WRITER_DELAY=100

	even
do_writer
	lea damier_base(pc),a5
	lea $dff000,a6

	jsr clear_screen_area

	lea LeftSpr,a0
	moveq #0,d0
	moveq #0,d1
	move.w #256,d2
	bsr put_sprite

	lea MiddleSpr,a0
	move.w #160,d0
	moveq #0,d1
	move.w #256,d2
	bsr put_sprite

	move.l writer_data_ptr(pc),a0
	move.l (a0)+,texte_ptr-damier_base(a5)
	move.w (a0)+,d0
	move.w d0,d1
	and.w #$f,d1
	move.w d1,CompB-damier_base(a5)
	lsr.w #4,d0
	move.w d0,d1
	and.w #$f,d1
	move.w d1,CompG-damier_base(a5)
	lsr.w #4,d0
	move.w d0,CompR-damier_base(a5)
	move.w (a0)+,VitX-damier_base(a5)
	move.w (a0)+,VitY-damier_base(a5)
	move.w (a0)+,CubeRot-damier_base(a5)
	move.w (a0)+,CubeRot+2-damier_base(a5)
	move.w (a0)+,CubeRot+4-damier_base(a5)
	lea cube_faces(pc),a1
	moveq #6-1,d7
init_cube_color
	move.w (a0)+,d0
	move.w d0,d1
	and.w #$f,d1
	move.w d1,Blue(a1)
	lsr.w #4,d0
	move.w d0,d1
	and.w #$f,d1
	move.w d1,Green(a1)
	lsr.w #4,d0
	move.w d0,Red(a1)
	lea face_SIZEOF(a1),a1
	dbf d7,init_cube_color
	move.l a0,writer_data_ptr-damier_base(a5)

	move.l texte_ptr(pc),a0
	bsr centre_texteX
	bsr centre_texteY

	clr.w Fade_cube-damier_base(a5)
	clr.w Defade_cube-damier_base(a5)
	clr.w DamierFlag-damier_base(a5)
	clr.w delay-damier_base(a5)
	move.w #100,DamierX-damier_base(a5)
	move.w #150,DamierY-damier_base(a5)
	move.w #-1,mask_number-damier_base(a5)
	move.l #screen_area,log_screen-damier_base(a5)
	move.l #screen_area+80,phy_screen-damier_base(a5)
	move.l #coplist1,log_coplist-damier_base(a5)
	move.l #coplist2,phy_coplist-damier_base(a5)

	lea coplist1,a0
	lea DamierColor-coplist1+4+6*4+2(a0),a0
	move.w #256-1,d0
rebuild_damier_in_coplist
	move.w #$312,(a0)
	move.w #$312,4(a0)
	lea 28+8*4(a0),a0
	dbf d0,rebuild_damier_in_coplist

	lea coplist1,a0
	lea coplist2,a1
	move.w #coplist1_size/4-1,d0
dup_coplist
	move.l (a0)+,(a1)+
	dbf d0,dup_coplist

	lea ColorMap+2,a0
	move.w #24*13-1,d0
init_colormap
	move.w #$312,(a0)
	move.w #$312,4(a0)
	addq.l #8,a0
	dbf d0,init_colormap

wait_vpos
	move.l vposr(a6),d0
	and.l #$1ff00,d0
	cmp.l #$13700,d0
	bne.s wait_vpos

	move.w #$81a0,dmacon(a6)		met les sprites
	move.l #vbl,$6c.w

finito_damieto
	tst.w Defade_cube-damier_base(a5)
	beq.s finito_damieto
finito_fado
	tst.w Fade_cube-damier_base(a5)
	bpl.s finito_fado
	move.w #$0020,dmacon(a6)		vire les sprites

	lea spr0data(a6),a0			vire les sprites !!
	moveq #8-1,d0
clear_spr
	clr.l (a0)
	addq.l #spr1data-spr0data,a0
	dbf d0,clear_spr
	rts

vbl
	movem.l d0-d7/a0-a6,-(sp)
	jsr mt_music

	lea damier_base(pc),a5
	lea $dff000,a6

***************************************** LES ANIMATIONS DANS LA VBL
	bsr flip_coplist
	bsr install_spr
	bsr writer
	bsr Clear_Troade
	bsr Compute_Matrix
	bsr Compute_Dots
	bsr Display_Cube
	bsr Fill_Screen
	bsr damier

	movem.w CubeRot(pc),d0-d2
	bsr Incrize_Angles

******************************************* FADE SUR LE CUBE
	eor.w #$ffff,delay-damier_base(a5)
	beq.s grmbl

	tst.w Defade_cube-damier_base(a5)
	beq.s inc_fade
	subq.w #1,Fade_cube-damier_base(a5)
	bra.s grmbl
inc_fade
	cmp.w #$f,Fade_cube-damier_base(a5)
	beq.s grmbl
	addq.w #1,Fade_cube-damier_base(a5)

grmbl
	move.w Fade_cube(pc),d0
	move.w d0,d2

	addq.w #2,d0
	cmp.w #$f,d0
	blt.s yo_le_chameau1
	move.w #$f,d0

yo_le_chameau1
	move.w d2,d1
	addq.w #1,d1
	cmp.w #$f,d1
	ble.s yo_le_chameau2
	move.w #$f,d1
yo_le_chameau2
	lsl.w #4,d1

	addq.w #3,d2
	cmp.w #$f,d2
	ble.s yo_le_chameau3
	move.w #$f,d2
yo_le_chameau3
	lsl.w #8,d2
	or.w d2,d1
	or.w d1,d0
	move.l log_coplist(pc),a0
	move.w d0,SprColor-coplist1+2(a0)

***************************************** FADE SUR LE DAMIER
	tst.w DamierFlag-damier_base(a5)
	beq.s Fill_Ligne_Paire
Fill_Ligne_Impaire
	move.w DamierFlag(pc),d0
	clr.w DamierFlag-damier_base(a5)

	lea ColorMap+8*24+4+2,a0	
	moveq #6-1,d1
do_impaire
girafe set 0
	rept 24
	move.w d0,girafe*8(a0)
girafe set girafe+1
	endr
	lea 8*24*2(a0),a0
	dbf d1,do_impaire
	bra end_fill_impaire

Fill_Ligne_Paire
	move.w Fade_cube(pc),d0
	move.w d0,d2
	addq.w #2,d0
	cmp.w CompB(pc),d0
	ble.s zoupla_dromadaire1
	move.w CompB(pc),d0
zoupla_dromadaire1

	move.w d2,d1
	addq.w #1,d1
	cmp.w CompG(pc),d1
	ble.s zoupla_dromadaire2
	move.w CompG(pc),d1
zoupla_dromadaire2
	lsl.w #4,d1

	addq.w #3,d2
	cmp.w CompR(pc),d2
	ble.s zoupla_dromadaire3
	move.w CompR(pc),d2
zoupla_dromadaire3
	lsl.w #8,d2

	or.w d2,d1
	or.w d1,d0

	move.w d0,DamierFlag-damier_base(a5)
	lea ColorMap+2,a0	
	moveq #7-1,d1
do_paire
girafe set 0
	rept 24
	move.w d0,girafe*8(a0)
girafe set girafe+1
	endr
	lea 8*24*2(a0),a0
	dbf d1,do_paire
end_fill_impaire

************************************** GESTION DU MOUVEMENT DU DAMIER
	move.w VitX(pc),d0
	add.w d0,DamierX-damier_base(a5)
	bgt.s toto1
	neg.w VitX-damier_base(a5)
toto1
	cmp.w #1210,DamierX-damier_base(a5)
	blt.s toto2
	neg.w VitX-damier_base(a5)
toto2
	move.w VitY(pc),d0
	add.w d0,DamierY-damier_base(a5)
	bgt.s toto3
	neg.w VitY-damier_base(a5)
toto3
	cmp.w #500,DamierY-damier_base(a5)
	blt.s toto4
	neg.w VitY-damier_base(a5)
toto4

***************************************** FIN DE LA VBL
	move.w #$0020,intreq(a6)
	movem.l (sp)+,d0-d7/a0-a6
	rte

flip_coplist
	movem.l log_coplist(pc),d0-d3
	exg d0,d1
	exg d2,d3
	movem.l d0-d3,log_coplist-damier_base(a5)

	move.l d1,cop1lc(a6)			init the copper
	clr.w copjmp1(a6)			va y coco !!

	move.l d3,bpl1ptH(a6)
	add.l #80*2,d3
	move.l d3,bpl3ptH(a6)
	rts

install_spr
	move.l #LeftSpr,spr0ptH(a6)
	move.l #MiddleSpr,spr1ptH(a6)
	move.l #BlkSpr,spr2ptH(a6)
	move.l #BlkSpr,spr3ptH(a6)
	move.l #BlkSpr,spr4ptH(a6)
	move.l #BlkSpr,spr5ptH(a6)
	move.l #BlkSpr,spr6ptH(a6)
	move.l #BlkSpr,spr7ptH(a6)
	rts
********************************************************************************
***************** CALCUL DES 2 MOTS DE CONTROLE D'UN SPRITE ********************
***************** EN ENTREE :  D0=COORD X		    ********************
*****************              D1=COORD Y		    ********************
*****************              D2=HAUTEUR DU SPRITE	    ********************
*****************              A0=ADR DU SPRITE		    ********************
********************************************************************************
put_sprite
	moveq #0,d3
	add.w #$7f,d0				recentre sur les X
	lsr.w #1,d0
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
	movem.w d0/d3,(a0)
	rts

************ MACRO QUI DECOLORE LES COULEURS... HAHAHAHAHAHA!!!
************
DECOLORE	macro
	move.w \1,\2
	sub.w #$111,\2

	moveq #0,d7
	move.w \2,d6
	and.w #$00f,d6
	cmp.w #$002,d6
	bge.s .ok1\@
	moveq #$2,d6
.ok1\@
	or.w d6,d7
	move.w \2,d6
	and.w #$0f0,d6
	cmp.w #$010,d6
	bge.s .ok2\@
	move.w #$010,d6
.ok2\@
	or.w d6,d7
	move.w \2,d6
	and.w #$f00,d6
	cmp.w #$300,d6
	bge.s .ok3\@
	move.w #$300,d6
.ok3\@
	or.w d6,d7
	move.w d7,\2
	endm

*******************
******************* LE DAMIER A GAUCHE DE L'ECRAN
*******************
damier
* on s'occupe d'abord des couleurs
	moveq #0,d0
	move.w DamierY(pc),d0
	divu #24*2,d0				fait un p'tit modulo
	clr.w d0
	swap d0
	lsl.w #3,d0				multiplie par 8
	add.l #ColorMap,d0			ptr couleurs

	move.l log_coplist(pc),a0
	lea DamierColor-coplist1+4+6*4(a0),a0	pointe les couleurs

damier_wait_blit
	btst #14,dmaconr(a6)
	bne.s damier_wait_blit

	move.l d0,bltapt(a6)
	move.l a0,bltdpt(a6)	
	moveq #-1,d0
	move.l d0,bltafwm(a6)
	move.l #28+6*4,bltamod(a6)		bltamod=0     bltdmod=28
	move.l #$09f00000,bltcon0(a6)		bltcon0=$09f0 bltcon1=$0000
	move.w #(256<<6)|4,bltsize(a6)		va y ma puce...
	
* on s'occupe ensuite des ptrs videos
	moveq #0,d0
	move.w DamierX(pc),d0
	divu #48*2,d0				quelle image ?
	swap d0
	mulu #80,d0				lignes de 80 octets
	add.l #DamierPic,d0

	move.l log_coplist(pc),a0
	lea DamierPtr-coplist1+2(a0),a0
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)

* init les couleurs du cube
	movem.w cube_color(pc),d0/d2/d4

	DECOLORE d0,d1
	DECOLORE d2,d3
	DECOLORE d4,d5

	move.l log_coplist(pc),a0
	add.l #DamierColor-coplist1+4+2+60*OFFSET,a0
	
	moveq #0,d6
	move.w DamierY(pc),d6
	add.w #OFFSET-10,d6
	divu #24*2,d6
	swap d6
	cmp.w #24,d6
	blt.s start_dup_color
	sub.w #24,d6
	exg d0,d1
	exg d2,d3
	exg d4,d5

start_dup_color
	neg.w d6				\ d6=24-d6
	add.w #24,d6				/
	moveq #96,d7
	sub.w d6,d7
	bra.s start_carre1
dup_color_carre1
	move.w d0,(a0)
	move.w d1,4(a0)
	move.w d2,8(a0)
	move.w d3,12(a0)
	move.w d4,16(a0)
	move.w d5,20(a0)
	lea 60(a0),a0
start_carre1
	dbf d6,dup_color_carre1

	moveq #24-1,d6
	sub.w #24*3,d7
dup_color_carre2
	move.w d1,(a0)
	move.w d0,4(a0)
	move.w d3,8(a0)
	move.w d2,12(a0)
	move.w d5,16(a0)
	move.w d4,20(a0)

	move.w d0,60*24(a0)
	move.w d1,60*24+4(a0)
	move.w d2,60*24+8(a0)
	move.w d3,60*24+12(a0)
	move.w d4,60*24+16(a0)
	move.w d5,60*24+20(a0)

	move.w d1,60*24*2(a0)
	move.w d0,60*24*2+4(a0)
	move.w d3,60*24*2+8(a0)
	move.w d2,60*24*2+12(a0)
	move.w d5,60*24*2+16(a0)
	move.w d4,60*24*2+20(a0)

	lea 60(a0),a0
	dbf d6,dup_color_carre2

	lea 60*24*2(a0),a0
	bra.s start_carre4
dup_color_carre4
	move.w d0,(a0)
	move.w d1,4(a0)
	move.w d2,8(a0)
	move.w d3,12(a0)
	move.w d4,16(a0)
	move.w d5,20(a0)
	lea 60(a0),a0
start_carre4
	dbf d7,dup_color_carre4
	rts

*******************
******************* LE WRITER
*******************
writer
	tst.w writer_clear-damier_base(a5)
	beq.s write_lettre

	cmp.w #256,clearY-damier_base(a5)
	bne do_clear_screen
	move.l texte_ptr(pc),a0
	tst.b (a0)
	bne.s zoupla_gambada
	move.w #-1,Defade_cube-damier_base(a5)
zoupla_gambada
	bsr centre_texteX
	bsr centre_texteY
	clr.w writer_clear-damier_base(a5)
	bra end_writer

do_clear_screen
	move.w clearY(pc),d0
	mulu #80*2*2,d0
	add.l #screen_area+40,d0
	move.l d0,a0				Ligne du haut à effacer

	move.w #255,d0
	sub.w clearY(pc),d0
	mulu #80*2*2,d0
	add.l #screen_area+40,d0
	move.l d0,a1

	moveq #4-1,d0				efface ces lignes !!
	moveq #0,d2
clear_all
	moveq #10-1,d1
clear_line
	move.l d2,(a0)+
	move.l d2,(a1)+
	dbf d1,clear_line
	lea 40(a0),a0
	lea 40(a1),a1
	dbf d0,clear_all

	addq.w #2,clearY-damier_base(a5)
	bra end_writer

write_lettre
	tst.w writer_pause-damier_base(a5)
	beq.s do_not_pause
	subq.w #1,writer_pause-damier_base(a5)
	bra end_writer

do_not_pause
	move.w mask_number(pc),d0		regarde si on est en train
	bge next_mask				d'afficher une lettre

writer_read
	move.l texte_ptr(pc),a0			ptr sur le texte

read_more
	moveq #0,d0
	move.b (a0)+,d0				va chercher une lettre
	beq end_writer				si 0 c'est la fin

	cmp.w #" ",d0				filtre les espaces
	bne.s not_space
	add.w #8,PosX-damier_base(a5)		met un espace
	bra.s read_more
not_space
	cmp.w #"@",d0
	bne.s not_pause
	move.l a0,texte_ptr-damier_base(a5)
	move.w #WRITER_DELAY,writer_pause-damier_base(a5)
	bra end_writer
not_pause
	cmp.w #"=",d0
	bne.s not_clear
	move.l a0,texte_ptr-damier_base(a5)
	clr.w clearY-damier_base(a5)
	subq.w #1,writer_clear-damier_base(a5)
	bra end_writer
not_clear
	cmp.w #10,d0				et les retours de lignes
	bne.s good_letter
	bsr centre_texteX
	add.w #31,PosY-damier_base(a5)		et passe à la ligne suivante
	bra.s read_more

good_letter
	move.l a0,texte_ptr-damier_base(a5)	sauve le ptr de texte
	sub.b #"!",d0				! est la base de la table
	add.w d0,d0				table de WORD
	lea Lettre_Taille(pc),a0
	move.w 0(a0,d0.w),lettre_size-damier_base(a5)
	add.w d0,d0				table de LONG
	lea Lettre_Adr(pc),a0
	move.l 0(a0,d0.w),lettre_ptr-damier_base(a5)	adr de la lettre
	moveq #-1,d0				1er mask

next_mask
	addq.w #1,d0				mask_suivant
	move.w d0,mask_number-damier_base(a5)	sauve le # de mask actuel
	cmp.w #6,d0				on en est au dernier mask ?
	bne.s not_end_mask
	move.w #-1,mask_number-damier_base(a5)	signal la fin des masks
	move.w lettre_size(pc),d0
	add.w d0,PosX-damier_base(a5)
	bra writer_read

Mask_Adr
	dc.l Mask0,Mask1,Mask3,Mask5,Mask7,Mask9

not_end_mask
	btst #14,dmaconr(a6)
	bne.s not_end_mask

	add.w d0,d0				table de LONG
	add.w d0,d0
	move.l Mask_Adr(pc,d0.w),bltbpt(a6)	B=adr du mask
	move.l lettre_ptr(pc),bltapt(a6)	A=adr lettre

	moveq #0,d0
	move.w PosX(pc),d0
	move.w d0,d1
	lsr.w #3,d0				met en octet  /8
	and.w #$f,d1				décalage à faire au blitter
	ror.w #4,d1				$x000
	move.w d1,bltcon1(a6)			décalage du mask ( B )
	or.w #$fea,d1
	move.w d1,bltcon0(a6)			D=(A&B)|C

	move.w PosY(pc),d1
	mulu #80*2*2,d1
	add.l d1,d0
	add.l #screen_area,d0
	move.l d0,bltcpt(a6)			C=ecran
	move.l d0,bltdpt(a6)			D=ecran

	move.l #76<<16,bltcmod(a6)		C=78 / B=0	modulos
	move.l #(76<<16)+76,bltamod(a6)		A=78 / D=78

	moveq #-1,d0
	move.l d0,bltafwm(a6)			masques sur la source A

	move.w #(58*2)<<6+2,bltsize(a6)		lettre de 32x29x2  *2 ecrans
end_writer
	rts

centre_texteX
	move.l a0,a1
	lea Lettre_Taille(pc),a2
	move.w #310,d0
biduleX
	moveq #0,d1
	move.b (a1)+,d1
	beq.s end_biduleX
	cmp.b #10,d1
	beq.s end_biduleX
	cmp.b #"=",d1
	beq.s end_biduleX
	cmp.b #" ",d1
	bne.s biduleXspace
	subq.w #8,d0
	bra.s biduleX
biduleXspace
	sub.w #"!",d1
	add.w d1,d1
	sub.w 0(a2,d1.w),d0
	bra.s biduleX
end_biduleX
	lsr.w #1,d0
	add.w #330,d0
	move.w d0,PosX-damier_base(a5)
	rts

centre_texteY
	move.l a0,a1
	move.w #256-31,d0
biduleY
	move.b (a1)+,d1
	beq.s end_biduleY
	cmp.b #"=",d1
	beq.s end_biduleY
	cmp.b #10,d1
	bne.s biduleY
	sub.w #31,d0
	bra.s biduleY
end_biduleY
	lsr.w #1,d0
	move.w d0,PosY-damier_base(a5)
	rts


********************************************************************************
************************  EFFACAGE DE L'ECRAN DE TRAVAIL  **********************
********************************************************************************
Clear_Troade
	btst #14,dmaconr(a6)
	bne.s Clear_Troade

	move.l log_screen(pc),a0
	add.l #80*2*2*OFFSET,a0
	move.l a0,bltdpt(a6)			efface le log_screen
	move.l #$1000000,bltcon0(a6)
	move.w #54+80,bltdmod(a6)
	move.w #(94*2<<6)|13,bltsize(a6)
	rts


********************************************************************************
*************                                                       ************
*************  AUGMENTATION DES ANGLES POUR LA MATRICE DE ROTATION  ************
*************                                                       ************
********************************************************************************
Incrize_Angles
	lea Alpha(pc),a0
do_Alpha
	add.w d0,(a0)+				ajoute l'angle
	bgt.s Alpha_test			signe du résultat
	beq.s do_Teta
	add.w #1440,-2(a0)
	bra.s do_Teta
Alpha_test
	cmp.w #1440,-2(a0)
	blt.s do_Teta
	sub.w #1440,-2(a0)
do_Teta
	add.w d1,(a0)+				ajoute l'angle
	bgt.s Teta_test				signe du résultat
	beq.s do_Phi
	add.w #1440,-2(a0)
	bra.s do_Phi
Teta_test
	cmp.w #1440,-2(a0)
	blt.s do_Phi
	sub.w #1440,-2(a0)
do_Phi
	add.w d2,(a0)				ajoute l'angle
	bgt.s Phi_test				signe du résultat
	beq.s end_Angles
	add.w #1440,(a0)
	rts
Phi_test
	cmp.w #1440,(a0)
	blt.s end_Angles
	sub.w #1440,(a0)
end_Angles
	rts



********************************************************************************
*********************                                    ***********************
*********************  CALCUL DE LA MATRICE DE ROTATION  ***********************
*********************                                    ***********************
********************************************************************************
cosalpha equr d0				qq equr pour se simplifier
sinalpha equr d1				la lecture
costeta  equr d2
sinteta  equr d3
cosphi   equr d4
sinphi   equr d5

Compute_Matrix
	lea Table_Cosinus(pc),a0
	lea Table_Sinus(pc),a1

	movem.w Alpha(pc),d0-d2			va chercher les angles

	move.w 0(a1,d2.w),sinphi		sinus phi
	move.w 0(a0,d2.w),cosphi		cosinus phi

	move.w 0(a1,d1.w),sinteta		sinus teta
	move.w 0(a0,d1.w),costeta		cosinus teta

	move.w 0(a1,d0.w),sinalpha		sinus alpha
	move.w 0(a0,d0.w),cosalpha		cosinus alpha

	lea matrix(pc),a0

	move.w costeta,d6
	muls cosphi,d6				cos(teta) * cos(phi)
	swap d6
	move.w d6,(a0)

	move.w costeta,d6
	muls sinphi,d6				cos(teta) * sin(phi)
	swap d6
	move.w d6,2(a0)

	move.w sinteta,d6
	neg.w d6
	asr.w #1,d6				on perd un bit à cause du swap
	move.w d6,4(a0)				-sin(teta)

	move.w costeta,d6
	muls sinalpha,d6			cos(teta) * sin(alpha)
	swap d6
	move.w d6,10(a0)

	move.w costeta,d6
	muls cosalpha,d6			cos(teta) * cos(alpha)
	swap d6
	move.w d6,16(a0)
	
	move.w sinalpha,d6
	muls sinteta,d6				sin(alpha) * sin(teta)
	swap d6
	rol.l #1,d6
	move.w d6,a1

	muls cosphi,d6				sin(alpha)*sin(teta)*cos(phi)
	move.w cosalpha,d7
	muls sinphi,d7				cos(alpha) * sin(phi)
	sub.l d7,d6
	swap d6
	move.w d6,6(a0)

	move.w a1,d6
	muls sinphi,d6				sin(alpha)*sin(teta)*sin(phi)
	move.w cosalpha,d7
	muls cosphi,d7				cos(alpha) * cos(phi)
	add.l d7,d6
	swap d6
	move.w d6,8(a0)

	move.w cosalpha,d6
	muls sinteta,d6				cos(alpha) * sin(teta)
	swap d6
	rol.l #1,d6
	move.w d6,a1

	muls cosphi,d6				cos(alpha)*sin(teta)*cos(phi)
	move.w sinalpha,d7
	muls sinphi,d7				sin(alpha) * sin(phi)
	add.l d7,d6
	swap d6
	move.w d6,12(a0)

	move.w a1,d6
	muls sinphi,d6				cos(alpha)*sin(teta)*sin(phi)
	move.w sinalpha,d7
	muls cosphi,d7				sin(alpha) * cos(phi)
	sub.l d7,d6
	swap d6
	move.w d6,14(a0)		

	rts

matrix	dcb.w 3*3,0				la matrice de rotation
Alpha	dc.w 0
Teta	dc.w 0
Phi	dc.w 0
Table_Cosinus
	incbin "table_cosinus_720.dat"
Table_Sinus=Table_Cosinus+90*4



********************************************************************************
*************                                                        ***********
*************  TRANSFORMATIONS DES COORDONNEES 3D EN COORDONNEES 2D  ***********
*************                                                        ***********
********************************************************************************
Compute_Dots
	lea dots_3d(pc),a0			pointe les points 3d originaux
	lea dots_2d(pc),a1			pointe les points 2d
	move.w #ZOOM,d6				le zoom
	moveq #8-1,d0				8 points sur le cube
	moveq #9,d7				valeur du shift de D

loop_compute_dots
	movem.w (a0),d1-d3			coord 3d du point
	muls matrix(pc),d1
	muls matrix+2(pc),d2
	muls matrix+4(pc),d3
	add.l d3,d2
	add.l d2,d1
	swap d1
	ext.l d1
	lsl.l d7,d1				X=X*D

	movem.w (a0),d2-d4			coord 3d du point
	muls matrix+6(pc),d2
	muls matrix+8(pc),d3
	muls matrix+10(pc),d4
	add.l d4,d3
	add.l d3,d2
	swap d2					Y
	ext.l d2
	lsl.l d7,d2				Y=Y*D

	movem.w (a0)+,d3-d5			coord 3d du point
	muls matrix+12(pc),d3
	muls matrix+14(pc),d4
	muls matrix+16(pc),d5
	add.l d5,d4
	add.l d4,d3
	swap d3					Z
	add.w d6,d3				zjoute le zoom

	beq.s no_divs
	divs d3,d1				Xe=X*D/Z
	divs d3,d2				Ye=Y*D/Z
	asr.w #1,d2
no_divs
	add.w #110,d1				recentre à l'écran
	add.w #48,d2
	move.w d1,(a1)+				sauve Xe,Ye
	move.w d2,(a1)+

	dbf d0,loop_compute_dots	
	rts	



********************************************************************************
******************************                   *******************************
******************************  AFFICHE LE CUBE  *******************************
******************************                   *******************************
********************************************************************************
Display_Cube
	bsr DrawLine_Init			init le blitter

	lea cube_color(pc),a1
	lea dots_2d(pc),a2			pointe les points 2d
	lea cube_faces(pc),a3			pointe descriptions des faces
	move.l log_screen(pc),a4
	add.l #80*2*2*OFFSET,a4			pointe l'écran de travail
	moveq #6-1,d7				6 faces pour un cube

draw_next_face
	movem.w (a3),d0/d2/d4			offset de 3 points
	movem.w 0(a2,d0.w),d0-d1		d0=X1   ,   d1=Y1
	movem.w 0(a2,d2.w),d2-d3		d2=X2   ,   d3=Y2
	movem.w 0(a2,d4.w),d4-d5		d4=X3   ,   d5=Y3
	sub.w d0,d2				(x2-x1)
	sub.w d1,d5				(y3-y1)
	muls d5,d2				(x2-x1)*(y3-y1)
	sub.w d0,d4				(x3-x1)
	sub.w d1,d3				(y2-y1)
	muls d4,d3				(x3-x1)*(y2-y1)
	sub.l d3,d2				(x2-x1)*(y3-y1)<(x3-x1)*(y2-y1)?
	bgt.s face_front			face devant si >0

	lea face_SIZEOF(a3),a3			pointe la face suivante
	dbf d7,draw_next_face
	rts					=0 => pas de face

face_front
	moveq #$f,d5
	mulu #$e,d2				calcule composante par
	divu #MAX,d2				rapport à $f
	addq.w #1,d2

	mulu Fade_cube(pc),d2			calcule composante par
	divu d5,d2				rapport au fade

	move.w d2,d3				calcule la composante Rouge
	mulu Red(a3),d3
	divu d5,d3
	addq.w #3,d3
	lsl.w #8,d3

	move.w d2,d4				calcule la composante Verte
	mulu Green(a3),d4
	divu d5,d4
	addq.w #1,d4
	lsl.w #4,d4

	mulu Blue(a3),d2			calcule la composante Bleue
	divu d5,d2
	addq.w #2,d2

	or.w d3,d2				composantes RGB de la face
	or.w d4,d2	

draw_face
	move.w bpl(a3),d6			met la couleur
	move.w d6,d0
	add.w d0,d0
	move.w d2,-2(a1,d0.w)

	lsr.b #1,d6
	bcc.s not_in_bpl1

	movem.w (a3),d0/d2			point 1 & 2
	movem.w 0(a2,d0.w),d0-d1
	movem.w 0(a2,d2.w),d2-d3
	move.l a4,a0
	bsr DrawLine

	movem.w point2(a3),d0/d2		point 2 & 3
	movem.w 0(a2,d0.w),d0-d1
	movem.w 0(a2,d2.w),d2-d3
	move.l a4,a0
	bsr DrawLine

	movem.w point3(a3),d0/d2		point 3 & 4
	movem.w 0(a2,d0.w),d0-d1
	movem.w 0(a2,d2.w),d2-d3
	move.l a4,a0
	bsr DrawLine
		
	move.w point4(a3),d0			point 1 & 4
	move.w (a3),d2
	movem.w 0(a2,d0.w),d0-d1
	movem.w 0(a2,d2.w),d2-d3
	move.l a4,a0
	bsr DrawLine

not_in_bpl1
	tst.b d6
	beq.s not_in_bpl2

	movem.w (a3),d0/d2			point 1 & 2
	movem.w 0(a2,d0.w),d0-d1
	movem.w 0(a2,d2.w),d2-d3
	lea 80*2(a4),a0
	bsr DrawLine

	movem.w point2(a3),d0/d2		point 2 & 3
	movem.w 0(a2,d0.w),d0-d1
	movem.w 0(a2,d2.w),d2-d3
	lea 80*2(a4),a0
	bsr DrawLine

	movem.w point3(a3),d0/d2		point 3 & 4
	movem.w 0(a2,d0.w),d0-d1
	movem.w 0(a2,d2.w),d2-d3
	lea 80*2(a4),a0
	bsr DrawLine
		
	move.w point4(a3),d0			point 1 & 4
	move.w (a3),d2
	movem.w 0(a2,d0.w),d0-d1
	movem.w 0(a2,d2.w),d2-d3
	lea 80*2(a4),a0
	bsr DrawLine

not_in_bpl2
	lea face_SIZEOF(a3),a3
	dbf d7,draw_next_face
	rts


********************************************************************************
*************************                             **************************
*************************  REMPLI LE CUBE AU BLITTER  **************************
*************************                             **************************
********************************************************************************
Fill_Screen
	add.l #80*2*2*93-160+26-2,a4

Fill_Screen_Wait
	btst #14,dmaconr(a6)
	bne.s Fill_Screen_Wait

	move.l a4,bltapt(a6)
	move.l a4,bltdpt(a6)
	move.w #80+54,bltamod(a6)		descending !!!!
	move.w #80+54,bltdmod(a6)
	moveq #-1,d0
	move.l d0,bltafwm(a6)
	move.l #$9f00012,bltcon0(a6)
	move.w #(93*2<<6)|13,bltsize(a6)
	rts



********************************************************************************
*******************                                            *****************
*******************  ROUTINE DE TRACE DE DROITES FAITE MAISON  *****************
*******************                                            *****************
********************************************************************************
Width=160				largeur en octets
Heigth=256				hauteur en pixels
Depth=2					profondeur en bitplans
MINTERM=$4a				minterm de la droite

DrawLine
	cmp.w d1,d3
	bgt.s .Y_OK
	beq .no_line

	exg d0,d2
	exg d1,d3
.Y_OK
	sub.w d0,d2				d2=deltaX
	sub.w d1,d3				d3=deltaY
	subq.w #1,d3

	moveq #0,d4
	ror.w #4,d0				\
	move.b d0,d4				 > d0=décalage
	and.w #$f000,d0				/

	add.b d4,d4				d4=adr en octets sur X
	add.w d1,d1				d1=d1*4 car table de LING
	add.w d1,d1				
	add.l Table_Mulu_Line(pc,d1.w),d4	d4=d1*Width+d4
	lea 0(a0,d4.l),a0			recherche 1er mot de la droite
	move.w d0,d4				sauvegarde du décalage
	or.w #$0b<<8|MINTERM,d4			source + masque
.find_octant	
	moveq #0,d1
	tst.w d2
	bpl.s .X1_inf_X2
	neg.w d2
	moveq #4,d1
.X1_inf_X2
	cmp.w d2,d3
	bpl.s .DY_sup_DX
	or.b #16,d1
	bra.s .octant_found
.DY_sup_DX
	exg d2,d3
	add.b d1,d1
.octant_found

	addq.b #3,d1				LINE + ONEDOT
	or.w d0,d1				rajoute le décalage
	
	add.w d3,d3				4*Pdelta
	add.w d3,d3
	add.w d2,d2				2*Gdelta

.wait
	btst #14,dmaconr(a6)
	bne.s .wait

	move.w d3,bltbmod(a6)
	sub.w d2,d3				4*Pdelta-2*Gdelta
	bge.s .no_SIGNFLAG
	or.w #$40,d1
.no_SIGNFLAG
	move.w d1,bltcon1(a6)
	move.w d3,bltapt+2(a6)
	sub.w d2,d3				4*Pdelta-4*Gdelta
	move.w d3,bltamod(a6)

	move.w d4,bltcon0(a6)

	move.l a0,bltcpt(a6)			\ pointeur sur 1er mot droite
	move.l a0,bltdpt(a6)			/

	addq.w #1<<1,d2				(Gdelta+1)<<1
	lsl.w #5,d2				(Gdelta+1)<<6
	addq.b #2,d2				(Gdelta+1)<<6+2
	move.w d2,bltsize(a6)			traçage de la droite
.no_line
	rts

Table_Mulu_Line
MuluCount set 0
	rept Heigth
	dc.l MuluCount*Width*Depth
MuluCount set MuluCount+1
	endr

DrawLine_Init
	btst #14,dmaconr(a6)
	bne.s DrawLine_Init

	move.w #Width*Depth,d0
	move.w d0,bltcmod(a6)			\ largeur de l'image
	move.w d0,bltdmod(a6)			/
	moveq #-1,d0
	move.w d0,bltbdat(a6)			masque de la droite
	move.l d0,bltafwm(a6)			masque sur A
	move.w #$8000,bltadat(a6)		Style du point
	rts	



********************************************************************************
*****************************                       ****************************
*****************************  DESCRIPTION DU CUBE  ****************************
*****************************                       ****************************
********************************************************************************
dots_3d
BING=500
	dc.w BING,BING,BING
	dc.w BING,-BING,BING
	dc.w -BING,-BING,BING
	dc.w -BING,BING,BING
	dc.w BING,BING,-BING
	dc.w BING,-BING,-BING
	dc.w -BING,-BING,-BING
	dc.w -BING,BING,-BING

dots_2d
	dcb.w 8*2,0

POINT	macro
	dc.w \1*4-4
	endm

cube_faces
* 1ère face
	POINT 2
	POINT 3
	POINT 4
	POINT 1
	dc.w 1
	dc.w $f
	dc.w $8
	dc.w $0

* 2ème face
	POINT 4
	POINT 3
	POINT 7
	POINT 8
	dc.w 2
	dc.w $f
	dc.w $0
	dc.w $8

* 3ème face
	POINT 7
	POINT 6
	POINT 5
	POINT 8
	dc.w 1
	dc.w $8
	dc.w $f
	dc.w $8

* 4ème face
	POINT 5
	POINT 6
	POINT 2
	POINT 1
	dc.w 2
	dc.w $f
	dc.w $0
	dc.w $f

* 5ème face
	POINT 2
	POINT 6
	POINT 7
	POINT 3
	dc.w 3
	dc.w $8
	dc.w $8
	dc.w $f

* 6ème face
	POINT 5
	POINT 1
	POINT 4
	POINT 8
	dc.w 3
	dc.w $f
	dc.w $f
	dc.w $0


*******************
******************* LES DATAS
*******************
damier_base

Lettre_Adr
dummy set 0
	rept 40
	dc.l Font+dummy*2
dummy set dummy+1
	endr
dummy set 0
	rept 18
	dc.l Font+80*29*2*2+dummy*2
dummy set dummy+1
	endr

Lettre_Taille
	dc.w 6,0,0,0,0,0,5,10,10,0,15,0,16
	dc.w 6,0,16,10,16,16,16,16,16,16,16,16,6
	dc.w 0,0,0,0,16,0,16,16,16,16,16,16,16,16,7
	dc.w 16,16,16,16,16,16,16,16,16,16,10,16,16,16,16,16,16

DamierX		dc.w 0
DamierY		dc.w 0
VitX		dc.w 0
VitY		dc.w 0
CompR		dc.w 0
CompG		dc.w 0
CompB		dc.w 0
DamierFlag	dc.w 0

PosX		dc.w 0
PosY		dc.w 0
mask_number	dc.w 0
lettre_ptr	dc.l 0
lettre_size	dc.w 0
texte_ptr	dc.l 0
writer_pause	dc.w 0
writer_clear	dc.w 0
clearY		dc.w 0

cube_color	dc.w 0,0,0
Fade_cube	dc.w 0
Defade_cube	dc.w 0
delay		dc.w 0
CubeRot		dc.w 0,0,0

log_coplist	dc.l 0
phy_coplist	dc.l 0
log_screen	dc.l 0
phy_screen	dc.l 0

writer_data_ptr
	dc.l cacolac

	section vaenchip,data_c
ColorMap
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr
	rept 24
	dc.w color02,$312
	dc.w color00,$312
	endr

DamierPic
	incbin "Damier.RAW"

LeftSpr
	dc.l 0
	incbin "LeftSpr.RAW"
BlkSpr
	dc.l 0
MiddleSpr
	dc.l 0
	incbin "MiddleSpr.RAW"
	dc.l 0

*******************
******************* LES COPLISTS
*******************
coplist1
	dc.w bplcon0,$3200|$8000
	dc.w bplcon1,$0000
	dc.w bplcon2,%100100
	dc.w ddfstrt,$003c
	dc.w ddfstop,$00d4
	dc.w diwstrt,$2b7f
	dc.w diwstop,$2bc1
	dc.w bpl1mod,80*3
	dc.w bpl2mod,-80
	dc.w color17,$312			\ couleurs des sprites
SprColor
	dc.w color18,$312			/
DamierPtr
	dc.w bpl2ptH,0				\ ptrs videos pour le damier
	dc.w bpl2ptL,0				/
DamierColor
dummy set $2b
	rept 256
	dc.b dummy&$ff,$21			\ wait sur la ligne
	dc.w $fffe				/
	dc.w color01,$f00
	dc.w color03,$f00
	dc.w color04,$00f
	dc.w color06,$00f
	dc.w color05,$0f0
	dc.w color07,$0f0
	dc.w color02,$312			\ couleurs de la ligne
	dc.w color00,$312			/
	dc.b dummy&$ff,$73
	dc.w $fffe
	dc.w color01,$aaa
	dc.w color04,$eee
	dc.w color05,$666
	dc.w color00,$312
	dc.b dummy&$ff,$df
	dc.w $fffe
dummy set dummy+1
	endr
	dc.l $fffffffe
coplist1_size=*-coplist1

coplist2
	dcb.b coplist1_size,0

Mask0	incbin "Mask0.RAW"
Mask1	incbin "Mask1.RAW"
Mask3	incbin "Mask3.RAW"
Mask5	incbin "Mask5.RAW"
Mask7	incbin "Mask7.RAW"
Mask9	incbin "Mask9.RAW"

Font
	incbin "WriterFont.RAW"

