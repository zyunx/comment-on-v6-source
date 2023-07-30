#
/*
 * login [ name ]
 */

struct {
	char	name[8];
	char	tty;
	char	ifill;
	int	time[2];
	int	ufill;
} utmp;

struct {
	int	speeds;
	char	erase, kill;
	int	tflags;
} ttyb;

struct {
	int	junk[5];
	int	size;
	int	more[12];
} statb;

char	*ttyx;

#define	ECHO	010

main(argc, argv)
char **argv;
{
	char pbuf[128];
	register char *namep, *np;
	char pwbuf[9];
	int t, sflags, f, c, uid, gid;

	/* comment: ignore interrupt signal */
	signal(3, 1);
	/* comment: ignore quit signal */
	signal(2, 1);
	/* comment: restore at default priority level, priority level will pass to child process. */
	nice(0);
	ttyx = "/dev/ttyx";
	/* comment: ttyn(0) returns standard input tty name */
	if ((utmp.tty=ttyn(0)) == 'x') {
		write(1, "Sorry.\n", 7);
		exit();
	}
	ttyx[8] = utmp.tty;
	gtty(0, &ttyb);
	ttyb.erase = '#';
	ttyb.kill = '@';
	stty(0, &ttyb);
    loop:
	/* comment: get user name */
	namep = utmp.name;
	if (argc>1) {
		np = argv[1];
		while (namep<utmp.name+8 && *np)
			*namep++ = *np++;
		argc = 0;
	} else {
		write(1, "Name: ", 7);
		while ((c = getchar()) != '\n') {
			if (c <= 0)
				exit();
			if (namep < utmp.name+8)
				*namep++ = c;
		}
	}
	while (namep < utmp.name+8)
		*namep++ = ' ';
	/* comment: get /etc/passwd entry for the user name, see PASSWD(V) */
	if (getpwentry(utmp.name, pbuf))
		goto bad;
	/* comment: skip user name part and compare password */
	np = colon(pbuf);
	if (*np!=':') {
		/* comment: diable echo */
		sflags = ttyb.tflags;
		ttyb.tflags =& ~ ECHO;
		stty(0, &ttyb);
		write(1, "Password: ", 10);
		namep = pwbuf;
		while ((c=getchar()) != '\n') {
			if (c <= 0)
				exit();
			if (namep<pwbuf+8)
				*namep++ = c;
		}
		*namep++ = '\0';
		/* comment: recover tty mode */
		ttyb.tflags = sflags;
		stty(0, &ttyb);
		write(1, "\n", 1);
		namep = crypt(pwbuf);
		while (*namep++ == *np++);
		if (*--namep!='\0' || *--np!=':')
			goto bad;
	}
	/* comment: skip password part and get uid */
	np = colon(np);
	uid = 0;
	while (*np != ':')
		uid = uid*10 + *np++ - '0';
	/* comment: get gid */
	np++;
	gid = 0;
	while (*np != ':')
		gid = gid*10 + *np++ - '0';
	np++;
	/* comment: skip GCOS part */
	np = colon(np);
	namep = np;
	np = colon(np);
	/* comment: change work directory */
	if (chdir(namep)<0) {
		write(1, "No directory\n", 13);
		goto loop;
	}
	time(utmp.time);
	/* comment: user login databsae */
	if ((f = open("/etc/utmp", 1)) >= 0) {
		t = utmp.tty;
		if (t>='a')
			t =- 'a' - (10+'0');
		seek(f, (t-'0')*16, 0);
		write(f, &utmp, 16);
		close(f);
	}
	if ((f = open("/usr/adm/wtmp", 1)) >= 0) {
		seek(f, 0, 2);
		write(f, &utmp, 16);
		close(f);
	}
	/* comment: motd = message of the day */
	if ((f = open("/etc/motd", 0)) >= 0) {
		while(read(f, &t, 1) > 0)
			write(1, &t, 1);
		close(f);
	}
	/* comment: get file inode info */
	if(stat(".mail", &statb) >= 0 && statb.size)
		write(1, "You have mail.\n", 15);
	chown(ttyx, uid);
	setgid(gid);
	setuid(uid);
	if (*np == '\0')
		np = "/bin/sh";
	/* comment: execute sh directly without fork */
	execl(np, "-", 0);
	write(1, "No shell.\n", 9);
	exit();
bad:
	write(1, "Login incorrect.\n", 17);
	goto loop;
}

getpwentry(name, buf)
char *name, *buf;
{
	extern fin;
	int fi, r, c;
	register char *gnp, *rnp;

	fi = fin;
	r = 1;
	if((fin = open("/etc/passwd", 0)) < 0)
		goto ret;
loop:
	gnp = name;
	rnp = buf;
	while((c=getchar()) != '\n') {
		if(c <= 0)
			goto ret;
		*rnp++ = c;
	}
	*rnp++ = '\0';
	rnp = buf;
	while (*gnp++ == *rnp++);
	if ((*--gnp!=' ' && gnp<name+8) || *--rnp!=':')
		goto loop;
	r = 0;
ret:
	close(fin);
	fin = 0;
	(&fin)[1] = 0;
	(&fin)[2] = 0;
	return(r);
}

colon(p)
char *p;
{
	register char *rp;

	rp = p;
	while (*rp != ':') {
		if (*rp++ == '\0') {
			write(1, "Bad /etc/passwd\n", 16);
			exit();
		}
	}
	*rp++ = '\0';
	return(rp);
}
