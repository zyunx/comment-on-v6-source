/ tap4 -- dec-tape lod/dmp

.data
tc:	</dev/tap>
/ comment: for DECtap
tcx:	<x\0>
mt:	</dev/mt>
/ comment: for megatape
mtx:	<0\0>
tboot:	</usr/mdec/tboot\0>
mboot:	</usr/mdec/mboot\0>
.even
.bss
/ comment: directory entry buffer
dir:	. = .+[mdirent*dirsiz]
/ comment: tread buffer
tapeb:
/ comment: for bitmap
map:	.=.+4096.
emap:
/ comment: ch is used as a buffer by putc
ch:	.=.+1
/ comment: flag of command option
/ comment: flag 'c' means a fresh dump is being created
flc:	.=.+1
/ comment: flag 'f' causes new entries on tape to be ‘fake’ in that no data is present for these entries
flf:	.=.+1
/ comment: flag 'i'(info) Errors reading and writing the tape are noted, but no action is taken.
fli:	.=.+1
/ comment: flag 'm', specify megatype as opposed to DECtape
flm:	.=.+1
/ comment: flag 'u': The named files are written on the tape AND update the tape.
flu:	.=.+1
/ comment: flag 'v'(verbose) option causes it to type the name of each file it treats preceded by the function letter.
flv:	.=.+1
/ comment: flag 'w'(wait) causes tp to pause before treating each file, 
/ comment: type the indicative letter and the file name (as with v) and await the user’s response.
flw:	.=.+1
.even

/ comment: the command indicated by the function key
command:.=.+2
sum:	.=.+2
size:	.=.+2
nentr:	.=.+2
nused:	.=.+2
nfree:	.=.+2
lused:	.=.+2
catlb:	.=.+20.
narg:	.=.+2
rnarg:	.=.+2
parg:	.=.+2
/ comment: file descriptor
fio:	.=.+2
mss:	.=.+2
/ comment: count of directory entry in $dir
ndirent:.=.+2
/ comment: ndirent divide by 8
ndentd8:.=.+2
edir:	.=.+2
/ comment: rseek accumulator
rseeka:	.=.+2
wseeka:	.=.+2
tapsiz:	.=.+2
/ comment: path name
name:	.=.+32.
name1:	.=.+32.
/ comment: inode buffer for stat
statb:	.=.+40.

smdate = 30.
