/ C return sequence which
/ sets errno, returns -1.

.globl	cerror
.comm	_errno,2

cerror:
	/ comment: move real error number in C variable errno
	mov	r0,_errno
	/ comment: return -1
	mov	$-1,r0
	mov	r5,sp
	mov	(sp)+,r5
	rts	pc
