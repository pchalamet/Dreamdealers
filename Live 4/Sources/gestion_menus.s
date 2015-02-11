*****************************************************************************
******************************* GESTION DES MENUS ***************************
*****************************************************************************
gestion_menus
	bsr Clear_HighLight			vire le HighLight !!

	movem.w MouseX(pc),d0-d1		position X et Y
	lsr.w #1,d1
	cmp.w #PART2+4,d1			fait gaffe kon sorte
	ble menu_exit				pas de l'écran !!!
	cmp.w #PART3-4,d1
	bge menu_exit

	move.l Menu_hook(pc),a0
	lea ms_MenuPos(a0),a0			saute ms_ExtraRender & ms_Text
	move.w (a0)+,d2
	sub.w d2,d1				position du menu
	move.l phy_screen(pc),a1

	sub.w #PART2+4,d1
	divu #9,d1				recherche le # de case / Y
	cmp.w #SCREEN_X/2,d0
	blt.s mouse_on_LMenu
mouse_on_RMenu
	lea ms_DefRMenu-ms_DefLMenu(a0),a0	menu de droite
	lea SCREEN_WIDTH/2(a1),a1		pointe l'écran de droite
mouse_on_LMenu
	move.l (a0)+,d0				Flags existance des menus
	btst d1,d0				il existe ce menu ?
	beq.s menu_exit

	tst.b Left_Mousebutton-data_base(a5)	au fait , il a clické le user ?
	bne.s check_menu_click

	mulu #SCREEN_WIDTH*SCREEN_DEPTH*9,d1
	add.w #3,d2				recalcul la position d'affichage
	muls #SCREEN_WIDTH*SCREEN_DEPTH,d2	du menu
	add.l d2,d1
	add.l #SCREEN_WIDTH*3+2,d1		ptr 4ème bpl pour le menu
	lea (a1,d1.l),a0
	move.l a0,Menu_Draw-data_base(a5)

	ALLOC_BLITTER
	move.l a0,bltdpt(a6)
	move.w #SCREEN_WIDTH*3+SCREEN_WIDTH/2+4,bltdmod(a6)
	move.l #$00ffff00,bltafwm(a6)		bltafwm & bltallwm
	move.w #$ffff,bltadat(a6)
	move.l #$01f00000,bltcon0(a6)		bltcon0 & bltcon1  A=D
	move.w #(10<<6)!(SCREEN_WIDTH/4-2),bltsize(a6)
	FREE_BLITTER
menu_exit
	rts

check_menu_click
	move.l (a0)+,d0				type des menus
	btst d1,d0
	bne.s render_NewMenu			sub menu ?

	add.w d1,d1				table de LONG
	add.w d1,d1
	move.l (a0,d1.w),a0			ptr associé au menu

	move.l Menu_SP(pc),a1
	move.l NbPages(pc),(a1)+
	move.l Menu_hook(pc),(a1)+
	move.l a1,Menu_SP-data_base(a5)
	clr.l Menu_hook-data_base(a5)

	jsr (a0)
	bra.s Display_NewMenu

render_NewMenu
	move.l Menu_SP(pc),a1			sauve le menu actuel dans la
	move.l NbPages(pc),(a1)+		pile de menu
	move.l Menu_hook(pc),(a1)+
	move.l a1,Menu_SP-data_base(a5)

	add.w d1,d1
	add.w d1,d1
	move.l (a0,d1.w),Menu_hook-data_base(a5)	nouveau menu
	bsr Global_Menus

Display_NewMenu
	sf Flip_Flag-data_base(a5)		pas de flip_screen
	clr.l Menu_Draw-data_base(a5)		vire le HighLight
	st Fade_Flag-data_base(a5)		fade_out demandé !!

	sf Barre_Flag-data_base(a5)
	bsr Render_Barre

	move.l Menu_hook(pc),a0
	move.l ms_ExtraRender(a0),d0		ya une extra render ?
	beq.s .no_extra_render
	move.l d0,a1				oui => alors on l'éxécute
	jsr (a1)
	bra.s .extra_render_done		en sortie d0=ColorMap
.no_extra_render
	bsr BackGround_Middle_Screen		installe le background

	moveq #2,d0				non => affichage normal
	move.l ms_Text(a0),a0			affiche le text du menu
	bsr Display_Text_Menu
	move.l #BackGround_Colors,d0
.extra_render_done
	move.l d0,-(sp)

	move.l Menu_hook(pc),a0			affiche du texte dans la
	move.l ms_BarText(a0),d0		barre si ya lieu d'être
	beq.s .no_bartext
	bsr Clear_Text_Barre
	move.l d0,a0
	bsr Display_Text_Barre

.no_bartext
	WAIT_FADE_OUT
	move.l (sp)+,ColorMap_hook-data_base(a5)

	st Flip_Flag-data_base(a5)		affiche le menu complet
	sf Fade_Flag-data_base(a5)		fade_in demandé !!
	bsr wait_buttons_up
	WAIT_FADE_IN
	rts

Clear_HighLight
	move.l Menu_Draw(pc),d0			efface la highlight box
	beq.s .no_clear				précédente si yen a une...
	ALLOC_BLITTER
	move.l d0,bltdpt(a6)
	move.w #SCREEN_WIDTH*3+SCREEN_WIDTH/2+4,bltdmod(a6)
	move.l #$01000000,bltcon0(a6)
	move.w #(10<<6)!(SCREEN_WIDTH/4-2),bltsize(a6)
	clr.l Menu_Draw-data_base(a5)
	FREE_BLITTER
.no_clear
	rts

Menu_Draw
	dc.l 0

