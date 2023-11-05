==============
UNIX Assembler
==============


Assemble Pass 1
===============

Goal
----

#. create a.temp1 file that store all processed tokens.
#. create a.temp2 file that store all temporary symbols.
#. create a.temp3 file that sotre all user symbols.
#. calculate all user symbols's type and value.


Code Conventions
----------------

#. when reading a symbol(readop), r4 is pointer the symbol entry's type when r4 > 200 or otherwise symbol type itself.
#. for all statement related parser functions, the first token is already read.
#. for parse a expression(express), r2 is the result value, r3 is the result type, r1 is the current operand value, r0 is the current operand type


Source Files
------------
as11.s: main control flow
as12.s: utility functions
as13.s: assemble pass 1 flow
as14.s: low level token functions
as15.s: high levelo token functions
as16.s: parse statement and addressing operand
as17.s: parse expression
as18.s: common variables
as19.s: builtin symbol table and start procedure

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


Assembler Pass 2
================

