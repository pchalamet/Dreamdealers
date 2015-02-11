
*				la 3d pour Pipeline
*				~~~~~~~~~~~~~~~~~~~



* les includes
* ~~~~~~~~~~~~
	incdir "Pipeline:"
	incdir "asm:sources/"
	include "registers.i"



	section molo,code

	KILL_SYSTEM do_3d
	moveq #0,d0
	rts

do_3d
	lea data_base,a5
	lea _Custom,a6

	move.l #vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	clr.w copjmp1(a6)

	move.w #$83c0,dmacon(a6)
	move.w #$8020,intena(a6)

	WAIT_LMB_DOWN
	RESTORE_SYSTEM

vbl
	SAVE_REGS

	lea data_base,a5
	lea _Custom,a6

	bsr Setup_Screen
	moveq #-12,d0
	moveq #10,d1
	moveq #4,d2
	bsr Incrize_Angles
	bsr Compute_Matrix			calcul la matrice de rotation
	bsr Compute_Dots			points 3d -> 2d
	bsr Display_Dots			afficher le cube

	move.w #$0020,intena(a6)
	RESTORE_REGS
	rte

