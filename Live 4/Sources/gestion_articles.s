* Gestion Adverts ( HAD & FAD )
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Adverts_Part1
	move.l #HalfAdverts_List+2,First_Page_Ptr-data_base(a5)
	lea AdvertPart1_BarText,a0
	bra Manage_Half_Pages

Adverts_Part2
	move.l #FullAdverts_List+2,First_Page_Ptr-data_base(a5)
	lea AdvertPart2_BarText,a0
	bra Manage_Full_Pages


* Tous les articles de LIVE
* ~~~~~~~~~~~~~~~~~~~~~~~~~
FirstWordsArticle
	move.l #FirstWords_Article+2,First_Page_Ptr-data_base(a5)
	lea FirstWords_BarText,a0
	bra Manage_Full_Pages

CreditsArticle
	move.l #Credits_Article+2,First_Page_Ptr-data_base(a5)
	lea CreditsIssue_BarText,a0
	bra Manage_Full_Pages

LiveStaffArticle
	move.l #LiveStaff_Article+2,First_Page_Ptr-data_base(a5)
	lea LiveStaff_BarText,a0
	bra Manage_Full_Pages

NewsA_DArticle
	move.l #NewsA_D_Article+2,First_Page_Ptr-data_base(a5)
	lea NewsA_D_BarText,a0
	bra Manage_Full_Pages

NewsE_PArticle
	move.l #NewsE_P_Article+2,First_Page_Ptr-data_base(a5)
	lea NewsE_P_BarText,a0
	bra Manage_Full_Pages

NewsQ_ZArticle
	move.l #NewsQ_Z_Article+2,First_Page_Ptr-data_base(a5)
	lea NewsQ_Z_BarText,a0
	bra Manage_Full_Pages

FishAndTipsArticle
	move.l #FishAndTips_Article+2,First_Page_Ptr-data_base(a5)
	lea FishAndTips_BarText,a0
	bra Manage_Full_Pages

BackStageArticle
	move.l #BackStage_Article+2,First_Page_Ptr-data_base(a5)
	lea BackStage_BarText,a0
	bra Manage_Full_Pages

HandleStoryArticle
	move.l #HandleStory_Article+2,First_Page_Ptr-data_base(a5)
	lea HandleStory_BarText,a0
	bra Manage_Full_Pages

HowToSupportArticle
	move.l #HowToSupport_Article+2,First_Page_Ptr-data_base(a5)
	lea HowToSupport_BarText,a0
	bra Manage_Full_Pages

DesignItArticle
	move.l #DesignIt_Article+2,First_Page_Ptr-data_base(a5)
	lea DesignIt_BarText,a0
	bra Manage_Full_Pages

AddressArticle
	move.l #Address_Article+2,First_Page_Ptr-data_base(a5)
	lea Address_BarText,a0
	bra Manage_Full_Pages

LastWordsArticle
	move.l #LastWords_Article+2,First_Page_Ptr-data_base(a5)
	lea LastWords_BarText,a0
	bra Manage_Full_Pages

SexArticle
	move.l #Sex_Article+2,First_Page_Ptr-data_base(a5)
	lea Sex_BarText,a0
	bra Manage_Full_Pages

StupidSwappersArticle
	move.l #StupidSwappers_Article+2,First_Page_Ptr-data_base(a5)
	lea StupidSwappers_BarText,a0
	bra Manage_Full_Pages

AboutSFArticle
	move.l #AboutSF_Article+2,First_Page_Ptr-data_base(a5)
	lea AboutSF_BarText,a0
	bra Manage_Full_Pages

OfficialSpreadersArticle
	move.l #OfficialSpreaders_Article+2,First_Page_Ptr-data_base(a5)
	lea OfficialSpreaders_BarText,a0
	bra Manage_Full_Pages

GatheringArticle
	move.l #Gathering_Article+2,First_Page_Ptr-data_base(a5)
	lea Gathering_BarText,a0
	bra Manage_Full_Pages

MovementStoryArticle1
	move.l #Movement1_Article+2,First_Page_Ptr-data_base(a5)
	lea Movement1_BarText,a0
	bra Manage_Full_Pages

MovementStoryArticle2
	move.l #Movement2_Article+2,First_Page_Ptr-data_base(a5)
	lea Movement2_BarText,a0
	bra Manage_Full_Pages

PartyIIILiveArticle
	move.l #PartyIII_Live_Article+2,First_Page_Ptr-data_base(a5)
	lea PartyIIILive_BarText,a0
	bra Manage_Full_Pages

PartyIIIRepportArticle
	move.l #PartyIII_Repport_Article+2,First_Page_Ptr-data_base(a5)
	lea PartyIIIRepport_BarText,a0
	bra Manage_Full_Pages

PartyIIIResultsArticle
	move.l #PartyIII_Results_Article+2,First_Page_Ptr-data_base(a5)
	lea PartyIIIResults_BarText,a0
	bra Manage_Full_Pages

HelpArticle
	move.l #Help_Article+2,First_Page_Ptr-data_base(a5)
	lea Help_BarText,a0
	bra Manage_Full_Pages


* Gestion des pages moitié écran
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Manage_Half_Pages
	bsr Dup_Text_Barre

	bsr Clear_HighLight
	move.l First_Page_Ptr(pc),Page_Ptr-data_base(a5)

	move.l Page_Ptr(pc),a0			compte les adverts
	moveq #0,d0
.count	addq.w #1,d0
	bsr Find_Next_Advert
	bne.s .count
	subq.w #1,d0
	move.w d0,NbPages-data_base(a5)
	clr.w Barre_Result-data_base(a5)

	lea Text_Barre+NUMBER_END(pc),a0	ecrit le nombre de page
	ext.l d0
	bsr Write_Number

HAD_Barre_Move
	sf Flip_Flag-data_base(a5)
	st Fade_Flag-data_base(a5)
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)
	bsr Clear_Middle_Screen

	lea Text_Barre+NUMBER_POS(pc),a0	écrit le numero de la page
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre			affiche la barre du haut
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre

	move.l Page_Ptr(pc),a0
	moveq #2,d0
	bsr Display_Text
	move.l Page_Ptr(pc),a0
	bsr Find_Next_Advert
	beq.s .one
	moveq #41,d0
	bsr Display_Text
.one
	bsr Render_Barre
	WAIT_FADE_OUT
	st Flip_Flag-data_base(a5)
	sf Fade_Flag-data_base(a5)
	WAIT_FADE_IN

gestion_HAD
	WAIT_VBL
	bsr gestion_shortcuts
	bsr gestion_gadgets

	tst.b Go_Left_Flag-data_base(a5)
	beq HAD_NoLeft

	clr.b Go_Left_Flag-data_base(a5)
	move.l Page_Ptr(pc),a0			recherche déja l'advert
	bsr Find_Previous_Advert		d'avant
	beq gestion_HAD
	pea (a0)
	bsr Find_Previous_Advert
	pea (a0)
	bne.s .display
	addq.w #1,Barre_Result-data_base(a5)
	move.l 4(sp),(sp)			met sur le coté gauche
	move.l Page_Ptr(pc),4(sp)		met sur coté droit
.display
	subq.w #2,Barre_Result-data_base(a5)
	sf Flip_Flag-data_base(a5)
	st Fade_Flag-data_base(a5)
	bsr Clear_Middle_Screen

	move.l (sp)+,a0
	move.l a0,Page_Ptr-data_base(a5)
	moveq #2,d0
	bsr Display_Text
	move.l (sp)+,a0
	moveq #41,d0
	bsr Display_Text

	lea Text_Barre+NUMBER_POS(pc),a0	écrit le numero de la page
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre			affiche la barre du haut
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre

	bsr Render_Barre
	WAIT_FADE_OUT
	st Flip_Flag-data_base(a5)
	sf Fade_Flag-data_base(a5)
	WAIT_FADE_IN
	bra gestion_HAD
	
HAD_NoLeft
	tst.b Go_Right_Flag-data_base(a5)
	beq HAD_NoRight

	clr.b Go_Right_Flag-data_base(a5)
	move.l Page_Ptr(pc),a0			recherche déja l'advert
	bsr Find_Next_Advert			d'apres
	beq gestion_HAD
	pea (a0)
	bsr Find_Next_Advert
	pea (a0)
	bne.s .ok
	addq.l #8,sp				nan => on se casse
	bra gestion_HAD
.ok
	bsr Find_Next_Advert
	beq.s .display
	move.l (sp),4(sp)
	move.l a0,(sp)
	addq.w #1,Barre_Result-data_base(a5)
.display
	addq.w #1,Barre_Result-data_base(a5)
	sf Flip_Flag-data_base(a5)
	st Fade_Flag-data_base(a5)
	bsr Clear_Middle_Screen

	move.l (sp)+,a0
	moveq #41,d0
	bsr Display_Text
	move.l (sp)+,a0
	move.l a0,Page_Ptr-data_base(a5)
	moveq #2,d0
	bsr Display_Text

	lea Text_Barre+NUMBER_POS(pc),a0	écrit le numero de la page
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre			affiche la barre du haut
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre

	bsr Render_Barre
	WAIT_FADE_OUT
	st Flip_Flag-data_base(a5)
	sf Fade_Flag-data_base(a5)
	WAIT_FADE_IN
	bra gestion_HAD

HAD_NoRight
	tst.b Barre_Flag-data_base(a5)
	beq gestion_HAD
	move.w Barre_Result(pc),d0
	move.l First_Page_Ptr(pc),a0
	bra.s .start
.search	bsr Find_Next_Advert
.start	dbf d0,.search
	move.l a0,Page_Ptr-data_base(a5)
	bra HAD_Barre_Move


Manage_Full_Pages
	bsr Dup_Text_Barre

	bsr Clear_HighLight
	move.l First_Page_Ptr(pc),Page_Ptr-data_base(a5)

	move.l Page_Ptr(pc),a0				compte les adverts
	moveq #0,d0
.count	addq.w #1,d0
	bsr Find_Next_Advert
	bne.s .count
	move.w d0,NbPages-data_base(a5)
	clr.w Barre_Result-data_base(a5)

	lea Text_Barre+NUMBER_END(pc),a0	ecrit le nombre de page
	ext.l d0
	bsr Write_Number

FAD_Barre_Move
	sf Flip_Flag-data_base(a5)
	st Fade_Flag-data_base(a5)
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)
	bsr Clear_Middle_Screen

	lea Text_Barre+NUMBER_POS(pc),a0	écrit le numero de la page
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre			affiche la barre du haut
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre

	move.l Page_Ptr(pc),a0			affiche l'article
	moveq #2,d0
	bsr Display_Text

	bsr Render_Barre

	WAIT_FADE_OUT
	st Flip_Flag-data_base(a5)
	sf Fade_Flag-data_base(a5)
	WAIT_FADE_IN

gestion_FAD
	WAIT_VBL
	bsr gestion_shortcuts
	bsr gestion_gadgets

	tst.b Go_Left_Flag-data_base(a5)
	beq.s FAD_NoLeft

	clr.b Go_Left_Flag-data_base(a5)
	move.l Page_Ptr(pc),a0			recherche déja l'advert
	bsr Find_Previous_Advert		d'avant
	beq gestion_FAD

	move.l a0,Page_Ptr-data_base(a5)
	subq.w #1,Barre_Result-data_base(a5)
	bra FAD_Barre_Move
	
FAD_NoLeft
	tst.b Go_Right_Flag-data_base(a5)
	beq.s FAD_NoRight

	clr.b Go_Right_Flag-data_base(a5)
	move.l Page_Ptr(pc),a0			recherche déja l'advert
	bsr Find_Next_Advert			d'apres
	beq gestion_FAD

	move.l a0,Page_Ptr-data_base(a5)
	addq.w #1,Barre_Result-data_base(a5)
	bra FAD_Barre_Move

FAD_NoRight
	tst.b Barre_Flag-data_base(a5)
	beq gestion_FAD
	move.w Barre_Result(pc),d0
	move.l First_Page_Ptr(pc),a0
	bra.s .start
.search	bsr.s Find_Next_Advert
.start	dbf d0,.search
	move.l a0,Page_Ptr-data_base(a5)
	bra FAD_Barre_Move

Page_Ptr
	dc.l 0
First_Page_Ptr
	dc.l 0


*****************************************************************************
************************* RECHERCHE DE L'ADVERT D'AVANT *********************
************************* en entrée: a0=ptr advert      *********************
************************* en sortie: a0=ptr advert      *********************
*****************************************************************************
Find_Previous_Advert
	subq.l #1,a0				pointe le 0 de fin d'advert
	tst.b -1(a0)				ya encore un 0 ?
	beq.s .no_previous
.loop_find_previous
	tst.b -(a0)				recherche l'advert d'avant
	bne.s .loop_find_previous
	addq.l #1,a0				saute le 0 trouvé
	moveq #-1,d0
.no_previous
	rts



*****************************************************************************
************************* RECHERCHE DE L'ADVERT D'APRES *********************
************************* en entrée: a0=ptr advert      *********************
************************* en sortie: a0=ptr advert      *********************
*****************************************************************************
Find_Next_Advert
	tst.b (a0)+				cherche le 0 suivant
	bne.s Find_Next_Advert
	tst.b (a0)				yen a un juste après ?
	rts

