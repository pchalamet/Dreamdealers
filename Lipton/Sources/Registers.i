
**************************************
* Registres hardware du Chip Set AGA *
**************************************
custom_base=$dff000
bltddat=$000
dmaconr=$002
vposr=$004
vhposr=$006
dskdatr=$008
joy0dat=$00a
joy1dat=$00c
clxdat=$00e
adkconr=$010
pot0dat=$012
pot1dat=$014
potinp=$016
serdatr=$018
dskbytr=$01a
intenar=$01c
intreqr=$01e
dskpt=$020
dsklen=$024
dskdat=$026
refptr=$028
vposw=$02a
vhposw=$02c
copcon=$02e
serdat=$030
serper=$032
potgo=$034
joytest=$036
strequ=$038
strvbl=$03a
strhor=$03c
strlong=$03e
bltcon0=$040
bltcon1=$042
bltafwm=$044
bltalwm=$046
bltcpt=$048
bltbpt=$04c
bltapt=$050
bltdpt=$054
bltsize=$058
bltcon0l=$05b				byte access only
bltsizV=$05c
bltsizH=$05e
bltcmod=$060
bltbmod=$062
bltamod=$064
bltdmod=$066
bltcdat=$070
bltbdat=$072
bltadat=$074
deniseid=$07c				$ff=chip aga
dsksync=$07e
cop1lc=$080
cop2lc=$084
copjmp1=$088
copjmp2=$08a
copins=$08c
diwstrt=$08e
diwstop=$090
ddfstrt=$092
ddfstop=$094
dmacon=$096
clxcon=$098
intena=$09a
intreq=$09c
adkcon=$09e
aud0lcH=$0a0
aud0lcL=$0a2
aud0len=$0a4
aud0per=$0a6
aud0vol=$0a8
aud0dat=$0aa
aud1lcH=$0a0
aud1lcL=$0a2
aud1len=$0a4
aud1per=$0a6
aud1vol=$0a8
aud1dat=$0aa
aud2lcH=$0a0
aud2lcL=$0a2
aud2len=$0a4
aud2per=$0a6
aud2vol=$0a8
aud2dat=$0aa
aud3lcH=$0a0
aud3lcL=$0a2
aud3len=$0a4
aud3per=$0a6
aud3vol=$0a8
aud3dat=$0aa
bpl1ptH=$e0
bpl1ptL=$e2
bpl2ptH=$e4
bpl2ptL=$e6
bpl3ptH=$e8
bpl3ptL=$ea
bpl4ptH=$ec
bpl4ptL=$ee
bpl5ptH=$f0
bpl5ptL=$f2
bpl6ptH=$f4
bpl6ptL=$f6
bpl7ptH=$f8
bpl7ptL=$fa
bpl8ptH=$fc
bpl8ptL=$fe
bplcon0=$100
bplcon1=$102
bplcon2=$104
bplcon3=$106
bpl1mod=$108
bpl2mod=$10a
bplcon4=$10c
clxcon2=$10e
bpl1dat=$110
bpl2dat=$112
bpl3dat=$114
bpl4dat=$116
bpl5dat=$118
bpl6dat=$11a
bpl7dat=$11c
bpl8dat=$11e
spr0ptH=$120
spr0ptL=$122
spr1ptH=$124
spr1ptL=$126
spr2ptH=$128
spr2ptL=$12a
spr3ptH=$12c
spr3ptL=$12e
spr4ptH=$130
spr4ptL=$132
spr5ptH=$134
spr5ptL=$136
spr6ptH=$138
spr6ptL=$13a
spr7ptH=$13c
spr7ptL=$13e
spr0pos=$140
spr0ctl=$142
spr0data=$144
spr0datb=$146
spr1pos=$148
spr1ctl=$14a
spr1data=$14c
spr1datb=$14e
spr2pos=$150
spr2ctl=$152
spr2data=$154
spr2datb=$156
spr3pos=$158
spr3ctl=$15a
spr3data=$15c
spr3datb=$15e
spr4pos=$160
spr4ctl=$162
spr4data=$164
spr4datb=$166
spr5pos=$168
spr5ctl=$16a
spr5data=$16c
spr5datb=$16e
spr6pos=$170
spr6ctl=$172
spr6data=$174
spr6datb=$176
spr7pos=$178
spr7ctl=$17a
spr7data=$17c
spr7datb=$17e
color00=$180
color01=$182
color02=$184
color03=$186
color04=$188
color05=$18a
color06=$18c
color07=$18e
color08=$190
color09=$192
color10=$194
color11=$196
color12=$198
color13=$19a
color14=$19c
color15=$19e
color16=$1a0
color17=$1a2
color18=$1a4
color19=$1a6
color20=$1a8
color21=$1aa
color22=$1ac
color23=$1ae
color24=$1b0
color25=$1b2
color26=$1b4
color27=$1b6
color28=$1b8
color29=$1ba
color30=$1bc
color31=$1be
htotal=$1c0
hsstop=$1c2
hbstrt=$1c4
hbstop=$1c6
vtotal=$1c8
vsstop=$1ca
vbstrt=$1cc
vbstop=$1ce
sprhstrt=$1d0
sprhstop=$1d2
bplhstrt=$1d4
bplhstop=$1d6
hhposw=$1d8
hhposr=$1da
beamcon0=$1dc
hsstrt=$1de
vsstrt=$1e0
hcenter=$1e2
diwhigh=$1e4
fmode=$1fc

**********************
* Registres du CIA-A *
**********************
ciaapra=$bfe001
ciaaprb=$bfe101
ciaaddra=$bfe201
ciaaddrb=$bfe301
ciaatalo=$bfe401
ciaatahi=$bfe501
ciaatblo=$bfe601
ciaatbhi=$bfe701
ciaatodlow=$bfe801
ciaatodmid=$bfe901
ciaatodhi=$bfea01
ciaasdr=$bfec01
ciaaicr=$bfed01
ciaacra=$bfee01
ciaacrb=$bfef01

**********************
* Registres du CIA-B *
**********************
ciabpra=$bfd000
ciabprb=$bfd100
ciabddra=$bfd200
ciabddrb=$bfd300
ciabtalo=$bfd400
ciabtahi=$bfd500
ciabtblo=$bfd600
ciabtbhi=$bfd700
ciabtodlow=$bfd800
ciabtodmid=$bfd900
ciabtodhi=$bfda00
ciabsdr=$bfdc00
ciabicr=$bfdd00
ciabcra=$bfde00
ciabcrb=$bfdf00

*****************************
* Offsets de l'exec.library *
*****************************
exec_base=4
Forbid=-132
Permit=-138
OpenLibrary=-552
CloseLibrary=-414
AllocMem=-198
FreeMem =-210
PUBLIC=1
CHIP=2
FAST=4
CLEAR=$10000

**********************************
* Offsets de la graphics.library *
**********************************
WaitTof=-270
OwnBlitter=-456
DisownBlitter=-462
WaitBlit=-228
LoadView=-222

**********
* Macros *
**********
KILL_SYSTEM	macro
Kill_System
	lea .GfxName(pc),a1			ouvre la graphics.library
	moveq #0,d0
	move.l (exec_base).w,a6
	jsr OpenLibrary(a6)
	move.l d0,a6

	move.w #150-1,d7			attend 3 secondes...
.delay
	jsr WaitTof(a6)
	dbf d7,.delay

	jsr OwnBlitter(a6)			monopolise le blitter
	jsr WaitBlit(a6)

	lea custom_base,a5			sauve intena/dmacon
	move.w intenar(a5),-(sp)
	or.w #$c000,(sp)
	move.l #$7fff7fff,intena(a5)
	move.w dmaconr(a5),-(sp)
	or.w #$8200,(sp)
	move.w #$7fff,dmacon(a5)

	move.w potinp(a5),-(sp)			sauve les directions des ports
	move.w #$ff00,potgo(a5)			et les configure comme ils
	move.b ciaapra,-(sp)			devraient l'être
	move.b ciaaddra,-(sp)
	move.b #$3,ciaaddra

	move.l $80.w,-(sp)			sauve quelques vecteurs
	move.l $6c.w,-(sp)
	move.l $78.w,-(sp)

	lea spr0pos(a5),a0			vire les sprites
	moveq #16-1,d0
.clear_spr
	clr.l (a0)+
	dbf d0,.clear_spr

	movem.l a5/a6,-(sp)			saute à la routine passée comme
	move.l #\1,$80.w			paramètre à la macro KILL_SYSTEM
	trap #0
	movem.l (sp)+,a5/a6

	move.l (sp)+,$78.w			remet tout comme c'était avant
	move.l (sp)+,$6c.w
	move.l (sp)+,$80.w

	move.b (sp)+,ciaaddra
	move.b (sp)+,ciaapra
	move.w (sp)+,potgo(a5)

	jsr WaitBlit(a6)
	jsr DisownBlitter(a6)
	move.w #$7fff,intena(a5)
	move.w #$7fff,dmacon(a5)
	move.w (sp)+,dmacon(a5)
	move.w (sp)+,intena(a5)

	move.l $26(a6),cop1lc(a5)
	move.l $32(a6),cop2lc(a5)
	clr.w copjmp1(a5)

	move.l a6,a1
	move.l (exec_base).w,a6
	jsr CloseLibrary(a6)
	moveq #0,d0
	rts

.GfxName
	dc.b "graphics.library",0
	dc.b " -- ©1993 Sync of Dreamdealers -- "
	even
	endm

SAVE_680x0	macro
Save_680x0
	move.l (exec_base).w,a0
	move.w 296(a0),d0
	and.w #$3,d0
	beq.s .MC68000
	subq.w #2,d0
	blt.s .MC68010
.MC680x0
	movec.l caar,d1
	move.l d1,-(sp)
	moveq #0,d1
	movec.l d1,caar
.MC68010
	movec.l vbr,d1
	move.l d1,-(sp)
	moveq #0,d1
	movec.l d1,vbr
.MC68000
	endm

RESTORE_680x0	macro
	move.l (exec_base).w,a0
	move.w 296(a0),d0
	and.w #$3,d0
	beq.s .MC68000
	move.l (sp)+,d1
	movec.l d1,vbr
	subq.w #2,d0
	blt.s .MC68000
	move.l (sp)+,d1
	movec.l d1,caar
.MC68000
	endm

;WAIT_BLITTER	macro
;.wait_blitter\@
;	btst #14,dmaconr(a6)
;	bne.s .wait_blitter\@
;	endm

;WAIT_VHSPOS	macro
;.wait_beam\@
;	move.l vposr(a6),d0
;	and.l #$1ff00,d0
;	IFEQ NARG
;	cmp.l #$12700,d0
;	ELSEIF
;	cmp.l #\1,d0
;	ENDC
;	bne.s .wait_beam\@
;	endm

;CALL	macro
;	IFNE NARG=2
;	move.l \1,a6
;	jsr _LVO\2(a6)
;	ELSEIF
;	jsr _LVO\1(a6)
;	ENC
;	endm

