
*				Convert Clipart v1.0 pour Live AGA
*				~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*				     ©1994 Sync/DreamDealers





*************************************************************************************************
*                                       LES INCLUDES
*************************************************************************************************

* Les includes
* ~~~~~~~~~~~~

	incdir "include:"
	incdir "Death:"
	incdir "Death:Sources/"
	incdir "Death:Includes/"

	include "exec/exec_lib.i"
	include "exec/memory.i"
	include "intuition/intuition_lib.i"
	include "intuition/intuition.i"
	include "graphics/graphics_lib.i"
	include "dos/dos_lib.i"
	include "dos/dos.i"
	include "dos/doshunks.i"
	include "libraries/iffparse_lib.i"
	include "libraries/iffparse.i"
	include "datatypes/pictureclass.i"
	include "misc/macros.i"


	rsreset
Clipart_Struct		rs.b 0
ca_Name			rs.b 32
ca_Image		rs.b ig_SIZEOF
ca_Colors		rs.l 2+32*3
ca_Next			rs.l 1
Clipart_SIZEOF		rs.b 0




*************************************************************************************************
*                               LES OPTIONS DE COMPILATIONS
*************************************************************************************************
	OPT AMIGA
	OPT O+,OW-,OW1+,OW6+
	OPT INCONCE
	OPT EVEN
;;	OPT NOLINE,NODEBUG
	OUTPUT Death:Objects/MakeClipart
;;	OUTPUT ram:X




*************************************************************************************************
*                                    LE PROGRAMME PRINCIPAL
*************************************************************************************************
	bra.s skip_version
	dc.b "$VER: MakeClipart v1.0  ©1994 Sync/DreamDealers",0
	even

skip_version
	lea _DataBase,a5

	movem.l d0/a0,CliArgs(a5)		sauve les arguments du CLI

* Ouverture des libraries
* ~~~~~~~~~~~~~~~~~~~~~~~
	move.l (_SysBase).w,a6
	move.l a6,_ExecBase(a5)

	lea DosName(pc),a1
	moveq #39,d0
	CALL OpenLibrary
	move.l d0,_DosBase(a5)
	beq no_dos

	lea IFFParseName(pc),a1
	moveq #39,d0
	CALL OpenLibrary
	move.l d0,_IFFParseBase(a5)
	beq no_iffparse

* Parsing de la ligne du CLI
* ~~~~~~~~~~~~~~~~~~~~~~~~~~
	movem.l CliArgs(a5),d0/a0
	lea CliArg1(a5),a1
	bsr line_parsing
	cmp.w #3,d0
	bne no_args
	
* Allocation d'une structure iff
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	CALL _IFFParseBase(a5),AllocIFF		allocation d'une structure IFF
	move.l d0,IFF_Handle(a5)
	beq no_allociff

	move.l d0,a0				passe ca par le DOS
	CALL InitIFFasDOS

* Chargement du clipart
* ~~~~~~~~~~~~~~~~~~~~~
	move.l CliArg1(a5),d1			nom du fichier à charger
	move.l #MODE_OLDFILE,d2
	CALL _DosBase(a5),Open
	move.l IFF_Handle(a5),a0
	move.l d0,iff_Stream(a0)
	beq no_open_clipart

* Ouverture du fichier IFF
* ~~~~~~~~~~~~~~~~~~~~~~~~
	move.l IFF_Handle(a5),a0
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
	move.l d0,CMAP_Chunk(a5)
	beq no_parse

	move.l IFF_Handle(a5),a0
	move.l #ID_ILBM,d0
	move.l #ID_BMHD,d1
	CALL FindProp
	move.l d0,BMHD_Chunk(a5)
	beq no_parse

* Recherche des info sur l'écran et alloue de la mémoire pour le clipart
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l BMHD_Chunk(a5),a0
	move.l spr_Data(a0),a0
	move.b bmh_Compression(a0),Crunch_Mode(a5)
	move.w bmh_Width(a0),d0
	move.w d0,ClipartX(a5)
	move.w bmh_Height(a0),d1
	move.w d1,ClipartY(a5)
	moveq #0,d2
	move.b bmh_Depth(a0),d2			on fait gaffe que l'on ait que 32
	move.w d2,ClipartDepth(a5)		couleurs au maximum

	add.w #15,d0
	lsr.w #4,d0				\ taille d'une ligne en octets (sur des WORDs)
	add.w d0,d0				/
	mulu.w d2,d1				calcule la taile de la structure
	mulu.w d1,d0
	move.l #MEMF_ANY|MEMF_CLEAR,d1
	move.l d0,d2
	move.l d2,ClipartSize(a5)
	CALL _ExecBase(a5),AllocMem
	move.l d0,ClipartAdr(a5)
	beq no_allocmem_clipart
	addq.l #3,d2				\ calcul la taille en LONG des datas du Clipart
	lsr.l #2,d2				/
	or.l d2,patch_hunk1_size1
	or.l d2,patch_hunk1_size2

* Allocation de mémoire pour charger le chunk BODY
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l IFF_Handle(a5),a0		recherche la taille du
	CALL _IFFParseBase(a5),CurrentChunk	chunk BODY

	move.l d0,a0
	move.l cn_Size(a0),d0
	move.l d0,Mem_Size(a5)
	move.l #MEMF_ANY,d1
	CALL _ExecBase(a5),AllocMem
	move.l d0,Mem_Adr(a5)
	beq no_allocmem

	move.l IFF_Handle(a5),a0
	move.l d0,a1
	CALL _IFFParseBase(a5),ReadChunkBytes
	tst.l d0
	bmi no_readchunkbytes


* On se charge ici de mettre le chunk BODY dans les bitplans
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	tst.b Crunch_Mode(a5)
	beq Body_None
	cmp.b #cmpByteRun1,Crunch_Mode(a5)
	bne unknown_cruncher

* Décrunchage d'une image ByteRun1
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Body_ByteRun1
	move.l ClipartAdr(a5),a0
	move.l Mem_Adr(a5),a1

	move.w ClipartX(a5),d0			\
	addq.w #7,d0				 > calcul la taille d'une ligne Clipart
	lsr.w #3,d0				/

	move.w ClipartX(a5),d1			pour passer au bitplan suivant
	add.w #15,d1
	lsr.w #4,d1
	add.w d1,d1
	moveq #0,d3
	move.w d1,d3
	mulu.w ClipartY(a5),d1

	move.l d1,d2				pour passer à la ligne suivante
	mulu.w ClipartDepth(a5),d2
	sub.l d3,d2

	move.w ClipartDepth(a5),d3		nombre de bitplan-1 (dbf)
	subq.w #1,d3
	move.w d3,a3

	moveq #0,d3				numero de ligne actuelle

BR1_Next_Line
	move.w a3,d4
BR1_Next_Bpl
	move.l a0,a2
	moveq #0,d5				nb d'octets écrit dans la ligne
BR1_Next_Control
	move.b (a1)+,d6				lit un octet de controle
	bmi.s crunched

not_crunched
	ext.w d6
	add.w d6,d5
	addq.w #1,d5
.copy	move.b (a1)+,(a2)+
	dbf d6,.copy
	cmp.w d0,d5
	blt.s BR1_Next_Control
	add.l d1,a0				bitplan suivant
	dbf d4,BR1_Next_Bpl
	sub.l d2,a0
	addq.w #1,d3
	cmp.w ClipartY(a5),d3
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
.copy	move.b d7,(a2)+
	dbf d6,.copy
	cmp.w d0,d5
	blt.s BR1_Next_Control
	add.l d1,a0				ligne suivante
	dbf d4,BR1_Next_Bpl
	sub.l d2,a0
	addq.w #1,d3
	cmp.w ClipartY(a5),d3
	blt.s BR1_Next_Line
	bra.s end_iff_decrunch

* Image non crunchée
* ~~~~~~~~~~~~~~~~~~
Body_None
	move.l ClipartAdr(a5),a0
	move.l Mem_Adr(a5),a1

	move.w ClipartX(a5),d0			\
	addq.w #7,d0				 > calcul la taille d'une ligne Clipart
	lsr.w #3,d0				/

	move.w ClipartX(a5),d1			pour passer au bitplan suivant
	add.w #15,d1
	lsr.w #4,d1
	add.w d1,d1
	moveq #0,d3
	move.w d1,d3
	mulu.w ClipartY(a5),d1

	move.l d1,d2				pour passer à la ligne suivante
	mulu.w ClipartDepth(a5),d2
	sub.l d3,d2

	move.w ClipartDepth(a5),d3		nombre de bitplan-1 (dbf)
	subq.w #1,d3
	move.w d3,a3

	moveq #0,d3				numero de ligne actuelle

.Next_Line
	move.w d0,d6
	move.w a3,d4
.Next_Bpl
	move.l a0,a2
.Put_Data
	move.b (a1)+,(a2)+
	dbf d6,.Put_Data
	add.l d1,a0				ligne suivante
	dbf d4,.Next_Bpl
	sub.l d2,a0
	addq.w #1,d3
	cmp.w ClipartY(a5),d3
	blt.s .Next_Line

end_iff_decrunch

* Init la structure Clipart
* ~~~~~~~~~~~~~~~~~~~~~~~~~
	lea clip_struct(pc),a0
	move.w ClipartX(a5),ca_Image+ig_Width(a0)
	move.w ClipartY(a5),ca_Image+ig_Height(a0)
	move.w ClipartDepth(a5),d0
	move.w d0,ca_Image+ig_Depth(a0)
	moveq #0,d1				calcul ig_PlanePick
	bset d0,d1
	subq.b #1,d1
	move.b d1,ca_Image+ig_PlanePick(a0)
	move.b #%11000000,ca_Image+ig_PlaneOnOff(a0)	met à 1 les bpls 7 & 8

	move.l CliArg2(a5),a1			met le nom du clipart
	lea ca_Name(a0),a2
.put_name
	move.b (a1)+,(a2)+
	bne.s .put_name

	lea ca_Colors+4(a0),a1			met en place la palette du clipart
	move.l CMAP_Chunk(a5),a2
	move.l spr_Size(a2),d0
	move.l d0,d1				le nombre de couleurs dans la palette
	divu #3,d1
	move.w d1,ca_Colors(a0)
	move.l spr_Data(a2),a2
	subq.w #1,d0				à cause du dbf
Make_ColorTab
	move.b (a2)+,d1				à partir de $XY.b on fabrique
	move.b d1,(a1)+				$XYXYXYXY.l
	move.b d1,(a1)+
	move.b d1,(a1)+
	move.b d1,(a1)+
	dbf d0,Make_ColorTab

no_error

* fabrication d'un fichier LoadSeg()'able du clipart
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	move.l CliArg3(a5),d1			ouvre le fichier
	move.l #MODE_NEWFILE,d2
	CALL _DosBase(a5),Open
	move.l d0,File_Handle(a5)
	beq.s no_open_file

	move.l d0,d1				écrit le header
	move.l #Hunk_Part1,d2
	move.l #Hunk_Part1_SIZEOF,d3
	CALL Write
	cmp.l d1,d3
	bne.s no_write

	move.l File_Handle(a5),d1
	move.l ClipartAdr(a5),d2
	move.l ClipartSize(a5),d3
	addq.l #3,d3
	and.l #~%11,d3
	CALL Write
	cmp.l d0,d3
	bne.s no_write

	move.l File_Handle(a5),d1
	move.l #Hunk_Part2,d2
	move.l #Hunk_Part2_SIZEOF,d3
	CALL Write
	cmp.l d0,d3
	bne.s no_write

	st ErrorFlag(a5)			pas d'erreur: miracle !

no_write
	move.l File_Handle(a5),d1		ferme le fichier
	CALL Close
no_open_file
unknown_cruncher
no_readchunkbytes
	move.l Mem_Adr(a5),a1			libère la mémoire allouée pour charger
	move.l Mem_Size(a5),d0			le hunk body du fichier iff
	CALL _ExecBase(a5),FreeMem
no_allocmem
	move.l ClipartAdr(a5),a1		libère la mémoire allouée pour
	move.l ClipartSize(a5),d0		les datas du clipart
	CALL FreeMem
no_allocmem_clipart
no_parse
	move.l IFF_Handle(a5),a0		ferme l'acces iff
	CALL _IFFParseBase(a5),CloseIFF
no_open_iff
	move.l IFF_Handle(a5),a0		referme le fichier dos
	move.l iff_Stream(a0),d1
	CALL _DosBase(a5),Close
no_open_clipart
	move.l IFF_Handle(a5),a0		libère la structure IFF
	CALL _IFFParseBase(a5),FreeIFF
no_allociff
no_args
* regarde si ya une erreur
* ~~~~~~~~~~~~~~~~~~~~~~~~
	tst.b ErrorFlag(a5)
	bne.s no_errormsg

	CALL _DosBase(a5),Output		affiche le msg d'erreur
	move.l d0,d1
	move.l #ErrorMsg,d2
	move.l #ErrorMsg_SIZE,d3
	CALL Write

no_errormsg
	move.l _IFFParseBase(a5),a1		ferme les libraries
	CALL _ExecBase(a5),CloseLibrary
no_iffparse
	move.l _DosBase(a5),a1
	CALL CloseLibrary
no_dos
	moveq #0,d0
	rts




*************************************************************************************************
*                                   PARSING DE LA LIGNE CLI
*************************************************************************************************
*  en entrée :	a0/d0 initialisés par le Dos  ;  a0=&CliLine  ; d0=Size
*		a1=&buffer
*  en sortie :	d0=nb d'arguments
*  d0/a0-a1 trashed !!
MAXARGC=3

line_parsing
	clr.b -1(a0,d0.w)			met un bo zero à la fin

	moveq #0,d0				Argc
	bra.s search_end_space
loop_parse_line
	clr.b -1(a0)
	addq.w #1,d0				incrémente argc
	cmp.w #MAXARGC,d0
	beq.s end_of_parsing
search_end_space
	cmp.b #" ",(a0)				saute tous les espaces
	beq.s search_end_space
	tst.b (a0)				fin de la ligne ?
	beq.s end_of_parsing
	move.l a0,(a1)+				sauve le ptr sur le début de l'argument
	cmp.b #'"',(a0)				argument entre quotes ?
	bne.s non_quoted_arg	

	addq.l #1,a0
	move.l a0,-4(a1)
quoted_arg
	tst.b (a0)+
	beq.s end_of_parsing			fin de la ligne ?
	cmp.b #'"',-1(a0)			fin de l'argument ?
	bne.s quoted_arg
	bra.s loop_parse_line

non_quoted_arg
	tst.b (a0)+
	beq.s end_non_quoted			fin de la ligne ?
	cmp.b #" ",-1(a0)			espace ?
	bne.s non_quoted_arg
	bra.s loop_parse_line
end_non_quoted
	addq.w #1,d0				incrémente argc
end_of_parsing
	rts



*************************************************************************************************
*                          LA STRUCTURE DU CLIPART LOADSEG()'ABLE
*************************************************************************************************
Hunk_Part1
	dc.l HUNK_HEADER			signale que c'est un LoadSeg()'able
	dc.l 0					fin du hunk name
	dc.l 2					ya 2 hunks
	dc.l 0					numero du premier hunk
	dc.l 1					numero du deuxièmre hunk
	dc.l (Clipart_SIZEOF+3)/4		taille en LONG du premier hunk
patch_hunk1_size1
	dc.l HUNKF_CHIP				taille en LONG du deuxième hunk

	dc.l HUNK_DATA				déclare un hunk data chargeable n'importe où
	dc.l (Clipart_SIZEOF+3)/4		taille en LONG de ce hunk
clip_struct
	ds.l (Clipart_SIZEOF+3)/4		les datas de ce hunk
	dc.l HUNK_RELOC32			déclare une relocation
	dc.l 1					1 relocation
	dc.l 1					relocation sur le hunk 1
	dc.l ca_Image+ig_ImageData		offset de relocation dans le hunk 0
	dc.l 0					fin du hunk relocation
Hunk_Part2
	dc.l HUNK_END
Hunk_Part2_SIZEOF=*-Hunk_Part2

	dc.l HUNK_DATA|HUNKF_CHIP		hunk en chip pour les datas de l'image
patch_hunk1_size2
	dc.l 0					taille en LONG de ce hunk
Hunk_Part1_SIZEOF=*-Hunk_Part1



*************************************************************************************************
*                                LES DATAS DU PROGRAMME
*************************************************************************************************
PropChunks_Tags
	dc.l ID_ILBM,ID_CMAP
	dc.l ID_ILBM,ID_BMHD

DosName
	dc.b "dos.library",0
IFFParseName
	dc.b "iffparse.library",0

ErrorMsg
	dc.b 10
	dc.b $9b,"0;32;40m"
	dc.b "** MakeClipart v1.0  ©1994 Sync/DreamDealers **",10
	dc.b "This tool convert IFF-Clipart for a use in Live.",10
	dc.b 10
	dc.b $9b,"0;33;40m"
	dc.b "Usage: "
	dc.b $9b,"0;31;40m"
	dc.b "MakeClipart <INPUT NAME> <CLIPART SURNAME> <OUTPUT NAME>",10
	dc.b 10
ErrorMsg_SIZE=*-ErrorMsg



	section gpeur,bss

	rsreset
DataBase_struct		rs.b 0
_ExecBase		rs.l 1
_DosBase		rs.l 1
_IFFParseBase		rs.l 1
File_Handle		rs.l 1
IFF_Handle		rs.l 1
CliArgs			rs.l 2
CliArg1			rs.l 1
CliArg2			rs.l 1
CliArg3			rs.l 1
ClipartSize		rs.l 1
ClipartAdr		rs.l 1
ClipartX		rs.w 1
ClipartY		rs.w 1
ClipartDepth		rs.w 1
BMHD_Chunk		rs.l 1
CMAP_Chunk		rs.l 1
Mem_Size		rs.l 1
Mem_Adr			rs.l 1
Crunch_Mode		rs.b 1
ErrorFlag		rs.b 1
DataBase_SIZEOF		rs.b 0

_DataBase
	ds.b DataBase_SIZEOF

