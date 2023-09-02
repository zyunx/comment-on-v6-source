=================
C Call Convention
=================

ccall.c::

    f1(a, b)
    int a, b;
    {
        return a + b;
    }

    f2()
    {
        f1(1, 2);
    }

Compile to assembly::

    cc -S ccall.c

ccall.s::

    .globl  _f1
    .text
    _f1:
    ~~f1:
    ~a=4
    ~b=6
    jsr     r5,csv
    mov     4(r5),r0
    add     6(r5),r0
    jbr     L1
    L1:jmp  cret
    .globl  _f2
    .text
    _f2:
    ~~f2:
    jsr     r5,csv
    mov     $2,(sp)
    mov     $1,-(sp)
    jsr     pc,*$_f1
    tst     (sp)+
    L2:jmp  cret
    .globl
    .data

You may see the assembly code referrence two names
``csv`` and ``cret``.

Find the their source at ``/usr/source/s4.s``

/usr/source/s4.s::

    / C register save and restore -- version 12/74

    .globl	csv
    .globl	cret

    csv:
        mov	r5,r0
        mov	sp,r5
        mov	r4,-(sp)
        mov	r3,-(sp)
        mov	r2,-(sp)
        tst	-(sp)
        jmp	(r0)

    cret:
        mov	r5,r1
        mov	-(r1),r4
        mov	-(r1),r3
        mov	-(r1),r2
        mov	r5,sp
        mov	(sp)+,r5
        rts	pc


C Calling Convention
====================

There are several points for C functions.

    #. The function body starts with ``jsr r5, csv``,
       and ends with ``jmp cret``.
    #. Before calling function, arguments are placed
       on the stack.
       And after returnning from function,
       arguments are removed from stack.
    #. To call function, use ``jsr pc, <func>``.
    #. Return value in R0
    #. R5 is used as call frame pointer
    #. R2, R3, R4 are guranteed the same
       before and after function call.

Go through the Code
===================

Suppose before call f2::

    R0 = R0[0]
    R1 = R1[0]
    R2 = R2[0]
    R3 = R3[0]
    R4 = R4[0]
    R5 = R5[0]
    STACK: ... (SP)

----

After entering f2::

    R0 = R0[0]
    R1 = R1[0]
    R2 = R2[0]
    R3 = R3[0]
    R4 = R4[0]
    R5 = R5[0]
    STACK: ... PC[0] (SP)
    PC[0] is instruction address after calling f2.

----

After f2's ``jsr R5, csv``::

    R0 = Instruction address after ``jsr R5, csv``
    R1 = R1[0]
    R2 = R2[0]
    R3 = R3[0]
    R4 = R4[0]
    R5 = R5[1]
    STACK: ... PC[0] R5[0] (R5) R4[0] R3[0] R2[0] ? (SP)

----

Before call f1, after arguments are placed::

    R0 = Instruction address after ``jsr R5, csv``
    R1 = R1[0]
    R2 = R2[0]
    R3 = R3[0]
    R4 = R4[0]
    R5 = R5[1]
    STACK: ... PC[0] R5[0] (R5) R4[0] R3[0] R2[] $2 $1 (SP)

----

After entering f1::

    R0 = Instruction address after ``jsr R5, csv``
    R1 = R1[0]
    R2 = R2[0]
    R3 = R3[0]
    R4 = R4[0]
    R5 = R5[1]
    STACK: ... PC[0] R5[0] (R5) R4[0] R3[0] R2[0] $2 $1 PC[1] (SP)
    PC[1] is instruction address after ``jsr pc, *$_f1``

----

After f1's ``jsr R5, csv``::

    R0 = Instruction address after this ``jsr R5, csv``
    R1 = R1[0]
    R2 = R2[0]
    R3 = R3[0]
    R4 = R4[0]
    R5 = R5[2]
    STACK: ... PC[0] R5[0] R4[0] R3[0] R2[0] $2 $1 PC[1] R5[1] (R5) R4[0] R3[0] R2[0] ? (SP)

----

Before f1's ``jmp cret``::

    R0 = $3
    R1 = R1[0]
    R2 = R2[0]
    R3 = R3[0]
    R4 = R4[0]
    R5 = R5[2]
    STACK: ... PC[0] R5[0] R4[0] R3[0] R2[0] $2 $1 PC[1] R5[1] (R5) R4[0] R3[0] R2[0] ? (SP)

----

After f1's ``jmp cret``::

    R0 = $3
    R1 = R5[2]
    R2 = R2[0]
    R3 = R3[0]
    R4 = R4[0]
    R5 = R5[1]
    PC = PC[1], instruction address after ``jsr pc, *$_f1`` 
    STACK: ... PC[0] R5[0] (R5) R4[0] R3[0] R2[0] $2 $1 (SP)

----

After removing arguments::

    R0 = $3
    R1 = R5[2]
    R2 = R2[0]
    R3 = R3[0]
    R4 = R4[0]
    R5 = R5[1]
    STACK: ... PC[0] R5[0] (R5) R4[0] R3[0] R2[0] $2 (SP)

----

After f2's ``jmp cret``::

    R0 = $3
    R1 = R5[1]
    R2 = R2[0]
    R3 = R3[0]
    R4 = R4[0]
    R5 = R5[0]
    PC = PC[0], instruction address after calling f2. 
    STACK: ... (SP)
