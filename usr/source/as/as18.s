/
/

/ a8 -- pdp-11 assembler pass 1

/ comment: Symbol name alphabets contains all chars
/ with map value > 0. Otherwise it's the offset of
/ the token parser function.
chartab:
	.byte -14,-14,-14,-14,-02,-14,-14,-14
	.byte -14,-22, -2,-14,-14,-22,-14,-14
	.byte -14,-14,-14,-14,-14,-14,-14,-14
	.byte -14,-14,-14,-14,-14,-14,-14,-14
	.byte -22,-20,-16,-14,-20,-20,-20,-12
	.byte -20,-20,-20,-20,-20,-20,056,-06
	.byte 060,061,062,063,064,065,066,067
	.byte 070,071,-20,-02,-00,-20,-14,-14
	.byte -14,101,102,103,104,105,106,107
	.byte 110,111,112,113,114,115,116,117
	.byte 120,121,122,123,124,125,126,127
	.byte 130,131,132,-20,-24,-20,-20,137
	.byte -14,141,142,143,144,145,146,147
	.byte 150,151,152,153,154,155,156,157
	.byte 160,161,162,163,164,165,166,167
	.byte 170,171,172,-14,-26,-14,176,-14

.data

namedone:.byte 0
/ comment: for program text
a.tmp1:	</tmp/atm1a\0>
/ comment: for forward/backward label
a.tmp2:	</tmp/atm2a\0>
/ comment: for user defined symbols
a.tmp3:	</tmp/atm3a\0>
	.even
/ comment: local label values
curfb:
	-1;-1;-1;-1;-1;-1;-1;-1;-1;-1
/ comment: output buffer pointer
obufp:	outbuf
/ comment: user symbol table end pointer
symend:	usymtab

.bss
/ comment: local label relative segment
curfbr:	.=.+10.
savdot:	.=.+6
bufcnt:	.=.+2
hshsiz = 1553.
hshtab:	.=2*hshsiz+.
pof:	.=.+1
wordf:	.=.+1
/ comment: current inpu file descriptor
fin:	.=.+1
fbfil:	.=.+1
fileflg:.=.+1
errflg:	.=.+1
ch:	.=.+1
.even
symbol:	.=.+8.
obufc:	.=.+2
/ comment: output buffer
outbuf:	.=.+512.
line:	.=.+2
/ comment: input buffer count
inbfcnt:.=.+2
/ comment: if block flag, if 0, statements in block need assembled, otherwise ignored
ifflg:	.=.+2
/ comment: input buffer pointer
inbfp:	.=.+2
/ comment: number of args for command argument processing
nargs:	.=.+2
/ comment: current arg pointer
curarg:	.=.+2
opfound:.=.+2
savop:	.=.+2
numval:	.=.+2
nxtfb:	.=.+4
usymtab:.=.+36.
end:
.text
