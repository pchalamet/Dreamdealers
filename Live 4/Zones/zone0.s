			****************
			* menu de live *
			****************
HitBox_List0
	START_HITBOX
	DEF_HITBOX 0,0,SCREEN_X,SCREEN_Y,RIGHT_MB,IMMEDIATE,menu_return
	DEF_HITBOX 22,219,594,4,LEFT_MB,IMMEDIATE,click_barre
	DEF_HITBOX 62,227,24,14,LEFT_MB,IMMEDIATE,dzign_selector
	DEF_HITBOX 170,227,24,14,LEFT_MB,IMMEDIATE,change_HP
	DEF_HITBOX 207,226,8,21,LEFT_MB,IMMEDIATE,set_global_volume
	DEF_HITBOX 226,227,35,14,LEFT_MB,IMMEDIATE,select_piano
	DEF_HITBOX 289,227,35,14,LEFT_MB,IMMEDIATE,goto_menu
	DEF_HITBOX 434,227,35,14,LEFT_MB,IMMEDIATE,goto_help
	DEF_HITBOX 512,227,24,14,LEFT_MB,IMMEDIATE,go_left
	DEF_HITBOX 564,227,24,14,LEFT_MB,IMMEDIATE,go_right
	DEF_HITBOX 614,6,10,6,LEFT_MB,IMMEDIATE,goto_system
	END_HITBOX

ShortCut_List0
	START_SHORTCUT
	DEF_SHORTCUT $41,IMMEDIATE,menu_return
	DEF_SHORTCUT $22,IMMEDIATE,dzign_selector
	DEF_SHORTCUT $37,IMMEDIATE,goto_menu
	DEF_SHORTCUT $21,IMMEDIATE,change_HP
	DEF_SHORTCUT $4c,IMMEDIATE,set_global_volume_plus
	DEF_SHORTCUT $4d,IMMEDIATE,set_global_volume_minus
	DEF_SHORTCUT $28,IMMEDIATE,select_piano
	DEF_SHORTCUT $32,IMMEDIATE,exit_live
	DEF_SHORTCUT $4f,IMMEDIATE,go_left
	DEF_SHORTCUT $4e,IMMEDIATE,go_right
	DEF_SHORTCUT $5f,IMMEDIATE,goto_help
	DEF_SHORTCUT $25,IMMEDIATE,goto_help
	DEF_SHORTCUT $45,IMMEDIATE,exit_live
	DEF_SHORTCUT $11,IMMEDIATE,goto_system
	END_SHORTCUT

ShortCut_List1
	START_SHORTCUT
	DEF_SHORTCUT $4f,IMMEDIATE,sc_mouse_left
	DEF_SHORTCUT $4e,IMMEDIATE,sc_mouse_right
	DEF_SHORTCUT $4c,IMMEDIATE,sc_mouse_up
	DEF_SHORTCUT $4d,IMMEDIATE,sc_mouse_down
	DEF_SHORTCUT $64,IMMEDIATE,sc_mouse_click_left
	END_SHORTCUT



* Changement du DZIGN !!
* ~~~~~~~~~~~~~~~~~~~~~~
dzign_selector
	lea Bob_dzign_down(pc),a0
	move.l #Packed_dzign_down0-Bob_dzign_down,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok0
	move.l #Packed_dzign_down1-Bob_dzign_down,bs_PackedData(a0)
.ok0	move.l Board_Bottom(pc),a1
	bsr put_gadget
	bsr wait_gadget_up
	lea Bob_dzign_up(pc),a0
	move.l #Packed_dzign_up0-Bob_dzign_up,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok1
	move.l #Packed_dzign_up1-Bob_dzign_up,bs_PackedData(a0)
.ok1	move.l Board_Bottom(pc),a1
	bsr put_gadget

	moveq #0,d0
	move.w DZign_Number(pc),d0
	addq.w #1,d0
	divu.w #NB_DZIGN,d0
	swap d0
	move.w d0,DZign_Number-data_base(a5)
	bra Init_DZign

Bob_dzign_down
	DEF_GADGET 62,227-PART3,24,14,Packed_dzign_down0
Packed_dzign_down0
	incbin "Dzign0_Gad_DZign_down.PAK"
Packed_dzign_down1
	incbin "Dzign1_Gad_DZign_down.PAK"
Bob_dzign_up
	DEF_GADGET 62,227-PART3,24,14,Packed_dzign_up0
Packed_dzign_up0
	incbin "Dzign0_Gad_DZign_up.PAK"
Packed_dzign_up1
	incbin "Dzign1_Gad_DZign_up.PAK"



* Retour au menu précédent
* ~~~~~~~~~~~~~~~~~~~~~~~~
menu_return
	move.l Menu_SP(pc),a0			SP des menus
	move.l -(a0),d0				adresse menu précédent
	beq.s .no_menu_return			c'est NULL ?
	move.l -(a0),NbPages-data_base(a5)	NbPages & Barre_Result
	move.l d0,Menu_hook-data_base(a5)
	move.l a0,Menu_SP-data_base(a5)		on est là maintenant
* bouffe l'adresse de retour pour revenir directement a la routine d'avant
	addq.l #8,sp
.no_menu_return
	bra wait_gadget_up
;;	rts					retombe sur Display_NewMenu



* Sortie de Live
* ~~~~~~~~~~~~~~
exit_live
	tst.b Exit_Flag-data_base(a5)
	bne.s .exit
	move.b #10,Exit_Flag-data_base(a5)
	rts
.exit
LIVE_FAIL_LOGO
	bsr NEv_stop
LIVE_FAIL_INPUT_HANDLER
	lea data_base(pc),a5
	move.l _VillageBase(pc),d0		ya une picasso ?
	beq.s .no_picasso
	tst.b VillageFlag-data_base(a5)		c'était koi le typez d'écran avant ?
	beq.s .no_picasso
	CALL d0,SetPicassoDisplay
	move.w $0180,custom_base+dmacon
.no_picasso
	move.l Live_Task(pc),a0			remet ca...
	move.l old_WindowPtr(pc),pr_WindowPtr(a0)

	lea VblIntStruct(pc),a1			vire la vbl system
	moveq #INTB_VERTB,d0
	CALL _ExecBase(pc),RemIntServer

	jsr mt_end
	jsr ResetCIAInt
	lea data_base(pc),a5
	lea custom_base,a6

	bsr Free_Module
	bsr Free_File

	lea Live_Requester(pc),a0		PurgeFiles()
	move.l _ReqBase(pc),a6
	jsr -114(a6)

	move.l _ExecBase(pc),a6			ferme la village.library si présente
	move.l _VillageBase(pc),d0
	beq.s .no_village
	move.l d0,a1
	CALL CloseLibrary
.no_village
	move.l _PowerpackerBase(pc),a1		ferme la powerpacker.library
	CALL CloseLibrary
LIVE_FAIL_POWERPACKER
	move.l _IntuitionBase(pc),a1		ferme l'intuition.library
	CALL CloseLibrary
LIVE_FAIL_INTUITION
	move.l _ReqBase(pc),a1			ferme la req.library
	CALL CloseLibrary
LIVE_FAIL_REQ
	move.l _GfxBase(pc),a1			remet la coplist system
	move.l $26(a1),custom_base+cop1lc	et ferme la graphics
	clr.w custom_base+copjmp1		$26=gb_copinit
	CALL CloseLibrary
LIVE_FAIL_GFX	
	move.l _DosBase(pc),a1			ferme la dos
	CALL CloseLibrary
LIVE_FAIL_DOS
	move.l save_SP(pc),sp			remet la pile
	rts



* Le user veut jouer avec le multitache...
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
goto_system
	lea Bob_WB_down(pc),a0
	move.l #Packed_WB_down0-Bob_WB_down,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok0
	move.l #Packed_WB_down1-Bob_WB_down,bs_PackedData(a0)
.ok0	lea Board_Top,a1
	bsr put_gadget

	bsr wait_gadget_up

	lea Bob_WB_up(pc),a0
	move.l #Packed_WB_up0-Bob_WB_up,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok1
	move.l #Packed_WB_up1-Bob_WB_up,bs_PackedData(a0)
.ok1	lea Board_Top,a1
	bsr put_gadget

	move.l _VillageBase(pc),d0
	beq.s .no_picasso1
	tst.b VillageFlag-data_base(a5)
	beq.s .no_picasso1
	CALL d0,SetPicassoDisplay
	move.w #$0180,custom_base+dmacon
.no_picasso1

	move.l _GfxBase(pc),a0
	move.l $26(a0),custom_base+cop1lc
	clr.w copjmp1(a6)

	bsr NEv_stop

	move.l Live_Task(pc),a0			remet les requesters
	move.l old_WindowPtr(pc),pr_WindowPtr(a0)

	lea Live_request_text(pc),a1
	lea Live_right_text(pc),a3
	moveq #0,d0
	moveq #0,d1
	move.l d0,a2				pas de gadget à gauche
	move.l d0,a0				pas de fenetre utilisateur
	move.w #230,d2
	moveq #50,d3
	CALL _IntuitionBase(pc),AutoRequest	et hop! un bo requester !

	move.l Live_Task(pc),a0			vire les requesters
	move.l pr_WindowPtr(a0),old_WindowPtr-data_base(a5)
	moveq #-1,d0
	move.l d0,pr_WindowPtr(a0)

	bsr NEv_start

	move.l _VillageBase(pc),d0
	beq.s .no_picasso2
	move.l d0,a6
	btst #4,$22(a6)
	seq VillageFlag-data_base(a5)
	CALL SetAmigaDisplay
	move.w #$8180,custom_base+dmacon
.no_picasso2

	lea custom_base,a6
	move.l #Live_Coplist,cop1lc(a6)
	clr.w copjmp1(a6)
	rts

Bob_WB_down
	DEF_GADGET 616,7,6,4,Packed_WB_down0
Packed_WB_down0
	incbin "Dzign0_WB_down.PAK"
Packed_WB_down1
	incbin "Dzign1_WB_down.PAK"
Bob_WB_up
	DEF_GADGET 616,7,6,4,Packed_WB_up0
Packed_WB_up0
	incbin "Dzign0_WB_up.PAK"
Packed_WB_up1
	incbin "Dzign1_WB_up.PAK"




* Le user a cliker sur la barre
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
click_barre
	move.w MouseX(pc),d0			recherche le # du message
	sub.w #22,d0
	mulu NbPages(pc),d0
	divu #594,d0
	cmp.w Barre_Result(pc),d0		euh.. ca a bougé ?
	beq click_barre_rts
	st Barre_Flag-data_base(a5)		la barre a bougée !!!
	move.w d0,Barre_Result-data_base(a5)

Render_Barre
	ALLOC_BLITTER					efface la barre complète
	move.l #BarreBack0,bltapt(a6)			source
	tst.w DZign_Number-data_base(a5)
	beq.s .ok0
	move.l #BarreBack1,bltapt(a6)
.ok0	move.l Board_Bottom(pc),a0
	lea (219-PART3)*SCREEN_WIDTH*SCREEN_DEPTH(a0),a0
	move.l a0,bltdpt(a6)				destination
	clr.l bltamod(a6)				bltamod & bltdmod
	move.l #$09f00000,bltcon0(a6)			bltcon0 & bltcon1
	moveq #-1,d0
	move.l d0,bltafwm(a6)				bltafwm & bltalwm
	move.w #((SCREEN_DEPTH*2)<<6)|(SCREEN_WIDTH/2),bltsize(a6)
	FREE_BLITTER

	move.w Barre_Result(pc),d0
	mulu #594,d0				calcule la VRAI position
	divu NbPages(pc),d0			d'affichage de la barre
	add.w #22,d0
	
	move.l #596,d1				calcul la largeur de la
	divu NbPages(pc),d1			barre
	bne.s .trou_duc
	moveq #1,d1
.trou_duc
; retracage de la barre
	move.w d0,d2				recherche DESTINATION
	lsr.w #4,d2
	add.w d2,d2
	lea (a0,d2.w),a1

	moveq #0,d2				calcule du décalage SOURCE A
	move.w d0,d2
	and.w #$f,d2

	move.w d1,d3				calcule de BLTSIZE
	add.w d2,d3
	add.w #15,d3
	lsr.w #4,d3
	move.w d3,d4
	or.w #(2*SCREEN_DEPTH)<<6,d3

	sub.w #SCREEN_WIDTH/2,d4		calcule des modulos
	neg.w d4
	add.w d4,d4

	move.w d2,d5				recherche les masks pour A
	add.w d5,d5
	move.w BarreMaskL(pc,d5.w),d5
	swap d5
	move.w d1,d5
	add.w d2,d5
	and.w #$f,d5
	add.w d5,d5
	move.w BarreMaskR(pc,d5.w),d5
	bra.s picnidouille

BarreMaskL
	dc.w $ffff,$7fff,$3fff,$1fff
	dc.w $0fff,$07ff,$03ff,$01ff
	dc.w $00ff,$007f,$003f,$001f
	dc.w $000f,$0007,$0003,$0001

BarreMaskR
	dc.w $ffff,$8000,$c000,$e000
	dc.w $f000,$f800,$fc00,$fe00
	dc.w $ff00,$ff80,$ffc0,$ffe0
	dc.w $fff0,$fff8,$fffc,$fffe

picnidouille
	ALLOC_BLITTER
	move.l #BarreMask,bltapt(a6)		BARRE_MASK
	move.l #Barre0,bltbpt(a6)		BARRE
	tst.w DZign_Number-data_base(a5)
	beq.s .ok1
	move.l #Barre1,bltbpt(a6)
.ok1	move.l a1,bltcpt(a6)			BACKGROUND
	move.l a1,bltdpt(a6)			DESTINATION
	move.w d4,bltamod(a6)
	move.w d4,bltbmod(a6)
	move.w d4,bltcmod(a6)
	move.w d4,bltdmod(a6)
	move.l #$0fca0000,bltcon0(a6)		(A and B) or (a and C)=D
	move.l d5,bltafwm(a6)
	move.w d3,bltsize(a6)
	FREE_BLITTER

Barre_Wait
	move.w d0,d2
	lsr.w #3,d2
	lea (a0,d2.w),a1			pointe le 1er octet
	move.w d0,d2
	and.w #$7,d2
	not.w d2

	bset d2,(a1)						couleur 15
	bset d2,SCREEN_WIDTH(a1)
	bset d2,SCREEN_WIDTH*2(a1)
	bset d2,SCREEN_WIDTH*3(a1)
click_barre_rts
	rts



* Changement de l'état du Haut Parleur
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
change_HP
	move.l Board_Bottom(pc),d0
	beq.s .start_error
	move.l d0,a1

	move.l Module_Adr(pc),d0
	beq .zik_off

	eor.b #$ff,HP_State-data_base(a5)
	bne.s .zik_off
.zik_on
	lea Bob_HP_up(pc),a0
	move.l #Packed_HP_up0-Bob_HP_up,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok0
	move.l #Packed_HP_up1-Bob_HP_up,bs_PackedData(a0)
.ok0	bsr put_gadget
	st mt_Enable
	rts
.zik_off
	lea Bob_HP_down(pc),a0
	move.l #Packed_HP_down0-Bob_HP_down,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok1
	move.l #Packed_HP_down1-Bob_HP_down,bs_PackedData(a0)
.ok1	bsr put_gadget
	IFNE ZIK
	clr.w mt_PatternPos
	jsr mt_end
	ENDC
	bsr wait_gadget_up
.start_error
	rts	

Bob_HP_down
	DEF_GADGET 170,227-PART3,24,14,Packed_HP_down0
Packed_HP_down0
	incbin "Dzign0_Gad_HP_down.PAK"
Packed_HP_down1
	incbin "Dzign1_Gad_HP_down.PAK"
Bob_HP_up
	DEF_GADGET 170,227-PART3,24,14,Packed_HP_up0
Packed_HP_up0
	incbin "Dzign0_Gad_HP_up.PAK"
Packed_HP_up1
	incbin "Dzign1_Gad_HP_up.PAK"



* Changement du volume de la replay
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set_global_volume_plus
	move.w Bob_volume_tile+bs_CoordY(pc),d0
	sub.w #225-PART3+1,d0
	bge.s Render_Volume
	rts

set_global_volume_minus
	move.w Bob_volume_tile+bs_CoordY(pc),d0
	sub.w #225-PART3-1,d0
	cmp.w #15,d0
	ble.s Render_Volume
	rts

set_global_volume
	move.w MouseY(pc),d0			regarde la valeur du déplacement
	lsr.w #1,d0
	sub.w #225+2,d0
	bge.s .ok1
	moveq #0,d0
	bra.s .ok2
.ok1
	cmp.w #15,d0
	ble.s .ok2
	moveq #15,d0
.ok2
Render_Volume
	move.w d0,d1
	add.w #225-PART3,d1
	lea Bob_volume_tile(pc),a0
	move.l #Packed_volume_tile0-Bob_volume_tile,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok3
	move.l #Packed_volume_tile1-Bob_volume_tile,bs_PackedData(a0)
.ok3	move.w d1,bs_CoordY(a0)
	add.w d0,d0
	IFNE ZIK
	move.w volume_table(pc,d0.w),vol_pos_to_reach-data_base(a5)
	ENDC

	lea Bob_volume_back(pc),a0
	move.l #Packed_volume_back0-Bob_volume_back,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok4
	move.l #Packed_volume_back1-Bob_volume_back,bs_PackedData(a0)
.ok4	move.l Board_Bottom(pc),a1		efface ce kia derriere
	bsr put_gadget
	lea Bob_volume_tile(pc),a0
	move.l Board_Bottom(pc),a1			et remet la tile à sa bonne
	bsr put_gadget				place
set_global_volume_exit
	rts

volume_table
	dc.w 128,120,112,104,94,86,78,70,62,56,48,40,32,24,16,8
Bob_volume_back
	DEF_GADGET 208,225-PART3,6,21,Packed_volume_back0
Packed_volume_back0
	incbin "Dzign0_Gad_VolumeBack.PAK"
Packed_volume_back1
	incbin "Dzign1_Gad_VolumeBack.PAK"
Bob_volume_tile
	DEF_GADGET 208,225-PART3,6,6,Packed_volume_tile0
Packed_volume_tile0
	incbin "Dzign0_Gad_VolumeTile.PAK"
Packed_volume_tile1
	incbin "Dzign1_Gad_VolumeTile.PAK"



* Fait choisir un module à l'utilisateur
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select_piano
	lea Bob_Piano_down(pc),a0
	move.l #Packed_Piano_down0-Bob_Piano_down,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok0
	move.l #Packed_Piano_down1-Bob_Piano_down,bs_PackedData(a0)
.ok0	move.l Board_Bottom(pc),a1
	bsr put_gadget

	bsr wait_gadget_up

	lea Bob_Piano_up(pc),a0
	move.l #Packed_Piano_up0-Bob_Piano_up,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok1
	move.l #Packed_Piano_up1-Bob_Piano_up,bs_PackedData(a0)
.ok1	move.l Board_Bottom(pc),a1
	bsr put_gadget
	bra Select_Module	

Bob_Piano_down
	DEF_GADGET 226,227-PART3,35,14,Packed_Piano_down0
Packed_Piano_down0
	incbin "Dzign0_Gad_Piano_down.PAK"
Packed_Piano_down1
	incbin "Dzign1_Gad_Piano_down.PAK"
Bob_Piano_up
	DEF_GADGET 226,227-PART3,35,14,Packed_Piano_up0
Packed_Piano_up0
	incbin "Dzign0_Gad_Piano_up.PAK"
Packed_Piano_up1
	incbin "Dzign1_Gad_Piano_up.PAK"



* On reviens au menu principal
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
goto_menu
	lea Bob_Menu_down(pc),a0
	move.l #Packed_Menu_down0-Bob_Menu_down,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok0
	move.l #Packed_Menu_down1-Bob_Menu_down,bs_PackedData(a0)
.ok0	move.l Board_Bottom(pc),a1
	bsr put_gadget

	bsr wait_gadget_up

	lea Bob_Menu_up(pc),a0
	move.l #Packed_Menu_up0-Bob_Menu_up,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok1
	move.l #Packed_Menu_up1-Bob_Menu_up,bs_PackedData(a0)
.ok1	move.l Board_Bottom(pc),a1
	bsr put_gadget

	move.l Menu_SP(pc),d0
	cmp.l #Menu_Stack+4,d0
	beq.s goto_menu_rts

	move.l #MainMenu,Menu_hook-data_base(a5)
	move.l #1<<16,NbPages-data_base(a5)
	move.l #Menu_Stack+4,Menu_SP-data_base(a5)
	move.l save_SP(pc),sp
	bra Global_Menus
goto_menu_rts
	rts

Bob_Menu_down
	DEF_GADGET 289,227-PART3,35,14,Packed_Menu_down0
Packed_Menu_down0
	incbin "Dzign0_Gad_Menu_down.PAK"
Packed_Menu_down1
	incbin "Dzign1_Gad_Menu_down.PAK"
Bob_Menu_up
	DEF_GADGET 289,227-PART3,35,14,Packed_Menu_up0
Packed_Menu_up0
	incbin "Dzign0_Gad_Menu_up.PAK"
Packed_Menu_up1
	incbin "Dzign1_Gad_Menu_up.PAK"
	


* On va au menu HELP
* ~~~~~~~~~~~~~~~~~~
goto_help
	lea Bob_help_down(pc),a0
	move.l #Packed_help_down0-Bob_help_down,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok0
	move.l #Packed_help_down1-Bob_help_down,bs_PackedData(a0)
.ok0	move.l Board_Bottom(pc),a1
	bsr put_gadget
	bsr wait_gadget_up
	lea Bob_help_up(pc),a0
	move.l #Packed_help_up0-Bob_help_up,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok1
	move.l #Packed_help_up1-Bob_help_up,bs_PackedData(a0)
.ok1	move.l Board_Bottom(pc),a1
	bsr put_gadget

	lea Menu_Stack+4(pc),a0
	move.l #1<<16,(a0)+
	move.l #MainMenu,(a0)+
	move.l a0,Menu_SP-data_base(a5)
	move.l save_SP(pc),sp

	bsr HelpArticle
	bra Global_Menus

Bob_help_down
	DEF_GADGET 434,227-PART3,35,14,Packed_help_down0
Packed_help_down0
	incbin "Dzign0_Gad_Help_down.PAK"
Packed_help_down1
	incbin "Dzign1_Gad_Help_down.PAK"
Bob_help_up
	DEF_GADGET 434,227-PART3,35,14,Packed_help_up0
Packed_help_up0
	incbin "Dzign0_Gad_Help_up.PAK"
Packed_help_up1
	incbin "Dzign1_Gad_Help_up.PAK"



* Click à gauche
* ~~~~~~~~~~~~~~
go_left
	lea Bob_left_down(pc),a0
	move.l #Packed_left_down0-Bob_left_down,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok0
	move.l #Packed_left_down1-Bob_left_down,bs_PackedData(a0)
.ok0	move.l Board_Bottom(pc),a1
	bsr put_gadget

	bsr wait_gadget_up

	lea Bob_left_up(pc),a0
	move.l #Packed_left_up0-Bob_left_up,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok1
	move.l #Packed_left_up1-Bob_left_up,bs_PackedData(a0)
.ok1	move.l Board_Bottom(pc),a1
	bsr put_gadget
	st Go_Left_Flag-data_base(a5)
	rts

Bob_left_down
	DEF_GADGET 512,227-PART3,24,14,Packed_left_down0
Packed_left_down0
	incbin "Dzign0_Gad_Left_down.PAK"
Packed_left_down1
	incbin "Dzign1_gad_Left_down.PAK"
Bob_left_up
	DEF_GADGET 512,227-PART3,24,14,Packed_left_up0
Packed_left_up0
	incbin "Dzign0_Gad_Left_up.PAK"
Packed_left_up1
	incbin "Dzign1_Gad_Left_up.PAK"



* Click à droite
* ~~~~~~~~~~~~~~
go_right
	lea Bob_right_down(pc),a0
	move.l #Packed_right_down0-Bob_right_down,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok0
	move.l #Packed_right_down1-Bob_right_down,bs_PackedData(a0)
.ok0	move.l Board_Bottom(pc),a1
	bsr put_gadget

	bsr wait_gadget_up

	lea Bob_right_up(pc),a0
	move.l #Packed_right_up0-Bob_right_up,bs_PackedData(a0)
	tst.w DZign_Number-data_base(a5)
	beq.s .ok1
	move.l #Packed_right_up1-Bob_right_up,bs_PackedData(a0)
.ok1	move.l Board_Bottom(pc),a1
	bsr put_gadget
	st Go_Right_Flag-data_base(a5)
	rts

Bob_right_down
	DEF_GADGET 564,227-PART3,24,14,Packed_right_down0
Packed_right_down0
	incbin "Dzign0_Gad_Right_down.PAK"
Packed_right_down1
	incbin "Dzign1_Gad_Right_down.PAK"
Bob_right_up
	DEF_GADGET 564,227-PART3,24,14,Packed_right_up0
Packed_right_up0
	incbin "Dzign0_Gad_Right_up.PAK"
Packed_right_up1
	incbin "Dzign1_Gad_Right_up.PAK"

sc_mouse_left
	sub.w #18,MouseX-data_base(a5)
	move.b #NO_SHORTCUT,Gadget_Key-data_base(a5)
	rts
sc_mouse_right
	add.w #18,MouseX-data_base(a5)
	move.b #NO_SHORTCUT,Gadget_Key-data_base(a5)
	rts
sc_mouse_up
	sub.w #18,MouseY-data_base(a5)
	move.b #NO_SHORTCUT,Gadget_Key-data_base(a5)
	rts
sc_mouse_down
	add.w #18,MouseY-data_base(a5)
	move.b #NO_SHORTCUT,Gadget_Key-data_base(a5)
	rts
sc_mouse_click_left
	st Left_Mousebutton-data_base(a5)
	addq.l #4,sp
	rts
