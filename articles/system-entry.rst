============
System Entry
============


Call System Entry from User Space
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


System entry table
==================

See usr/sys/ken/sysent.c for all system entries.

Structure of the system entry table (sysent.c)
::

    struct sysent	{
        int	count;		/* argument count */
        int	(*call)();	/* name of handler */
    } sysent[64];
