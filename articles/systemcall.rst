============
System Call
============


System Call from User Space
=================================

See example code:

#. usr/source/s5/read.s
#. usr/source/s4/cerror.s

These code can be used as template for system entry C function.

::
    
    sys is another name for the trap instruction.
    It is used to code system calls. Its operand is required to be expressible in 6 bits.
    -- UNIX Assembler Reference Manual

``trap`` interrupts to vector 34 (PC at 34, PS at 36). See usr/sys/conf/l.s for intrrupt vectors.

There can be 64 system calls(6 bits operand) which are stored in ``sysent`` table variable.
The operand of ``sys`` is an index of the ``sysent`` table.

``sys 0;`` is a indirect system call. See ``trap`` code in usr/sys/ken/trap.c


System Call in Kernel Space
============================

System call begin executing ``trap`` in /usr/sys/m40.s through vector 34 in /usr/sys/l.s.
Then it transfter control to ``call1`` which is a modified version of ``call``.
The ``call1`` then transfers control to ``trap`` in function in /usr/sys/ken/trap.c.
::
                                                                                                                                                                                                                               
    +------------------------+               +-------------------------+              +-----------------------------+      
    | trap in /usr/sys/m40.s |-------------->| call1 in /usr/sys/m40.s |------------->| trap in /usr/sys/ken/trap.c |      
    +------------------------+               +-------------------------+              +-----------------------------+      
                                                                                                                        
``trap in /usr/sys/m40.s`` can only be entered by system fault or system call.
If a ``nofault`` is set, then it transfer control to ``nofault``.(This mechanism is somewhat like ``try catch``.)
Otherwise, it save some execution info and jump to ``call1 in /usr/sys/m40.s``.
``call1`` set CPU priority to 0, so the CPU can be interrupted by other hardware interrupts and faults.
(CPU won't be interrupted by other system calls, because system call can only issued in user space.)

In the case of system call, ``call1`` setup the stack and call ``trap in /usr/sys/ken/trap.c`` .

**You can check yourself the stack layout is consistent with the trap function arguments.**

After return from ``trap in /usr/sys/ken/trap.c``, ``call1`` checks if a reschedule is required.
If so, ``call1`` invoke ``swtch`` to switch to another process. 


System entry table
------------------

See usr/sys/ken/sysent.c for all system entries.

Structure of the system entry table (sysent.c)
::

    struct sysent	{
        int	count;		/* argument count */
        int	(*call)();	/* name of handler */
    } sysent[64];
