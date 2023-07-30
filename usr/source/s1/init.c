#define	tabsize	20
#define	all	p = &itab[0]; p < &itab[20]; p++
#define	ever	;;
#define	single	0173030
#define	reboot	0173040
char	shell[]	"/bin/sh";
char	minus[]	"-";
char	runc[]	"/etc/rc";
char	init[]	"/etc/init";
char	ifile[]	"/etc/ttys";
char	utmp[]	"/etc/utmp";
char	wtmpf[]	"/usr/adm/wtmp";
char	ctty[]	"/dev/tty8";
int	fi;
struct
{
	int	flag;
	int	line;
	char	coms[2];
} line;

/* comment: state for all teletypers */
struct	tab
{
	int	pid;
	int	line;
	int	comn;
} itab[tabsize];

struct {
	char	name[8];
	char	tty;
	char	fill;
	int	time[2];
	int	wfill;
} wtmp;

main()
{
	register i;
	register struct tab *p, *q;
	int reset();

	/*
	 * if not single user,
	 * run shell sequence
	 */

	if(getcsw() != single) {
		/* comment: run script /etc/rc */
		i = fork();
		if(i == 0) {
			open("/", 0);
			dup(0);
			dup(0);
			execl(shell, shell, runc, 0);
			exit();
		}
		while(wait() != i);
		/* comment: create or rewrite /etc/utmp */
		close(creat(utmp, 0644));
		/* comment: write a record in /usr/adm/wtmp */
		if ((i = open(wtmpf, 1)) >= 0) {
			seek(i, 0, 2);
			/* comment: ‘ ̃’ indicates that the system was rebooted at the indicated time */
			wtmp.tty = '~';
			/* comment: get date and time */
			time(wtmp.time);
			write(i, &wtmp, 16);
			close(i);
		}
	}

	/*
	 * main loop for hangup signal
	 * close all files and
	 * check switches for magic values
	 */
	/* comment: reset, setexit − execute non-local goto */
	setexit();
	/* comment: 1 is hangup. The SIGHUP signal is sent to a process when its controlling terminal is closed. 
	 * It was originally designed to notify the process of a serial line drop (a hangup). 
	 * In modern systems, this signal usually means that the controlling pseudo or virtual terminal has been closed.
	 * Many daemons will reload their configuration files and reopen their logfiles instead of exiting when 
	 * receiving this signal.[4] nohup is a command to make a command ignore the signal.
	 */
	signal(1, reset);
	for(i=0; i<10; i++)
		close(i);
	switch(getcsw()) {

	case single:
	error:
		termall();
		i = fork();
		if(i == 0) {
			open(ctty, 2);
			dup(0);
			execl(shell, minus, 0);
			exit();
		}
		while(wait() != i);

	case reboot:
		termall();
		execl(init, minus, 0);
		reset();
	}

	/*
	 * open and merge in init file
	 */
	/* comment: init file is /etc/ttys.
	 * Itab may be not empty when a huangup signal received.
	 */
	fi = open(ifile, 0);
	q = &itab[0];
	while(rline()) {
		if(line.flag == '0')
			continue;
		for(all)
			if(p->line==line.line || p->line==0) {
				if(p >= q) {
					i = p->pid;
					p->pid = q->pid;
					q->pid = i;
					p->line = q->line;
					p->comn = q->comn;
					q->line = line.line;
					q->coms[0] = line.comn;
					q++;
				}
				break;
			}
	}
	close(fi);
	if(q == &itab[0])
		goto error;
	for(; q < &itab[tabsize]; q++)
		term(q);
	/* comment: create processes for every tty if there's no process on this tty */
	for(all)
		if(p->line != 0 && p->pid == 0)
			dfork(p);
	/* comment: wait all child process exits, and recreate new process. */
	for(ever) {
		i = wait();
		for(all)
			if(p->pid == i) {
				rmut(p);
				dfork(p);
			}
	}
}

/* comment: terminate all processes on ttys */
termall()
{
	register struct tab *p;

	for(all)
		term(p);
}

/* comment: terminate the process on a tty */
term(ap)
struct tab *ap;
{
	register struct tab *p;

	p = ap;
	if(p->pid != 0) {
		rmut(p);
		kill(p->pid, 9);
	}
	p->pid = 0;
	p->line = 0;
}

rline()
{
	static char c[4];

	if(read(fi, c, 4) != 4 || c[3] != '\n')
		return(0);
	line.flag = c[0];
	line.line = c[1];
	line.comn = c[2];
	return(1);
}

/* comment: fork and execute /etc/getty on this tty */
dfork(ap)
struct tab *ap;
{
	register i;
	register char *tty;
	register struct tab *p;

	p = ap;
	i = fork();
	if(i == 0) {
		signal(1, 0);
		tty = "/dev/ttyx";
		tty[8] = p->line;
		chown(tty, 0);
		chmod(tty, 0622);
		open(tty, 2);
		dup(0);
		execl("etc/getty", minus, p->coms, 0);
		exit();
	}
	p->pid = i;
}

/* comment: erase utmp record and record logout in wtmp */
rmut(p)
struct tab *p;
{
	register i, f;
	static char zero[16];
	/* comment: erase utmp record in /etc/utmp */
	f = open(utmp, 1);
	if(f >= 0) {
		i = p->line;
		if(i >= 'a')
			i =+ '0' + 10 - 'a';
		seek(f, (i-'0')*16, 0);
		write(f, zero, 16);
		close(f);
	}
	/* comment: record logout in /usr/adm/wtmp */
	f = open(wtmpf, 1);
	if (f >= 0) {
		wtmp.tty = p->line;
		time(wtmp.time);
		/* commen: set file pointer to the end so that append */
		seek(f, 0, 2);
		write(f, &wtmp, 16);
		close(f);
	}
}
