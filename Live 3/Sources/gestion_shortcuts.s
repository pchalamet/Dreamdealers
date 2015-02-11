
*			Gestion des shortcuts pour LIVE
*			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


gestion_shortcuts
	move.b #$43,d0				ENTER=PASSWORDS SECRETS
	bsr TestKey
	bne.s Check_PASSWORDS

no_enter
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

	tst.b (a0)+				il est actif ce shortcut ?
	bne.s shortcut0
	addq.l #scs_SIZEOF-scs_Code,a0
	dbf d0,loop_find_shortcut
shortcuts_exit
	rts
shortcut0
	cmp.b (a0)+,d1				c'est le même code ?
	beq.s that_is_this_shortcut
	addq.l #scs_SIZEOF-scs_Routine,a0
	dbf d0,loop_find_shortcut
	rts
that_is_this_shortcut
	move.b d1,Gadget_Key-data_base(a5)	sauve le code
	move.l (a0),d0				execute la fonction
	jsr (a1,d0.l)
	bra wait_gadget_up


Check_PASSWORDS
check_MOUSE
	move.w #$29,d0				M
	bsr TestKey
	beq.s not_MOUSE
	move.w #$18,d0				O
	bsr TestKey
	beq.s not_MOUSE
	move.w #$16,d0				U
	bsr TestKey
	beq.s not_MOUSE
	move.w #$21,d0				S
	bsr TestKey
	beq.s not_MOUSE
	move.w #$12,d0				E
	bsr TestKey
	beq.s not_MOUSE

	st Mouse_Flag-data_base(a5)
	rts

not_MOUSE
Check_PLANTE
	move.w #$19,d0				P
	bsr TestKey
	beq.s not_PLANTE
	move.w #$28,d0				L
	bsr TestKey
	beq.s not_PLANTE
	move.w #$10,d0				A
	bsr TestKey
	beq.s not_PLANTE
	move.w #$36,d0				N
	bsr TestKey
	beq.s not_PLANTE
	move.w #$14,d0				T
	bsr TestKey
	beq.s not_PLANTE
	move.w #$12,d0				E
	bsr TestKey
	beq.s not_PLANTE

	illegal					hahah...

not_PLANTE
	rts