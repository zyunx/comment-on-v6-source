=====
A.OUT
=====

Foramt
======

::
    
    +--------------------+
    |                    |
    |  Header            |
    |                    |
    |--------------------|
    |                    |
    |  Text Segment      |
    |                    |
    |--------------------|
    |                    |
    |  Data Segment      |
    |                    |
    |--------------------|
    |                    |
    |                    |
    |                    |
    |  Relocation Bits   |
    |  (If present)      |
    |                    |
    |                    |
    |--------------------|
    |                    |
    |  Symbol Table      |
    |                    |
    +--------------------+


Exec
====
Exec system call only read header, text segment and data segment. 
Relocation info and symbol table are not relevent to execution.
So stripping them does not affect the object code to be loaded for execution.

see strip(I)

Relocation Bits
===============

See a.out(5) for the detailed description of this area.

And see /usr/source/s1/ld.c to see how relocation works.

Symbol Table
============

What is Symbol
--------------
In my definition, *symbol* is a name or identifier which is not a keyword.

Program is a precise description of a procedure.
All the names in a program must be defined before the program can be executed correctly.
Keword is defined by program lanuages. Other names(symbol) should be defined by programmers.

Symbol table could contains all information about symbols used in your program.  
Every entry in the table records symbol's name, type and value.

See /usr/source/s1/ld.c::

    struct	symbol {
        char	sname[8];
        char	stype;
        char	spad;
        int	svalue;
    };


Type of Symbol
--------------

See a.out(5), the type of symbol has 11 values below:

    00 undefined symbol
    01 absolute symbol
    02 text segment symbol
    03 data segment symbol
    37 file name symbol (produced by ld) 04 bss segment symbol
    40 undefined external (.globl) symbol 41 absolute external symbol
    42 text segment external symbol
    43 data segment external symbol
    44 bss segment external symbol

The type of symbol refers to the value of the names represented by the symbol.  
For example, undefined symbol type means the value of the name represented by
the symbol is undefined, not the address of that.

Then I will showcase these types of a symbol using assembly language.

To insert a undefined symbol(00), just write a undefined name is source.

Source file u.s::

    mov a, r0

To assemble it::

    as u.s
    mov a.out u.o

To see the binary::

    od u.o

You got the output::

    0000000 000407 000004 000000 000000 000014 000000 000000 000000
    0000020 016700 177774 000000 000001 000141 000000 000000 000000
    0000040 000000 000000

The symbol entry for `a` is::

    000141 000000 000000 000000 0000040 000000 000000

You get the type of 00 that is undefined symbol.

Similarly.

`a` in::

    a = 123456
    mov a, r

is a absolute symbol.  


`a` in::

    .text
    a:

is a text segment symbol.


`a` in::

    .data
    a:

is a data segment symbol.


`a` in::

    .bss
    a:

is a bss segment symbol.


To make a symbol extenal, just write a line `.globl <name>` before the name.  
Like this:

    .globl a
    mov a, r0

