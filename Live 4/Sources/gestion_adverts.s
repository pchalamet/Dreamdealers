gestion_adverts
	tst.b Go_Left_Flag-data_base(a5)
	beq.s Advert_NoLeft

	clr.b Go_Left_Flag-data_base(a5)
	move.l Advert_Ptr(pc),a0		recherche déja l'advert
	bsr Find_Previous_Advert		d'avant
	beq Advert_Nothing
	pea (a0)
	bsr Find_Previous_Advert
	pea (a0)
	bne.s .display
	move.l 4(sp),(sp)			met sur le coté gauche
	move.l Advert_Ptr(pc),4(sp)		met sur coté droit
.display
	bsr Clear_Middle_Screen
	move.l (sp)+,a0
	move.l a0,Advert_Ptr-data_base(a5)
	moveq #1,d0
	bsr Display_Text
	move.l (sp)+,a0
	moveq #41,d0
	bsr Display_Text
	st Flip_Flag-data_base(a5)
	WAIT_VBL
	rts
	
Advert_NoLeft
	tst.b Go_Right_Flag-data_base(a5)
	beq.s Advert_Nothing

	clr.b Go_Right_Flag-data_base(a5)
	move.l Advert_Ptr(pc),a0		recherche déja l'advert
	bsr Find_Next_Advert			d'apres
	pea (a0)
	bsr Find_Next_Advert
	pea (a0)
	bne.s .display
	move.l 4(sp),(sp)			affiche coté droit
	move.l Advert_Ptr(pc),4(sp)		affiche coté gauche

.display
	bsr Clear_Middle_Screen
	move.l (sp)+,a0
	moveq #41,d0
	bsr Display_Text
	move.l (sp)+,a0
	move.l a0,Advert_Ptr-data_base(a5)
	moveq #1,d0
	bsr Display_Text
	st Flip_Flag-data_base(a5)
	WAIT_VBL
	
Advert_Nothing
	rts

Advert_Ptr
	dc.l HalfAdverts_List+2


*****************************************************************************
************************* RECHERCHE DE L'ADVERT D'AVANT *********************
************************* en entrée: a0=ptr advert      *********************
************************* en sortie: a0=ptr advert      *********************
*****************************************************************************
Find_Previous_Advert
	move.l a0,a1
	subq.l #1,a1				pointe le 0 de fin d'advert
	tst.b -1(a1)				ya encore un 0 ?
	beq.s .no_previous
.loop_find_previous
	tst.b -(a1)				recherche l'advert d'avant
	bne.s .loop_find_previous
	lea 1(a1),a0				saute le 0 trouvé
	moveq #-1,d0
.no_previous
	rts



*****************************************************************************
************************* RECHERCHE DE L'ADVERT D'AVANT *********************
************************* en entrée: a0=ptr advert      *********************
************************* en sortie: a0=ptr advert      *********************
*****************************************************************************
Find_Next_Advert
	moveq #0,d0
	move.l a0,a1
.loop_find_next
	tst.b (a1)+				cherche le 0 suivant
	bne.s .loop_find_next
	tst.b (a1)				yen a un juste après ?
	beq.s .no_next
	move.l a1,a0
	rts


