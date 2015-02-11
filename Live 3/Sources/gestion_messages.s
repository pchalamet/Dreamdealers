
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
LEFT_BORDER=1
RIGHT_BORDER=2
GOTOXY=3
SET_COLOR=4
SET_FONT=5
LF=10

*---------------------> equ divers
NO_CLIPART=1
COUNT_CLIPART set NO_CLIPART
MAXSTR=20		longueur max des chaines de recherche
; pas plus de 1024 messages pour une personne et
; pas plus de 1024 Noms,Groupes ou Pays ( suffisant nan ????!! )
MAXPTR=1024
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
