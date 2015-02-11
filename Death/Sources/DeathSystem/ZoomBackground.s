


**
** $VER:  Live AGA v1.0
**        (c)1994 Sync/DreamDealers
**
** LOAD_BACKGROUND "file name"
**     Extension pour charger une image et la zoomer
**     dans le fond de Live
**



*************************************************************************************************
*                                TOUS LES INCLUDES DE DEATH
*************************************************************************************************
	incdir "include:"
	incdir "Death:"
	incdir "Death:Sources/"
	incdir "Death:Includes/"

	include "exec/exec_lib.i"
	include "exec/memory.i"
	include "graphics/graphics_lib.i"
	include "graphics/scale.i"
	include "dos/dos_lib.i"
	include "dos/dos.i"
	include "libraries/iffparse_lib.i"
	include "libraries/iffparse.i"
	include "datatypes/pictureclass.i"
	include "misc/macros.i"

	include "Extensions.i"




*************************************************************************************************
*                               LES OPTIONS DE COMPILATIONS
*************************************************************************************************
	OPT AMIGA
	OPT O+,OW-,OW1+,OW6+
	OPT INCONCE
	OPT EVEN
	IFEQ LIVE_DEBUG
	OPT NOLINE,NODEBUG
	ENDC

	OUTPUT Live:LiveExtensions/ZoomBackground




*************************************************************************************************
*                            ROUTINES D'INIT DE CETTE EXTENSION
* en entrée: a5=DeathDataBase
*
* en sortie: d0=DEATH_ERROR ou DEATH_OK
*
*************************************************************************************************
Extension_Tags
	dc.l Init_Point
	dc.l Exit_Point
	dc.l Tk
	dc.l 0
Version
	dc.b "$VER: ZoomBackGround v1.0 - (c)1994 Sync/DreamDealers",0
	CNOP 0,4

Init_Point
	moveq #DEATH_OK,d0
Exit_Point
	rts




*************************************************************************************************
*                   INSTRUCTION PERMETTANT DE ZOOMER UNE IMAGE POUR LE FOND DE LIVE
*
* success=ZOOM_BACKGROUND "File Name"
*
* en entrée: a5=DeathDataBase
*
* en sortie: a5=DeathDataBase
*
*************************************************************************************************
Zoom_Background
	SAVE_REGS

	lea LocalData(pc),a4
	move.l #DEATH_ERROR,ReturnCode-LocalData(a4)
	move.l #ErrorZoomBackground,DeathErrorString(a5)

	tst.l LiveScreen(a5)			ya un ecran ?
	beq no_open

	move.l DeathArg0(a5),d1			nom du fichier à charger
	move.l #MODE_OLDFILE,d2
	CALL _DosBase(a5),Open
	move.l IFF_Handle(a5),a0
	move.l d0,iff_Stream(a0)
	beq no_open

* Ouverture du fichier IFF
* ~~~~~~~~~~~~~~~~~~~~~~~~
;;;	move.l IFF_Handle(a5),a0
	moveq #IFFF_READ,d0
	CALL _IFFParseBase(a5),OpenIFF
	tst.l d0
	bne no_open_iff

* Déclaration des chunks à chercher
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l IFF_Handle(a5),a0		déclare les chunks à rechercher:
	lea PropChunks_Tags(pc),a1		BMHD,CMAP
	moveq #2,d0
	CALL PropChunks
	tst.l d0
	bne no_parse

	move.l IFF_Handle(a5),a0		déclare le chunk d'arret:
	move.l #ID_ILBM,d0			BODY
	move.l #ID_BODY,d1
	CALL StopChunk
	tst.l d0
	bne no_parse

* Scanne tout le fichier
* ~~~~~~~~~~~~~~~~~~~~~~
	move.l IFF_Handle(a5),a0
	moveq #IFFPARSE_SCAN,d0
	CALL ParseIFF
	tst.l d0
	bne no_parse

* Recherche chaque chunk en mémoire
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l IFF_Handle(a5),a0		recherche les chunks:
	move.l #ID_ILBM,d0			CMAP,BMHD,BODY
	move.l #ID_CMAP,d1
	CALL FindProp
	move.l d0,CMAP_Chunk-LocalData(a4)
	beq no_parse

	move.l IFF_Handle(a5),a0
	move.l #ID_ILBM,d0
	move.l #ID_BMHD,d1
	CALL FindProp
	move.l d0,BMHD_Chunk-LocalData(a4)
	beq no_parse

* Recherche des info sur l'écran et Allocation d'une BitMap
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l BMHD_Chunk(pc),a0		alloue une Bitmap pour le zoom
	move.l spr_Data(a0),a0
	move.b bmh_Compression(a0),Crunch_Mode-LocalData(a4)
	move.w bmh_Width(a0),d0
	move.w d0,ZoomBitMapX-LocalData(a4)
	move.w bmh_Height(a0),d1
	move.w d1,ZoomBitMapY-LocalData(a4)
	move.b bmh_Depth(a0),d2			on fait gaffe que l'on ait que 128
	move.b d2,ZoomBitMapDepth-LocalData(a4)	couleurs au maximum
	cmp.b #7,d2
	bgt no_alloc_bitmap
	moveq #SCREEN_DEPTH,d2
	moveq #BMF_CLEAR,d3
	sub.l a0,a0
	CALL _GfxBase(a5),AllocBitMap
	move.l d0,ZoomBitMap-LocalData(a4)
	beq no_alloc_bitmap

* Mise en place de la palette de l'image
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l CMAP_Chunk(pc),a0
	move.l spr_Size(a0),d0
	move.l spr_Data(a0),a0
	lea LiveScreenColors(a5),a1
	addq.l #4,a1				saute le nb de couleur + couleur de départ
	subq.w #1,d0				à cause du dbf
Make_ColorTab
	move.b (a0)+,d1				à partir de $XY.b on fabrique
	move.b d1,(a1)+				$XYXYXYXY.l
	move.b d1,(a1)+
	move.b d1,(a1)+
	move.b d1,(a1)+
	dbf d0,Make_ColorTab

* Allocation de mémoire pour charger le chunk BODY
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l IFF_Handle(a5),a0		recherche la taille du
	CALL _IFFParseBase(a5),CurrentChunk	chunk BODY

	move.l d0,a0
	move.l cn_Size(a0),d0
	move.l d0,Mem_Size-LocalData(a4)
	move.l #MEMF_ANY,d1
	CALL _ExecBase(a5),AllocMem
	move.l d0,Mem_Adr-LocalData(a4)
	beq no_allocmem

	move.l IFF_Handle(a5),a0
	move.l d0,a1
	CALL _IFFParseBase(a5),ReadChunkBytes
	tst.l d0
	bmi no_readchunkbytes


* On se charge ici de mettre le chunk BODY dans les bitplans
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.b Crunch_Mode-LocalData(a4)
	beq Body_None
	cmp.b #cmpByteRun1,Crunch_Mode-LocalData(a4)
	bne unknown_cruncher

* Décrunchage d'une image ByteRun1
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Body_ByteRun1
	move.l ZoomBitMap(pc),a0
	move.l Mem_Adr(pc),a1
	move.w bm_BytesPerRow(a0),d0		taille réelle d'une ligne écran
	move.w ZoomBitMapX(pc),d1		recherche la largeur d'une
	addq.w #7,d1				ligne écran
	lsr.w #3,d1
	moveq #0,d2
	move.b ZoomBitMapDepth(pc),d2		nombre de bitplans
	subq.w #1,d2
	moveq #0,d3				on commence à cette ligne
	lea bm_Planes(a0),a0
BR1_Next_Line
	move.l a0,a2
	move.w d2,d4
BR1_Next_Bpl
	move.l (a2)+,a3
	move.w d3,d5				\ calcule l'offset pour
	mulu.w d0,d5				/ à la bonne ligne
	add.l d5,a3
	moveq #0,d5
BR1_Next_Control
	move.b (a1)+,d6				lit un octet de controle
	bmi.s crunched

not_crunched
	ext.w d6
	add.w d6,d5
	addq.w #1,d5
.copy	move.b (a1)+,(a3)+
	dbf d6,.copy
	cmp.w d1,d5
	blt.s BR1_Next_Control
	dbf d4,BR1_Next_Bpl
	addq.w #1,d3
	cmp.w ZoomBitMapY(pc),d3
	blt.s BR1_Next_Line
	bra.s end_iff_decrunch

crunched
	cmp.b #$80,d6				octet de padding ?
	beq.s BR1_Next_Control
	neg.b d6
	ext.w d6
	add.w d6,d5
	addq.w #1,d5
	move.b (a1)+,d7
.copy	move.b d7,(a3)+
	dbf d6,.copy
	cmp.w d1,d5
	blt.s BR1_Next_Control
	dbf d4,BR1_Next_Bpl
	addq.w #1,d3
	cmp.w ZoomBitMapY(pc),d3
	blt.s BR1_Next_Line
	bra.s end_iff_decrunch

* Image non crunchée
* ~~~~~~~~~~~~~~~~~~
Body_None
	move.l ZoomBitMap(pc),a0
	move.l Mem_Adr(pc),a1
	move.w bm_BytesPerRow(a0),d0		taille réelle d'une ligne écran
	move.w ZoomBitMapX(pc),d1		recherche la largeur d'une
	addq.w #7,d1				ligne écran
	lsr.w #3,d1
	subq.w #1,d1
	moveq #0,d2
	move.b ZoomBitMapDepth(pc),d2		nb de bitplans
	subq.w #1,d2
	moveq #0,d3				on commence à la ligne 0
	lea bm_Planes(a0),a0
.Next_Line
	move.l a0,a2
	move.w d2,d4
	move.w d3,d5				\ calcule l'offset pour arriver
	mulu.w d0,d5				/ à la bonne ligne
.Next_Bpl
	move.l (a2)+,a3				adresse d'un bpl
	add.l d5,a3
	move.w d1,d6
.Put_Data
	move.b (a1)+,(a3)+
	dbf d6,.Put_Data
	dbf d4,.Next_Bpl
	addq.w #1,d3				ligne suivante
	cmp.w ZoomBitMapY(pc),d3
	blt.s .Next_Line

end_iff_decrunch


* zoom de l'image pour le fond de Live AGA
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	lea LiveScaleStruct(pc),a0
	clr.w bsa_SrcX(a0)
	clr.w bsa_SrcY(a0)
	move.w ZoomBitMapX(pc),bsa_SrcWidth(a0)
	move.w ZoomBitMapY(pc),bsa_SrcHeight(a0)
	move.w ZoomBitMapX(pc),d0
	clr.w bsa_DestX(a0)
	clr.w bsa_DestY(a0)
	move.l ZoomBitMap(pc),bsa_SrcBitMap(a0)
	move.l LiveScreen(a5),a1
	move.l sc_RastPort+rp_BitMap(a1),bsa_DestBitMap(a0)
	clr.l bsa_Flags(a0)

	move.w #2000,bsa_XSrcFactor(a0)
	move.w #2000,bsa_YSrcFactor(a0)
	move.l #SCREEN_X*2000,d0
	divu.w ZoomBitMapX(pc),d0
	move.w d0,bsa_XDestFactor(a0)
	move.l #SCREEN_Y*2000,d0
	divu.w ZoomBitMapY(pc),d0
	move.w d0,bsa_YDestFactor(a0)

	CALL _GfxBase(a5),BitMapScale


* charge les couleurs du Background dans l'écran
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l LiveScreen(a5),a0
	lea sc_ViewPort(a0),a0
	lea LiveScreenColors(a5),a1
	move.l #128<<16,(a1)
	CALL LoadRGB32

no_error
	move.l #DEATH_OK,ReturnCode-LocalData(a4)
unknown_cruncher
no_readchunkbytes
	move.l Mem_Adr(pc),a1			libère la mémoire allouée avant
	move.l Mem_Size(pc),d0
	CALL _ExecBase(a5),FreeMem
no_allocmem
	move.l ZoomBitMap(pc),a0		libère la bitmap
	CALL _GfxBase(a5),FreeBitMap
no_alloc_bitmap
no_parse
	move.l IFF_Handle(a5),a0		ferme l'acces iff
	CALL _IFFParseBase(a5),CloseIFF
no_open_iff
	move.l IFF_Handle(a5),a0		referme le fichier dos
	move.l iff_Stream(a0),d1
	CALL _DosBase(a5),Close
no_open
	move.l ReturnCode(pc),d0	
	RESTORE_REGS
	rts	




*************************************************************************************************
*                               LA TABLE D'INSTRUCTION DU MODULE
*************************************************************************************************
Tk
* ZOOM_PICTURE "Nom fichier"
	dc.l Zoom_Background
	dc.b "ZOOM_BACKGROUND",0
	dc.b "S",0

	dc.l 0



*************************************************************************************************
*                               DATAS POUR L'OUVERTURE D'UN ECRAN
*************************************************************************************************
	CNOP 0,4
LocalData

ReturnCode
	dc.l 0
ZoomBitMap
	dc.l 0
ZoomBitMapX
	dc.w 0
ZoomBitMapY
	dc.w 0
ZoomBitMapDepth
	dc.b 0
Crunch_Mode
	dc.b 0
BMHD_Chunk
	dc.l 0
CMAP_Chunk
	dc.l 0
Mem_Size
	dc.l 0
Mem_Adr
	dc.l 0

LiveScaleStruct
	ds.b bsa_SIZEOF

PropChunks_Tags
	dc.l ID_ILBM,ID_CMAP
	dc.l ID_ILBM,ID_BMHD

ErrorZoomBackground
	dc.b "Instruction ZOOM_BACKGROUND failed",0


