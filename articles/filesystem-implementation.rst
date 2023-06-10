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

All used blocks can be addressed by all i-node's *i_addr* fields.

Free blocks are addressed by a linked list. 
The head of the linked list is stored in s_nfree and s_free[100] of super block.
Each of ther nodes is stored in one of the the free blocks that is address by previous node's first free block address.

The only thing users care about free blocks is that they are free.
Content of free blocks is no importance for users.
Thus system software can use them to store some information.

Free blocks addressed by some node can be allocated only after ones addressed by previous nodes.
So when a block which contains a node is about to be allocated, the node will be the head of the linked list.
And just before the block is allocated, the node data is read into s_nfree and s_free[100].
So the head of the linked list is never lost. S_nfree and s_free[100] is always the head.

The linked list is like::

    +---------------------------------------------------+                                                                                               
    |         |           |                |            |                                                                                               
    | s_nfree | s_free[0] |   - - - - - -  | s_free[99] |                                                                                               
    |         |           |                |            |                                                                                               
    +---------------------------------------------------+                                                                                               
                    \                                                                                                                                   
                     \ +-----------------------------------------------------------------------------------------------+                                
                      -|                  |                        |                 |                        |        |                                
                       | free block count | 1st free block address |   - - - - - -   | nth free block address | unused |                                
                       |                  |                        |                 |                        |        |                                
                       +-----------------------------------------------------------------------------------------------+                                
                                                    \                                                                                                   
                                                     \ +-----------------------------------------------------------------------------------------------+
                                                      -|                  |                        |                 |                        |        |
                                                       | free block count | 1st free block address |   - - - - - -   | nth free block address | unused |
                                                       |                  |                        |                 |                        |        |
                                                       +-----------------------------------------------------------------------------------------------+
                                                                                    \                                                                   
                                                                                     \                                                                  
                                                                                      -                                                                 
                                                                                                - - - - - - 

                                         
For code, see *free()* and *alloc()* in usr/source/s1/icheck.c
