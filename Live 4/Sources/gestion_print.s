*****************************************************************************
*************************     AFFICHAGE D'UN TEXT      **********************
************************* en entrée : a0=Text          **********************
*************************   messages: a2=*Ecran        **********************
*************************   messages: d7=couleur       **********************
*************************             d0=Offset ecran  **********************
*****************************************************************************
Display_Text
	move.l log_screen(pc),a2
	add.w #SCREEN_WIDTH*SCREEN_DEPTH*4,d0	saute qq lignes au début
	lea (a2,d0.w),a2			on écrit à partir d'ici
	move.w #"1",d7				couleur 1 par défaut
Display_Text_Message
	lea Fonts_List,a1			fonte par defaut
	move.l a1,Text_Font-data_base(a5)
	move.w fs_Size(a1),d1
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d1
	move.l d1,Text_Line_Offset-data_base(a5)
	move.l a2,Text_Origin-data_base(a5)
	move.l a2,Text_Margin-data_base(a5)
	move.l #SCREEN_WIDTH*SCREEN_DEPTH*9,Text_Line_Offset-data_base(a5)
loop_display_Text
	moveq #0,d0
	move.b (a0)+,d0				lit un char de l'advert
	beq.s .display_Text_exit		on sort ?
	cmp.b #10,d0				char return ?
	beq.s .Return
	cmp.b #"°",d0				on change de couleurs ?
	beq.s .Color
	cmp.b #"£",d0				on fait un locate ?
	beq.s .Locate
	cmp.b #9,d0				une tabulation ?
	beq .Tab
	cmp.b #"§",d0				changement de fonte ?
	beq .SetFont

	sub.b #"!",d0				! est la base des fontes
	blt.s .space				espace ?

	lsl.w #3,d0				mulu #8,d0
	lea fs_Chars(a1,d0.w),a3		pointe la bonne lettre
	move.b (a3)+,(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH*2(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH*3(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH*4(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH*5(a2)
	move.b (a3)+,SCREEN_WIDTH*SCREEN_DEPTH*6(a2)
	move.b (a3),SCREEN_WIDTH*SCREEN_DEPTH*7(a2)
.space	addq.l #1,a2
	bra.s loop_display_Text
.display_Text_exit
	rts

.Return
	move.l Text_Margin(pc),a2
	add.l Text_Line_Offset(pc),a2
	move.l a2,Text_Margin-data_base(a5)
	bra.s loop_display_Text

.Color
	move.b (a0)+,d0				lit la couleur
	sub.w d7,d0
	beq.s loop_display_Text
	add.w d0,d7
	muls #SCREEN_WIDTH,d0			nouvel offset couleur
	add.l d0,a2
	add.l d0,Text_Margin-data_base(a5)
	bra loop_display_Text

.Locate
	move.l Text_Origin(pc),a2		SYNTAXE: £XX-YYY
	move.b (a0)+,d0				lit d'abord la position XX
	sub.b #"0",d0
	mulu.w #10,d0
	add.b (a0)+,d0
	sub.b #"0",d0
	lea (a2,d0.w),a2			LOCATE fait sur les X
	addq.l #1,a0				saute le '-'
	move.b (a0)+,d0				lit ensuite la position YYY
	sub.b #"0",d0
	mulu #100,d0
	moveq #0,d1
	move.b (a0)+,d1
	sub.b #"0",d1
	mulu #10,d1
	add.w d1,d0
	add.b (a0)+,d0
	sub.b #"0",d0
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d0
	move.w d7,d1
	sub.w #"1",d1
	mulu #SCREEN_WIDTH,d1
	add.l d1,d0
	lea (a2,d0.l),a2			locate fait sur les Y
	move.l a2,Text_Margin-data_base(a5)
	bra loop_display_Text

.Tab
	addq.l #8,a2
	bra loop_display_Text

.SetFont
	moveq #0,d0				lit le numero de la fonte
	move.b (a0)+,d0
	sub.b #"1",d0
	mulu #fs_SIZEOF,d0
	lea Fonts_List,a1
	lea (a1,d0.l),a1			datas de la fonte
	move.w fs_Size(a1),d0			calcule la taille de la fonte
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d0
	move.l d0,Text_Line_Offset-data_base(a5)
	bra loop_display_Text



*****************************************************************************
*************************      AFFICHAGE D'UN TEXT     **********************
*************************        pour les menus        **********************
************************* en entrée : a0=Text          **********************
*************************             d0=Offset ecran  **********************
*****************************************************************************
Display_Text_Menu
	lea Fonts_List,a1			fonte par defaut
	move.l a1,Text_Font-data_base(a5)
	move.w fs_Size(a1),d1
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d1
	move.l d1,Text_Line_Offset-data_base(a5)
	move.l log_screen(pc),a2
	add.w #SCREEN_WIDTH*SCREEN_DEPTH*4,d0	saute qq lignes au début
	lea (a2,d0.w),a2			on écrit à partir d'ici
	move.l a2,Text_Origin-data_base(a5)
	move.l a2,Text_Margin-data_base(a5)
	move.l #SCREEN_WIDTH*SCREEN_DEPTH*9,Text_Line_Offset-data_base(a5)
	move.w #"1",d7				couleur 1 par défaut
loop_display_Text_Menu
	moveq #0,d0
	move.b (a0)+,d0				lit un char de l'advert
	beq .display_Text_exit			on sort ?
	cmp.b #10,d0				char return ?
	beq .Return
	cmp.b #"°",d0				on change de couleurs ?
	beq .Color
	cmp.b #"£",d0				on fait un locate ?
	beq .Locate
	cmp.b #9,d0				une tabulation ?
	beq .Tab
	cmp.b #"§",d0				changement de fonte ?
	beq .SetFont

	sub.b #"!",d0				! est la base des fontes
	blt.s .space				espace ?

	lsl.w #3,d0				mulu #8,d0
	lea fs_Chars(a1,d0.w),a3		pointe la bonne lettre
	move.b (a3)+,d0
	or.b d0,(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*2(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*3(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*4(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*5(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*6(a2)
	move.b (a3)+,d0
	or.b d0,SCREEN_WIDTH*SCREEN_DEPTH*7(a2)

	move.b d7,d1				couleur actuelle
	sub.b #"1",d1
	moveq #-1,d0
	bclr d1,d0				BPL non utilisés par la couleur

	lea SCREEN_WIDTH*SCREEN_DEPTH*7(a2),a4	recherche le BPL 1
	tst.b d1				couleur 1 ?
	beq.s .do_not
	lea -SCREEN_WIDTH+SCREEN_WIDTH*SCREEN_DEPTH*7(a2),a4
	subq.b #1,d1				couleur 2 ?
	beq.s .do_not				sinon couleur 3
	lea -SCREEN_WIDTH*2+SCREEN_WIDTH*SCREEN_DEPTH*7(a2),a4
.do_not
	moveq #8-1,d1				8 lignes pour une lettre
.not_char
	move.b -(a3),d2				lit un octet de la lettre
	not.b d2				fabrication du mask de la lettre
	move.b d0,d3				mask BPL actuel

	moveq #3-1,d4				ya 3 BPL à masker
.not_line
	lsr.b #1,d3				il faut masker le bpl ?
	bcc.s .skip				nan...
	and.b d2,(a4)				bon.. on mask
.skip	lea SCREEN_WIDTH(a4),a4
	dbf d4,.not_line			boucle pour les 3 BPL
	lea -SCREEN_WIDTH*(SCREEN_DEPTH+3)(a4),a4
	dbf d1,.not_char			boucle pour tout la lettre

.space	addq.l #1,a2
	bra loop_display_Text_Menu
.display_Text_exit
	rts

.Return
	move.l Text_Margin(pc),a2
	add.l Text_Line_Offset(pc),a2
	move.l a2,Text_Margin-data_base(a5)
	bra loop_display_Text_Menu

.Color
	move.b (a0)+,d0				lit la couleur
	sub.w d7,d0
	beq loop_display_Text_Menu
	add.w d0,d7
	muls #SCREEN_WIDTH,d0			nouvel offset couleur
	add.l d0,a2
	add.l d0,Text_Margin-data_base(a5)
	bra loop_display_Text_Menu

.Locate
	move.l Text_Origin(pc),a2		SYNTAXE: £XX-YYY
	move.b (a0)+,d0				lit d'abord la position XX
	sub.b #"0",d0
	mulu.w #10,d0
	add.b (a0)+,d0
	sub.b #"0",d0
	lea (a2,d0.w),a2			LOCATE fait sur les X
	addq.l #1,a0				saute le '-'
	move.b (a0)+,d0				lit ensuite la position YYY
	sub.b #"0",d0
	mulu #100,d0
	moveq #0,d1
	move.b (a0)+,d1
	sub.b #"0",d1
	mulu #10,d1
	add.w d1,d0
	add.b (a0)+,d0
	sub.b #"0",d0
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d0
	move.w d7,d1
	sub.w #"1",d1
	mulu #SCREEN_WIDTH,d1
	add.l d1,d0
	lea (a2,d0.l),a2			locate fait sur les Y
	move.l a2,Text_Margin-data_base(a5)
	bra loop_display_Text_Menu

.Tab
	addq.l #8,a2
	bra loop_display_Text_Menu

.SetFont
	moveq #0,d0
	move.b (a0)+,d0
	mulu #fs_SIZEOF,d0
	lea Fonts_List,a1
	lea (a1,d0.l),a1
	move.w fs_Size(a1),d0
	mulu #SCREEN_WIDTH*SCREEN_DEPTH,d0
	move.l d0,Text_Line_Offset-data_base(a5)
	bra loop_display_Text_Menu



*****************************************************************************
*************** ECRITURE D'UNE LIGNE DANS LA BARRE DU HAUT ******************
*************** en entrée : a0=Text                        ******************
*****************************************************************************
Display_Text_Barre
	bsr Dup_Text_Barre

	lea Text_Barre(pc),a0
	lea Font_MicroKnight,a1
	lea Board_Top+SCREEN_WIDTH*SCREEN_DEPTH*6+8,a2
.loop_display_Text_Barre
	moveq #0,d0
	move.b (a0)+,d0
	beq.s .exit				on sort ?

	sub.b #"!",d0				! est la base des fontes
	blt.s .space				espace ?
	lsl.w #3,d0				mulu #8,d0
	lea fs_Chars(a1,d0.w),a3

;	tst.w DZign_Number-data_base(a5)
;	bne.s .DZign1
;.DZign0
;	moveq #0,d1
;	move.w #SCREEN_WIDTH*2,d2
;	moveq #8-1,d3
;.put0	move.b (a3),(a2,d1.w)
;	move.b (a3)+,(a2,d2.w)
;	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d1
;	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d2
;	dbf d3,.put0
;	bra.s .space

.DZign1
	moveq #0,d1
	moveq #SCREEN_WIDTH,d2
	move.w #SCREEN_WIDTH*2,d3
	move.w #SCREEN_WIDTH*3,d4
	moveq #8-1,d5
.put1	move.b (a3)+,d6
	not.b d6
	and.b d6,(a2,d1.w)
	and.b d6,(a2,d2.w)
	and.b d6,(a2,d3.w)
	and.b d6,(a2,d4.w)
	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d1
	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d2
	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d3
	add.w #SCREEN_WIDTH*SCREEN_DEPTH,d4
	dbf d5,.put1

.space	addq.l #1,a2
	bra.s .loop_display_Text_Barre
.exit	rts


Dup_Text_Barre
	lea Text_Barre(pc),a1
.dup	move.b (a0)+,(a1)+
	bne.s .dup
	rts



*****************************************************************************
********************** ECRITURE D'UN NOMBRE EN DECIMAL **********************
********************** en entrée : a0=ou on l'écrit    **********************
**********************             d0.l=Nbre           **********************
*****************************************************************************
Write_Number
	divu #1000,d0				calcul les milliers
	move.b d0,d1
	bne.s .write0
	move.b #" "-"0",d0
.write0	add.b #"0",d0
	move.b d0,(a0)+
	clr.w d0
	swap d0
	divu #100,d0				calcule les centaines
	bne.s .write1
	tst.b d1
	bne.s .write1
	move.b #" "-"0",d0
.write1	add.b #"0",d0
	move.b d0,(a0)+
	clr.w d0
	swap d0
	divu #10,d0				calcule les dizaines
	bne.s .write2				égal à 0 ?
	tst.b d1				c'est un 0 => on a koi avant ?
	bne.s .write2
	move.b #" "-"0",d0
.write2	add.b #"0",d0
	move.b d0,(a0)+
.skip2	swap d0					calcule les unités
	add.b #"0",d0
	move.b d0,(a0)
	rts

