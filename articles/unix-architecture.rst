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
                                                                                             
                                                                                             
 Kernel Space      +---------+                   +-------------+                             
                   | Process |                   | File System |                             
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
                                                                                                    
                                                                                             

Buffer layer provides the abstraction that allows
Process and File system access all external block storages
without going into detail over syncing
between core and external block storages.


