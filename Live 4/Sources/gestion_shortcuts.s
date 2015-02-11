
*			Gestion des shortcuts pour LIVE
*			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


gestion_shortcuts
	move.b #$66,d0				Amiga gauche préssée ?
	bsr TestKey
	beq.s no_left_amiga
	lea ShortCut_List1(pc),a0
	bra.s examine_shortcuts
no_left_amiga
	lea ShortCut_List0(pc),a0
examine_shortcuts
	move.l a0,-(sp)
	bsr GetKey				lit une touche
	move.b d0,d1
	move.l (sp)+,a0
	move.w (a0)+,d0				nombre de shortcuts
loop_find_shortcut
	move.l a0,a1

	cmp.b (a0)+,d1				c'est le même code ?
	beq.s that_is_this_shortcut
	addq.l #scs_SIZEOF-scs_Type,a0
	dbf d0,loop_find_shortcut
shortcuts_exit
	rts
that_is_this_shortcut
	move.b d1,Gadget_Key-data_base(a5)	sauve le code de touche
	move.l scs_Routine-scs_Type(a0),d0	adresse relative de la fonction
	tst.b (a0)+				type du shortcut ?
	beq.s .shortcut_immediate
.shortcut_defered
	movem.l d0/a1,-(sp)
	bsr wait_gadget_up
	movem.l (sp)+,d0/a1
	jmp (a1,d0.l)

.shortcut_immediate
	jsr (a1,d0.l)
	bra wait_gadget_up
