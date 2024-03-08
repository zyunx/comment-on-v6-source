/lib/c0
-------

extdef ---- symbol

decl1(): 

symbol(): a stream of symbols from source file.

/lib/c1
-------
The executable is to generate assmebly code.

/lib/c2
-------
The executable is to optimize generated assmebly code.

/lib/crt0.o
-----------
The  C runtime libary which call the C main function.

Function expand
---------------
C macro processing

Function Call Hiearchy
expand ---- insym ---- lookup ---- subst
       |
       +--- getline ---- getch ---- getc1
                    |          |
                    |          +--- ungetc
                    +--- sch
                    
