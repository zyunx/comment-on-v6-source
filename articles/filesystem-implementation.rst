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

data block stats at block *s_isize* + 2, and ends at *s_fsize* (exclusive).

Other blocks are unused.

For code, see *check()* in usr/source/s1/icheck.c and *chk()* in usr/source/s1/icheck.c

I-Node
======

I-Node Data Block Structure
---------------------------

Data Block Management
=====================
