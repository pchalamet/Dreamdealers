
*	demo executer   pour la Live Supportro !!!!  Sync/TSB
*	--------------------------------------------------------->

	opt O+,OW-

	incdir "asm:" "ram:" "dh1:Livetro/" "dH1:Livetro/Music/"
	include "sources/registers.i"

	XDEF LIVETRO
	XDEF SCREEN_AREA
	XDEF MT_INIT,MT_MUSIC
	XREF INFINITE
	XDEF DECRUNCH
	XREF CHESSFIELD
	XREF GELS
	XREF _DOSBASE

	section vroum,code
LIVETRO
	lea data_base(pc),a5

	moveq #0,d0				ouvre la gfx
	lea GfxName(pc),a1
	move.l 4.w,a6
	jsr OpenLibrary(a6)
	move.l d0,_GfxBase-data_base(a5)
	beq Error_Gfx

	move.l d0,a1
	move.l $26(a1),copinit-data_base(a5)	init avec l'adresse des coplists
	move.l $32(a1),a0
	move.l a0,copLOF-data_base(a5)
	addq.l #6,a0
	move.l a0,pompom-data_base(a5)

	moveq #4-1,d0				sauve les couleurs de départ
	lea save_colors(pc),a2
copy_colors
	move.w (a0),(a2)+
	addq.l #4,a0
	dbf d0,copy_colors

	jsr CloseLibrary(a6)			ferme la gfx

	move.l _DOSBASE,a6
wait_end_text
	tst.l _DOSBASE				attend la fin du writer
	beq.s end_wait
	moveq #2,d1
	jsr -198(a6)				Delay
	bra.s wait_end_text
end_wait
	move.l 4.w,a6
	jsr Forbid(a6)

	lea $dff000,a6				sauve les registres importants
	move.l $6c.w,save_IT3-data_base(a5)
	move.l $78.w,save_IT6-data_base(a5)
	move.w intenar(a6),save_intena-data_base(a5)
	or.w #$c000,save_intena-data_base(a5)
	move.w dmaconr(a6),save_dmacon-data_base(a5)
	or.w #$8200,save_dmacon-data_base(a5)

	move.w #$7fff,intena(a6)
	move.b #$87,$bfd100			vire les drives
	move.l #fade_vbl,$6c.w
	move.l copLOF(pc),cop1lc(a6)
	move.w #$0020,dmacon(a6)		vire les sprites
	move.w #$c020,intena(a6)

wait_end_fade
	tst.w end_fade-data_base(a5)
	bne.s wait_end_fade
	
*-----------------------------> Infinite
	lea CHESSPIC(pc),a0			\
	lea SCREEN_AREA,a1			 | decrunch l'image
	bsr DECRUNCH				/
	jsr INFINITE
*-----------------------------> ChessField
	jsr CHESSFIELD
*-----------------------------> Gels
	jsr GELS

	bsr mt_end

	lea $dff000,a6
	move.l copinit(pc),cop1lc(a6)
	move.l copLOF(pc),cop2lc(a6)
	move.l save_IT3(pc),$6c.w
	move.l save_IT6(pc),$78.w
	move.w save_intena(pc),intena(a6)	
	move.w save_dmacon(pc),dmacon(a6)

	lea save_colors(pc),a0			remet les couleurs
	move.l pompom(pc),a1
	moveq #4-1,d0
restore_colors
	move.w (a0)+,(a1)
	addq.l #4,a1
	dbf d0,restore_colors

	move.l 4.w,a6
	jsr Permit(a6)
error_gfx
	rts

fade_vbl
	movem.l d0-d7/a0-a6,-(sp)
	lea table(pc),a0
	bsr.s fade
	clr.w copjmp1(a6)			relance la coplist
	subq.w #1,end_fade-data_base(a5)
	move.w #$0020,$dff000+intreq
	movem.l (sp)+,d0-d7/a0-a6
	rte

*----------------------------> routines pour le fade   a0=table des datas
Fade
	subq.w #1,(a0)+			faut faire le fade ?
	bne.s EndFade			ben nan..
DoFade
	move.w (a0)+,-4(a0)		remet le compteur
	move.w (a0)+,d0			nb de couleurs-1
	move.l (a0)+,a1			adr des modifs
	
LoopFadeB
	move.w (a0)+,d1			va chercher la couleur à atteindre
	move.w (a1),d3			couleur actuelle

	move.w d1,d2
	and.w #$f,d2			valeur a atteindre B
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
DofadeOutG
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
	move.w d3,(a1)
	addq.l #4,a1
	dbf d0,LoopFadeB
EndFade
	rts

* interne.W
* wait.W
* nb couleurs.W
* adr couleurs.L

data_base
table
	dc.w 1
	dc.w 3
	dc.w 4-1
pompom	dc.l 0
	dc.w 0,0,0,0

_GfxBase
	dc.l 0
save_IT3
	dc.l 0
save_IT6
	dc.l 0
save_intena
	dc.w 0
save_dmacon
	dc.w 0
copinit
	dc.l 0
copLOF
	dc.l 0
end_fade
	dc.w 20*3
save_colors
	dcb.w 4,0
GfxName
	dc.b "graphics.library",0
	even

	include "decrunch.s"

CHESSPIC
	incbin "ChessField/ChessPic.PAK"

	include "asm:Sources/TMC_Replay.s"
	include "ram:Song.s"
	section zkos,data_c
	include "ram:Samples.s"
	
	section toto,bss_c
SCREEN=(352/8)*272
SCREEN_AREA
	ds.b SCREEN*(3*2+2)

