=============
Memory Layout
=============

Note: Here, we use **Segmnets** to refer physical memory, and **Page** to refer virtual memory.
And we focus on PDP11-40.

Physical Memory Layout
======================

The physical memory consist 4 parts.

#. Kernel's segments, which contain kernel's text, data, bss segmetns.
#. Process 0's segments.
#. Available core memory segments, which is used by OS's later operations.
#. IO segments, which contain hardware registers.

::
                                                                                    
                            0 +------------------------+                            
                              |                        |                            
                              |                        |                            
                              |   Kernel's Segments    |                            
                              |                        |                            
                              |                        |                            
                              |------------------------|                            
                              |        unused          |                            
    next memory block address |------------------------|                            
     after kernel's segments  |                        |                            
     (a memory block is 64B)  |                        |                            
                              |  Process 0's Segments  |                            
                              |  (Only USIZE blocks)   |                            
                              |                        |                            
                              |                        |                            
                              |------------------------|                            
                              |                        |                            
                              |                        |                            
                              |                        |                            
                              |                        |                            
                              |  Available Core Memory |                            
                              |  Segments              |                            
                              |  (coremap)             |                            
                              |                        |                            
                              |                        |                            
                              |                        |                            
                              |                        |                            
                       760000 |------------------------|                            
                              |                        |                            
                              |                        |                            
                              |     IO Segments        |                            
                              |                        |                            
                              |                        |                            
                              +------------------------+                            
                                                                                             

Kernel and Process 0
====================

Kernel binary is loaded at 0 by second phrase loader. See /usr/mdec/run.

Look at ``ld -x a.out m40.o c.o ../lib1 ../lib2`` in /usr/sys/run,
We can see that the kernel's physical memory is
::

    +--------------------+                                   
    |                    |                                   
    |   l.s text         |                                   
    |                    |                                   
    |--------------------|                                   
    |                    |                                   
    |   m40.s text       |                                   
    |                    |                                   
    |--------------------|                                   
    |                    |                                   
    |   c.c text         |                                   
    |                    |                                   
    |--------------------|                                   
    |                    |                                   
    |  ken's text        |                                   
    |                    |                                   
    |--------------------|                                   
    |                    |                                   
    |  dmr's text        |                                   
    |                    |                                   
    |--------------------|                                   
    |                    |                                   
    |  program's data    |                                   
    |                    |                                   
    |--------------------|                                   
    |                    |                                   
    |  bss               |                                   
    |                    |                                   
    +--------------------+ 

Text and data sections are loaded by the loader.
Bss section is initialized as 0, see ``start`` in /usr/sys/conf/m40.s.

L.s text mainly contains one branch instruction, one jump instruction to start in m40.s,
and all interrupt vectors.

M40.s contains almost all assembly codes. 
The ``start`` in it setups kernel's virtual memory mappings,
and jump to ``main`` in /usr/ken/main.c.

Kernel's first 6 pages identically map to physical memory.

Kernel's 7th page initially maps to process 0's segment.
In later time, the 7th page will map to other processes' segments,
through which it have access to them.

Kernel's 8th page is map to IO segments so that it accesses IO registers
the same way as without memory management unit enabled.

C.c contains hardware configurations.

Ken's text contains **process**, **file system** code.

Dmr's text contains **IO layers**, and various **hardware drivers**.

``Main`` in /usr/sys/ken/main.c compute all available core memory,
which is recorded in ``coremap``.


Available Core Memory Segments
==============================

This segments is used by later operations.

Kernel does not directly access memory after kernel's segments,
but it access them through kernel's 7th page or user's pages.
(See ``_copyseg``, ``_clearseg`` in /usr/sys/conf/m40.s)

At the beginning, these memory is not mapped,
but in later time, they will be allocated
and mapped by user model memory management registers.
For instance, when a new process is created,
some memory will be allocated for process's
program(See ``newproc`` in /usr/sys/ken/slp.c),
and mapped by process's page registers.

These segments are not structured,
they can contain any data,
includes process memory, etc.

Process Memory Layout
=====================

Process 0 is a special process.
It's the system process,
It's the first process,
and it's the simplest process.

Process 0's segments contains only a **Per process area**,
which consist
::                                              
                                                               
     +----------------------+                                  
     |                      |                                  
     |     user struct      |                                  
     |                      |                                  
     |----------------------|                                  
     |                      |                                  
     | process kernel stack |                                  
     |                      |                                  
     +----------------------+                                  
                                     
Process 0's segments is at the next 64B memory boundary
after kernel's segments.

The process 0 is close related to the kernel,
because kernel always use it's kernel stack
and user struct.

A normal process's physical memory segments
contains program text, data, and stack sections
besides the per process area.
(In m40.s, text and data sections are in the same data segment)

And it is a continous memory area, which consists
::
                                                                                                                       
    Some addres                                                          
    in availale +----------------------+                                 
    core memory |                      |                                 
                |     user struct      |                                 
                |                      |                                 
                |----------------------|                                 
                |                      |                                 
                | process kernel stack |                                 
                |                      |                                 
                |----------------------|                                 
                |                      |                                 
                |        data          |                                 
                |                      |                                 
                |----------------------|                                 
                |                      |                                 
                |        stack         |                                 
                |                      |                                 
                +----------------------+                                 

Process 0 is special one without user data and stack.

Process's virtual memory contains only to data and stack parts
of it's segments. See ``estabur`` in /usr/sys/ken/main.c.
::                                            
                                                               
    0 +----------------------+                                 
      |                      |                                 
      |        data          |                                 
      |                      |                                 
      |----------------------|                                 
      |                      |                                 
      |        stack         |                                 
      |                      |                                 
      +----------------------+   

So it can not access it's per process area.

Why the per process area is not allowed be accessed,
but stay with user's data and stack?
Because the whole segments can be swap in and out
altogether.

A process's the memory mapping is stored
in the ``u_uisa`` and ``u_uisd`` in ``user struct``
in the per process area.
When a process is to be executed by the CPU,
the memory mapping is loaded into CPU's
user memory management registers.

Look at ``estabur`` in /usr/sys/ken/main.c,
It first set up memory mapping prototypes
in ``u_uisa`` and ``u_uisd``, and then 
load the prototype into CPU's
user memory management registers
by ``sureg``.

