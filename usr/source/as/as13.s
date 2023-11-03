/ comment: assemble a statement
/
/

/ a3 -- pdp-11 assembler pass 1

assem:
	jsr	pc,readop
	/ comment: check end of statement
	jsr	pc,checkeos
		br ealoop
	/ comment: it's not end-of-statement token
	tst	ifflg
	beq	3f
	cmp	r4,$200
	blos	assem
	/ comment: process '.if' and '.endif'
	cmpb	(r4),$21	/if
	bne	2f
	inc	ifflg
2:
	cmpb	(r4),$22   /endif
	bne	assem
	dec	ifflg
	br	assem
3:
	/ comment: It's not in .if
	mov	r4,-(sp)
	/ comment: look ahead next token
	jsr	pc,readop
	cmp	r4,$'=
	beq	4f
	cmp	r4,$':
	beq	1f
	/ comment: otherwise is a operation line
	mov	r4,savop
	mov	(sp)+,r4
	jsr	pc,opline
	br	ealoop
1:
	/ comment: prase labels
	mov	(sp)+,r4
	/ comment: check if r4 is a pointer of name type or not.
	/ comment: It's a name when r4 >= 200, 200 is the celling of ascii values.
	cmp	r4,$200
	bhis	1f
	cmp	r4,$1		/ digit
	beq	3f
	jsr	r5,error; 'x
	br	assem
1:
	/ comment: Now, the current token is a name
	/ comment: Check if it is defined
	bitb	$37,(r4)
	beq	1f
	/ comment: multiply defined symbol as label
	jsr	r5,error; 'm
1:
	/ comment: give this symbol dot's type (text)
	bisb	dot-2,(r4)
	/ comment: give this symbol dot's value
	mov	dot,2(r4)
	br	assem
3:
	/ comment: process local label
	mov	numval,r0
	jsr	pc,fbcheck
	/ comment: current flag buffer segment
	movb	dotrel,curfbr(r0)
	asl	r0
	/ comment: segment type
	movb	dotrel,nxtfb
	/ comment: value
	mov	dot,nxtfb+2
	/ comment: label number
	movb	r0,nxtfb+1
	/ comment: current flag buffer value
	mov	dot,curfb(r0)
	/ comment: write to a.tmp2
	movb	fbfil,r0
	sys	write; nxtfb; 4
	br	assem
4:
	/ comment: parse assignment statement
	jsr	pc,readop
	jsr	pc,expres
	mov	(sp)+,r1
	cmp	r1,$200
	bhis	1f
	/ comment: if last token is not a symbol, show error
	jsr	r5,error; 'x
	br	ealoop
1:
	cmp	r1,$dotrel
	bne	2f
	/ comment: left side is dotrel
	bic	$40,r3
	cmp	r3,dotrel
	bne	1f
	/ comment: now, right side is of type dotrel
2:
	bicb	$37,(r1)
	bic	$!37,r3
	bne	2f
	/ comment: if result type is undefined
	clr	r2
2:
	/ comment: set type and value
	bisb	r3,(r1)
	mov	r2,2(r1)
	br	ealoop
1:
	/ comment: illegal assignment to ‘‘ . ’’
	jsr	r5,error; '.
	movb	$2,dotrel
ealoop:
	/ comment: process token that ends an instruction
	cmp	r4,$';
	beq	assem1
	cmp	r4,$'\n
	bne	1f
	inc	line
	br	assem1
1:
	cmp	r4,$'\e
	bne	2f
	/ comment: end of file
	tst	ifflg
	beq	1f
	/ comment: syntax error
	jsr	r5,error; 'x
1:
	rts	pc
2:
	jsr	r5,error; 'x
2:
	/ comment: eat token upto end of statement
	jsr	pc,checkeos
		br assem1
	jsr	pc,readop
	br	2b
assem1:
	jmp	assem

fbcheck:
	cmp	r0,$9.
	bhi	1f
	rts	pc
1:
	/ comment: error in local (‘‘f ’’ or ‘‘b’’) type symbol
	jsr	r5,error; 'f
	clr	r0
	rts	pc

/ comment: check end of symbol
checkeos:
	cmp	r4,$'\n
	beq	1f
	cmp	r4,$';
	beq	1f
	cmp	r4,$'\e
	beq	1f
	add	$2,(sp)
1:
	rts	pc

