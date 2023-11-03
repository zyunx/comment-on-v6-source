==============
UNIX Assembler
==============


Assemble Pass 1
===============

as11.s: main control flow
as12.s: utility functions
as13.s: assemble pass 1 flow
as14.s: low level token functions
as15.s: high levelo token functions
as16.s: 
as17.s:
as18.s: common variables
as19.s: builtin symbol table and start procedure

conventions:
#. r4 is point the symbol entry.


atm1* file format
-----------------

all blank token is ignored
assembly source file begin record: 5 <filename> -1
token | : 037
escaped token \/ : '/ or 057
escaped token \< : 035
escaped token \> : 036
escaped token \% : 037
other escaped token : '\ or 134
! $ % & ( ) * + , - : = [ ] ^ newline : as is
double quote char: 1 <double chars value in word>
single quote char: 1 <single char value in word>
string: < <escaped chars> -1
number: 1 <number value in word>
temperary symbol (forward/backward label) : 141 + forward label digit or 151 + backward label digit
builtin symbol : $1000 + (builtin symbol index / 3)
user symbol : $4000 + (user symbol index / 3)




