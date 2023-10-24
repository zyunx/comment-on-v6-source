/ comment: for reading from input and puting into symbol table
/
/

/ a4 -- pdp-11 assembler pass1

/ comment: read a name, and create symbol entry if neccesary,
/ return the symbol entry in r4
rname:
	mov	r1,-(sp)
	mov	r2,-(sp)
	mov	r3,-(sp)
	mov	$8,r5
	mov	$symbol+8.,r2
	clr	-(r2)
	clr	-(r2)
	clr	-(r2)
	clr	-(r2)
	clr	-(sp)
	clr	-(sp)
	/ comment: r0 is the lookahead char
	cmp	r0,$'~		/  symbol not for hash table
	bne	1f
	inc	2(sp)
	/ comment: ignore '~'
	clr	ch
1:
	jsr	pc,rch
	movb	chartab(r0),r3
	ble	1f
	/ comment: calculate hash value in (sp)
	add	r3,(sp)
	swab	(sp)
	dec	r5
	/ comment: if name is greater than 8, ignore rest of chars
	blt	1b
	movb	r3,(r2)+
	br	1b
1:
	/ comment: the char is not in name alphabet,
	/ that is name is read completely.
	/ comment: put back the non alphanum char
	mov	r0,ch
	/ comment: hash value of name
	mov	(sp)+,r1
	clr	r0
	/ comment: test '~' prefix flag
	tst	(sp)+
	beq	1f
	/ comment: if '~' prefix flag is set,
	/ just create symbol entry,
	/ don't create hash table entry.
	mov	symend,r4
	br	4f
1:
	/ comment: calculate hashtable index
	div	$hshsiz,r0
	ashc	$1,r0
	add	$hshtab,r1
1:
	/ comment: handle hash collision
	sub	r0,r1
	cmp	r1,$hshtab
	bhi	2f
	add	$2*hshsiz,r1
2:
	/ comment: compare symbol names
	mov	$symbol,r2
	mov	-(r1),r4
	beq	3f
	cmp	(r2)+,(r4)+
	bne	1b
	cmp	(r2)+,(r4)+
	bne	1b
	cmp	(r2)+,(r4)+
	bne	1b
	cmp	(r2)+,(r4)+
	bne	1b
	br	1f
3:
	/ comment: empty hashtable entry found
	/ that is, it's a new name.
	mov	symend,r4
	/ comment: r1 is hash table entry
	mov	r4,(r1)
4:
	/ comment: create a new symbol
	/ expand memory if neccesary.
	mov	$symbol,r2
	mov	r4,-(sp)
	add	$20,r4
	cmp	r4,0f
	blos	4f
	add	$512.,0f
	sys	indir; 9f
	.data
9:	sys	break; 0:end
	.text
4:
	/ comment: create symbol
	mov	(sp)+,r4
	mov	(r2)+,(r4)+
	mov	(r2)+,(r4)+
	mov	(r2)+,(r4)+
	mov	(r2)+,(r4)+
	clr	(r4)+
	clr	(r4)+
	mov	r4,symend
	sub	$4,r4
1:
	/ comment: now, r4 is point the symbol table entry
	mov	r4,-(sp)
	mov	r4,r3
	sub	$8,r3
	cmp	r3,$usymtab
	blo	1f
	sub	$usymtab,r3
	clr	r2
	div	$3,r2
	mov	r2,r4
	add	$4000,r4		/ user symbol
	br	2f
1:
	/ comment: process builtin symbol
	sub	$symtab,r3
	clr	r2
	div	$3,r2
	mov	r2,r4
	add	$1000,r4		/ builtin symbol
2:
	jsr	pc,putw
	/ comment: r4 is the symbol entry
	mov	(sp)+,r4
	mov	(sp)+,r3
	mov	(sp)+,r2
	mov	(sp)+,r1
	tst	(sp)+
	rts	pc

/ comment: read a number or temperary label.
/ It it's a number, return it in r0,
/ otherwise, return the temperary label in r0 and r4
number:
	mov	r2,-(sp)
	mov	r3,-(sp)
	mov	r5,-(sp)
	clr	r1
	clr	r5
1:
	jsr	pc,rch
	jsr	r5,betwen; '0; '9
		br 1f
	sub	$'0,r0
	/ comment: r5 store decimal
	mpy	$10.,r5
	add	r0,r5
	/ comment: r1 store octal
	als	$3,r1
	add	r0,r1
	br	1b
1:
	cmp	r0,$'b
	beq	1f
	cmp	r0,$'f
	beq	1f
	cmp	r0,$'.
	bne	2f
	/ comment: return decimal in r0
	mov	r5,r1
	clr	r0
2:
	movb	r0,ch
	mov	r1,r0
	mov	(sp)+,r5
	mov	(sp)+,r3
	mov	(sp)+,r2
	rts	pc
1:
	/ comment: temperary symbols suffixed with 'b' or 'f'
	mov	r0,r3
	mov	r5,r0
	jsr	pc,fbcheck
	add	$141,r0
	cmp	r3,$'b
	beq	1f
	add	$10.,r0
1:
	mov	r0,r4
	mov	(sp)+,r5
	mov	(sp)+,r3
	mov	(sp)+,r2
	add	$2,(sp)
	rts	pc

/ comment: read a char into r0
/ comment: `ch` is a putback char
rch:
	/ comment: read from putback char
	movb	ch,r0
	beq	1f
	clrb	ch
	rts	pc
1:
	/ comment: read from buffer
	dec	inbfcnt
	blt	2f
	movb	*inbfp,r0
	inc	inbfp
	bic	$!177,r0
	beq	1b
	rts	pc
2:
	movb	fin,r0
	beq	3f
	sys	read; inbuf;512.
	/ comment: if read error, close file, open next file
	bcs	2f
	tst	r0
	/ comment: if end of file, close file, open next file
	beq	2f
	mov	r0,inbfcnt
	mov	$inbuf,inbfp
	br	1b
2:
	movb	fin,r0
	clrb	fin
	sys	close
3:
	/ comment: pull next cmd arg, and open it for input
	decb	nargs
	bgt	2f
	/ comment: No more file args, return end mark
	mov	$'\e,r0
	rts	pc
2:
	tst	ifflg
	beq	2f
	/ comment: ifflg is still set at the end of a file
	jsr	r5,error; 'i
	jmp	aexit
2:
	/ comment: open next file for input
	mov	curarg,r0
	tst	(r0)+
	mov	(r0),0f
	mov	r0,curarg
	incb	fileflg
	sys	indir; 9f
	.data
9:	sys	open; 0:0; 0
	.text
	bec	2f
	mov	0b,r0
	jsr	r5,filerr; <?\n>
	jmp	 aexit
2:
	/ comment: now, file opened successfully
	/ comment: current 
	movb	r0,fin
	/ comment: line number
	mov	$1,line
	mov	r4,-(sp)
	mov	r1,-(sp)
	/ comment: put file name to atm1x
	mov	$5,r4
	jsr	pc,putw
	mov	*curarg,r1
2:
	/ comment: put file name to atm1x
	movb	(r1)+,r4
	beq	2f
	jsr	pc,putw
	br	2b
2:
	/ comment: put -1 to atm1x
	mov	$-1,r4
	jsr	pc,putw
	mov	(sp)+,r1
	mov	(sp)+,r4
	br	1b

