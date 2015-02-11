
*			Routines utiles pour Live
*			~~~~~~~~~~~~~~~~~~~~~~~~~


wait_buttons_up
	tst.w Left_Mousebutton-data_base(a5)
	bne.s wait_buttons_up
	rts

wait_gadget_up
	tst.w Left_Mousebutton-data_base(a5)
	bne.s wait_gadget_up

	move.b Gadget_Key(pc),d0
	cmp.b #NO_SHORTCUT,d0
	beq.s .ok
.wait	bsr TestKey
	bne.s .wait
.ok	rts
	