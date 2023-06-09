=================================
The Implementation of File System
=================================


Super Block
===========

see: struct filsys in usr/sys/filsys.h

Disk Layout
===========

UNIX V6 regards disk as 512-byte blocks.

::

    +-----------------------------------------------------------------------------+
    |           |               |               |               |                 |
    |  block 0  |  super block  |  i-node list  |  data blocks  |  unused blocks  |
    |           |               |               |               |                 |
    +-----------------------------------------------------------------------------+

Super block is located block 1 (2nd block).

I-node list starts at block 2, and is *s_isize* size.

Data blocks start at block *s_isize* + 2, and ends at *s_fsize* (exclusive).

Other blocks are unused.

For code, see *check()* in usr/source/s1/icheck.c and *chk()* in usr/source/s1/icheck.c

I-Node
======

I-Node Data Block Structure
---------------------------

For large file i-node::
                                                                                                    
                                                               data block                        
                                                                +-------+                        
                                                                |       |                        
                                     indirect block             |       |                        
                                        +-------+               |       |                        
                                        |       |---------------|       |                        
                                        |-------|               |       |                        
                                        |       |               |       |                        
                                        |   -   |               |       |                        
                                    ----|   -   |               |       |                        
                +-------+    ------/    |   -   |               +-------+                        
      i_addr[0] |       |---/           |   -   |                                                
                |-------|               |       |                                                
      i_addr[1] |       |               +-------+                                                
                |-------|                                                              data block
      i_addr[2] |       |                                                               +-------+
                |-------|                                                               |       |
      i_addr[3] |       |                                   2nd indirect block          |       |
                |-------|                                       +-------+               |       |
      i_addr[4] |       |                                       |       |---------------|       |
                |-------|            indirect block             |-------|               |       |
      i_addr[5] |       |               +-------+               |       |               |       |
                |-------|               |       |---------------|   -   |               |       |
      i_addr[6] |       |               |-------|               |   -   |               |       |
                |-------|               |       |               |   -   |               +-------+
      i_addr[7] |       |---------------|   -   |               |   -   |                        
                +-------+               |   -   |               |       |                        
                                        |   -   |               +-------+                        
                                        |   -   |                                                
                                        |       |                                                
                                        +-------+                                                

Each of the first 7 elements of i-node's i_addr points a indirect block (a special data block) that contains 256 data block addresses.

The 8th element of i_addr points a indirect block that contain 256 pointers to 2nd level indirect blocks of which each contains 256  data block adresses.

So large file's size is 7 * 256 * 512 + 256 * 256 * 512 bytes at maximum.

For code, see *pass1()* in usr/source/s1/icheck.c

Data Block Management
=====================
