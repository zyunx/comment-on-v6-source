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
    |  Relocation Info   |
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