
*				Menu de PipeLine
*				~~~~~~~~~~~~~~~~
*			code (c) 1994 Sync/DreamDealers



* options de compilations ( devpac 3 )
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	OPT P=68000
	OPT O+,OW-
	OPT NODEBUG,NOLINE

	OUTPUT ram:Pipeline

DATA_OFFSET=$7ffe
PIPELINE_DEBUG=0



* les chemins d'accés aux fichiers + includes
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	incdir "Pipeline:"
	incdir "Pipeline:sources/"
	incdir "Pipeline:gfx/"
	incdir "include:"

	include "exec/exec_lib.i"
	include "exec/memory.i"
	include "dos/dos_lib.i"
	include "dos/dos.i"
	include "graphics/gfxbase.i"

	include "libraries/village_lib.i"
	include "hardware/custom.i"
	include "hardware/cia.i"
	include "misc/macros.i"


WAIT_BLITTER	macro
	btst #6,dmaconr(a6)
.wait_blitter\@
	btst #6,dmaconr(a6)
	bne.s .wait_blitter\@
	endm



* Quelques EQU pour les ecrans etc..
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SCREEN_X=640
SCREEN_Y=256
SCREEN_DEPTH=4
SCREEN_WIDTH=SCREEN_X/8

SELECTOR_WIDTH=40
SELECTOR_X=20*8
SELECTOR_Y=110

MAX_DEMOS=20


* le point d'entrée
* ~~~~~~~~~~~~~~~~~
	section Pipeline,code
Main
	lea _DataBase,a5

	move.l (_SysBase).w,a6			met ExecBase en fast si possible
	move.l a6,_ExecBase(a5)

	move.l #RETURN_ERROR,d7			code de retour


	lea GfxName(pc),a1			ouvre la graphics.library
	moveq #0,d0
	CALL OpenLibrary
	move.l d0,_GfxBase(a5)
	beq no_gfx

	lea DosName(pc),a1			ouvre la dos.library
	moveq #0,d0
	CALL OpenLibrary
	move.l d0,_DosBase(a5)
	beq no_dos


* on s'occupe du module
* ~~~~~~~~~~~~~~~~~~~~~
	lea ModuleName(pc),a0			ouvre le module
	move.l a0,d1
	move.l #MODE_OLDFILE,d2
	CALL d0,Open
	move.l d0,ModuleHandle(a5)
	beq no_open_module

	move.l d0,d1				recherche la taille du module
	moveq #0,d2
	move.l #OFFSET_END,d3
	CALL Seek
	tst.l d0
	bmi no_seek_module

	move.l ModuleHandle(a5),d1
	moveq #0,d2
	move.l #OFFSET_BEGINNING,d3
	CALL Seek
	move.l d0,ModuleSize(a5)
	bmi no_seek_module

	move.l #MEMF_CHIP,d1			alloue de la mémoire en chip pour
	CALL _ExecBase(a5),AllocMem		charger le module
	move.l d0,ModuleAdr(a5)
	beq no_allocmem_module

	move.l ModuleHandle(a5),d1		lit le module entièrement
	move.l d0,d2
	move.l ModuleSize(a5),d3
	CALL _DosBase(a5),Read
	cmp.l d0,d3
	bne no_read_module

* on s'occupe du scrolltext
* ~~~~~~~~~~~~~~~~~~~~~~~~~
	lea ScrollName(pc),a0			ouvre le fichier du scrolltext
	move.l a0,d1
	move.l #MODE_OLDFILE,d2
	CALL Open
	move.l d0,ScrollHandle(a5)
	beq no_open_scroll

	move.l d0,d1				recherche la taille du scrolltext
	moveq #0,d2
	move.l #OFFSET_END,d3
	CALL Seek
	tst.l d0
	bmi no_seek_scroll

	move.l ScrollHandle(a5),d1
	moveq #0,d2
	move.l #OFFSET_BEGINNING,d3
	CALL Seek
	addq.l #1,d0				on rajoute un 0 à la fin
	move.l d0,ScrollSize(a5)
	beq no_seek_scroll			-1(erreur)+1=0

	move.l #MEMF_ANY,d1			alloue de la mémoire n'importe ou pour
	CALL _ExecBase(a5),AllocMem		charger le scrolltext
	move.l d0,ScrollAdr(a5)
	beq no_allocmem_scroll

	move.l ScrollHandle(a5),d1		lit le scrolltext entièrement
	move.l d0,d2
	move.l ScrollSize(a5),d3
	subq.l #1,d3				car ya le 0 !
	CALL _DosBase(a5),Read
	cmp.l d0,d3
	bne no_read_scroll
	move.l ScrollAdr(a5),a0
	clr.b (a0,d3.l)				met un 0 à la fin

* on s'occupe de toutes les demos du menu
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea DirDemosName(pc),a0			on cherche un Lock sur le dir des demos
	move.l a0,d1
	move.l #SHARED_LOCK,d2
	CALL Lock
	move.l d0,DirDemosLock(a5)
	beq no_lock

	move.l d0,d1				dup le lock pour faire un CurrentDir
	CALL DupLock
	move.l d0,d1
	beq no_duplock

	CALL CurrentDir				et hop! on y est!
	move.l d0,OldDir

	move.l DirDemosLock(a5),d1		et hop... un coup dans l'eau
	lea PipelineFIB(a5),a2
	move.l a2,d2
	CALL Examine

	moveq #-1,d7				aucune demos pour l'instant ( ~0 )
	lea FileNames(a5),a3
	bra.s .start_dir_demos

.read_dir_demos
	lea fib_FileName(a2),a0			recopie le nom du fichier demos
	move.l a3,a1
.dup1	move.b (a0)+,(a1)+
	bne.s .dup1

	lea fib_Comment(a2),a0			recopie les comments du fichier
	lea 32*MAX_DEMOS(a3),a1
.dup2	move.b (a0)+,(a1)+
	bne.s .dup2

	lea 32(a3),a3				fichier suivant

.start_dir_demos
	move.l DirDemosLock(a5),d1		lit toutes les entrées du dir demos
	move.l a2,d2
	CALL _DosBase(a5),ExNext
	tst.l d0
	dbeq d7,.read_dir_demos

	not.w d7
	move.w d7,NbDemos(a5)			hey.. ya des demos au moins ?
	beq debug_rulez


*************************************************************************************************
*************************************************************************************************
Pipeline_Return

* on s'occupe de la picasso
* ~~~~~~~~~~~~~~~~~~~~~~~~~
	lea VillageName(pc),a1			ouvre la village.library si présente
	moveq #0,d0
	CALL _ExecBase(a5),OpenLibrary
	move.l d0,_VillageBase(a5)
	beq.s .no_village

	move.l d0,a6
	btst #4,$22(a6)				c'est la picasso ?
	seq PicassoOnScreen(a5)
	CALL SetAmigaDisplay			passe en mode AMIGA dans tous les cas

.no_village

	move.l ModuleAdr(a5),a0			-- execute PipeLine --
	bsr mt_init
	bsr init_screen_ptr
	bsr init_sprite_ptr
	bsr global_init

	moveq #2*50,d1				attend 2 vbls hoho
	CALL _DosBase(a5),Delay

	move.l $80.w,-(sp)
	move.l #do_Pipeline,$80.w
	trap #0
	move.l (sp)+,$80.w
*************************************************************************************************
*************************************************************************************************

no_error
	bsr mt_end

	move.l _GfxBase(a5),a0			en sortant a6=_Custom
	move.l gb_copinit(a0),cop1lc(a6)
	clr.w copjmp1(a6)

	move.l _VillageBase(a5),d0		si y avait la picasso avant on la
	beq.s .no_village			remet
	tst.b PicassoOnScreen(a5)
	beq.s .no_village
	CALL d0,SetPicassoDisplay

.no_village

*************************************************************************************************
zorglub
	IFNE PIPELINE_DEBUG
	btst #2,_Custom+potinp
	beq.s debug_rulez
	ENDC

	moveq #0,d0				recherche le nom du fichier à executer
	move.w MouseY(a5),d0
	divu.w #12,d0
	mulu.w #32,d0
	lea FileNames(a5),a0			argl...
	lea (a0,d0.l),a0			on le tient !

	move.l a0,d1				execute la chose
	moveq #0,d2
	moveq #0,d3
	CALL _DosBase(a5),Execute

	bra Pipeline_Return


*************************************************************************************************
* c'est la fin du pipeline... snifff
* on y va seulement en mode DEBUG avec les 2 boutons de la souris
*************************************************************************************************
debug_rulez
	moveq #0,d7

	move.l OldDir(a5),d1			revient au dir d'avant
	CALL _DosBase(a5),CurrentDir
	move.l d0,d1				libère le lock duplocké
	CALL UnLock
no_duplock
	move.l DirDemosLock(a5),d1		libère le lock sur le dir demos
	CALL UnLock
no_lock
no_read_scroll
	move.l ScrollAdr(a5),a1			libère la mémoire du scrolltext
	move.l ScrollSize(a5),d0
	CALL _ExecBase(a5),FreeMem
no_allocmem_scroll
no_seek_scroll
	move.l ScrollHandle(a5),d1		ferme le fichier scrolltext
	CALL _DosBase(a5),Close
no_open_scroll
no_read_module
	move.l ModuleAdr(a5),a1			libère la mémoire du module
	move.l ModuleSize(a5),d0
	CALL _ExecBase(a5),FreeMem
no_allocmem_module
no_seek_module
	move.l ModuleHandle(a5),d1		ferme le fichier du module
	CALL _DosBase(a5),Close

no_open_module
	move.l _DosBase(a5),a1			ferme la dos.library
	CALL _ExecBase(a5),CloseLibrary
no_dos
	move.l _GfxBase(a5),a1			ferme la graphics.library
	CALL CloseLibrary
no_gfx
	move.l d7,d0
	rts





* initialisation globale du pipeline
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*  -->	a5=_DataBase
global_init
	move.l ScrollAdr(a5),ScrollPos(a5)
	move.b #1,ScrollShift(a5)
	rts



* à partir d'ici on est normalement en superviseur
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* -->	a5=_DataBase
do_Pipeline
	lea _Custom,a6

	move.w dmaconr(a6),-(sp)
	or.w #$8200,(sp)
	move.w intenar(a6),-(sp)
	or.w #$c000,(sp)
	move.w #$7fff,dmacon(a6)
	move.w #$7fff,intena(a6)
	move.w #$7fff,intreq(a6)
	move.l $6c.w,-(sp)

	move.w #$8240,dmacon(a6)		dma blitter...
	bsr Build_Selector_Window
	WAIT_BLITTER

	move.l #pipeline_vbl,$6c.w
	move.l #coplist,cop1lc(a6)
	clr.w copjmp1(a6)

	move.w #$87e0,dmacon(a6)
	move.w #$c020,intena(a6)

wait_mouse
	IFNE PIPELINE_DEBUG
	btst #7,_CiaA+ciapra			on sort du pipeline ?
	beq.s escape_from_the_jungle
	ENDC

	btst #6,_CiaA+ciapra			menu choisi ?
	bne.s wait_mouse

escape_from_the_jungle
	move.w #$7fff,intena(a6)		houba ! on sort
	move.w #$7fff,intreq(a6)
	WAIT_BLITTER
	move.w #$7fff,dmacon(a6)
	move.l (sp)+,$6c.w
	move.w (sp)+,intena(a6)
	move.w (sp)+,dmacon(a6)
	rte



* met en place les pointeurs videos de l'écran dans la coplist
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
init_screen_ptr
	lea ScreenPtr,a0
	move.l #Screen,d0

	moveq #SCREEN_DEPTH-1,d1
.loop
	move.w d0,4(a0)				bplxptL
	swap d0
	move.w d0,(a0)				bplxptH
	swap d0
	add.l #SCREEN_WIDTH,d0
	addq.l #8,a0				ptr suivant dans la coplist
	dbf d1,.loop
	rts


* met en place les pointeurs videos des sprites dans la coplist
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
init_sprite_ptr
	lea SpritePtr,a0			sprite 0
	move.l #Selector_Spr0,d0
	bsr.s inst_spr_ptr

	addq.l #8,a0				sprite 1
	move.l #Selector_Spr1,d0
	bsr.s inst_spr_ptr

	moveq #6-1,d1				sprites 2-7
	move.l #Blank_Spr,d0
.blk
	addq.l #8,a0
	bsr.s inst_spr_ptr
	swap d0
	dbf d1,.blk
	rts

inst_spr_ptr
	move.w d0,4(a0)
	swap d0
	move.w d0,(a0)
	rts




* ca c la nouvelle vbl
* ~~~~~~~~~~~~~~~~~~~~
pipeline_vbl
	movem.l d0-d7/a0-a4,-(sp)
	movem.l a5/a6,-(sp)

	bsr mt_music

	movem.l (sp)+,a5-a6

	bsr.s Display_Scrolltext
	bsr Booze_Souris
	bsr Display_Selector

	move.w #$0020,intreq(a6)
	movem.l (sp)+,d0-d7/a0-a4
	rte





Display_Scrolltext
	btst #2,potinp(a6)
	beq gele_scroll

	WAIT_BLITTER
	move.l #Screen+SCREEN_WIDTH*254*SCREEN_DEPTH+64-2,bltapt(a6)
	move.l #Screen+SCREEN_WIDTH*254*SCREEN_DEPTH+64-2,bltdpt(a6)
	move.l #$19f00002,bltcon0(a6)
	move.l #((SCREEN_WIDTH*SCREEN_DEPTH-(64-16))<<16)|(SCREEN_WIDTH*SCREEN_DEPTH-(64-16)),bltamod(a6)
	moveq #-2,d0
	move.l d0,bltafwm(a6)
	move.w #(10<<6)|((64-16)/2),bltsize(a6)

	subq.b #1,ScrollShift(a5)
	bne .no_new_letter

	move.l ScrollPos(a5),a0			*char suivant

.read_more
	move.b (a0)+,d0				lit le char
	bne.s .not_end				c'est la fin ?
	move.l ScrollAdr(a5),a0
	move.b (a0)+,d0
.not_end
	cmp.b #10,d0				gere les char return etc..
	beq.s .read_more
	cmp.b #13,d0
	beq.s .read_more

	cmp.b #"a",d0				convertit en minuscule s'il le faut
	blt.s .no_minus
	cmp.b #"z",d0
	bgt.s .no_minus
	sub.b #"a"-"A",d0
.no_minus

	move.l a0,ScrollPos(a5)

	move.b #6,ScrollShift(a5)		euh.. c'est un espace ??
	cmp.b #" ",d0				voui => on fait rien
	beq.s .no_new_letter

	moveq #NB_LETTERS-1,d1			recherche l'offset de la lettre
	lea FontStore(pc),a0
.chk
	cmp.b (a0)+,d0
	dbeq d1,.chk
	bne.s .no_new_letter

	sub.w #NB_LETTERS-1,d1			recherche le veritable offset
	neg.w d1

	lea FontSize(pc),a0			tagada.. bouge de là
	move.b (a0,d1.w),ScrollShift(a5)

	lea Font,a0				on recopie la lettre dans l'écran
	add.w d1,d1
	lea (a0,d1.w),a0

	WAIT_BLITTER
	move.l a0,bltapt(a6)
	move.l #Screen+SCREEN_WIDTH*245*SCREEN_DEPTH+62,bltdpt(a6)
	move.l #$09f00000,bltcon0(a6)
	moveq #-1,d0
	move.l d0,bltafwm(a6)
	move.l #(((NB_LETTERS-1)*2)<<16)|(SCREEN_WIDTH*SCREEN_DEPTH-2),bltamod(a6)
	move.w #(10<<6)|(1),bltsize(a6)

.no_new_letter
gele_scroll
	rts



* Gestion de la souris
* ~~~~~~~~~~~~~~~~~~~~
Booze_Souris
	move.w joy0dat(a6),d1
	moveq #-1,d3				d3=255
	
	move.b MouseLastX(a5),d0		etat précédent
	move.b d1,MouseLastX(a5)		etat actuel
	sub.b d1,d0				différence=précédent-actuel
	bvc.s test_Y				Overflow clear ?
	bge.s pas_depassementX_right
	addq.b #1,d0				-255+différence
	bra.s test_Y
pas_depassementX_right
	add.b d3,d0				255+différence
test_Y
	lsr.w #8,d1				récupère les Y
	move.b MouseLastY(a5),d2
	move.b d1,MouseLastY(a5)
	sub.b d1,d2				idem
	bvc.s fin_testY
	bge.s pas_depassementY_down
	addq.b #1,d2
	bra.s fin_testY
pas_depassementY_down
	add.b d3,d2
fin_testY
	ext.w d0
	ext.w d2
	sub.w d0,MouseX(a5)
	sub.w d2,MouseY(a5)
	

.chk_low
	tst.w MouseY(a5)
	bgt.s .chk_high				clipping du déplacement souris
	clr.w MouseY(a5)
	rts
.chk_high
	move.w NbDemos(a5),d0
	subq.w #1,d0
	mulu.w #12,d0
	cmp.w MouseY(a5),d0
	bge.s .done
	move.w d0,MouseY(a5)
.done
	rts




* le pire est à venir... l'affichage du selector !  Love Blitter 4ever...
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Display_Selector
	lea Selector_Screen,a0			regarde à partir d'où on affiche
	moveq #0,d0
	move.w MouseY(a5),d0
	divu.w #12,d0
	mulu.w #SELECTOR_WIDTH*12,d0
	add.l d0,a0

	WAIT_BLITTER
	move.l a0,bltapt(a6)
	move.l #Screen+SCREEN_WIDTH*SCREEN_DEPTH*SELECTOR_Y+SELECTOR_X/8,bltdpt(a6)
	move.l #SCREEN_WIDTH*SCREEN_DEPTH-SELECTOR_WIDTH,bltamod(a6)
	move.l #$09f00000,bltcon0(a6)
	moveq #-1,d0
	move.l d0,bltafwm(a6)
	move.w #(9*12<<6)|(SELECTOR_WIDTH/2),bltsize(a6)
	rts











* Preparation de la fenetre du Selector
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Build_Selector_Window
	WAIT_BLITTER				init le blitter avant de rentrer dans la boucle
	move.l #$ffff0000,bltafwm(a6)
	move.w #(SELECTOR_WIDTH-4),bltbmod(a6)
	move.l #(((NB_LETTERS-2)*2)<<16)|(SELECTOR_WIDTH-4),bltamod(a6)
	clr.w bltcon1(a6)			non non.. on fait pas de 3d

	lea Selector_Screen+SELECTOR_WIDTH*12*4,a0
	lea MenuNames(a5),a1
	lea FontSize(pc),a2
	lea Font,a3

	move.w NbDemos(a5),d7
	bra.s start_build_selector

loop_build_selector
	tst.b (a1)+				va au FileName suivant
	beq.s loop_build_selector
	subq.l #1,a1

* affichage du nom de la demo sur le coté gauche
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	moveq #1,d6				affiche la démo à gauche
	bsr.s Display_Selector_Text

* affichage du nom du groupe sur le coté droit
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l a1,-(sp)
	move.w #SELECTOR_WIDTH*8,d6		centrage à droite
.centrage
	move.b (a1)+,d0
	beq.s .end_centrage

	cmp.b #" ",d0				espace ?
	beq.s .space

	cmp.b #"a",d0				convertit en minuscule s'il le faut
	blt.s .no_minus
	cmp.b #"z",d0
	bgt.s .no_minus
	sub.b #"a"-"A",d0
.no_minus

	moveq #NB_LETTERS-1,d1			recherche l'offset de la lettre
	lea FontStore(pc),a4
.chk
	cmp.b (a4)+,d0
	dbeq d1,.chk
	bne.s .end_centrage

	sub.w #NB_LETTERS-1,d1			recherche le veritable offset
	neg.w d1

	moveq #0,d5
	move.b (a2,d1.w),d5
	sub.w d5,d6
	bra.s .centrage
.space
	subq.w #6,d6
	bra.s .centrage

.end_centrage
	move.l (sp)+,a1
	bsr.s Display_Selector_Text

* passe à la ligne suivante
* ~~~~~~~~~~~~~~~~~~~~~~~~~
	lea SELECTOR_WIDTH*12(a0),a0
start_build_selector
	dbf d7,loop_build_selector
	rts


* affichage de text pour les menus
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*  -->	d6=Position relative par rapport au début de la ligne
Display_Selector_Text
	move.b (a1)+,d0				lit une lettre du FileName
	beq.s .no_more				on sort ?
	cmp.b #"§",d0
	beq.s .no_more

	cmp.b #" ",d0
	beq.s .space

	cmp.b #"a",d0				convertit en minuscule s'il le faut
	blt.s .no_minus
	cmp.b #"z",d0
	bgt.s .no_minus
	sub.b #"a"-"A",d0
.no_minus

	moveq #NB_LETTERS-1,d1			recherche l'offset de la lettre
	lea FontStore(pc),a4
.chk
	cmp.b (a4)+,d0
	dbeq d1,.chk
	bne.s .space
	
	sub.w #NB_LETTERS-1,d1			recherche le veritable offset
	neg.w d1

	move.w d1,d2
	add.w d2,d2				recherche la lettre elle même
	lea (a3,d2.w),a4

	move.w d6,d5
	move.w d5,d4
	ror.w #4,d4				calcul bltcon0
	and.w #$f000,d4				décalage source A
	or.w #$dfc,d4				D=A!B
	lsr.w #4,d5				\ offset dans le bitplan
	add.w d5,d5				/ WORD aligned pilzzzz

	WAIT_BLITTER
	move.l a4,bltapt(a6)
	lea (a0,d5.w),a4			argl... g pas assez de registres !
	move.l a4,bltbpt(a6)			la vie doit etre dur sur 486
	move.l a4,bltdpt(a6)
	move.w d4,bltcon0(a6)
	move.w #(10<<6)|(2),bltsize(a6)

	moveq #0,d5				ca serait cool d'inventer l'instruction
	move.b (a2,d1.w),d5			addb.w <ea>,dx
	add.w d5,d6				hein Mr Motorolla ?

	bra.s Display_Selector_Text
.no_more
	rts

.space
	addq.w #6,d6
	bra Display_Selector_Text



* la replay de protracker
* ~~~~~~~~~~~~~~~~~~~~~~~
	include "asm:sources/Play200.s"



* datas statiques du pipeline
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~
GfxName
	dc.b "graphics.library",0
DosName
	dc.b "dos.library",0
VillageName
	dc.b "village.library",0
ModuleName
	dc.b "PipelineDatas/mod.pipeline",0
ScrollName
	dc.b "PipelineDatas/scrolltext.ASC",0
DirDemosName
	dc.b "PipelineDemos/",0


FontStore
	dc.b "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890?!./+()'=%*-&#:"
NB_LETTERS=*-FontStore

FontSize
	dc.b 9,9,9,9,8,8,9,9,3,8,9,8
	dc.b 10,9,9,9,10,9,8,9,9,9,13
	dc.b 9,9,9,4,9,8,9,8,9,8,9
	dc.b 9,9,9,3,3,12,9,8,8,3
	dc.b 7,12,10,9,9,10,3



* Toutes les datas du pipeline
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	section mes_daaaatas,bss

	rsset -DATA_OFFSET
DataBase	rs.b 0
PipelineFIB	rs.b fib_SIZEOF
_ExecBase	rs.l 1
_GfxBase	rs.l 1
_DosBase	rs.l 1
_VillageBase	rs.l 1
ModuleHandle	rs.l 1
ModuleAdr	rs.l 1
ModuleSize	rs.l 1
ScrollHandle	rs.l 1
DirDemosLock	rs.l 1
OldDir		rs.l 1
ScrollAdr	rs.l 1
ScrollSize	rs.l 1
ScrollPos	rs.l 1
ScrollShift	rs.b 1
LetterSize	rs.b 1
NbDemos		rs.w 1
FileNames	rs.b 32*MAX_DEMOS
MenuNames	rs.b 80*MAX_DEMOS
MouseX		rs.w 1
MouseY		rs.w 1
MouseLastX	rs.b 1
MouseLastY	rs.b 1
PicassoOnScreen	rs.b 1




DataBase_SIZEOF=__RS-DataBase

_DataBase=*+DATA_OFFSET
	ds.b DataBase_SIZEOF



* les datas qui doivent aller en chip
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	section entombed,data_c

Selector_Spr0
	dc.l $cc65d101
	dc.w $f000,0
	dc.w $f000,0
	dc.w $f000,0
	dc.w $f000,0
Blank_Spr
	dc.l 0

Selector_Spr1
	dc.l $ccb8d101
	dc.w $f000,0
	dc.w $f000,0
	dc.w $f000,0
	dc.w $f000,0
	dc.l 0

coplist
	dc.w fmode,$0
	dc.w bplcon0,$4200|$8000
	dc.w bplcon1,$0
	dc.w bplcon2,$0
	dc.w bplcon3,$0c00
	dc.w bplcon4,$11
	dc.w ddfstrt,$3c
	dc.w ddfstop,$d4
	dc.w diwstrt,$2b81
	dc.w diwstop,$2bc1
	dc.w bpl1mod,SCREEN_WIDTH*(SCREEN_DEPTH-1)
	dc.w bpl2mod,SCREEN_WIDTH*(SCREEN_DEPTH-1)

ptr set bplpt
ScreenPtr=*+2
	REPT SCREEN_DEPTH*2			les pointeurs videos
	dc.w ptr,0
ptr set ptr+2
	ENDR

ptr set sprpt
SpritePtr=*+2
	REPT 8*2				les pointeurs des DMAs sprites
	dc.w ptr,0
ptr set ptr+2
	ENDR

	dc.w color+00,$000
	dc.w color+02,$EEE
	dc.w color+04,$945
	dc.w color+06,$E79
	dc.w color+08,$E68
	dc.w color+10,$E57
	dc.w color+12,$D46
	dc.w color+14,$C35
	dc.w color+16,$B24
	dc.w color+18,$A13
	dc.w color+20,$902
	dc.w color+22,$801
	dc.w color+24,$700
	dc.w color+26,$500
	dc.w color+28,$A56
	dc.w color+30,$B67
	dc.w color+34,$00f			pour les sprites 0 & 1

	dc.w $9901,$fffe			petit dégradé en haut
	dc.w color+02,$444
	dc.w $9a01,$fffe
	dc.w color+02,$777
	dc.w $9b01,$fffe
	dc.w color+02,$bbb
	dc.w $9c01,$fffe
	dc.w color+02,$eee

	dc.w $ff01,$fffe
	dc.w color+02,$bbb
	dc.w $ffdf,$fffe			petit dégardé en bas
	dc.w color+02,$777
	dc.w $0101,$fffe
	dc.w color+02,$444
	dc.w $0201,$fffe
	dc.w color+02,$333
	dc.w $0301,$fffe
	dc.w color+02,$EEE

	dc.l $fffffffe

* l'ecran de Pipeline  640*256 Hires
Screen
	incbin "Pipeline.RAW"

Font
	incbin "Fonte.RAW"




* c'est ici kon va mettre l'écran du selector. Blitter rulez
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	section selector,bss_c
Selector_Screen
	ds.b SELECTOR_WIDTH*12*(4+MAX_DEMOS+4)


* end of file
