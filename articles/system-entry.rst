============
System Entry
============


System entry table
==================

See usr/sys/ken/sysent.c for all system entries.

Structure of the system entry table (sysent.c)
::

    struct sysent	{
        int	count;		/* argument count */
        int	(*call)();	/* name of handler */
    } sysent[64];
