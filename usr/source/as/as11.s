/ comment: main control flow
/
/

/ PDP-11 assembler pass 0

indir	= 0

	jmp	start
/ comment: main control flow
/ comment: Now, 'unglob' flag is assigned, 
/ text file and forward/backward label file is created,
/ and symbol hashtable is setup.
go:
	jsr	pc,assem
	movb	pof,r0
	sys	write; outbuf; 512.
	movb	pof,r0
	sys	close
	movb	fbfil,r0
	sys	close
	tstb	errflg
	bne	aexit
	/ comment: write symbol table
	jsr	r5,fcreat; a.tmp3
	mov	r0,r1
	mov	symend,0f
	sub	$usymtab,0f
	sys	indir; 9f
	.data
9:	sys	write; usymtab; 0:..
	.text
	mov	r1,r0
	sys	close
	sys	exec; 2f; 1f
	mov	$2f,r0
	jsr	r5,filerr; "?\n

aexit:
	sys	unlink; a.tmp1
	sys	unlink; a.tmp2
	sys	unlink; a.tmp3
	sys	exit
.data
1:
	2f
	a.tmp1
	a.tmp2
	a.tmp3
unglob:
	3f
	0
	.text
2:
fpass2:
	</lib/as2\0>
3:
	<-g\0>
	.even

/ comment: print file error
/ comment: r0 is file name
filerr:
	mov	r4,-(sp)
	mov	r0,r4
	mov	r4,0f
	clr	r0
1:
	/ comment: make r4 point end of filename
	tstb	(r4)+
	beq	1f
	inc	r0
	br	1b
1:
	/ comment: r0 now is the length of filename
	mov	r0,1f
	mov	$1,r0
	sys	indir; 9f
	.data
9:	sys	write; 0:0; 1:0
	.text
	/ comment: r5 is the rest of error message
	mov	r5,0f
	mov	$1,r0
	sys	indir; 9f
	.data
9:	sys	write; 0:0; 2
	.text
	tst	(r5)+
	mov	(sp)+,r4
	rts	r5

/ comment: create tmp file */
fcreat:
	mov	r4,-(sp)
	mov	(r5)+,r4
	/ comment: r4 is the file name
	mov	r4,0f
1:
	sys	indir; 9f
	.data
9:	sys	stat; 0:..; outbuf
	.text
	bec	2f			/ comment: branch if error clear
	/ comment: the file does not exist
	mov	r4,0f
	sys	indir; 9f
	.data
9:	sys	creat; 0:..; 444
	.text
	bes	2f
	mov	(sp)+,r4
	rts	r5
2:
	incb	9.(r4)
	cmpb	9.(r4),$'z
	blos	1b
	mov	r4,r0
	jsr	r5,filerr; "?\n
	sys	exit
