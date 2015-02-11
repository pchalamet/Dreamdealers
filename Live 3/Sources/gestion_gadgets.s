
*			Gestion des gadgets de Live II
*			-------------------------------->



*****************************************************************************
***************************** GESTION DES GADGETS ***************************
*****************************************************************************
gestion_gadgets
	cmp.w #PART2*2,MouseY-data_base(a5)
	blt.s .no_border_move
	cmp.w #PART3*2,MouseY-data_base(a5)
	bge.s .no_border_move
	tst.w MouseX-data_base(a5)
	seq d0
	or.b d0,Go_Left_Flag-data_base(a5)
	cmp.w #SCREEN_X-1,MouseX-data_base(a5)
	seq d0
	or.b d0,Go_Right_Flag-data_base(a5)
.no_border_move
	move.b #NO_SHORTCUT,Gadget_Key-data_base(a5)

	move.w Left_Mousebutton(pc),d3		état des boutons souris
	movem.w MouseX(pc),d1-d2		position X et Y
	lsr.w #1,d2
	lea HitBox_List0(pc),a0
	move.w (a0)+,d0				nombre de gadgets
loop_find_gadget
	move.l a0,a1				sauve GadgetStruct

	tst.w (a0)+				le gadget est actif ?
	bne.s gadget0
	lea gs_SIZEOF-gs_Left(a0),a0
	dbf d0,loop_find_gadget
gadgets_exit
	rts
gadget0
	cmp.w (a0)+,d1				bord gauche
	bge.s gadget1
	lea gs_SIZEOF-gs_Top(a0),a0		passe au gadget suivant
	dbf d0,loop_find_gadget
	rts
gadget1
	cmp.w (a0)+,d2				bord haut
	bge.s gadget2
	lea gs_SIZEOF-gs_Right(a0),a0
	dbf d0,loop_find_gadget
	rts
gadget2
	cmp.w (a0)+,d1				bord droit
	ble.s gadget3
	addq.l #gs_SIZEOF-gs_Bottom,a0
	dbf d0,loop_find_gadget
	rts
gadget3
	cmp.w (a0)+,d2				bord bas
	ble.s that_is_this_gadget
	addq.l #gs_SIZEOF-gs_Button,a0
	dbf d0,loop_find_gadget
	rts

that_is_this_gadget
	move.w (a0)+,d5				récupère le masque des boutons
	and.w d3,d5				les boutons sont bons ?
	bne.s execute_routine
	addq.l #gs_SIZEOF-gs_Routine,a0
	dbf d0,loop_find_gadget
	rts

execute_routine
	move.l (a0),d0				execute la fonction
	jsr (a1,d0.l)
	bra wait_gadget_up
