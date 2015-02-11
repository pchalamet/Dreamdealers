
DEBUG=0

*
*		Point d'entrée de la Lipton  ©1993 Dreamdealers
*		---------------------------------------------------->
*		Coded by Sync/Dreamdealers


	XDEF screen_area
	XDEF mt_music
	XDEF clear_screen_area
	XREF do_writer
	XREF do_inconvex
	XREF do_dragonball
	XREF do_tunnel
	XREF do_bigballs

	incdir "asm:sources/"
	incdir "asm:datas/"
	incdir "ram:"
	incdir "Lipton:PAK/"
	incdir "Lipton:RAW/"
	include "registers.i"

	section badaboum,code

	KILL_SYSTEM Entry_Point


Entry_Point
	SAVE_680x0				vire les caches et vbr

	move.l 4.w,a3				sauve les vecteurs reset
	move.w 82(a3),-(sp)
	move.l 50(a3),-(sp)
	move.l 46(a3),-(sp)
	move.l 42(a3),-(sp)

	move.l #Reset_Rout,42(a3)		installe les vecteurs resets
	clr.l 46(a3)
	clr.l 50(a3)
	lea 34(a3),a1
	moveq #0,d1
	moveq #17-1,d7
make_checksum
	add.w (a1)+,d1
	dbf d7,make_checksum
	not.w d1
	move.w d1,82(a3)
****************************************

	lea custom_base,a6

	move.l #intro_vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	clr.w copjmp1(a6)
	jsr mt_init

	move.l #image_list,image_ptr

	move.w #$8640,dmacon(a6)
	bsr clear_screen_area

wait_vpos
	move.l vposr(a6),d0
	and.l #$1ff00,d0
	cmp.l #$13700,d0
	bne.s wait_vpos

	move.w #$87c0,dmacon(a6)

******************************************************
****************************************************** DREAM DEALERS ARE BACK
******************************************************
	lea LipTitlePak(pc),a5			decrunch le premier ecran
	lea (4+16)*2(a5),a0
	move.l log_screen(pc),a1
	bsr decrunch

	move.w #$c020,intena(a6)

	moveq #5-1,d7
loop_display_screens
	move.l log_screen(pc),d0		echange les ecrans
	move.l phy_screen(pc),log_screen
	move.l d0,phy_screen

	stop #$2200

	lea 4*2(a5),a0				copy les couleurs pour le
	lea fade_color(pc),a1			fade
	moveq #16-1,d1
copy_color
	move.w (a0)+,(a1)+
	dbf d1,copy_color	

	move.w #32,fade_counter			lance le fade
	move.w (a5)+,bpl_patch			init la coplist
	move.w (a5),mod1_patch
	move.w (a5)+,mod2_patch
	move.w (a5)+,interlace_mod
	move.w (a5)+,wait_vbl
	clr.w copjmp1(a6)			relance la coplist

	addq.l #4,image_ptr			passe à l'image suivante
	move.l image_ptr(pc),a0
	move.l (a0),a5				choppe l'adr de l'image

	lea (4+16)*2(a5),a0			va decruncher l'image
	move.l log_screen(pc),a1
	bsr decrunch

counter
	tst.w wait_vbl
	bne.s counter

	dbf d7,loop_display_screens

************

	move.l log_screen(pc),d0		echange les ecrans
	move.l phy_screen(pc),log_screen
	move.l d0,phy_screen

	stop #$2200

	lea 4*2(a5),a0				copy les couleurs pour le
	lea fade_color(pc),a1			fade
	moveq #16-1,d1
copy_color2
	move.w (a0)+,(a1)+
	dbf d1,copy_color2

	move.w #32,fade_counter			lance le fade
	move.w (a5)+,bpl_patch			init la coplist
	move.w (a5),mod1_patch
	move.w (a5)+,mod2_patch
	move.w (a5)+,interlace_mod
	move.w (a5)+,wait_vbl
	clr.w copjmp1(a6)			relance la coplist

counter2
	tst.w wait_vbl
	bne.s counter2
	IFNE DEBUG
	btst #6,ciaapra
	beq lipton_exit
	ENDC

******************************************************
****************************************************** WRITER
******************************************************
	stop #$2200
	jsr do_writer
	IFNE DEBUG
	btst #6,ciaapra
	beq lipton_exit
	ENDC

******************************************************
****************************************************** LA DRAGONBALL
******************************************************
	move.l #intro_vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	stop #$2200
	jsr do_dragonball
	IFNE DEBUG
	btst #6,ciaapra
	beq lipton_exit
	ENDC

******************************************************
****************************************************** WRITER
******************************************************
	move.l #intro_vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	stop #$2200
	jsr do_writer
	IFNE DEBUG
	btst #6,ciaapra
	beq lipton_exit
	ENDC

******************************************************
****************************************************** LE TUNNEL DE POINTS
******************************************************
	move.l #intro_vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	stop #$2200
	jsr do_tunnel
	IFNE DEBUG
	btst #6,ciaapra
	beq lipton_exit
	ENDC

******************************************************
****************************************************** WRITER
******************************************************
	move.l #intro_vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	stop #$2200
	jsr do_writer
	IFNE DEBUG
	btst #6,ciaapra
	beq lipton_exit
	ENDC

******************************************************
****************************************************** LES BIGBALLS
******************************************************
	move.l #intro_vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	stop #$2200
	jsr do_bigballs
	IFNE DEBUG
	btst #6,ciaapra
	beq lipton_exit
	ENDC

******************************************************
****************************************************** WRITER
******************************************************
	move.l #intro_vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	stop #$2200
	jsr do_writer
	IFNE DEBUG
	btst #6,ciaapra
	beq lipton_exit
	ENDC

******************************************************
****************************************************** LE LOGO DRD EN 3D
******************************************************
	move.l #intro_vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	stop #$2200
	jsr do_inconvex
	IFNE DEBUG
	btst #6,ciaapra
	beq lipton_exit
	ENDC

******************************************************
****************************************************** WRITER
******************************************************
	move.l #intro_vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	stop #$2200
	jsr do_writer
	IFNE DEBUG
	btst #6,ciaapra
	beq lipton_exit
	ENDC
******************************************************
****************************************************** LE BIG MONSTER
******************************************************
	move.w #$0180,dmacon(a6)		vire les dmas bpl
	move.l #intro_vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	move.w #$312,color00(a6)		huuummmm ???
	stop #$2200
	IFNE DEBUG
	btst #6,ciaapra
	beq lipton_exit
	ENDC

	lea LiptonMonsterPak,a5			decrunch le premier ecran
	lea (4+16)*2(a5),a0
	move.l phy_screen(pc),a1
	bsr decrunch
	move.w #$8180,dmacon(a6)		remet les dmas

	lea 4*2(a5),a0				copy les couleurs pour le
	lea fade_color(pc),a1			fade
	moveq #16-1,d1
copy_color3
	move.w (a0)+,(a1)+
	dbf d1,copy_color3

	move.w #32,fade_counter			lance le fade
	move.w (a5)+,bpl_patch			init la coplist
	move.w (a5),mod1_patch
	move.w (a5)+,mod2_patch
	move.w (a5)+,interlace_mod
	move.w (a5)+,wait_vbl
	clr.w copjmp1(a6)			relance la coplist

counter3
	move.w #50,fade_counter			attend le bouton de la souris
	btst #6,ciaapra
	bne.s counter3

	move.w #-32,fade_counter
	move.w #32,wait_vbl

choucroute
	tst.w wait_vbl
	bne.s choucroute

******************************************************
****************************************************** C LA FIN !!!
******************************************************
lipton_exit
	move.l #intro_vbl,$6c.w
	move.l #coplist,cop1lc(a6)

	move.w #$7fff,intena(a6)		casse toi d'là la vbl !!
	jsr mt_end

	lea lipton_samples,a0
	lea lipton_samples_end,a1
.protect_samples
	move.l d0,(a0)+
	cmp.l a1,a0
	blt.s .protect_samples

	lea lipton_patterns,a0
	lea lipton_patterns_end,a1
.protect_patterns
	move.l d0,(a0)+
	cmp.l a1,a0
	blt.s .protect_patterns

	move.l (exec_base).w,a6
	move.l (sp)+,42(a6)			remet les vecteurs reset
	move.l (sp)+,46(a6)			en place vu kon sort
	move.l (sp)+,50(a6)			normalement...
	move.w (sp)+,82(a6)

	RESTORE_680x0
	rte	

fade_counter
	dc.w 0
log_screen
	dc.l screen_area
phy_screen
	dc.l screen_area+80*256*4
interlace_mod
	dc.w 0
wait_vbl
	dc.w 0
vbl_flag
	dc.w 0

image_ptr
	dc.l image_list
image_list
	dc.l LipTitlePak
	dc.l DreamPak
	dc.l DealersPak
	dc.l ArePak
	dc.l BackPak
	dc.l ComaPak

*******************************************
clear_screen_area
	btst #14,dmaconr(a6)
	bne.s clear_screen_area

	move.l #screen_area,bltdpt(a6)		efface la premiere moitié
	clr.w bltdmod(a6)
	move.l #$01000000,bltcon0(a6)
	move.w #60,bltsize(a6)			120*1024
	btst #14,dmaconr(a6)
.wait_cool
	btst #14,dmaconr(a6)
	bne.s .wait_cool

	move.l #screen_area+120*1024,bltdpt(a6)	efface la seconde moitié
	move.w #(768<<6)|60,bltsize(a6)		120*768
	btst #14,dmaconr(a6)
.wait_zen
	btst #14,dmaconr(a6)
	bne.s .wait_zen
	rts

* La protection... gasp!
*******************************************
Reset_Rout
	lea screen_area,a0
	move.l a0,a1
	add.l #80*512*2*2,a1
	moveq #0,d0
.protect_screen
	move.l d0,(a0)+
	cmp.l a1,a0
	blt.s .protect_screen

	lea lipton_samples,a0
	lea lipton_samples_end,a1
.protect_samples
	move.l d0,(a0)+
	cmp.l a1,a0
	blt.s .protect_samples

	lea lipton_patterns,a0
	lea lipton_patterns_end,a1
.protect_patterns
	move.l d0,(a0)+
	cmp.l a1,a0
	blt.s .protect_patterns
	clr.l 4.w

	move.l #porouge,$80.w
	trap #0
porouge
	lea 2.w,a0
	reset
	jmp (a0)

*******************************************


zik_vbl
	movem.l d0-d7/a0-a6,-(sp)
	jsr mt_music
	move.w #$0020,intreq+$dff000
	movem.l (sp)+,d0-d7/a0-a6
	rte

*************************
*************************  LA VBL
*************************
intro_vbl
	movem.l d0-d7/a0-a6,-(sp)

	jsr mt_music

	subq.w #1,wait_vbl

	lea custom_base,a6

	cmp.w #32,wait_vbl			gestion du fade
	bne.s no_fade_out
	move.w #-32,fade_counter

no_fade_out
	move.l phy_screen(pc),a0		init les ptrs videos
	move.w vposr(a6),d0
	bmi.s LongFrame
	move.w interlace_mod(pc),d0		modulo...
	lea 0(a0,d0.w),a0
LongFrame
	move.l a0,bpl1ptH(a6)
	lea 80(a0),a0
	move.l a0,bpl2ptH(a6)
	lea 80(a0),a0
	move.l a0,bpl3ptH(a6)
	lea 80(a0),a0
	move.l a0,bpl4ptH(a6)

	tst.w fade_counter
	beq.s do_nothing
	blt.s fade_to_fond

	subq.w #1,fade_counter
	lea Pic_table(pc),a0			fade in
	bra.s yo_fade
fade_to_fond
	addq.w #1,fade_counter
	lea Fond_table(pc),a0			fade out
yo_fade
	lea color_patch,a1
	bsr fade

do_nothing
	move.w #$0020,intreq(a6)
	movem.l (sp)+,d0-d7/a0-a6
	rte


***************************
*************************** LE FADING
***************************

fade
	move.w (a0)+,d0			a1 adresse des modifications
	subq.w #1,d0			d0 nb de changements-1
	move.w (a0)+,d5			offset
	move.w (a0)+,d6			prochaine couleur
	ext.l d6
	move.w (a0)+,d1			a0 adresse couleurs a atteindre
	move.w (a0),d2			met compteur dans d2
	cmp.w d1,d2			cmp
	beq.s DoFade			on a assez attendu => fading
	addq.w #1,(a0)			sinon on attend encore
	rts
	
* B=valeur Bleu  G=valeur vert  R=valeur rouge
	
DoFade
	clr.w (a0)+			remet a 0 le compteur
	
* differents tests sont effectués pour atteindre la bonne valeur de R,G ou B

LoopFadeB
	move.w (a0)+,d1
	move.w d1,d2
	and.w #$f,d2			valeur a atteindre B
	
	move.w 0(a1,d5.w),d3
	move.w d3,d4
	and.w #$f,d4			valeur actuelle B
	
	cmp.w d2,d4
	beq.s LoopFadeG
	bgt.s DoFadeOutB
	addq.w #1,d3			inferieur => on augmente
	bra.s LoopFadeG
DoFadeOutB
	subq.w #1,d3			superieur => on diminue

LoopFadeG
	move.w d1,d2
	and.w #$f0,d2			valeur a atteindre G
	
	move.w d3,d4
	and.w #$f0,d4			valeur actuelle G
	
	cmp.w d2,d4
	beq.s LoopFadeR
	bgt.s DoFadeOutG
	add.w #$10,d3			inferieur => on augmente
	bra.s LoopFadeR
DoFadeOutG
	sub.w #$10,d3			superieur => on diminue
	
LoopFadeR
	move.w d1,d2
	and.w #$f00,d2			valeur a atteindre R
	
	move.w d3,d4
	and.w #$f00,d4			valeur actuelle R
	
	cmp.w d2,d4
	beq.s FadeAgain
	bgt.s DoFadeOutR
	add.w #$100,d3
	bra.s FadeAgain
DoFadeOutR
	sub.w #$100,d3
FadeAgain
	move.w d3,0(a1,d5.w)
	add.l d6,a1
	dbra d0,LoopFadeB
	rts

* structure des tables de couleurs a atteindre
* nb de couleur.W
* offset.W
* prochaine couleur offset.W
* wait.W
* temps.W
* couleurs.W

Fond_table
	dc.w 16
	dc.w 2,4
	dc.w 0,0
	dc.w $312,$312,$312,$312,$312,$312,$312,$312
	dc.w $312,$312,$312,$312,$312,$312,$312,$312

Pic_table
	dc.w 16
	dc.w 2,4
	dc.w 0,0
fade_color
	dc.w $312,$312,$312,$312,$312,$312,$312,$312
	dc.w $312,$312,$312,$312,$312,$312,$312,$312

*************************
************************* ROUTINE DE DECRUNCHAGE BKMP
*************************
; ByteKiller Mega Profesionnal decrunch routine v1.4
; ©1993 Sync/Dreamdealers !!
; Based on Lord Blitter's ByteKiller1.2
; a0=source   a1=destination
; d0-d5/a0/a2 trashed !!

decrunch
	move.l a1,a2
	add.l (a0)+,a2
	add.l (a0),a0
	moveq #31,d5
	move.l -(a0),d0
dec1	lsr.l #1,d0
	bne.s dec2
	move.l -(a0),d0
	lsr.l #1,d0
	bset d5,d0
dec2	bcs.s dec11
	moveq #8,d1
	moveq #1,d3
	lsr.l #1,d0
	bne.s dec3
	move.l -(a0),d0
	lsr.l #1,d0
	bset d5,d0
dec3	bcs.w dec17
	moveq #3,d1
	moveq #0,d4
dec4	subq.w #1,d1
	moveq #0,d2
dec5	lsr.l #1,d0
	bne.s dec6
	move.l -(a0),d0
	lsr.l #1,d0
	bset d5,d0
dec6	addx.l d2,d2
	dbf d1,dec5
	move.w d2,d3
	add.w d4,d3
dec7	moveq #7,d1
dec8	lsr.l #1,d0
	bne.s dec9
	move.l -(a0),d0
	lsr.l #1,d0
	bset d5,d0
dec9	addx.l d2,d2
	dbf d1,dec8
	move.b d2,-(a2)
	dbf d3,dec7
	bra.s dec21
dec10	moveq #8,d1
	moveq #8,d4
	bra.s dec4
dec11	moveq #2,d1
	subq.w #1,d1
	moveq #0,d2
dec12	lsr.l #1,d0
	bne.s dec13
	move.l -(a0),d0
	lsr.l #1,d0
	bset d5,d0
dec13	addx.l d2,d2
	dbf d1,dec12
	cmp.b #2,d2
	blt.s dec16
	cmp.b #3,d2
	beq.s dec10
	moveq #8,d1
	subq.w #1,d1
	moveq #0,d2
dec14	lsr.l #1,d0
	bne.s dec15
	move.l -(a0),d0
	lsr.l #1,d0
	bset d5,d0
dec15	addx.l d2,d2
	dbf d1,dec14
	move.w d2,d3
	moveq #12,d1
	bra.s dec17
dec16	moveq #9,d1
	add.w d2,d1
	addq.w #2,d2
	move.w d2,d3
dec17	subq.w #1,d1
	moveq #0,d2
dec18	lsr.l #1,d0
	bne.s dec19
	move.l -(a0),d0
	lsr.l #1,d0
	bset d5,d0
dec19	addx.l d2,d2
	dbf d1,dec18
dec20	move.b -1(a2,d2.w),-(a2)
	dbf d3,dec20
***	move.w a2,$dff180
dec21	cmp.l a2,a1
	blt.w dec1
	rts

	include "asm:.s/The Module Converter/TMC_Replay3.8.s"
lipton_patterns
	include "Song.s"
lipton_patterns_end

LipTitlePak
	dc.w $C200,80*3,0,190
	dc.w $312,$fdb,$eb9,$ea8
	dc.w $d97,$b75,$953,$731
	dc.w $a64,$333,$555,$777
	dc.w $999,$bbb,$ddd,$fff
	incbin "LipTitle.PAK"
DreamPak
	dc.w $A204,80*3,80*2,95
	dc.w $312,$ddd,$aaa,$777
	dc.w $000,$000,$000,$000
	dc.w $000,$000,$000,$000
	dc.w $000,$000,$000,$000
	incbin "Dream.PAK"
DealersPak
	dc.w $A204,80*3,80*2,95
	dc.w $312,$ddd,$aaa,$777
	dc.w $000,$000,$000,$000
	dc.w $000,$000,$000,$000
	dc.w $000,$000,$000,$000
	incbin "Dealers.PAK"
ArePak
	dc.w $A204,80*3,80*2,95
	dc.w $312,$ddd,$aaa,$777
	dc.w $000,$000,$000,$000
	dc.w $000,$000,$000,$000
	dc.w $000,$000,$000,$000
	incbin "Are.PAK"
BackPak
	dc.w $A204,80*3,80*2,125
	dc.w $312,$ddd,$aaa,$777
	dc.w $000,$000,$000,$000
	dc.w $000,$000,$000,$000
	dc.w $000,$000,$000,$000
	incbin "Back.PAK"
ComaPak
	dc.w $C200,80*3,0,330
	dc.w $312,$ccc,$999,$777
	dc.w $555,$333,$a00,$f00
	dc.w $a64,$333,$555,$777
	dc.w $999,$bbb,$ddd,$00a
	incbin "LiptonComa.PAK"
LiptonMonsterPak
	dc.w $C200,80*3,0,460
	dc.w $312,$fff,$feb,$eb9
	dc.w $ea8,$d97,$c86,$b75
	dc.w $a64,$953,$842,$731
	dc.w $620,$510,$400,$ffd
	incbin "LiptonMonster.PAK"

	section caca,data_c
lipton_samples
	include "Samples.s"
lipton_samples_end

coplist
bpl_patch=*+2
	dc.w bplcon0,$2204|$8000
	dc.w bplcon1,$0000
	dc.w bplcon2,$0000
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w ddfstrt,$003c
	dc.w ddfstop,$00d4
mod1_patch=*+2
	dc.w bpl1mod,0
mod2_patch=*+2
	dc.w bpl2mod,0
color_patch
	dc.w color00,$312
	dc.w color01,$312
	dc.w color02,$312
	dc.w color03,$312
	dc.w color04,$312
	dc.w color05,$312
	dc.w color06,$312
	dc.w color07,$312
	dc.w color08,$312
	dc.w color09,$312
	dc.w color10,$312
	dc.w color11,$312
	dc.w color12,$312
	dc.w color13,$312
	dc.w color14,$312
	dc.w color15,$312
	dc.l $fffffffe

	section fae,bss_c
screen_area
	ds.b 120*256
	ds.b 120*256
	ds.b 120*256
	ds.b 120*256
	ds.b 120*256
	ds.b 120*256
	ds.b 120*256

