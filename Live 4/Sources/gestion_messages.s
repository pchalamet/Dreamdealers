
*			Recherche des messages pour Live
*			-------------------------------------->
*			Last Change : 13 Mai 1993


*
*		FORMAT DES MESSAGES:
*
*		dc.b N° de l'image
*		dc.b "FromName",0,"FromGroup",0,"FromCountry",0
*		dc.b "ForName",0,"ForGroup",0,"ForCountry",0
*		dc.b "Message",0
*
*	------ NE SURTOUT PAS OUBLIER LES 0 SINON CA FOIRE MECHAMENT ------
*	       ------ LES MESSAGES SONT INDEXES A PARTIR DE 0 ------
*

*
*	Fonctions:
*
*	Get_MsgPtr:   Recherche les Noms,Groupes ou Country des messages + tri
*	Get_Msg_X  :  Recherche un message N° dans une rubrique
*	Get_All_Msg:  Recherche tous les messages dans une rubrique
*	Get_Msg    :  Recherche le message suivant
*


*---------------------> les options de recherche
SEARCH_WHOLE=-1
FROM_NAME=0
FROM_GROUP=1
FROM_COUNTRY=2
FOR_NAME=3
FOR_GROUP=4
FOR_COUNTRY=5

*---------------------> commandes pour les messages de live
;LEFT_BORDER=1
;RIGHT_BORDER=2
;GOTOXY=3
;SET_COLOR=4
;SET_FONT=5
LF=10

*---------------------> equ divers
NO_CLIPART=1
COUNT_CLIPART set NO_CLIPART
MAXSTR=20		longueur max des chaines de recherche
; pas plus de 1024 messages pour une personne et
; pas plus de 1024 Noms,Groupes ou Pays ( suffisant nan ????!! )
MAXPTR=2048
; saut à faire pour sauter un clip-art
SKIP_CLIPART=3

*---------------------> une ch'tite macro qui convertit un parametre en UPCASE
CONVERT_UPCASE macro
	cmp.b #"a",\1
	blt.s \@
	cmp.b #"z",\1
	bgt.s \@
	sub.b #"a"-"A",\1
\@
	endm



* Gestion des pages cyclantes pour les Name/Pays...
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MenuFromName
	move.w #FROM_NAME,OptionNumber-data_base(a5)
	bra.s Menu_Messages_start
MenuFromGroup
	move.w #FROM_GROUP,OptionNumber-data_base(a5)
	bra.s Menu_Messages_start
MenuFromCountry
	move.w #FROM_COUNTRY,OptionNumber-data_base(a5)
	bra.s Menu_Messages_start
MenuForName
	move.w #FOR_NAME,OptionNumber-data_base(a5)
	bra.s Menu_Messages_start
MenuForGroup
	move.w #FOR_GROUP,OptionNumber-data_base(a5)
	bra.s Menu_Messages_start
MenuForCountry
	move.w #FOR_COUNTRY,OptionNumber-data_base(a5)
Menu_Messages_start
	move.l #MsgPtr,ListPtr-data_base(a5)
	bsr Clear_HighLight

	st Fade_Flag-data_base(a5)		fade out demandé !
	sf Flip_Flag-data_base(a5)
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)
	clr.b OptionStr-data_base(a5)		efface ces chaines C !!!
	clr.b SearchStr-data_base(a5)
	bsr BackGround_Middle_Screen

	move.w OptionNumber(pc),d0
	bsr Get_MsgPtr

	lea MsgPtr(pc),a0			installation de la barre
	moveq #-1,d0
.count
	tst.l (a0)+
	dbeq d0,.count
	not.l d0
	add.w #(NB_LEFT+NB_RIGHT)-1,d0
	divu #(NB_LEFT+NB_RIGHT),d0
	move.w d0,NbPages-data_base(a5)
	clr.w Barre_Result-data_base(a5)
	bsr Render_Barre
	bra.s Display_Menu_Messages

Next_Menu_Page
	bsr Clear_HighLight
	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)
	bsr Render_Barre
	bsr BackGround_Middle_Screen

Display_Menu_Messages
	bsr Build_ListText
	lea ListMenuText,a0
	moveq #2,d0
	bsr Display_Text_Menu

	WAIT_FADE_OUT
	move.l #BackGround_Colors,ColorMap_hook-data_base(a5)
	sf Fade_Flag-data_base(a5)
	st Flip_Flag-data_base(a5)
	move.l #ListMenu,Menu_hook-data_base(a5)
	WAIT_FADE_IN
MenuMessageLoop
	WAIT_VBL
	tst.b Go_Left_Flag-data_base(a5)
	beq.s .no_left
	move.l ListPtr(pc),a0
	cmp.l #MsgPtr,a0
	bls.s .no_right
	lea -(NB_LEFT+NB_RIGHT)*4(a0),a0
	move.l a0,ListPtr-data_base(a5)
	subq.w #1,Barre_Result-data_base(a5)
	bra Next_Menu_Page
.no_left
	tst.b Go_Right_Flag-data_base(a5)
	beq.s .no_right
	move.l ListPtr(pc),a0
	moveq #(NB_LEFT+NB_RIGHT)-1,d0
.gogo
	tst.l (a0)+
	dbeq d0,.gogo
	tst.l (a0)
	beq.s .no_right
	move.l a0,ListPtr-data_base(a5)
	addq.w #1,Barre_Result-data_base(a5)
	bra Next_Menu_Page
.no_right
	clr.w Go_Left_Flag-data_base(a5)
	tst.b Barre_Flag-data_base(a5)
	beq.s .no_barre
	move.w Barre_Result(pc),d0
	mulu #(NB_LEFT+NB_RIGHT)*4,d0
	lea MsgPtr(pc),a0
	add.l d0,a0
	move.l a0,ListPtr-data_base(a5)
	bra Next_Menu_Page
.no_barre
	bsr gestion_shortcuts
	bsr gestion_menus
	bsr gestion_gadgets
	bra MenuMessageLoop

* Construction de la page de texte pour les menus Name etc...
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Build_ListText
	lea ListMenuText+2,a0			efface le text PAGE_X*PAGE_Y
	move.w #(PAGE_X+1)*PAGE_Y-1,d0
	move.b #" ",d1
.clear
	move.b d1,(a0)+
	dbf d0,.clear

	lea ListMenuText+2+PAGE_X+1,a0		met des chr$(10) en fin de ligne!
	moveq #PAGE_Y-1,d0
	moveq #10,d1
.return
	move.b d1,(a0)
	lea PAGE_X+1(a0),a0
	dbf d0,.return
	clr.b -(PAGE_X+1)(a0)			met un 0 à la fin

	lea ListMenuText+2+PAGE_X+1+1,a0	construit la partie de gauche
	move.l ListPtr(pc),a1
	moveq #NB_LEFT,d7
	bsr.s Build_Part
	move.l d1,List_Flag1
	lea ListMenuText+2+PAGE_X+1+PAGE_X/2+3,a0	puis la partie de droite
	moveq #NB_RIGHT,d7
	bsr.s Build_Part
	move.l d1,List_Flag2
	rts

Build_Part
	moveq #0,d0				nbre de menu
.build_all
	move.l (a1)+,d1				pointeur nom
	beq.s .end				c'est la fin de la liste ?
	cmp.w d7,d0				nombre de menu
	beq.s .end				en bas de l'écran ??
	addq.w #1,d0				et ho! encore une nouvelle entrée

	move.l d1,a3				*nom du menu

	move.l d1,a4
	moveq #PAGE_X/2,d1
.size
	tst.b (a4)+
	dbeq d1,.size
	lsr.w #1,d1
	lea (a0,d1.w),a2			*text
.dup
	move.b (a3)+,(a2)+
	bne.s .dup
	move.b #" ",-1(a2)
	lea PAGE_X+1(a0),a0			ligne suivante
	bra.s .build_all
.end
	moveq #0,d1
.make
	bset d0,d1
	dbf d0,.make
	bclr #0,d1				vire le bit 0... arf!!!
	subq.l #4,a1				revient en arrière...
	rts




* gestion des accés directs aux messages
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MenuForEverybody
	move.w #FOR_NAME,OptionNumber-data_base(a5)
	lea EverybodyStr(pc),a0
	clr.b SearchStr-data_base(a5)
	bra Read_Selected_branch
MenuForMembers
	move.w #FOR_NAME,OptionNumber-data_base(a5)
	lea MembersStr(pc),a0
	clr.b SearchStr-data_base(a5)
	bra Read_Selected_branch
MenuForContacts
	move.w #FOR_NAME,OptionNumber-data_base(a5)
	lea ContactsStr(pc),a0
	clr.b SearchStr-data_base(a5)
	bra Read_Selected_branch

EverybodyStr
	dc.b "EVERYBODY",0
MembersStr
	dc.b "ALL MEMBERS",0
ContactsStr
	dc.b "ALL CONTACTS",0
	even



******************************************************************************
************** REQUESTER D'UNE CHAINE DE CHAR DANS LES MESSAGES **************
******************************************************************************
StringSearch
	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)
	bsr BackGround_Middle_Screen

	lea StringSearch_Edito,a0
	moveq #2,d0
	bsr Display_Text_Menu

	clr.b OptionStr-data_base(a5)
	clr.b SearchStr-data_base(a5)		efface cette chaine C !!!
	clr.w SearchStr_Pos-data_base(a5)
	move.w #SEARCH_WHOLE,OptionNumber-data_base(a5)

	WAIT_FADE_OUT
	move.l #BackGround_Colors,ColorMap_hook-data_base(a5)
	sf Fade_Flag-data_base(a5)
	st Flip_Flag-data_base(a5)
	WAIT_FADE_IN

StringSearch_Loop
	WAIT_VBL
	bsr gestion_gadgets

	bsr GetKey				lit une touche
	bmi.s StringSearch_Loop

	cmp.b #$41,d0				backspace ?
	bne.s .not_backspace
	subq.w #1,SearchStr_Pos-data_base(a5)
	bge.s .ok
	clr.w SearchStr_Pos-data_base(a5)
.ok	move.w SearchStr_Pos(pc),d0
	lea SearchStr,a0
	clr.b (a0,d0.w)
	bra.s .display_string
.not_backspace
	cmp.b #$44,d0				enter ?
	bne.s .not_enter

	lea LiveMsg(pc),a0			regarde voir si ya des messages
	lea Next_Rout(pc),a1
	bsr Get_Msg
	bne Read_Selected_branch		oui ?
	bra.s StringSearch_Loop			nan...

.not_enter
	lea KeyBoard_ASCII,a0			met la touche en ASCII
	move.b (a0,d0.w),d0			ou 0 si pas bonne
	beq.s StringSearch_Loop

	move.w SearchStr_Pos(pc),d1		met la touche dans le buffer
	lea SearchStr,a0			de chaine
	move.b d0,(a0,d1.w)
	clr.b 1(a0,d1.w)

	addq.w #1,d1
	cmp.w #MAXSTR,d1
	beq.s .display_string
	move.w d1,SearchStr_Pos-data_base(a5)
.display_string
	move.l phy_screen(pc),a2
	add.l #SCREEN_WIDTH*SCREEN_DEPTH*(98+16)+30+SCREEN_WIDTH,a2
	ALLOC_BLITTER
	WAIT_VBL
	move.l a2,bltdpt(a6)
	move.w #SCREEN_WIDTH*(SCREEN_DEPTH-1)+(SCREEN_WIDTH-20),bltdmod(a6)
	move.l #$01000000,bltcon0(a6)
	move.w #(8<<6)|(20/2),bltsize(a6)
	FREE_BLITTER

	lea SearchStr,a0
	moveq #"1",d7
	bsr Display_Text_Message

	bra StringSearch_Loop


* Gestion des clicks menus pour les pages Name etc...
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
List_LMenu0
	moveq #0,d0
	bra Read_Selected
List_LMenu1
	moveq #1*4,d0
	bra Read_Selected
List_LMenu2
	moveq #2*4,d0
	bra Read_Selected
List_LMenu3
	moveq #3*4,d0
	bra Read_Selected
List_LMenu4
	moveq #4*4,d0
	bra Read_Selected
List_LMenu5
	moveq #5*4,d0
	bra Read_Selected
List_LMenu6
	moveq #6*4,d0
	bra Read_Selected
List_LMenu7
	moveq #7*4,d0
	bra Read_Selected
List_LMenu8
	moveq #8*4,d0
	bra.s Read_Selected
List_LMenu9
	moveq #9*4,d0
	bra.s Read_Selected
List_LMenu10
	moveq #10*4,d0
	bra.s Read_Selected
List_LMenu11
	moveq #11*4,d0
	bra.s Read_Selected
List_LMenu12
	moveq #12*4,d0
	bra.s Read_Selected
List_LMenu13
	moveq #13*4,d0
	bra.s Read_Selected
List_LMenu14
	moveq #14*4,d0
	bra.s Read_Selected
List_LMenu15
	moveq #15*4,d0
	bra.s Read_Selected
List_LMenu16
	moveq #16*4,d0
	bra.s Read_Selected
List_LMenu17
	moveq #17*4,d0
	bra.s Read_Selected
List_LMenu18
	moveq #18*4,d0
	bra.s Read_Selected

List_RMenu0
	moveq #19*4,d0
	bra.s Read_Selected
List_RMenu1
	moveq #20*4,d0
	bra.s Read_Selected
List_RMenu2
	moveq #21*4,d0
	bra.s Read_Selected
List_RMenu3
	moveq #22*4,d0
	bra.s Read_Selected
List_RMenu4
	moveq #23*4,d0
	bra.s Read_Selected
List_RMenu5
	moveq #24*4,d0
	bra.s Read_Selected
List_RMenu6
	moveq #25*4,d0
	bra.s Read_Selected
List_RMenu7
	moveq #26*4,d0
	bra.s Read_Selected
List_RMenu8
	moveq #27*4,d0
	bra.s Read_Selected
List_RMenu9
	moveq #28*4,d0
	bra.s Read_Selected
List_RMenu10
	moveq #29*4,d0
	bra.s Read_Selected
List_RMenu11
	moveq #30*4,d0
	bra.s Read_Selected
List_RMenu12
	moveq #31*4,d0
	bra.s Read_Selected
List_RMenu13
	move.w #32*4,d0
	bra.s Read_Selected
List_RMenu14
	move.w #33*4,d0
	bra.s Read_Selected
List_RMenu15
	move.w #34*4,d0
	bra.s Read_Selected
List_RMenu16
	move.w #35*4,d0
	bra.s Read_Selected
List_RMenu17
	move.w #36*4,d0
	bra.s Read_Selected
List_RMenu18
	move.w #37*4,d0

* Lecture d'une série de messages
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Read_Selected
	move.l ListPtr(pc),a0
	move.l (a0,d0.w),a0			pointe le nom du menu
Read_Selected_branch
	lea OptionStr(pc),a1
.dup	move.b (a0)+,(a1)+			recopie le nom du menu
	bne.s .dup

	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)

	bsr Count_Msg
	move.w d7,NbPages-data_base(a5)
	clr.w Barre_Result-data_base(a5)

	lea ReadMessage_BarText,a0
	bsr Dup_Text_Barre

	moveq #0,d0				écrit le nombre de messages
	move.w d7,d0
	lea Text_Barre+NUMBER_END(pc),a0
	bsr Write_Number

	lea LiveMsg(pc),a0			cherche le 1er message.. il
	lea Next_Rout(pc),a1			existe toujours !!!
	bsr Get_Msg

TeufTeuf
	move.l a0,MessPtr-data_base(a5)

	lea Text_Barre+NUMBER_POS(pc),a0	affiche la barre
	moveq #1,d0
	add.w Barre_Result(pc),d0
	bsr Write_Number

	bsr Clear_Text_Barre
	lea Text_Barre(pc),a0
	bsr Display_Text_Barre

	bsr Render_Barre
	bsr Clear_Middle_Screen
	clr.w Go_Left_Flag-data_base(a5)
	sf Barre_Flag-data_base(a5)

	pea BackGround_Colors(pc)

	lea ClipArts_List,a0			ptr sur la liste des ClipArts
	move.l MessPtr(pc),a1			ptr sur le message
	moveq #0,d0
	move.b (a1)+,d0
	subq.w #NO_CLIPART+1,d0			ya un clipart ?
	blt.s .no_clipart
	
	mulu #bs_SIZEOF,d0			choppe la structure ClipArt
	lea (a0,d0.l),a0
	move.b (a1)+,bs_CoordX+1(a0)
	move.b (a1)+,bs_CoordY+1(a0)
	move.l log_screen(pc),a1
	bsr put_clipart

	lea pp_space+2,a0			recopie les couleurs
	lea Temp_Colors,a1
	move.l a1,(sp)				ecrase BackGround_Colors
	move.w #BACKGROUND_COLOR,(a1)+		pas touche color 0
	moveq #NB_COLORS-1-1,d0
.dup	move.w (a0)+,(a1)+
	dbf d0,.dup
.no_clipart

* Affiche de FROM: Name/Group/Country
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea MsgText_From,a0
	move.l log_screen(pc),a2
	lea SCREEN_WIDTH*SCREEN_DEPTH*(4+4)+20(a2),a2
	moveq #"1",d7
	bsr Display_Text_Message

	move.l MessPtr(pc),a0
	lea SKIP_CLIPART(a0),a0
	lea SCREEN_WIDTH(a2),a2
	moveq #"2",d7
	bsr Display_Text_Message

	pea (a0)
	lea MsgText_Slash,a0
	bsr Display_Text_Message

	move.l (sp)+,a0
	bsr Display_Text_Message

	pea (a0)
	lea MsgText_Slash,a0
	bsr Display_Text_Message

	move.l (sp)+,a0
	bsr Display_Text_Message

* Affiche de FOR: Name/Group/Country
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	pea (a0)
	lea MsgText_For,a0
	move.l log_screen(pc),a2
	lea SCREEN_WIDTH*SCREEN_DEPTH*(4+4+8)+20(a2),a2
	moveq #"1",d7
	bsr Display_Text_Message

	move.l (sp)+,a0
	lea SCREEN_WIDTH(a2),a2
	moveq #"2",d7
	bsr Display_Text_Message

	pea (a0)
	lea MsgText_Slash,a0
	bsr Display_Text_Message

	move.l (sp)+,a0
	bsr Display_Text_Message

	pea (a0)
	lea MsgText_Slash,a0
	bsr Display_Text_Message

	move.l (sp)+,a0
	bsr Display_Text_Message
	
* Affichage du message lui-même
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l log_screen(pc),a2
	lea SCREEN_WIDTH*SCREEN_DEPTH*(4+4+8+8+16)+4(a2),a2
	moveq #"1",d7
	bsr Display_Text_Message

	WAIT_FADE_OUT
	move.l (sp)+,ColorMap_hook-data_base(a5)

	sf Fade_Flag-data_base(a5)
	st Flip_Flag-data_base(a5)
	WAIT_FADE_IN
Main
	WAIT_VBL
	bsr gestion_shortcuts
	bsr gestion_gadgets

	tst.b Go_Left_Flag-data_base(a5)	gestion des toutouches
	beq.s .no_left
	move.l MessPtr(pc),a0
	lea Previous_Rout(pc),a1
	bsr Get_Msg
	beq.s .no_right
	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)
	subq.w #1,Barre_Result-data_base(a5)
	bra TeufTeuf
.no_left
	tst.b Go_Right_Flag-data_base(a5)
	beq.s .no_right
	move.l MessPtr(pc),a0
	lea Next_Rout(pc),a1
	bsr Get_Msg
	beq.s .no_right
	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)
	addq.w #1,Barre_Result-data_base(a5)
	bra TeufTeuf
.no_right
	clr.w Go_Left_Flag-data_base(a5)
	tst.b Barre_Flag-data_base(a5)
	beq Main

	move.w Barre_Result(pc),d7
	bsr Get_Msg_X
	st Fade_Flag-data_base(a5)
	sf Flip_Flag-data_base(a5)
	bra TeufTeuf










********************************************************************************
***************** RECHERCHE TOUS LES NOMS,GROUPES OU PAYS DES ******************
*****************            MESSAGES ET LES TRIES            ******************
***************** EN ENTREE : D0=Rubrique                     ******************
***************** EN SORTIE : MsgPtr initialisée + 0 à la fin ******************
********************************************************************************
Get_MsgPtr
	lea LiveMsg(pc),a0		1er message
	moveq #0,d1			compteur de messages
	bra.s old_ptr			saute le vide...
loop_get_ptr
	move.w d0,d2			recherche la bonne section

	lea SKIP_CLIPART(a0),a1		saute le clipart
	tst.b -SKIP_CLIPART(a1)		regarde si on arrive a la fin
	bne.s .skip_section		des messages
	tst.b (a1)
	bne.s .skip_section
	bra.s sort_all_ptr

.loop_skip_section
	tst.b (a1)+			pointe la bonne section
	bne.s .loop_skip_section
.skip_section
	dbf d2,.loop_skip_section

	move.w d1,d2			regarde si on l'a pas deja en
	lea MsgPtr(pc),a2		reserve par hazard
	bra.s already_start

check_end_already
	tst.b (a3)
	bne.s already_start
	bra.s old_ptr

loop_already
	move.l a1,a3			nom actuel
	move.l (a2)+,a4			ptr sur le nom
check_same
	move.b (a4)+,d3
	beq.s check_end_already
	cmp.b (a3)+,d3
	beq.s check_same
already_start
	dbf d2,loop_already
new_ptr
	move.l a1,(a2)+
	addq.w #1,d1
old_ptr
	moveq #7-1,d2			passe au message suivant
.next_msg
	tst.b (a0)+
	bne.s .next_msg
	dbf d2,.next_msg
	bra.s loop_get_ptr

*----------------------> ici on trie les ptrs
sort_all_ptr
	lea MsgPtr(pc),a0		ptr sur les ptr de noms
	move.w d1,d0			nb de messages

	ext.l d1
	add.l d1,d1			table de LONG
	add.l d1,d1
	clr.l 0(a0,d1.l)
	clr.l 4(a0,d1.l)

	subq.w #1,d0			à cause du dbf

big_loop_sort_messages
	subq.w #1,d0			on trie tjs sur N+1
	blt.s end_sort
	move.w d0,d1			nb d'élément à trier
	move.l a0,a1			*element
	moveq #0,d2			la marque
loop_sort_messages
	move.l (a1)+,a2			*message1
loop_sort_messages_second
	move.l (a1),a3			*message2

CmpStr
	move.b (a2)+,d3			compare les chaines
	beq.s swap_messages
	cmp.b (a3)+,d3
	beq.s CmpStr
	blt.s messages_ok

swap_messages
	move.l -4(a1),a2		\
	move.l (a1),-4(a1)		 |  échange les ptrs
	move.l a2,(a1)+			/
	addq.w #1,d2			signale le changement
	dbf d1,loop_sort_messages_second
	bra.s big_loop_sort_messages
messages_ok
	dbf d1,loop_sort_messages
	tst.w d2
	bne.s big_loop_sort_messages
end_sort
	rts	


********************************************************************************
****************** RECHERCHE LE MESSAGE D7 POUR UNE RUBRIQUE *******************
****************** EN ENTREE : LES CHAINES SONT INITIALISEES *******************
******************             D7=numero du message          *******************
******************             LES CHAINES SONT INITIALISEES *******************
****************** EN SORTIE : A0=Ptr sur le message         *******************
********************************************************************************
Get_Msg_X
	lea LiveMsg(pc),a0
	lea Next_Rout(pc),a1
loop_get_X
	bsr.s Get_Msg			saute tous ces messy jusqu'a temps
	dbf d7,loop_get_X		de trouver le bon
	rts
	

********************************************************************************
***************** RECHERCHE DES MESSAGES POUR UNE RUBRIQUE    ******************
***************** EN ENTREE : LES CHAINES SONT INITIALISEES   ******************
***************** EN SORTIE : D7=Nb de messages               ******************
*****************             MsgPtr initialisée + 0 à la fin ******************
********************************************************************************
Get_All_Msg
	lea LiveMsg(pc),a0
	lea Next_Rout(pc),a1
	lea MsgPtr(pc),a4		c la kon stocke les messy
	moveq #-1,d7
loop_all
	addq.w #1,d7
	bsr.s Get_Msg			va chercher le message suivant
	move.l a0,(a4)+			et on le stocke
	bne.s loop_all
	rts


********************************************************************************
***************** COMPTE TOUS LES MESSAGES POUR UNE RUBRIQUE  ******************
***************** EN ENTREE : LES CHAINES SONT INITIALISEES   ******************
***************** EN SORTIE : D7=Nb de messages               ******************
********************************************************************************
Count_Msg
	lea LiveMsg(pc),a0
	lea Next_Rout(pc),a1
	moveq #-1,d7
count_all
	addq.w #1,d7
	bsr.s Get_Msg			va chercher le message suivant
	bne.s count_all
	rts


********************************************************************************
****************** ROUTINE QUI RECHERCHE LE MESSAGE SUIVANT  *******************
****************** EN ENTREE : A0=PTR SUR UN MESSAGE         *******************
******************             A1=PTR SUR ROUTINE DE SKIP    *******************
******************             LES CHAINES SONT INITIALISEES *******************
****************** EN SORTIE : A0=PTR SUR LE MESSAGE SUIVANT *******************
******************             Z=0 si A0 valide, Z=1 sinon   *******************
********************************************************************************
Get_Msg
	jmp (a1)			passe au message suivant
skip_return
	tst.b (a0)
	bne.s not_end_MsgList
	tst.b SKIP_CLIPART(a0)
	beq error_Msg			pas de message => on sort !!

*-----------------> regarde si la chaine search est dans le message (a2)
not_end_MsgList
	moveq #7-1,d0			recherche la chaine search dans le msg
	lea SKIP_CLIPART(a0),a2
	move.b SearchStr(pc),d1		recherche le 1er char de SearchStr
	beq.s search_found
search_beginning
	lea SearchStr+1(pc),a3
search_start
	move.b (a2)+,d2
	beq.s not_in_str
	CONVERT_UPCASE d1
	CONVERT_UPCASE d2
	cmp.b d1,d2			la lettre est trouvée ?
	bne.s search_start
cmp_search
	move.b (a3)+,d2			regarde si le reste correspond
	beq.s search_found
	move.b (a2)+,d3
	beq.s not_in_str
	CONVERT_UPCASE d2
	CONVERT_UPCASE d3
	cmp.b d2,d3
	beq.s cmp_search
	subq.l #1,a2
	bra.s search_beginning
not_in_str
	dbf d0,search_beginning
	bra.s Get_Msg

*-----------------> le message contient la chaine SearchStr
*-----------------> regarde maintenant si le message correspond à la section
search_found
	lea SKIP_CLIPART(a0),a2
	move.w OptionNumber(pc),d0	on est dans quelle section ?
	bpl.s skip_section		recherche bestiale ??
	bra.s return_Msg

*----------------> regarde si le message correspond à la section
loop_skip_section
	tst.b (a2)+			recherche la section dans le message
	bne.s loop_skip_section
skip_section
	dbf d0,loop_skip_section

	lea OptionStr(pc),a3
cmp_option
	move.b (a3)+,d0			compare l'option à la chaine
	beq.s check_end_section		alors le msg est bon ?
	move.b (a2)+,d1
	CONVERT_UPCASE d0
	CONVERT_UPCASE d1
	cmp.b d0,d1
	beq.s cmp_option
	bra Get_Msg

check_end_section
	tst.b (a2)			ya un zero à la fin ?
	bne Get_Msg

return_Msg
	move.l a0,d0			message actuel + Z=1
	rts

error_Msg
	moveq #0,d0			pas de message + Z=0
	move.l d0,a0
	rts

********************************************************************************
************** ROUTINES POUR PASSER AU MESSAGE D'AVANT ET D'APRES **************
************** EN ENTREE : A0=PTR SUR LE MESSAGE ACTUEL           **************
************** EN SORTIE : A0=PTR SUR LE MESSAGE SUIVANT          **************
********************************************************************************
Next_Rout
	moveq #7-1,d0			passe au message suivant
.next_msg
	tst.b (a0)+
	bne.s .next_msg
	dbf d0,.next_msg
	bra skip_return

Previous_Rout
	moveq #7-1,d0			passe au message d'avant
	subq.l #1,a0
.previous_msg
	tst.b -(a0)
	bne.s .previous_msg
	dbf d0,.previous_msg
	addq.l #1,a0			à cause du pré-décrémenté
	bra skip_return
	
*-----------------------> datas pour la routine de recherche
OptionNumber	dc.w 0			option pour la recherche des msg
SearchStr	dcb.b MAXSTR+1,0	chaine à rechercher dans le msg
OptionStr	dcb.b MAXSTR+1,0	rubrique des messages
MsgPtr		dcb.l MAXPTR+1,0	espace pour des pointeurs
