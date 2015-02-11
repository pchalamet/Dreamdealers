Clear_Text_Barre
	move.l a0,-(sp)
	ALLOC_BLITTER
	WAIT_VBL
	move.l Board_Top_Back(pc),a0
	lea SCREEN_WIDTH*SCREEN_DEPTH*6(a0),a0
	move.l a0,bltapt(a6)
	move.l #Board_Top+SCREEN_WIDTH*SCREEN_DEPTH*6,bltdpt(a6)
	move.l #-1,bltafwm(a6)
	clr.l bltamod(a6)
	move.l #$09f00000,bltcon0(a6)
	move.w #(8*SCREEN_DEPTH<<6)|(SCREEN_WIDTH/2),bltsize(a6)
	FREE_BLITTER
	move.l (sp)+,a0
	rts

*****************************************************************************
***************** EFFACAGE DE L'ECRAN LOGIQUE MIDDLE SCREEN *****************
*****************************************************************************
Clear_Middle_Screen
	ALLOC_BLITTER
	move.l log_screen(pc),bltdpt(a6)
	clr.w bltdmod(a6)
	move.l #$01000000,bltcon0(a6)
	move.w #((PART3-PART2)*SCREEN_DEPTH<<6)!(SCREEN_WIDTH/2),bltsize(a6)
	FREE_BLITTER
	rts



*****************************************************************************
************ REMPLISSAGE DE L'ECRAN LOGIQUE AVEC LE BACKGROUND **************
*****************************************************************************
BackGround_Middle_Screen
	ALLOC_BLITTER
	move.l #BackGround,bltapt(a6)
	move.l log_screen(pc),bltdpt(a6)
	move.l #-1,bltafwm(a6)
	clr.l bltamod(a6)
	move.l #$09f00000,bltcon0(a6)
	move.w #((PART3-PART2)*SCREEN_DEPTH<<6)|(SCREEN_WIDTH/2),bltsize(a6)
	FREE_BLITTER
	rts



*****************************************************************************
********************** MET DES PTRS VIDEOS DANS LA COPLIST ******************
**********************   En entrée: D0=ecran  A0=Coplist   ******************
**********************              D1=SCREEN_WIDTH        ******************
**********************              D2=SCREEN_DEPTH-1      ******************
*****************************************************************************
Init_BplPtrs
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	swap d0
	add.l d1,d0
	addq.l #8,a0
	dbf d2,Init_BplPtrs
	rts


*****************************************************************************
*********************** INSTALLATION D'UN NOUVEAU DZIGN *********************
*****************************************************************************
Init_DZign
	move.w DZign_Number(pc),d0		recherche un ptr sur la
	mulu.w #dz_SIZEOF,d0			structure DZign
	lea DZign_List(pc),a4
	lea (a4,d0.l),a4

	move.l (a4)+,d0				recopie le board dans l'écran
	move.l d0,Board_Top_Back-data_base(a5)
	ALLOC_BLITTER
	WAIT_VBL
	move.l d0,bltapt(a6)
	move.l #Board_Top,bltdpt(a6)
	move.l #-1,bltafwm(a6)
	clr.l bltamod(a6)
	move.l #$09f00000,bltcon0(a6)
	move.w #((PART2-PART1)*SCREEN_DEPTH<<6)|(SCREEN_WIDTH/2),bltsize(a6)
	FREE_BLITTER

	move.l (a4)+,d0				installe le bas
	move.l d0,Board_Bottom-data_base(a5)
	lea Bottom_Ptrs+2,a0
	moveq #SCREEN_WIDTH,d1
	moveq #SCREEN_DEPTH-1,d2
	bsr Init_BplPtrs

	lea Sprites_Ptrs+2,a0
	move.l (a4)+,d0				init le pointeur souris
	move.l d0,Mouse_Sprite-data_base(a5)
	move.w d0,4(a0)
	move.w d0,4+8(a0)
	swap d0
	move.w d0,(a0)
	move.w d0,8(a0)
	lea 8*2(a0),a0
	move.l (a4)+,d0				init bordure gauche spr0
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	addq.l #8,a0
	move.l (a4)+,d0				init bordure gauche spr1
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	addq.l #8,a0
	move.l (a4)+,d0				init bordure droite spr2
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	addq.l #8,a0
	move.l (a4)+,d0				init bordure droite spr3
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)

	lea Top_Colors+2,a0			installe les couleurs
	lea Bottom_Colors+2,a1			des écrans
	moveq #NB_COLORS-1,d0
.put_colors0
	move.w (a4),(a0)
	move.w (a4)+,(a1)
	addq.l #4,a0
	addq.l #4,a1
	dbf d0,.put_colors0

	lea Sprites_Colors+2,a0			installe les couleurs
	moveq #16-1,d0				des sprites
.put_colors1
	move.w (a4)+,(a0)
	addq.l #4,a0
	dbf d0,.put_colors1

	move.w bs_CoordY+Bob_volume_tile(pc),d0
	sub.w #225-PART3,d0
	bsr Render_Volume			retrace la tile du volume
	bsr Render_Barre			retrace la barre

	lea Text_Barre(pc),a0			reaffiche le texte de la barre
	bra Display_Text_Barre


