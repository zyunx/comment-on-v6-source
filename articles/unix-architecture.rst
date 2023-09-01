====================
UNIX V6 Architecture
====================

Overview
========
::
                                                                                                 
 User Space                                                                                  
                                                                                             
                                            +-------------+                                  
             -------------------------------| System Call |----------------------------------
                                            +-------------+                                  
                                                                                             
                                                                                             
 Kernel Space      +---------+       open        +-------------+                             
                   | Process | ----------------> | File System |                             
                   +---------+                   +-------------+                             
                        |                             |   |                                  
                        |                             |   |                                  
                        |                             |   |                                  
                        |      +--------------+       |   |       +------------+             
                        +----->| Buffer Layer |<------+   +------>| Char Layer |             
                               +--------------+                   +------------+             
                                       |                                |                    
                                       | block drivers                  | char drivers       
                                       v                                v                    
                               +---------------+                 +--------------+            
                               | Block Devices |                 | Char Devices |            
                               +---------------+                 +--------------+            
                                                                                                    

A Pervasive Mechanism                                                                                             
---------------------

There is an excellent abstraction in the implementation of UNIX kernel.
CPU can only directly access internal memory.
In economic, we can not put all data in core memory.
This abstraction provides the illusion that all data are in core memory.

All processes seem to be in core memory through swaping.
All storage blocks seem to be in core memory through buffer layer,
therefore all disk files seem to be in core memory.

The underlying mechanism is a relatively small core memory region
which syncs automatically with the parts of external storages
currently in use.
 

Buffer Layer
------------
Buffer layer provides the abstraction that allows
process and file system access all external block storages
by just geting a buffer at (device, block),
and keeping it or returning it without

#. going into detail over various external storages
   through block device drivers.
#. deciding when to read from or write to external storages.

