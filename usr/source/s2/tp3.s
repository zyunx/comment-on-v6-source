/ tap3 -- dec-tape lod/dmp

/ comment: traverse the 'dir' to process cmd argument
gettape:
	mov	$dir,r1
	clr	-(sp)
1:
	tst	(r1)
	beq	2f
	jsr	r5,decode; name
	cmp	rnarg,$2
	ble	4f
	mov	$name,r2
	mov	*parg,r3
3:
	tstb	(r3)
	beq	3f
	cmpb	(r2)+,(r3)+
	beq	3b
	br	2f
3:
	tstb	(r2)
	beq	4f
	cmpb	(r2),$'/
	bne	2f
/ comment: if name not privided or names match , call the REAL function
4:
	mov	r1,-(sp)
	jsr	pc,*(r5)
	mov	(sp)+,r1
	inc	(sp)
2:
	add	$dirsiz,r1
	cmp	r1,edir
	blo	1b
	/ comment: end of traverse 'dir'
	tst	(sp)+
	bne	2f
	cmp	rnarg,$2
	ble	2f
	/ comment: A name comamnd arg is provided and the name is not found
	mov	*parg,r1
	jsr	pc,pstr
	jsr	r5,mesg
		< not found\n\0>; .even
2:
	dec	narg
	add	$2,parg
	cmp	narg,$2
	/ comment: branch to process next command argument
	bgt	gettape
	tst	(r5)+
	rts	r5

delete:
	jsr	r5,verify; 'd
		rts pc
	jsr	pc,clrent
	rts	pc

/ comment: print number in r0
numb:
	mov	r1,-(sp)
	mov	r0,-(sp)
	clr	r0
	br	1f

/ comment: print number in r0
numbx:
	mov	r1,-(sp)
	mov	r0,-(sp)
	movb	size0(r1),r0
1:
	mov	$catlb,r2
1:
	mov	$"  ,(r2)+
	cmp	r2,$catlb+12.
	blo	1b
	cmp	(r5),$2
	bne	1f
	mov	$"00,-2(r2)
1:
	/ comment: change number in r1 to string pointed by r2
	mov	(sp)+,r1
	jsr	pc,numb2
	/ comment: print string pointed by r2, size is in (r5)
	mov	(r5)+,r0
	sub	r0,r2
	mov	r2,0f
	mov	r0,0f+2
	mov	$1,r0
	sys	0; 9f
.data
9:
	sys	write; 0:..; ..
.text
	mov	(sp)+,r1
	rts	r5

/ comment: recursive, change number in r0 r1 to string pointed by r2
numb1:
	clr	r0
numb2:
	div	$10.,r0
	mov	r1,-(sp)
	mov	r0,r1
	beq	1f
	jsr	pc,numb1
1:
	/ comment: change digit in (sp) to char at (r2)
	mov	(sp)+,r0
	add	$'0,r0
	movb	r0,(r2)+
	rts	pc

update:
	jsr	pc,bitmap
	mov	$dir,r1
1:
	tst	(r1)
	beq	2f
	bit	$100000,mode(r1)
	beq	2f
	tstb	size0(r1)
	bne	9f
	tst	size1(r1)
	beq	2f
/ comment: Now found a entry to be updated, and size is not 0
9:
	mov	ndentd8,-(sp)
	inc	(sp)
	/ comment: (sp) is the first data block
	movb	size0(r1),r2
	mov	size1(r1),r3
	add	$511.,r3
	adc	r2
	ashc	$-9,r2
	mov	r3,size
3:
	mov	(sp),r2
	mov	size,r3
4:
	jsr	pc,bitcalc
	inc	r2
	bitb	(sp)+,map(r0)
	bne	4f
	sob	r3,4b
	/ comment: Now, found continuous blocks for store the file to be updated
	/ comment: relocate the dir entry and update it's block bitmap
	mov	(sp)+,tapea(r1)
	jsr	pc,setmap
	br	2f
4:
	inc	(sp)
	br	3b
2:
	add	$dirsiz,r1
	cmp	r1,edir
	blo	1b
	jsr	pc,wrdir

/ comment: write updated files' data to tape
update1:
	mov	$dir,r1
	clr	-(sp)
	mov	$-1,-(sp)
1:
/ comment: find the 'lowest' entry to be updated
	tst	(r1)
	beq	2f
	bit	$100000,mode(r1)
	beq	2f
	cmp	tapea(r1),(sp)
	bhis	2f
	mov	tapea(r1),(sp)
	mov	r1,2(sp)
2:
	add	$dirsiz,r1
	cmp	r1,edir
	blo	1b
	tst	(sp)+
	mov	(sp)+,r1
	bne	1f
	rts	pc
1:
/ comment: Now, a dir entry pointed by r1 with 'lowest' address 
	/ comment: mark the entry is processed
	bic	$100000,mode(r1)
	movb	size0(r1),mss
	mov	size1(r1),r2
	bne	4f
	tst	mss
	/ comment: if the entry's size is 0, find next one.
	beq	update1
4:
/ comment: Open file for the entry, the fd is in r3.
/ comment: And set tape write pointer at entry's address
	jsr	r5,decode; name
	mov	tapea(r1),r0
	jsr	pc,wseek
	clr	r3
	sys	open; name; 0
	bes	phserr
	mov	r0,r3
3:
/ comment: write all file data to tape
	tst	mss
	bne	4f
	cmp	r2,$512.
	blo	3f
4:
/ comment: write whole blocks data
	mov	r3,r0
	sys	read; tapeb; 512.
	bes	phserr
	cmp	r0,$512.
	bne	phserr
	jsr	pc,twrite
	sub	$512.,r2
	sbc	mss
	br	3b
3:
/ comment: write left data in last block.
	mov	r2,0f
	beq	3f
	mov	r3,r0
	sys	0; 9f
.data
9:
	sys	read; tapeb; 0:..
.text
	bes	phserr
	cmp	r0,0b
	bne	phserr
	jsr	pc,twrite
3:
/ comment: check there are no data left
	mov	r3,r0
	sys	read; tapeb; 512.
	bes	phserr
	tst	r0
	bne	phserr
	mov	r3,r0
	sys	close
2:
	jmp	update1

phserr:
	mov	r1,-(sp)
	mov	$name,r1
	jsr	pc,pstr
	jsr	r5,mesg
		< -- Phase error\n\0>; .even
	mov	(sp)+,r1
	clr	time0(r1) / time
	beq	2b
	sys	close
	br	2b

/ comment: initialize bitmap
bitmap:
	mov	$map,r0
1:
	/ comment: clear 'map'
	clr	(r0)+
	cmp	r0,$emap
	blo	1b
	mov	$dir,r1
1:
	tst	(r1)
	beq	2f
	bit	$100000,mode(r1)
	/ comment: Now, not exist
	bne	2f
	tst	size1(r1)
	/ comment: Now, size is not 0
	bne	3f
	tstb	size0(r1)
	beq	2f
3:
	jsr	pc,setmap
2:
	add	$dirsiz,r1
	cmp	r1,edir
	blo	1b
	rts	pc

/ comment: set disk block bit map for one 'dir' entries
setmap:
	/ comment: r1 is address of the dir entry in $dir
	movb	size0(r1),r2
	mov	size1(r1),r3
	add	$511.,r3
	adc	r2
	/ comment: arithmetic shift combined, r2 is no used, r3 is the block size
	ashc	$-9.,r2
	mov	tapea(r1),r2
1:
	jsr	pc,bitcalc
	bitb	(sp),map(r0)
	bne	maperr
	bisb	(sp)+,map(r0)
	inc	r2
	sob	r3,1b
	rts	pc

/ comment: calculte bitmap index(in r0) and mask(on stack) of block address r2 
bitcalc:
	/ comment: TRICK!!! Combine with "mov r0,2(sp)", "rts pc" to make a stack element for outer procedure.
	mov	(sp),-(sp)
	/ comment: r2 is the tape address
	cmp	r2,tapsiz
	bhis	maperr
	mov	r2,r0
	bic	$!7,r0
	mov	r0,-(sp)
	mov	$1,r0
	als	(sp)+,r0
	mov	r0,2(sp)
	/ comment: The bit mask is moved to stack
	mov	r2,r0
	ash	$-3,r0
	bic	$160000,r0
	/ comment: r0 contains the index of map
	rts	pc

maperr:
	jsr	r5,mesg
		<Tape overflow\n\0>; .even
	jmp	done

usage:
	jsr	pc,bitmap
	mov	$dir,r2
/ comment: calculate number of valid entries
1:
	tst	(r2)
	beq	2f
	inc	nentr
2:
	add	$dirsiz,r2
	cmp	r2,edir
	blo	1b
	mov	ndentd8,r2
	inc	r2
	mov	tapsiz,r3
	dec	r3
	sub	ndentd8,r3
1:
	jsr	pc,bitcalc
	bitb	(sp)+,map(r0)
	beq	2f
	inc	nused
	mov	r2,lused
	br	3f
2:
	inc	nfree
	tstb	flm
	bne	1f
3:
	inc	r2
	sob	r3,1b
	/ comment: print usage statistic
1:
	mov	nentr,r0
	jsr	r5,numb; 4
	jsr	r5,mesg
		< entries\n\0>; .even
	mov	nused,r0
	jsr	r5,numb; 4
	jsr	r5,mesg
		< used\n\0>; .even
	tstb	flm
	bne	1f
	mov	nfree,r0
	jsr	r5,numb; 4
	jsr	r5,mesg
		< free\n\0>; .even
1:
	mov	lused,r0
	jsr	r5,numb; 4
	jsr	r5,mesg
		< last\n\0>; .even
	rts	pc

taboc:
	tstb	flv
	beq	4f
	mov	mode(r1),r0
	mov	r0,-(sp)
	ash	$-6,r0
	bit	$40,r0
	jsr	pc,pmod
	mov	(sp),r0
	ash	$-3,r0
	bit	$200,r0
	jsr	pc,pmod
	mov	(sp)+,r0
	bit	$1000,r0
	jsr	pc,pmod
	/ comment: print uid
	clr	r0
	bisb	uid(r1),r0
	jsr	r5,numb; 4
	/ comment: print gid
	clr	r0
	bisb	gid(r1),r0
	jsr	r5,numb; 4
	/ comment: print tape address
	mov	tapea(r1),r0
	jsr	r5,numb; 5
	/ comment: print size
	mov	size1(r1),r0
	jsr	r5,numbx; 9.
	mov	r1,-(sp)
	add	$time0,(sp)
	jsr	pc,_localtime
	mov	r0,(sp)
	mov	10.(r0),r0
	jsr	r5,numb; 3
	mov	$'/,r0
	jsr	pc,putc
	mov	(sp),r0
	mov	8.(r0),r0
	inc	r0
	jsr	r5,numb; 2
	mov	$'/,r0
	jsr	pc,putc
	mov	(sp),r0
	mov	6(r0),r0
	jsr	r5,numb; 2
	mov	(sp),r0
	mov	4(r0),r0
	jsr	r5,numb; 3
	mov	$':,r0
	jsr	pc,putc
	mov	(sp)+,r0
	mov	2(r0),r0
	jsr	r5,numb; 2
	mov	$' ,r0
	jsr	pc,putc
4:
/ comment: print name
	mov	$name,r1
	jsr	pc,pstr
	jsr	r5,mesg
		<\n\0>
	rts	pc

pmod:
	beq	1f
	mov	$'s,-(sp)
	br	2f
1:
	bit	$1,r0
	beq	1f
	mov	$'x,-(sp)
	br	2f
1:
	mov	$'-,-(sp)
2:
	bit	$2,r0
	beq	1f
	mov	$'w,-(sp)
	br	2f
1:
	mov	$'-,-(sp)
2:
	bit	$4,r0
	beq	1f
	mov	$'r,r0
	br	2f
1:
	mov	$'-,r0
2:
	jsr	pc,putc
	mov	(sp)+,r0
	jsr	pc,putc
	mov	(sp)+,r0
	jsr	pc,putc
	rts	pc

xtract:
	movb	size0(r1),mss
	bne	2f
	tst	size1(r1)
	beq	1f
	/ comment: branch if size is 0
2:
	jsr	r5,verify; 'x
		rts pc
	mov	size1(r1),r3
	mov	tapea(r1),r0
	jsr	pc,rseek
	sys	unlink; name
	mov	mode(r1),0f
	sys	0; 9f
.data
9:
	sys	creat; name; 0:..
.text
	bes	crterr
	mov	r0,r2
2:
	tst	mss
	bne	3f
	cmp	r3,$512.
	blo	2f
3:
	jsr	pc,tread
	mov	r2,r0
	sys	write; tapeb; 512.
	bes	crterr1
	cmp	r0,$512.
	bne	crterr1
	sub	r0,r3
	sbc	mss
	br	2b
2:
	mov	r3,0f
	beq	2f
	jsr	pc,tread
	mov	r2,r0
	sys	0; 9f
.data
9:
	sys	write; tapeb; 0:..
.text
	bes	crterr1
	cmp	r0,0b
	bne	crterr1
2:
	mov	r2,r0
	sys	close
	movb	gid(r1),0f+1
	movb	uid(r1),0f
	sys	0; 9f
.data
9:
	sys	chown; name; 0:..
.text
	mov	time0(r1),r0
	mov	r1,-(sp)
	mov	time1(r1),r1
/	sys	0; 9f
.data
9:
	sys	smdate; name
.text
	mov	(sp)+,r1
1:
	rts	pc

crterr1:
	clr	r0
	mov	r1,-(sp)
	clr	r1
/	sys	smdate; name
	mov	(sp)+,r1
	mov	r2,r0
	sys	close

crterr:
	mov	$name,r1
	jsr	pc,pstr
	jsr	r5,mesg
		< -- create error\n\0>; .even
	rts	pc
