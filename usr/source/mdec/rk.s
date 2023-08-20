/ rk05 disk driver

rkda = 177412
	/ comment: disk logical address to Cylinder/Suface/Sector address
	mov	dska,r1
	clr	r0
	div	$12.,r0
	ash	$4.,r0
	bis	r1,r0
	/ comment: command
	mov	$rkda,r1
	mov	r0,(r1)
	mov	ba,-(r1)
	mov	wc,-(r1)
	mov	$iocom,-(r1)
1:
	tstb	(r1)
	bpl	1b
	rts	pc
