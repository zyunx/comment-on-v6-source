/ tape boot program to load and transfer
/ to a 'tp' entry

/ entry is made by jsr pc,*$0
/ so return can be rts pc
/ jsr pc,(r5) is putc
/ jsr pc,2(r5) is getc
/ jsr pc,4(r5) is mesg

/ comment: 24K words of core memory
core = 24.
.mt. = 1
/ relocation address, see UNIX Assembler Reference Manual
.. = [core*2048.]-512.
start:
	mov	$..,sp
	mov	$name,r4
	mov	sp,r1
	cmp	pc,r1
	/ comment: if load at relocation address
	bhis	2f
	/ comment: load at 0
	clr	r0
	/ commnet: a.out magic number
	cmp	(r0),$407
	bne	1f
	/ comment: skip a.out header
	mov	$20,r0
1:
/ comment: relocate
	mov	(r0)+,(r1)+
	cmp	r1,$end
	blo	1b
	/ comment: jmp to start
	jmp	(sp)

2:
	/ comment: rewind
	jsr	pc,rew
	/ comment: function vector, put, get, mesg
	/ comment: put '='
	mov	$tvec,r5
	mov	$'=,r0
	jsr	pc,(r5)
/ comment: read string into (r4), that is 'name'. '@' for clearing, '#' for backspace.
2:
	mov	r4,r1
1:
	jsr	pc,2(r5)
	cmp	r0,$'\n
	beq	1f
	cmp	r0,$'@
	beq	2b
	movb	r0,(r1)+
	cmp	r0,$'#
	bne	1b
	sub	$2,r1
	cmp	r1,r4
	blo	2b
	br	1b
1:
	/ comment: if name is empty, restart
	clrb	(r1)
	cmp	r1,r4
	blos	start
	/ read dir entries
	mov	$1,tapa
	mov	$-6144.,wc
	jsr	pc,taper
	/ comment: compare names to find the dir entry
	clr	r1
1:
	mov	r1,r2
	mov	r4,r0
2:
	cmpb	(r0)+,(r1)
	bne	2f
	tstb	(r1)+
	bne	2b
	/ comment: The named dir entry is found
	br	1f
2:
	mov	r2,r1
	add	$64.,r1
	cmp	r1,$12288.
	blo	1b
	jsr	pc,rew
	br	start
1:
	mov	44.(r2),tapa
	/ comment: calculate word count from size in bytes
	mov	38.(r2),r0
	inc	r0
	clc
	ror	r0
	neg	r0
	mov	r0,wc
	clr	r0
	/ comment: clear memory
1:
	clr	(r0)+
	cmp	r0,sp
	blo	1b
	/ comment: read file contents
	jsr	pc,taper
	jsr	pc,rew
	clr	r0
	cmp	(r0),$407		/ unix a.out?
	bne	2f
	/ comment: remove a.out header
1:
	mov	20(r0),(r0)+
	cmp	r0,sp
	blo	1b
2:
	jsr	pc,*$0
	br	start

.if .mt.
mts = 172520
mtc = 172522
mtbrc = 172524
mtcma = 172526

taper:
	clr	mtma
	cmp	mtapa,tapa
	beq	1f
	bhi	2f
	jsr	pc,rrec
	br	taper
2:
	jsr	pc,rew
	br	taper
/ comment: read (wc + 255)/256 blocks
1:
	mov	wc,r1
1:
	jsr	pc,rrec
	add	$256.,r1
	bmi	1b
	rts	pc

/ comment: read a 512B record
rrec:
	/ comment: wait rewind operation to complete
	bit	$2,*$mts
	bne	rrec
	/ comment: wait the tape to ready
	tstb	*$mtc
	bge	rrec
	mov	$-512.,*$mtbrc
	mov	mtma,*$mtcma
	/ comment: 9-channel, read, go
	mov	$60003,*$mtc
1:
	/ comment: wait the tape to ready
	tstb	*$mtc
	bge	1b
	/ comment: test error
	tst	*$mtc
	bge	1f
	/ comment: erro condition
	mov	$-1,*$mtbrc
	mov	$60013,*$mtc
	br	rrec
1:
	add	$512.,mtma
	inc	mtapa
	rts	pc

/ comment: rewind
rew:
	/ comment: 9-channel tape, rewind, go
	mov	$60017,*$mtc
	clr	mtapa
	rts	pc
.endif

.if .mt.-1
tcdt = 177350
tccm = 177342
taper:
	mov	$tcdt,r0
	mov	$tccm,r1
for:
	mov	$3,(r1)			/ rbn for
1:
	tstb	(r1)
	bge	1b
	tst	(r1)
	blt	rev
	cmp	tapa,(r0)
	beq	rd
	bgt	for

rev:
	mov	$4003,(r1)		/ rbn bac
1:
	tstb	(r1)
	bge	1b
	tst	(r1)
	blt	for
	mov	(r0),r2
	add	$5,r2
	cmp	tapa,r2
	blt	rev
	br	for

rd:
	clr	-(r0)				/ bus addr
	mov	wc,-(r0)			/ wc
	mov	$5,-(r0)			/ read
1:
	tstb	(r1)
	bge	1b
	tst	(r1)
	blt	taper
	rts	pc

rew:
	mov	$4003,tccm
	rts	pc
.endif

tvec:
	br	putc
	br	getc
	br	mesg

tks = 177560
tkb = 177562
getc:
	mov	$tks,r0
	inc	(r0)
1:
	tstb	(r0)
	bge	1b
	mov	tkb,r0
	bic	$!177,r0
	cmp	r0,$'A
	blo	1f
	cmp	r0,$'Z
	bhi	1f
	add	$40,r0
1:
	cmp	r0,$'\r
	bne	putc
	mov	$'\n,r0

tps = 177564
tpb = 177566
putc:
	tstb	tps
	bge	putc
	cmp	r0,$'\n
	bne	1f
	mov	$'\r,r0
	jsr	pc,(r5)
	mov	$'\n+200,r0
	jsr	pc,(r5)
	clr	r0
	jsr	pc,(r5)
	mov	$'\n,r0
	rts	pc
1:
	mov	r0,tpb
	rts	pc

mesg:
	movb	*(sp),r0
	beq	1f
	jsr	pc,(r5)
	inc	(sp)
	br	mesg
1:
	add	$2,(sp)
	bic	$1,(sp)
	rts	pc

end:
/ comment: tape address to be read
tapa:	.=.+2
/ comment: current megatape address
mtapa:	.=.+2
/ commnet: current megatap memory address
mtma:	.=.+2
/ comment: word count
wc:	.=.+2
name:	.=.+32.
