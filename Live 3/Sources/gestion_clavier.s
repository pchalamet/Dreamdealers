
*			Gestion du clavier pour LIVE
*			~~~~~~~~~~~~~~~~~~~~~~~~~~~~

KB_SIZE=32

* Routine d'initialisation du clavier AVANT celle de la musique
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Keyboard_init
	move.b #$7f,ciaaicr			vire CIA-A ICR
	move.b #$7f,ciabicr			vire CIA-B ICR
	bclr #0,ciabcra				arrete le timer A
	move.b #$78,ciabtalo			delay pour 85 microsecondes
	move.b #$00,ciabtahi			le timer démare => on attend
	move.b #$98,ciabcra			one-shot + stop + force load
	move.b #$88,ciaaicr			IT quand SP recu
	move.b #$81,ciabicr			IT quand CIA-B timer A = 0
	rts

* IT appellée quand le clavier envoie une touche
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IT_Keyboard_1
	moveq #0,d0
	move.b ciaasdr,d0			lit la touche recue
	bset #6,ciaacra				met SP en sortie (handshaking)
	bset #0,ciabcra				démarre le CIA-B timer A

	not.b d0				\ récupère le bon Code
	ror.b #1,d0				/

	move.w d0,d1				recherche le code dans la
	and.w #$7f,d1				matrice du clavier
	lsr.w #3,d1				d1=Code / 8

	lea KB_Mat(pc),a0
	bclr #7,d0
	bne.s .KeyUp
.KeyDown
	bset d0,(a0,d1.w)			touche enfoncée : met le bit
	move.w KB_Pos(pc),d1
	cmp.w #KB_SIZE,d1			euh... ya encore de la place ?
	beq.s .KB_exit
	addq.w #1,KB_Pos-data_base(a5)
	lea KB_Buffer(pc),a0
	move.b d0,(a0,d1.w)
	bra.s .KB_exit
.KeyUp
	bclr d0,(a0,d1.w)
.KB_exit
	rts


* IT appellée quand le CIA-B timer A a fini de compter
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IT_Keyboard_2
	bclr #6,ciaacra				met SP en entrée
	rts

* Routine pour lire la dernière touche appuyée
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GetKey
	move.w KB_Pos(pc),d0
	subq.w #1,d0
	bmi.s .no_key
	move.w d0,KB_Pos-data_base(a5)
	lea KB_Buffer(pc),a0
	move.b (a0,d0.w),d0
.no_key	rts

* Routine pour voir si une touche est appuyée ou non
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*  -->	d0.b=Code
*  <--	Z according to Key
TestKey
	and.w #$7f,d0
	move.w d0,d1
	lsr.w #3,d1
	lea KB_Mat(pc),a0
	btst d0,(a0,d1.w)
	rts
