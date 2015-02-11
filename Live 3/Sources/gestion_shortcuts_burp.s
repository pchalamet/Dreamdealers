
*			Gestion des shortcuts pour LIVE
*			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


gestion_shortcuts
	bsr check_hidden_ra

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




* Un petit shortcut pour ce bon vieux RA !!
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
check_hidden_ra
	move.b #$13,d0				test le R
	bsr TestKey
	beq .no_ra
	move.b #$10,d0				test le A
	bsr TestKey
	beq .no_ra

	move.b HP_State(pc),d0
	move.w d0,-(sp)
	st HP_State-data_base(a5)
	jsr mt_end
	WAIT_VBL
	WAIT_VBL

	move.l #Burp,aud0lcH(a6)
	move.w #Burp_size/2,aud0len(a6)
	move.w #428,aud0per(a6)
	move.w #64,aud0vol(a6)

	move.l #Burp,aud1lcH(a6)
	move.w #Burp_size/2,aud1len(a6)
	move.w #428,aud1per(a6)
	move.w #64,aud1vol(a6)

	move.l #Burp,aud2lcH(a6)
	move.w #Burp_size/2,aud2len(a6)
	move.w #428,aud2per(a6)
	move.w #64,aud2vol(a6)

	move.l #Burp,aud3lcH(a6)
	move.w #Burp_size/2,aud3len(a6)
	move.w #428,aud3per(a6)
	move.w #64,aud3vol(a6)

	move.w #$800f,dmacon(a6)
	WAIT_VBL
	WAIT_VBL
	move.w #1,aud0len(a6)
	move.w #1,aud1len(a6)
	move.w #1,aud2len(a6)
	move.w #1,aud3len(a6)

.loop_ra
	move.b #$13,d0				test le R
	bsr TestKey
	bne.s .loop_ra
	move.b #$10,d0				test le A
	bsr TestKey
	bne.s .loop_ra

	move.w #$000f,dmacon(a6)
	move.w (sp)+,d0
	move.b d0,HP_State-data_base(a5)	
.no_ra
	rts