
*	Root pour l'overlay
*	--------------------->  1993 Sync/TSB


	XREF LIVETRO
	XDEF _DOSBASE

	section begin,code
ROOT
	lea DosName(pc),a1
	moveq #0,d0
	move.l 4.w,a6
	jsr -552(a6)				OpenLibrary
	move.l d0,_DosBase
	bne.s dos_opened
	rts
dos_opened
	move.l d0,a6
	jsr -60(a6)				Output
	move.l d0,_StdOut

	move.l #TaskName,d1			name
	moveq #0,d2				priority
	move.l #Writer,d3			adr APTR du Segment
	lsr.l #2,d3				met en BCPL..
	move.l #2048,d4				stack size
	jsr -138(a6)				crée un Process
	tst.l d0				erreur dans CreateProc ?
	beq.s end_writer

	jmp LIVETRO				saute a la demo

	cnop 0,4
Writer
	dc.l 0
	move.l _StdOut(pc),d7
	lea Text(pc),a5
	move.l _DosBase(pc),a6
loop_write
	move.l d7,d1
	move.l a5,d2
	moveq #1,d3
	jsr -48(a6)				Write
	moveq #1,d1
	jsr -198(a6)				Delay
	addq.l #1,a5
	tst.b (a5)
	bne.s loop_write
end_writer
	move.l a6,a1
	move.l 4.w,a6
	jsr -414(a6)				CloseLibrary
	moveq #0,d0
	move.l d0,_DOSBASE			signal la fin
	rts

_DosBase
	dc.l 0
_StdOut
	dc.l 0

DosName	dc.b "dos.library",0

TaskName
	dc.b "»» Live Supportro 2  ©1993 Sync/TSB ««",0
Text	include "Message.s"
	dc.b 0
