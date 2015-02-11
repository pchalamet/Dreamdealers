
*		Convertisseur pour la font pour le damier
*		-----------------------------------------

	incdir "dH1:Lipton/RAW/"


	lea Font(pc),a0
	lea Start,a1
	moveq #58*2-1,d0
dup_all
	lea 80(a1),a2
	moveq #20-1,d1
dup_line
	move.l (a0),(a1)+
	move.l (a0)+,(a2)+
	dbf d1,dup_line

	move.l a2,a1
	dbf d0,dup_all
	rts

Font
	incbin "Font.RAW"
Start
	dcb.b 80*58*2*2
End

