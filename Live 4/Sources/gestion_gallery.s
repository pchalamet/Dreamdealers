******************************************************************************
********************************* LA GALLERY *********************************
******************************************************************************
Gallery
	lea Gallery_BarText,a0
	bsr Dup_Text_Barre

	move.l #COUNT_GALLERY,d0
	move.w d0,NbPages-data_base(a5)
	clr.w Barre_Result-data_base(a5)

	lea Text_Barre+NUMBER_END(pc),a0	écrit le nombre de page
	bsr Write_Number

Display_Gallery
	sf Flip_Flag-data_base(a5)
	st Fade_Flag-data_base(a5)
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)
	bsr Clear_Middle_Screen

	lea Gallery_List,a0
	move.w Barre_Result(pc),d0
	mulu.w #grs_SIZEOF,d0
	lea (a0,d0.l),a0			ptr sur la structure gallery
	move.l a0,-(sp)				sauve le ptr

	lea grs_Name(a0),a0			charge l'image avec powerpacker
	bsr Load_Powerpacker
	move.l (sp)+,a0

	tst.l d0				au fait.. ya eut une erreur ?
	bne gallery_load_ok

**** ca a cafouillé on dirait!!
	bsr BackGround_Middle_Screen
	lea Gallery_Msg,a0
	moveq #2,d0
	bsr Display_Text_Menu

	WAIT_FADE_OUT
	st Flip_Flag-data_base(a5)		affiche le menu complet
	sf Fade_Flag-data_base(a5)		fade_in demandé !!
	WAIT_FADE_IN

	bsr Insert_Disk2

	bra Display_Gallery

******** tout est ok
gallery_load_ok
	move.w grs_BltSize(a0),d0
	and.w #%111111,d0
	sub.w #SCREEN_WIDTH/2,d0
	neg.w d0
	lsr.w #1,d0				CoordX

	move.w grs_BltSize(a0),d2
	lsr.w #6,d2				vire SizeX, SizeY*4, divise par 2
	lsr.w #3,d2
	sub.w #(PART3-PART2)/2,d2
	neg.w d2				CoordY

	move.l log_screen(pc),a1
	ext.l d0
	add.w d0,d0				offset X = WORD
	mulu.w #SCREEN_WIDTH*SCREEN_DEPTH,d2
	add.l d2,d0			
	lea (a1,d0.l),a1			adresse destination

	ALLOC_BLITTER
	move.l File_Adr(pc),d0
	add.l #SAFETY_MARGIN+pp_Datas,d0
	move.l d0,bltapt(a6)			copie toute bete avec
	move.l a1,bltdpt(a6)			A=D   sur la limite d'un mot !
	clr.w bltamod(a6)
	move.w grs_Modulo(a0),bltdmod(a6)
	moveq #-1,d0
	move.l d0,bltafwm(a6)
	move.l #$09f00000,bltcon0(a6)
	move.w grs_BltSize(a0),bltsize(a6)
	FREE_BLITTER
	
	bsr Render_Barre

	move.l File_Adr(pc),a0			installe les couleurs
	lea SAFETY_MARGIN+2(a0),a0
Gallery_branch
	WAIT_FADE_OUT
	lea Temp_Colors(pc),a1
	move.l a1,ColorMap_hook-data_base(a5)
	move.w #BACKGROUND_COLOR,(a1)+
	moveq #NB_COLORS-1-1,d0
.dup
	move.w (a0)+,(a1)+
	dbf d0,.dup

	lea Text_Barre+NUMBER_POS(pc),a0	écrit le numero de la page
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre			affiche la barre du haut
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre

	st Flip_Flag-data_base(a5)
	sf Fade_Flag-data_base(a5)
	WAIT_FADE_IN

Gallery_Events
	WAIT_VBL
	bsr gestion_shortcuts
	bsr gestion_gadgets

	tst.b Go_Right_Flag-data_base(a5)
	beq.s .no_right
	clr.b Go_Right_Flag-data_base(a5)
	move.w Barre_Result(pc),d0
	cmp.w #COUNT_GALLERY-1,d0
	beq.s Gallery_Events
	addq.w #1,Barre_Result-data_base(a5)
	bra Display_Gallery
	
.no_right
	tst.b Go_Left_Flag-data_base(a5)
	beq.s .no_left
	clr.b Go_Left_Flag-data_base(a5)
	tst.w Barre_Result-data_base(a5)
	beq.s Gallery_Events
	subq.w #1,Barre_Result-data_base(a5)
	bra Display_Gallery

.no_left
	tst.b Barre_Flag-data_base(a5)
	beq.s Gallery_Events
	clr.b Barre_Flag-data_base(a5)
	bra Display_Gallery
