========================
Swtch: The CPU Scheduler
========================

**Switch** schedules CPU between processes.
At the lowest level, CPU does not know **Process** concept.
It only knows **Instruction Cycle**, that is to fetch
next instruction addressed by PC register, and execute it,
and udpate state in registers.
The **Instruction Set** contains some instructions
which depend on stacks.
So the registers and stack consitutes the state of CPU.

**Process** is a concept of UNIX.

    An image is a computer execution environment. 
    It includes a core image, general register values, 
    status of open files, current directory, 
    and the like. 
    An image is the current state of a pseudo computer.
    
    A process is the execution of an image. 
    While the processor is executing on behalf of a process, 
    the image must reside in core; 
    during the execution of other processes it remains in core 
    unless the appearance of an active, 
    higher-priority process forces it to be swapped 
    out to the fixed-head disk.

    -- from The UNIX Timesharing System

So, to switch to another process,
The CPU need save its core image,
general register values, status of open files,
current directory and the like,
and load those of another process.

Aside from general register vaules,
other image data is stored in core memory.
Without regard to swap, changing to another
process involve's load general register
of another process and it's virtual memory
mappings.

For general registers, the **C Calling Convention**
automatically stores on and reload from stack
PC, R5, R4, R3, R2. 
New R5 and SP, which is related to
stack (process's kernel stack), 
are saved in and load from  u.u_rsav by
``savu`` and ``retu``.

For virtual memory mappings, ``sureg`` setup them
according to the memory prototype in the ``u``.

