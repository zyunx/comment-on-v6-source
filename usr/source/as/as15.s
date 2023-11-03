/ comment: token parsers
/
/

/ a5 -- pdp-11 assembler pass 1

/ comment: Abstract as a stream of token,
/ and put these tokens in a.temp1 (processed program file),
/ and if it's a new user symbol, create a user defined symbol entry,
/ comment: if it's a symbol, return the symbol type pointer in r4,
/ otherwise, return the symbol type.
readop:
	/ comment: return from op putback buffer
	mov	savop,r4
	beq	1f
	clr	savop
	rts	pc
1:
	jsr	pc,8f
	jsr	pc,putw
	rts	pc

8:
	jsr	pc,rch
_readop:
	mov	r0,r4
	movb	chartab(r0),r1
	bgt	rdname
	jmp	*1f-2(r1)

	/ comment: chartab -26
	fixor
	/ comment: chartab -24
	escp
	/ comment: chartab -22
	8b					/ comment: blank, just ignore this char
	/ comment: chartab -20
	retread
	/ comment: chartab -16
	dquote
	/ comment: chartab -14
	garb
	/ comment: chartab -12
	squote
	/ comment: chartab -10
	rdname
	/ comment: chartab -6
	skip					/ comment: process comment
	/ comment: chartab -4
	rdnum
	/ comment: chartab -2
	retread
	/ comment: chartab 0
	string
1:

escp:
	jsr	pc,rch
	mov	$esctab,r1
1:
	cmpb	r0,(r1)+
	beq	1f
	tstb	(r1)+
	bne	1b
	rts	pc
1:
	movb	(r1),r4
	rts	pc

esctab:
	.byte '/, '/
	.byte '\<, 035
	.byte '>, 036
	.byte '%, 037
	.byte 0, 0

fixor:
	mov	$037,r4
retread:
	rts	pc

rdname:
	/ comment: put back char into input, r0 is the look ahead
	movb	r0,ch
	/ comment: r1 is chartab value
	cmp	r1,$'0
	blo	1f
	cmp	r1,$'9
	/ comment: r1 is a digit, read a number
	blos	rdnum
1:
	jmp	rname

rdnum:
	/ comment: maybe a number or a local label.
	/ comment: if it's a number, branch 1f
	jsr	pc,number
		br 1f
	rts	pc

squote:
	jsr	pc,rsch
	br	1f
dquote:
	jsr	pc,rsch
	mov	r0,-(sp)
	jsr	pc,rsch
	swab	r0
	bis	(sp)+,r0
1:
	/ comment: numval is the value if the token is a number
	mov	r0,numval
	mov	$1,r4
	jsr	pc,putw
	mov	numval,r4
	jsr	pc,putw
	/ comment: if 1 (absolute, see as19.s), double or single quote char
	mov	$1,r4
	/ comment: return 2 level
	tst	(sp)+
	rts	pc

/ comment: '/' is read, skip to end of line
skip:
	jsr	pc,rch
	mov	r0,r4
	cmp	r0,$'\e
	beq	1f
	cmp	r0,$'\n
	bne	skip
1:
	rts	pc

/ comment: garbage chars
garb:
	jsr	r5,error; 'g
	br	8b

string:
	mov	$'<,r4
	jsr	pc,putw
	clr	numval
1:
	jsr	pc,rsch
	/ comment: if r1 is zero, this char is escaped '>'
	tst	r1
	bne	1f
	mov	r0,r4
	bis	$400,r4
	jsr	pc,putw
	inc	 numval
	br	1b
1:
	mov	$-1,r4
	jsr	pc,putw
	mov	$'<,r4
	tst	(sp)+
	rts	pc

/ comment: read char, parsing escape sequence
rsch:
	jsr	pc,rch
	cmp	r0,$'\e
	beq	4f
	cmp	r0,$'\n
	beq	4f
	clr	r1
	cmp	r0,$'\\
	bne	3f
	/ comment: process escape sequence
	jsr	pc,rch
	mov	$schar,r2
1:
	cmpb	(r2)+,r0
	beq	2f
	tstb	(r2)+
	bpl	1b
	/ comment: return r0 it as it is
	rts	pc
2:
	movb	(r2)+,r0
	clr	r1
	rts	pc
3:
	cmp	r0,$'>
	bne	1f
	/ comment: not escaped '>'
	inc	r1
1:
	rts	pc
4:
	/ comment: string not terminated properly
	jsr	r5,error; '<
	jmp	aexit

schar:
	.byte 'n, 012
	.byte 't, 011
	.byte 'e, 004
	.byte '0, 000
	.byte 'r, 015
	.byte 'a, 006
	.byte 'p, 033
	.byte 0,  -1

