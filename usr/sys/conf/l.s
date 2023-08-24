/ comment: To understand UNIX assembly, see UNIX Assembler Reference Manual and LD(I) in V6 manual.
/ low core

/ comment: bus request priorities, see 2.6 AUTOMATIC PRIORITY INTERRUPTS in PDP11/40 Processor Handbook.

br4 = 200
br5 = 240
br6 = 300
br7 = 340

/ comment: The object code of this file will be loaded at memory 0. see /usr/sys/run and LD(I) in V6 manual.
/ comment: Low memory map, see APPENDIX B MEMORY MAP in PDP11/40 Processor Handbook.
/ comment: see BASIC ADDRESSING LOGIC in PDP11/40 Processor Handbook.

. = 0^.
        br      1f
        4

/ trap vectors
/ comment: To understand what these traps mean, see 2.7 PROCESSOR TRAPS in PDP11/40 Processor Handbook.
        trap; br7+0.            / bus error
        trap; br7+1.            / illegal instruction
        trap; br7+2.            / bpt-trace trap
        trap; br7+3.            / iot trap
        trap; br7+4.            / power fail
        trap; br7+5.            / emulator trap
        trap; br7+6.            / system entry

. = 40^.
/ comment: jump to start in m40.s or m45.s 
.globl  start, dump
1:      jmp     start
        jmp     dump


. = 60^.
        klin; br4
        klou; br4

. = 100^.
        kwlp; br6
        kwlp; br6

. = 114^.
        trap; br7+7.            / 11/70 parity

. = 214^.
        tcio; br6

. = 220^.
        rkio; br5

. = 224^.
        tmio; br5

. = 240^.
        trap; br7+7.            / programmed interrupt
        trap; br7+8.            / floating point
/ comment: also known as PDP11 Aborts, see 6.5.2 Page Descriptor Register and 6.6 Fault Registers in PDP11 Processor Handbook
        trap; br7+9.            / segmentation violation

//////////////////////////////////////////////////////
/               interface code to C
//////////////////////////////////////////////////////

/ comment: Global symbols in assembly, which begin with '_', is the same as global variables without the '_' in C source

.globl  call, trap

.globl  _klrint
klin:   jsr     r0,call; _klrint
.globl  _klxint
klou:   jsr     r0,call; _klxint

.globl  _clock
kwlp:   jsr     r0,call; _clock


.globl  _tcintr
tcio:   jsr     r0,call; _tcintr

.globl  _rkintr
rkio:   jsr     r0,call; _rkintr

.globl  _tmintr
tmio:   jsr     r0,call; _tmintr

