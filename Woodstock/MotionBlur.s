 

*				  BLUR
*				  ~~~~
*			(c)1995 Sync/DreamDealers




*********************************************************************************
*                                   Les EQUs                                    *
*********************************************************************************
BLUR_DATA_OFFSET=$7ffe


ROTO_MAX_ANGLE=360

INC_ZOOM1=3
INC_ZOOM2=2
ANGLE_COUNTER=60

MAX_SPEED=4
DELTA_SPEED=1

PICTURE_X=TEXTURE_X*4
PICTURE_Y=64
PICTURE_DEPTH=5
PICTURE_COLORS=1<<PICTURE_DEPTH
PICTURE_BITPLAN_LINE_SIZE=(PICTURE_X+7)/8
PICTURE_BITPLAN_SIZE=PICTURE_BITPLAN_LINE_SIZE*PICTURE_Y
BLUR_ZOOM=2

NEW_PERCENT=20
OLD_PERCENT=80
HOW_PERCENT=100

INC_ALPHA=5
INC_TETA=1

WAVE_RADIUS=150
CIRCLE_RADIUS=350


*********************************************************************************
*                          Point d'entrée de la demo !                          *
*********************************************************************************
	section zoom,code


Blur_Init
	movem.l a5/a6,-(sp)

	lea _Blur_DataBase,a5
	lea _CustomBase,a6

	tst.w Quoi(a5)				on fait koi ?
	bne.s .quoi

	bsr Build_Vache_Blur_Table		bah.. c'est pour la vache
	bsr Blur_Build_Vache_Picture
	bra.s .exit
.quoi
	bsr Build_Cochon_Blur_Table		le cochon
	bsr Blur_Build_Cochon_Picture

.exit
	movem.l (sp)+,a5/a6
	rts


Blur_Initial_PC
	movem.l a5/a6,-(sp)

	lea _Blur_DataBase,a5
	lea _CustomBase,a6

	bsr.s Init_Blur_DataBase
	jsr Clear_Coplists

	WAIT_VHSPOS
	move.w #$8020,dmacon(a6)

	lea Blur_VBL(pc),a0
	move.l a0,$6c.w

Blur_Main_Loop
	bsr Update_Mouse
	bsr Gestion_Deplacement
	bsr Roto_Build_Table_Rotate
	bsr Blur_Flip_Coplists
	bsr RotoZoom_Blur

	tst.b Blur_End(a5)
	beq.s Blur_Main_Loop

	addq.w #1,Quoi(a5)

	WAIT_VHSPOS
	move.w #$0020,dmacon(a6)

	movem.l (sp)+,a5/a6
	rts





*********************************************************************************
*			Initialisation des datas				*
*********************************************************************************
Init_Blur_DataBase
	move.w #20*50,Blur_Compteur(a5)
	sf Blur_End(a5)

	clr.w Roto_CentreX(a5)
	clr.w Roto_CentreY(a5)
	clr.w Roto_Angle(a5)
	clr.w Roto_Inc_X(a5)
	clr.w Roto_Inc_Y(a5)
	clr.w MouseX(a5)
	clr.w MouseY(a5)

* init pour le blur
	lea _Tmap_DataBase,a0
	move.l Log_Coplist(a0),Blur_Log_Coplist(a5)
	move.l Phy_Coplist(a0),Blur_Phy_Coplist(a5)

	clr.w Alpha(a5)
	clr.w Teta(a5)

* init pour la rotation
	move.w #ANGLE_COUNTER,Roto_Angle_Counter(a5)
	move.w #MAX_SPEED,Roto_Inc_Angle(a5)
	rts





*********************************************************************************
*			Juste une petite VBL pour la muzik			*
*********************************************************************************
Blur_VBL
	SAVE_REGS
	
	jsr P61_Music
;	jsr mt_music
	jsr Check_Quick_Exit

	lea _Blur_DataBase,a5
	lea _CustomBase,a6

	subq.w #1,Blur_Compteur(a5)
	bne.s .skip
	st Blur_End(a5)
.skip
	sf Blur_Flip_Flag(a5)
	move.w #$0020,intreq(a6)
	RESTORE_REGS
	rte




*********************************************************************************
*                           Permutation des coplists                            *
*   -->	a5=_Blur_DataBase                                                            *
*	a6=_Custom                                                              *
*********************************************************************************
Blur_Flip_Coplists
	st Blur_Flip_Flag(a5)

	move.l Blur_Log_Coplist(a5),d0
	move.l Blur_Phy_Coplist(a5),Blur_Log_Coplist(a5)
	move.l d0,Blur_Phy_Coplist(a5)

	move.l d0,cop1lc(a6)			init la nouvelle coplist
.wait	tst.b Blur_Flip_Flag(a5)		attend la syncho
	bne.s .wait
	clr.w copjmp1(a6)
	rts




*********************************************************************************
*				Gestion de la souris				*
*   -->	a5=_Blur_DataBase								*
*	a6=_CustomBase								*
*********************************************************************************
Update_Mouse
	lea Table_Cosinus,a0
	lea Table_Sinus,a1

	moveq #0,d0
	move.w Alpha(a5),d0			calcul de R=Rorg*Cos(Alpha)
	move.w #WAVE_RADIUS,d1			Rorg
	muls.w (a0,d0.w*2),d1		
	swap d1
	add.w #CIRCLE_RADIUS,d1			==> R

	add.w #INC_ALPHA,d0			Alpha=Alpha+INC_ALPHA
	divu.w #360,d0
	swap d0
	move.w d0,Alpha(a5)

	moveq #0,d0
	move.w Teta(a5),d0
	move.w d1,d2
	muls.w (a1,d0.w*2),d2
	swap d2					Y=R*Sin(Teta)

	muls.w (a0,d0.w*2),d1
	swap d1					X=R*Cos(Teta)

	add.w #INC_TETA,d0			Teta=Teta+INC_TETA
	divu.w #360,d0
	swap d0
	move.w d0,Teta(a5)

	movem.w d1/d2,MouseX(a5)
	rts






*********************************************************************************
*			Gestion du deplacement du rotozoom-bluré		*
*   -->	a5=_Blur_DataBase							*
*********************************************************************************
Gestion_Deplacement
* Modification de l'angle de la rotation
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
modify_angle
	move.w Roto_Inc_Angle(a5),d0
	add.w d0,Roto_Angle(a5)
	bge.s .ang
	add.w #ROTO_MAX_ANGLE,Roto_Angle(a5)
	bra.s modify_inc_angle
.ang
	cmp.w #ROTO_MAX_ANGLE,Roto_Angle(a5)
	blt.s modify_inc_angle
	sub.w #ROTO_MAX_ANGLE,Roto_Angle(a5)

* Modification du sens de la rotation
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
modify_inc_angle
	tst.w Roto_Angle_Counter(a5)		on va vers un autre Inc_Angle?
	bne.s .tralala

	move.w Roto_Inc_Angle(a5),d0		on est bon ?
	cmp.w Roto_Save_Inc_Angle(a5),d0
	beq.s .plus_tralala
	blt.s .inc
.dec
	subq.w #1,Roto_Inc_Angle(a5)
	bra.s modify_zoom
.inc
	addq.w #1,Roto_Inc_Angle(a5)
	bra.s modify_zoom

.plus_tralala
	move.w #ANGLE_COUNTER,Roto_Angle_Counter(a5)
	bra.s modify_zoom

.tralala
	subq.w #1,Roto_Angle_Counter(a5)
	bne.s modify_zoom
	move.w Roto_Inc_Angle(a5),Roto_Save_Inc_Angle(a5)
	neg.w Roto_Save_Inc_Angle(a5)
	subq.w #DELTA_SPEED,Roto_Save_Inc_Angle(a5)

* Modification du zoom
* ~~~~~~~~~~~~~~~~~~~~
pas_de_rotate_cochon
modify_zoom
	move.w Roto_Offset_Zoom1(a5),d0
	addq.w #INC_ZOOM1,d0
	cmp.w #ROTO_MAX_ANGLE,d0
	blt.s .ok5
	sub.w #ROTO_MAX_ANGLE,d0
.ok5	move.w d0,Roto_Offset_Zoom1(a5)

	move.w Roto_Offset_Zoom2(a5),d1
	addq.w #INC_ZOOM2,d1
	cmp.w #ROTO_MAX_ANGLE,d1
	blt.s .ok6
	sub.w #ROTO_MAX_ANGLE,d1
.ok6	move.w d1,Roto_Offset_Zoom2(a5)

	lea Table_Cosinus,a0
	move.w (a0,d0.w*2),d0
	muls.w #$200,d0
	move.w (a0,d1.w*2),d1
	muls.w #$140,d1
	add.l d1,d0
	asr.l #3,d0
	swap d0
	add.w #$18,d0
	move.w d0,Roto_Zoom(a5)

* Changement du centre
* ~~~~~~~~~~~~~~~~~~~~
modify_center
	movem.w MouseX(a5),d0-d1
	divs.w #2*(PICTURE_X/4)*BLUR_ZOOM,d0	essait de rester dans
	swap d0					l'image...
	tst.w d0
	bpl.s .ok_centrex
	add.w #2*(PICTURE_X/4)*BLUR_ZOOM,d0
.ok_centrex
	divs.w #PICTURE_Y*BLUR_ZOOM,d1
	swap d1
	tst.w d1
	bpl.s .ok_centrey
	add.w #PICTURE_Y*BLUR_ZOOM,d1
.ok_centrey
	movem.w d0/d1,MouseX(a5)
	rts





*********************************************************************************
*			Fabrication de la table de rotation			*
*   -->	a5=_Blur_DataBase							*
*********************************************************************************
Roto_Build_Table_Rotate
	move.w #(-NB_LIGNES/2),d0		B=(-COP_MOVEY/2)*Zoom
	muls.w Roto_Zoom(a5),d0

	move.w #(-NB_COLONNES/2),d1		A=(-COP_MOVEX/2)*Zoom
	muls.w Roto_Zoom(a5),d1

	move.w Roto_Angle(a5),d7		ANGLE
	lea Table_Cosinus,a1
	move.w (a1,d7.w*2),d3			Cos(ANGLE)
	lea Table_Sinus,a2
	move.w (a2,d7.w*2),d4			Sin(ANGLE)

	sub.l a0,a0
	sub.l a1,a1
	lea Roto_Table_Rotate(a5),a2
	lea Roto_Table_Centre(a5),a3

* M varie de 1-1=0 à NB_COLONNES-1
	moveq #0,d2				M
for_M
	move.w d1,d5
	muls.w d3,d5				A*Cos(ANGLE)
	move.w d0,d6
	muls.w d4,d6				B*Sin(ANGLE)
	add.l d6,d5
	asr.l #3,d5
	swap d5					X=A*Cos(ANGLE)+B*Sin(ANGLE)

	move.w d0,d6
	muls.w d3,d6				B*Cos(ANGLE)
	move.w d1,d7
	muls.w d4,d7				A*Sin(ANGLE)
	sub.l d7,d6
	asr.l #3,d6
	swap d6					Y=B*Cos(ANGLE)-A*Sin(ANGLE)

	ext.l d5
	move.w d6,d7
	muls.w #PICTURE_Y*BLUR_ZOOM,d7		Y*PIC_X
	add.l d5,d7
	add.l d7,d7				(X+Y*PIC_X)*2
	move.l d7,(a2)+

.no_more
	tst.w d2				1-1<M-1<=NB_LIGNES-1
	beq.s no_change_center
	cmp.w #NB_LIGNES-1,d2
	bgt.s no_change_center

	sub.w a0,d5				DX=X-OLD_X
	add.w d5,a0				OLD_X=X
	sub.w a1,d6				DY=Y-OLD_Y
	add.w d6,a1				OLD_Y=Y

	muls.w #PICTURE_Y*BLUR_ZOOM,d5		DX*PIC_X
	ext.l d6
	sub.l d6,d5				-DY+DX*PIC_X
	add.l d5,d5				(-DY+DX*PIC_X)*2
	move.l d5,(a3)+
.next_M
	add.w Roto_Zoom(a5),d1			Inc A

	addq.w #1,d2
	cmp.w #NB_COLONNES,d2
	bne.s for_M
	rts

no_change_center
	move.w d5,a0				UPDATE OLD_X & OLD_Y
	move.w d6,a1
.next_M
	add.w Roto_Zoom(a5),d1			Inc A

	addq.w #1,d2
	cmp.w #NB_COLONNES,d2
	bne.s for_M
	rts



*********************************************************************************
*			   Routine de Motion Blur				*
*   --> a5=_Blur_DataBase							*
*********************************************************************************
RotoZoom_Blur
	movem.l a5/a6,-(sp)

	move.l Blur_Table(a5),a0

	move.l Chunky_Picture(a5),a1
	movem.w MouseX(a5),d0-d1
	add.l #PICTURE_X/3,d0
	mulu.w #PICTURE_Y*BLUR_ZOOM,d0
	add.l d1,d0
	lea (a1,d0.l*2),a1

	move.l Blur_Log_Coplist(a5),a2
	lea COP_SKIP+4+2(a2),a2			saute init + bplcon3 + move

	move.l Blur_Phy_Coplist(a5),a3
	lea COP_SKIP+4+2(a3),a3			idem

	lea Roto_Table_Rotate(a5),a4
	lea Roto_Table_Centre(a5),a5

	moveq #NB_LIGNES-1,d7
.loop_Y
	move.l a4,a6
	moveq #3-1,d6				3 parties à remplir
.loop_Part
	moveq #32/4-1,d5			32 couleurs par parties
.loop_X
	movem.l (a6)+,d0/d1/d2/d3		lit les offsets de 4 points

* point #1
	moveq #0,d4
	move.w (a1,d0.l),d4			lit la "couleur" du point
	add.l d4,d4
	or.w (a3),d4				ancienne couleur
	addq.l #4,a3
	add.l d4,d4
	move.w (a0,d4.l),(a2)			nouvelle couleur
	addq.l #4,a2
* point #2
	moveq #0,d4
	move.w (a1,d1.l),d4			lit la "couleur" du point
	add.l d4,d4
	or.w (a3),d4				ancienne couleur
	addq.l #4,a3
	add.l d4,d4
	move.w (a0,d4.l),(a2)			nouvelle couleur
	addq.l #4,a2
* point #3
	moveq #0,d4
	move.w (a1,d2.l),d4			lit la "couleur" du point
	add.l d4,d4
	or.w (a3),d4				ancienne couleur
	addq.l #4,a3
	add.l d4,d4
	move.w (a0,d4.l),(a2)			nouvelle couleur
	addq.l #4,a2
* point #4
	moveq #0,d4
	move.w (a1,d3.l),d4			lit la "couleur" du point
	add.l d4,d4
	or.w (a3),d4				ancienne couleur
	addq.l #4,a3
	add.l d4,d4
	move.w (a0,d4.l),(a2)			nouvelle couleur
	addq.l #4,a2
.Next_X
	dbf d5,.loop_X
.Next_Part
	addq.l #4,a2				\ saute bplcon3 ou wait
	addq.l #4,a3				/
	dbf d6,.loop_Part			partie suivante
.Next_Y
	add.l (a5)+,a1				change la position du Centre
	addq.l #2*4,a2				\ saute bplcon3 + move
	addq.l #2*4,a3				/
	dbf d7,.loop_Y

	movem.l (sp)+,a5/a6
	rts







*********************************************************************************
*			Fabrication de l'image à rotozoobluré			*
*   -->	a5=_Blur_DataBase							*
*********************************************************************************
Blur_Build_Vache_Picture
	movem.l a5/a6,-(sp)

	lea Picture_space,a0
	move.l a0,Chunky_Picture(a5)

	lea Vache1_BMP,a1
	bsr Transmute_BMP

	move.l (sp),a5
	move.l Chunky_Picture(a5),a0
	add.l #1*(PICTURE_X/4)*BLUR_ZOOM*PICTURE_Y*BLUR_ZOOM*2,a0
	lea Vache2_BMP,a1
	bsr Transmute_BMP

	move.l (sp),a5
	move.l Chunky_Picture(a5),a0
	add.l #2*(PICTURE_X/4)*BLUR_ZOOM*PICTURE_Y*BLUR_ZOOM*2,a0
	lea Vache1_BMP,a1
	bsr.s Transmute_BMP

	move.l (sp),a5
	move.l Chunky_Picture(a5),a0
	add.l #3*(PICTURE_X/4)*BLUR_ZOOM*PICTURE_Y*BLUR_ZOOM*2,a0
	lea Vache2_BMP,a1
	bsr.s Transmute_BMP

	movem.l (sp)+,a5/a6
	rts


Blur_Build_Cochon_Picture
	movem.l a5/a6,-(sp)

	lea Picture_space,a0
	move.l a0,Chunky_Picture(a5)

	lea Cochon_BMP,a1
	moveq #4,d1
	bsr.s Transmute_BMP_Cochon

	move.l (sp),a5
	move.l Chunky_Picture(a5),a0
	add.l #1*(PICTURE_X/4)*BLUR_ZOOM*PICTURE_Y*BLUR_ZOOM*2,a0
	moveq #4,d1
	lea Cochon_BMP,a1
	bsr.s Transmute_BMP_Cochon

	move.l (sp),a5
	move.l Chunky_Picture(a5),a0
	add.l #2*(PICTURE_X/4)*BLUR_ZOOM*PICTURE_Y*BLUR_ZOOM*2,a0
	moveq #4,d1
	lea Cochon_BMP,a1
	bsr.s Transmute_BMP_Cochon

	move.l (sp),a5
	move.l Chunky_Picture(a5),a0
	add.l #3*(PICTURE_X/4)*BLUR_ZOOM*PICTURE_Y*BLUR_ZOOM*2,a0
	moveq #4,d1
	lea Cochon_BMP,a1
	bsr.s Transmute_BMP_Cochon

	movem.l (sp)+,a5/a6
	rts



Transmute_BMP
	moveq #PICTURE_DEPTH,d1
Transmute_BMP_Cochon
* recherche la fin
	move.w d1,d2
	mulu.w #TEXTURE_BITPLAN_SIZE,d2
	lea (a1,d2.w),a2

* recherche la taille d'une ligne de texture
	move.w d1,d2
	mulu.w #TEXTURE_BITPLAN_LINE_SIZE,d2
	move.l d2,a4

*************************************************
* OCCUPATION DES REGISTRES:			*
* d0=Compteur du nombre de textures		*
* d1=Nb de bitplan de la texture en cours	*
* a0=Ptr destination de la texture		*
* a1=Ptr source de la texture			*
* a2=Ptr table des couleurs de la texture	*
* a3=Abscisse du point en cours			*
* a4=Taille d'une ligne complète de la texture	*
*************************************************
* boucle pour convertir sur les Y
	bra.s .start_convert_y
.loop_convert_y
	move.l a0,a6
	sub.l a3,a3				commence à la position 0
	bra.s .start_convert_x
.loop_convert_x
	move.w a3,d5				recherche le bit
	lsr.w #3,d5				numero de l'octet
	move.w a3,d4
	not.w d4
	and.b #$7,d4				numero du bit

	lea (a1,d5.w),a5			pointe l'octet
	moveq #0,d2
	moveq #0,d3
	bra.s .start_read_pixel
.loop_read_pixel
	btst d4,(a5)				bit à 1 ?
	beq.s .clear_bit
.set_bit
	bset d3,d2				met le bit
.clear_bit
	lea TEXTURE_BITPLAN_LINE_SIZE(a5),a5	bitplan suivant
	addq.w #1,d3
.start_read_pixel
	cmp.w d1,d3
	bne.s .loop_read_pixel

	ror.w #PICTURE_DEPTH,d2
	move.l a6,a5

* zomme le point par 2
	move.w d2,(a5)
	move.w d2,2(a5)
	move.w d2,PICTURE_Y*BLUR_ZOOM*2(a5)
	move.w d2,PICTURE_Y*BLUR_ZOOM*2+2(a5)

	lea PICTURE_Y*BLUR_ZOOM*BLUR_ZOOM*2(a6),a6
	addq.w #1,a3
.start_convert_x
	cmp.w #TEXTURE_X,a3
	bne.s .loop_convert_x

	addq.l #2*BLUR_ZOOM,a0
	add.l a4,a1				ligne suivante
.start_convert_y
	cmp.l a1,a2				fini ?
	bne.s .loop_convert_y
	rts






*********************************************************************************
*                    Contruction de la table de blur				*
*   -->	a5=_Blur_DataBase                                                            *
*********************************************************************************
Build_Cochon_Blur_Table
	lea Cochon_PAL,a1		fabrique la table de blur du cochon
	bra.s Cochon_Branch

Build_Vache_Blur_Table
	lea Vache1_PAL,a1		fabrique la table de blur de la vache

Cochon_Branch
	lea Blur_Table_space,a0
	move.l a0,Blur_Table(a5)

* pour chaque nouvelle couleurs, on fait
* correspondre une nouvelle palette

	moveq #PICTURE_COLORS-1,d0
.loop_color
	move.w (a1)+,d4			lit la couleur suivante
	moveq #0,d1
.loop_build_red
	moveq #0,d2
.loop_build_green
	moveq #0,d3
.loop_build_blue

	move.w #NEW_PERCENT,Percent_New(a5)
	move.w #OLD_PERCENT,Percent_Old(a5)
	move.w #HOW_PERCENT,Percent_How(a5)

* on fait un mélange des couleurs 3/4 pour l'original et 1/4 pour l'ancienne

.redo_it
* traitement du rouge
	move.w d4,d5			$rgb
	and.w #$f00,d5			$0r00
	lsr.w #8,d5			$000r
	mulu.w Percent_New(a5),d5	pour l'original
	move.w d1,d7
	mulu.w Percent_Old(a5),d7	pour l'ancienne
	add.w d7,d5
	divu Percent_How(a5),d5
	lsl.w #8,d5

* traitement du vert
	move.w d4,d6			$rgb
	and.w #$f0,d6			$00g0
	lsr.w #4,d6			$000g
	mulu.w Percent_New(a5),d6
	move.w d2,d7
	mulu.w Percent_Old(a5),d7
	add.w d7,d6
	divu Percent_How(a5),d6
	lsl.w #4,d6
	or.w d6,d5

* traitement du bleu
	move.w d4,d6			$rgb
	and.w #$f,d6			$000b
	mulu.w Percent_New(a5),d6
	move.w d3,d7
	mulu.w Percent_Old(a5),d7
	add.w d7,d6
	divu Percent_How(a5),d6
	or.w d6,d5

* regarde si on a obtenu la meme couleur ancienne
* si oui, augmente le pourcentage
	moveq #0,d6
	move.w d1,d6			$00r
	lsl.w #4,d6			$0r0
	or.w d2,d6			$0rg
	lsl.w #4,d6			$rg0
	or.w d3,d6			$rgb

	cmp.w d5,d6
	bne.s .ok

	addq.w #1,Percent_New(a5)
	subq.w #1,Percent_Old(a5)

	move.w Percent_New(a5),d7
	cmp.w Percent_How(a5),d7
	ble.s .redo_it
	move.w d4,d5

* stockage de la couleur blurée
.ok
	move.w d5,(a0)+	

.next_blue
	addq.w #1,d3
	cmp.w #$10,d3
	bne .loop_build_blue
.next_green
	addq.w #1,d2
	cmp.w #$10,d2
	bne .loop_build_green
.next_red
	addq.w #1,d1
	cmp.w #$10,d1
	bne .loop_build_red
.next_color
	dbf d0,.loop_color
	rts






*********************************************************************************
*                         Toutes les datas du programme                         *
*********************************************************************************
	ROUND
	section mes_daaaatas,bss
	rsset -BLUR_DATA_OFFSET
Blur_DataBase_Struct	rs.b 0
Blur_Compteur		rs.w 1
Roto_Table_Rotate	rs.l NB_COLONNES
Roto_Table_Centre	rs.l NB_LIGNES-1
Roto_CentreX		rs.w 1
Roto_CentreY		rs.w 1
Roto_Angle		rs.w 1
Roto_Angle_Counter	rs.w 1
Roto_Inc_X		rs.w 1
Roto_Inc_Y		rs.w 1
Roto_Inc_Angle		rs.w 1
Roto_Save_Inc_Angle	rs.w 1
Roto_Zoom		rs.w 1
Roto_Offset_Zoom1	rs.w 1
Roto_Offset_Zoom2	rs.w 1

Blur_Log_Coplist	rs.l 1
Blur_Phy_Coplist	rs.l 1
Chunky_Picture		rs.l 1
Blur_Table		rs.l 1
Alpha			rs.w 1
Teta			rs.w 1
MouseX			rs.w 1
MouseY			rs.w 1
Percent_New		rs.w 1
Percent_Old		rs.w 1
Percent_How		rs.w 1
Quoi			rs.w 1
LastX			rs.b 1
LastY			rs.b 1
Blur_Flip_Flag		rs.b 1
Blur_End		rs.b 1
Blur_DataBase_SIZEOF=__RS-Blur_DataBase_Struct

_Blur_DataBase=*+BLUR_DATA_OFFSET
	ds.b Blur_DataBase_SIZEOF

	even
Blur_Table_space
	ds.w PICTURE_COLORS*4096

Picture_space
	ds.w PICTURE_X*BLUR_ZOOM*PICTURE_Y*BLUR_ZOOM


	ROUND

***************
* end of file *
***************
