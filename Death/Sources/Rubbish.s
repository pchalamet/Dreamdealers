***********
* les EQU *
***********
check_EQU
	move.b (a0)+,d0
	beq ErrorPrototype			fin de ligne prématurée ?
	cmp.b #10,d0
	beq ErrorPrototype
	cmp.b #";",d0				fin de ligne ?
	beq ErrorPrototype
	cmp.b #" ",d0				espace ?
	beq.s check_EQU
	cmp.b #9,d0				tabulation ?
	beq.s check_EQU
	subq.l #1,a0				un en trop !


* on doit normalement tomber sur le nom de l'EQU
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.dup_EQU
	move.b (a0)+,d0				recopie le nom de la variable
	beq ErrorPrototype
	cmp.b #10,d0
	beq ErrorPrototype
	cmp.b #",",d0
	beq.s .dupped

	cmp.b #"A",d0				c'est du A-Z ?
	blt ErrorPrototype
	cmp.b #"Z",d0
	ble.s .char_ok

	cmp.b #"a",d0				c'est du a-z ?
	blt ErrorPrototype
	cmp.b #"z",d0
	bgt ErrorPrototype
.char_ok
	move.b d0,(a1)+
	bra.s .dup_EQU
.dupped
	clr.b (a1)+				chaine C dans DataSpace
	subq.l #1,a0				un en trop !

* recherche maintenant le deuxieme argument cad la valeur à associer à cette variable
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.search
	move.b (a0)+,d0
	beq ErrorPrototype			fin de ligne prématurée ?
	cmp.b #10,d0
	beq ErrorPrototype
	cmp.b #" ",d0				espace ?
	beq.s .search
	cmp.b #9,d0				tabulation ?
	beq.s .search

	cmp.b #"0",d0				c'est un entier ?
	blt.s EQU_not_INT
	cmp.b #"9",d0
	bgt.s EQU_not_INT

* c'est un entier
* ~~~~~~~~~~~~~~~
	subq.l #1,a0
	bsr Read_Integer

	addq.w #1,NbArgs
	move.l d0,-(sp)

	movem.l a0/a1,-(sp)
	move.l #Integer_SIZEOF,d0		alloue de la place mémoire
	move.l #MEMF_ANY|MEMF_CLEAR,d1
	CALL _ExecBase(a5),AllocMem
	movem.l (sp)+,a0/a1
	tst.l d0
	beq ErrorMemory

	move.l d0,a3
	lea DataSpace(pc),a2			recopie le nom de l'EQU dans sa structure
.dup	move.b (a2)+,(a3)+
	bne.s .dup

	move.l d0,a3
	move.l (sp)+,int_Value(a3)
	move.l IntegerList(a5),int_Next(a3)
	move.l a3,integerList(a5)
	bra check_end_EQU

EQU_not_INT
	cmp.b #'"',d0
	bne ErrorPrototype

* c'est une chaine
* ~~~~~~~~~~~~~~~~
	move.l a1,a3
	bsr Read_Str

	movem.l a0/a1,-(sp)
	move.l #Str_SIZEOF,d0			alloue de la place mémoire
	move.l #MEMF_ANY|MEMF_CLEAR,d1
	CALL _ExecBase(a5),AllocMem
	movem.l (sp)+,a0/a1
	tst.l d0
	beq ErrorMemory

	movem.l d0/a3,-(sp)			sauve adr struct & le ptr chaine EQU
	lea DataSpace(pc),a2
	move.l d0,a3
.dup	move.b (a2)+,(a3)+
	bne.s .dup

	movem.l (sp)+,a2/a3
	move.l a2,d0
.dup2	move.b (a2)+,(a3)+
	bne.s .dup2

	move.l d0,a3
	move.l StringList(a5),str_Next(a3)
	move.l a3,StringList(a5)
	bra check_end_EQU



check_end_EQU
	moveq #0,d7



