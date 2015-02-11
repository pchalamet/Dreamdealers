
			*****************************
			* installation d'un handler *
			* pour éviter que tout ne   *
			* tombe dans l'écran du     *
			* workbench		    *
			*****************************

NEv_start
	lea NEv_io(pc),a0
	move.w #IOSTD_SIZE+MP_SIZE+IS_SIZE-1,d0
.clear
	clr.b (a0)+
	dbf d0,.clear

	clr.w KB_Pos-data_base(a5)
	movem.l d0-d7/a0-a6,-(sp)
	lea NEv_msg(pc),a2
	lea NEv_io(pc),a3
	lea NEv_int(pc),a4

	moveq #-1,d0
	CALL _ExecBase(pc),AllocSignal
	cmp.l #-1,d0
	beq LIVE_FAIL_INPUT_HANDLER

	move.l a2,a1
	move.b #NT_MSGPORT,LN_TYPE(a1)
	move.b #PA_SIGNAL,MP_FLAGS(a1)
	move.b d0,MP_SIGBIT(a1)
	move.l Live_Task(pc),MP_SIGTASK(a1)
	lea MP_MSGLIST(a1),a0
	move.l a0,(a0)				initialisation de la list du port
	addq.l #4,a0
;;	clr.l 4(a0)
	move.l a0,8(a0)
	CALL AddPort

	move.b #NT_MESSAGE,LN_TYPE(a3)
	move.l a2,MN_REPLYPORT(a3)

	lea NEv_name(pc),a0
	move.l a3,a1
	moveq #0,d0
	moveq #0,d1
	CALL OpenDevice

	lea NEv_Handler(pc),a0
	move.l a0,IS_CODE(a4)
	clr.l IS_DATA(a4)
	move.b #100,LN_PRI(a4)
	move.l a3,a1
	move.l a4,IO_DATA(a1)
	move.w #IND_ADDHANDLER,IO_COMMAND(a1)
	CALL DoIO
	movem.l (sp)+,d0-d7/a0-a6
	rts

NEv_stop
	movem.l d0-d7/a0-a6,-(sp)
	lea NEv_msg(pc),a2
	lea NEv_io(pc),a3
	lea NEv_int(pc),a4
	move.b MP_SIGBIT(a2),d0
	CALL _ExecBase(pc),FreeSignal

	move.l a3,a1
	move.l a4,IO_DATA(a1)
	move.w #IND_REMHANDLER,IO_COMMAND(a1)
	CALL DoIO
	move.l a3,a1
	CALL CloseDevice
	move.l a2,a1
	CALL RemPort
	movem.l (sp)+,d0-d7/a0-a6
	rts

* Le InputHandler pour LIVE
* ~~~~~~~~~~~~~~~~~~~~~~~~~
*  -->	A0=InputEvent
NEv_Handler
	move.l a2,-(sp)
	lea data_base(pc),a2

	move.l a0,d0				sauve InputEvent
	move.l a0,d2
	moveq #0,d3
.loop	move.b ie_Class(a0),d1			classe de l'event
	cmp.b #IECLASS_RAWMOUSE,d1		souris ? => poubelle
	beq.s .trash_mouse
	cmp.b #IECLASS_RAWKEY,d1		clavier ? => sauve code/poubelle
	beq.s .trash_key
	move.l d2,d3				on fait rien
	move.l ie_NextEvent(a0),d2		Event suivant
.next	move.l d2,a0				Z inchangé
	bne.s .loop				yen a d'autres ?
	move.l (sp)+,a2
	rts


* on utilise le deplacement souris de l'input device
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*  -->	a0=InputEvent
.trash_mouse
	move.w ie_X(a0),d7
	add.w d7,MouseX-data_base(a2)		regarde si la souris
	bge.s .X_mouse_ok1			est encore dans l'ecran
	clr.w MouseX-data_base(a2)
	bra.s .X_mouse_ok2
.X_mouse_ok1
	cmp.w #SCREEN_X-1,MouseX-data_base(a2)
	ble.s .X_mouse_ok2
	move.w #SCREEN_X-1,MouseX-data_base(a2)
.X_mouse_ok2
	move.w ie_Y(a0),d7
	add.w d7,MouseY-data_base(a2)
	bge.s .Y_mouse_ok1
	clr.w MouseY-data_base(a2)
	bra.s .remove_event
.Y_mouse_ok1
	cmp.w #SCREEN_Y*2-1,MouseY-data_base(a2)
	ble.s .remove_event
	move.w #SCREEN_Y*2-1,MouseY-data_base(a2)
	bra.s .remove_event
	

* on utilise la touche de l'input.device
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*  -->	a0=InputEvent
.trash_key
	move.w ie_Code(a0),d7
	and.w #$ff,d7
	move.w d7,d6
	and.w #$7f,d6
	lsr.w #3,d6

	lea KB_Mat(pc),a1
	bclr #IECODEB_UP_PREFIX,d7		touche enfoncé ?
	bne.s .KeyUp
.KeyDown
	bset d7,(a1,d6.w)			touche enfoncée : met le bit
	bne.s .remove_event			y était déja celle la ?
	move.w KB_Pos(pc),d6
	cmp.w #KB_SIZE,d6			euh... ya encore de la place ?
	beq.s .remove_event
	addq.w #1,KB_Pos-data_base(a2)
	lea KB_Buffer(pc),a1
	move.b d7,(a1,d6.w)
	bra.s .remove_event
.KeyUp	bclr d7,(a1,d6.w)


* routine qui se charge de virer un InputEvent de la liste simplement chainée
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.remove_event
	tst.l d3				yavait un Event avant ?
	beq.s .skip2				non => pas bouffe
	move.l d3,a1				A->B->C
	move.l ie_NextEvent(a0),d2
	move.l d2,ie_NextEvent(a1)		A->C
	bra .next
.skip2	move.l ie_NextEvent(a0),d0		saute normalement l'event
	move.l d0,a0
	bne .loop
	move.l (sp)+,a2
	rts


*********************************************************************************
NEv_io	ds.b IOSTD_SIZE
NEv_msg	ds.b MP_SIZE
NEv_int	ds.b IS_SIZE
NEv_name	dc.b "input.device",0
	even
