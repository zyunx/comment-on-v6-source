/ comment: parse expression
/
/

/  a7 -- pdp-11 assembler pass 1

/ comment: a token is ready to process
/ comment: r2 is expression result,
/          r3 is result type
/          r0 is current operand type
/          r1 is current operand value
expres:
	mov	r5,-(sp)
	/ comment: for operator
	mov	$'+,-(sp)
	/ comment: is operand found?
	clr	opfound
	/ comment: expression result, 0
	clr	r2
	/ comment: result type, 1 = absolute
	mov	$1,r3
	br	1f
advanc:
	jsr	pc,readop
1:
	mov	r4,r0
	jsr	r5,betwen; 0; 177
		br .+4
	br	7f
	movb	(r4),r0
	mov	2(r4),r1
	br	oprand
7:
	/ comment: if current token is a non-symbol
	cmp	r4,$141
	blo	1f
	cmp	r4,$141+10.
	bhis	2f
	/ comment: if current token is alocal label, curfbr-141(r4) = r4 + (curfbr - 141) = r4 - 141 + curfbr 
	movb	curfbr-141(r4),r0
	asl	r4
	/ comment: curfb-[2*141](r4) = 2 * r4 + (curfb-[2*141]) = 2 * r4 - [2*141] + curfbr = 2*(r4-141) + curbr
	mov	curfb-[2*141](r4),r2
	bpl	oprand
	/ comment: just show local label error
	jsr	r5,error; 'f
	br	oprand
2:
	clr	r3
	clr	r2
	br	oprand
1:
	/ comment: handle operators
	mov	$esw1,r1
1:
	/ comment: loop all operators
	cmp	(r1)+,r4
	/ comment: if equal, operator found
	beq	1f
	tst	(r1)+
	bne	1b
	/ comment: not a operator, so expression ends.
	tst	opfound
	bne	2f
	/ comment: if operator not found error expression
	jsr	pc,errore
2:
	tst	(sp)+
	mov	(sp)+,r5
	rts	pc
1:
	jmp	*(r1)

esw1:
	'+;	binop
	'-;	binop
	'*;	binop
	'/;	binop
	'&;	binop
	037;	binop
	035;	binop
	036;	binop
	'%;	binop
	'[;	brack
	'^;	binop
	1;	exnum
	'!;	binop
	0;	0

binop:
	cmpb	(sp),$'+
	beq	1f
	jsr	pc,errore
1:
	movb	r4,(sp)
	br	advanc

exnum:
	mov	numval,r1
	mov	$1,r0
	br	oprand

brack:
	mov	r2,-(sp)
	mov	r3,-(sp)
	jsr	pc,readop
	jsr	pc,expres
	cmp	r4,$']
	beq	1f
	jsr	r5,error; ']
1:
	mov	r3,r0
	mov	r2,r1
	mov	(sp)+,r3
	mov	(sp)+,r2

/ comment: current token is a operand
/ comment: evaluate expression result upto this operand
/ comment: process current operand
oprand:
	inc	opfound
	mov	$exsw2,r5
1:
	/ comment: check previous operator
	cmp	(sp),(r5)+
	beq	1f
	tst	(r5)+
	bne	1b
	br	eoprnd
1:
	jmp	*(r5)

exsw2:
	'+; exadd
	'-; exsub
	'*; exmul
	'/; exdiv
	037; exor
	'&; exand
	035;exlsh
	036;exrsh
	'%; exmod
	'!; exnot
	'^; excmbin
	0;  0

excmbin:
	mov	r0,r3			/ give left flag of right
	br	eoprnd

exrsh:
	neg	r1
	beq	exlsh
	inc	r1
	clc
	ror	r2
exlsh:
	jsr	r5,combin; 0
	als	r1,r2
	br	eoprnd

exmod:
	jsr	r5,combin; 0
	mov	r1,-(sp)
	mov	r2,r1
	clr	r0
	dvd	(sp)+,r0
	mov	r1,r2
	br	eoprnd

exadd:
	jsr	r5,combin; 0
	add	r1,r2
	br	eoprnd

exsub:
	jsr	r5,combin; 1
	sub	r1,r2
	br	eoprnd

exand:
	jsr	r5,combin; 0
	com	r1
	bic	r1,r2
	br	eoprnd

exor:
	jsr	r5,combin; 0
	bis	r1,r2
	br	eoprnd

exmul:
	jsr	r5,combin; 0
	mpy	r2,r1
	mov	r1,r2
	br	eoprnd

exdiv:
	jsr	r5,combin; 0
	mov	r1,-(sp)
	mov	r2,r1
	clr	r0
	dvd	(sp)+,r0
	mov	r0,r2
	br	eoprnd

exnot:
	jsr	r5,combin; 0
	com	r1
	add	r1,r2
	br	eoprnd

/ comment: default to '+' operator
/ comment: end of processing a operand
eoprnd:
	mov	$'+,(sp)
	jmp	advanc

/ comment: combine type
/ comment: see 6.3 Type propagation in expressions in UNIX Assembler Manual
combin:
	/ comment: r0 is symbol type, r3 is the result type
	mov	r0,-(sp)
	bis	r3,(sp)
	/ comment: (sp) = r0 or r3
	/ comment: only leave bit 5 of r0 or r3, it's 0 most likely.
	bic	$!40,(sp)
	/ comment: leave only type bits
	bic	$!37,r0
	bic	$!37,r3
	/ comment: let the small one in r0
	cmp	r0,r3
	ble	1f
	mov	r0,-(sp)
	mov	r3,r0
	mov	(sp)+,r3
1:
	tst	r0
	/ comment: branch if one of them is 0 (undefined)
	beq	1f
	/ comment: check (r5)
	tst	(r5)+
	/ comment: if arg is 0, return the greater one
	beq	2f
	/ comment: now arg is 1
	cmp	r0,r3
	/ comment: if not the same, return the greater one
	bne	2f
	/ comment: if they're the same, return 1 (absolute)
	mov	$1,r3
	br	2f
1:
	tst	(r5)+
	clr	r3
2:
	bis	(sp)+,r3
	rts	r5

