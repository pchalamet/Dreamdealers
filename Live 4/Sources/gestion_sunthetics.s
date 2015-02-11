
*				Section Sunthetics
*				~~~~~~~~~~~~~~~~~~

Sunthetics_Menu_Render
	bsr BackGround_Middle_Screen

	moveq #2,d0				non => affichage normal
	lea SuntheticsLoader_Edito,a0
	bsr Display_Text_Menu

Suunthetics_Display_Informations
	lea Sun_Custom(pc),a0
	move.w Sunthetics_Number(pc),d0
	beq.s .display

	lea Sun_Info1(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info2(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info3(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info4(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info5(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info6(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info7(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info8(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info9(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info10(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info11(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info12(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info13(pc),a0
	subq.w #1,d0
	beq.s .display
	lea Sun_Info14(pc),a0
.display
	moveq #6,d0
	bsr Display_Text_Menu

	move.l #BackGround_Colors,d0
	rts

Sun_Custom
	dc.b "°2£00-140Custom Module",10
	dc.b "°3Can't display informations.",0

Sun_Info1
	dc.b "°2£00-140The Sideshow",10
	dc.b "°3Live main module made by",10
	dc.b "911/Movement. Thanx to you",10
	dc.b "man!",0

Sun_Info2
	dc.b "°2£00-140Hanging fire",10
	dc.b "°3Made by Killerman/Majic12",0

Sun_Info3
	dc.b "°2£00-140Jump and run 2",10
	dc.b "°3Module made by the GREAT",10
	dc.b "master : Sun/DreamDealers !",0

Sun_Info4
	dc.b "°2£00-140Nono",10
	dc.b "°3Our spiritual master Sun",10
	dc.b "is back with this tune !",0

Sun_Info5
	dc.b "°2£00-140Kinder",10
	dc.b "°3by Gandbox/Ivory",10
	dc.b "whaaou! 7208 bytes !!!",0

Sun_Info6
	dc.b "°2£00-140Flagada",10
	dc.b "°3This crazy tune was made by",10
	dc.b "Gandbox/Ivory.",0

Sun_Info7
	dc.b "°2£00-140Stand-by-kini",10
	dc.b "°3Hop! Hop! Shining Sun",10
	dc.b "again...",0

Sun_Info8
	dc.b "°2£00-140Minidisco",10
	dc.b "°3Show us how you dance",10
	dc.b "my deeeaarr Sun!",0

Sun_Info9
	dc.b "°2£00-140Between 2 waters",10
	dc.b "°3made by Doh/Cryptoburners",0

Sun_Info10
	dc.b "°2£00-140Nesquik",10
	dc.b "°3Houba! This superb tune",10
	dc.b "was made by Gandbox/Ivoiry",0

Sun_Info11
	dc.b "°2£00-140Madness",10
	dc.b "°3Stop the madness!",10
	dc.b "Stop Sun/DreamDealers!!",0

Sun_Info12
	dc.b "°2£00-140Monsieur Lampiste",10
	dc.b "°3Strange name for this music",10
	dc.b "done by Doh/Cryptoburners...",0

Sun_Info13
	dc.b "°2£00-140Solitary Brotha",10
	dc.b "°3Hello Clawz/Complex!!",10
	dc.b "What what ??? It's not",10
	dc.b "hardcore techno gore music!?",10
	dc.b "How did you manage ?!?",0

Sun_Info14
	dc.b "°2£00-140Bamse I Trollskogen",10
	dc.b "°3Oops... hard to pronounce this one!",10
	dc.b "made by Some1 and Prime",10
	dc.b "of Carl and Mikko Dzsign!",0

	even
Load_Sunthetics_Music1
	lea Live_Module1,a0
	moveq #1,d0
	bra Load_Sunthetics

Load_Sunthetics_Music2
	lea Live_Module2,a0
	moveq #2,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music3
	lea Live_Module3,a0
	moveq #3,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music4
	lea Live_Module4,a0
	moveq #4,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music5
	lea Live_Module5,a0
	moveq #5,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music6
	lea Live_Module6,a0
	moveq #6,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music7
	lea Live_Module7,a0
	moveq #7,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music8
	lea Live_Module8,a0
	moveq #8,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music9
	lea Live_Module9,a0
	moveq #9,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music10
	lea Live_Module10,a0
	moveq #10,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music11
	lea Live_Module11,a0
	moveq #11,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music12
	lea Live_Module12,a0
	moveq #12,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music13
	lea Live_Module13,a0
	moveq #13,d0
	bra.s Load_Sunthetics

Load_Sunthetics_Music14
	lea Live_Module14,a0
	moveq #14,d0

Load_Sunthetics
	movem.l d0/a0,-(sp)
	move.w d0,Sunthetics_Number-data_base(a5)
	bsr Load_Module				charge le module

	sf Flip_Flag-data_base(a5)		pas de flip_screen
	clr.l Menu_Draw-data_base(a5)		vire le HighLight
	st Fade_Flag-data_base(a5)		fade_out demandé !!

	tst.l Module_Adr
	bne.s .ok

**** ca a cafouillé on dirait!!
	bsr BackGround_Middle_Screen
	lea Sunthetics_Msg,a0
	moveq #2,d0
	bsr Display_Text_Menu

	WAIT_FADE_OUT
	st Flip_Flag-data_base(a5)		affiche le menu complet
	sf Fade_Flag-data_base(a5)		fade_in demandé !!
	WAIT_FADE_IN

	bsr Insert_Disk2

	movem.l (sp)+,d0/a0
	bra.s Load_Sunthetics

******** tout est ok..;
.ok
	addq.l #8,sp
	bsr Sunthetics_Menu_Render

	WAIT_FADE_OUT
	st Flip_Flag-data_base(a5)		affiche le menu complet
	sf Fade_Flag-data_base(a5)		fade_in demandé !!
	WAIT_FADE_IN

	bsr menu_return				et reviens au menu d'avant

