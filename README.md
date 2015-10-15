# profile
I maintain accounts on lots of machines, and not all of them mount the same
home directories. Keeping my profile files in a repository like this helps me
maintain profiles across all the machines I need to do work on. Since I don't
want bin, sbin, lib, man, and share directories directly in my home directory,
I gather them all under a ~/my directory. This just helps me to keep my home
directory a little neater. So I have ~/my/bin, ~/my/sbin, etc.

##.zshenv (and .env-prolog and .env-epilog)
Zshell sources this file first for all instances (in the absence of -f). This
is where I set up the environment I want *everything* to run in. Particularly,
this is where the architechure-specific logic is.

The architecture awareness is based on information from uname and culminates in
the value of the ARCHOS environment varaible. I called it ARCHOS because it
combines architecture and OS information. Happy accident: It's also Latin for
**ruler** (*noun* a person exercising government or dominion). I use it to hold
the name of the directory with architecture-specific file (e.g.
`/Users/jclough/my/archos/Darwin_14.3_x86_64`), which comes in handy when
building projects across disparate hosts. Under the $ARCHOS directory are the
usual bin, sbin, lib, man, and share direcories.

### Environment Variables

- `ARCHOS`
- `EDITOR`
- `LD_LIBRARY_PATH`
- `MANPATH`
- `PAGER`
- `PATH`
- `PYTHONPATH`
- `RSYNC_RSH`
- `architecture`
- `oskernel`
- `osname`
- `rt_env_type`

### Shell functions

- `prepend_path`
- `prepend_paths`

##.zprofile (and .profile-prolog and .profile-epilog)
Zshell sources .zprofile after .zshenv and before .zshrc. Other than that, it's
just like .zlogin (which I don't actually use). At the moment, I'm only using
.zprofile to correct an svn-related command completion bug in the stock
distributeion of Zshell.

###Shell functions:

- `_pip_completion`

##.zshrc (and .rc-prolog and .rc-epilog)
Zshell sources .zshrc in interactive shells. I set up things like LSCOLORS,
command history options, command aliases, and window title management here.

###Environment Variables:

- `HISTFILE`
- `HISTSIZE`
- `SAVEHIST`
- `CLICOLOR`
- `SCOLORS`

###Shell functions:

- `windowtitle`
- `precmd`
- `ML`

###Aliases:

- `less='less -R '`
- `ls='ls -F'`
- `la='ls -a'`
- `ll='ls -l'`
- `lla='ll -a'`
- `lld='ll -d'`
- `lrt='ll -rt'`
- `lrtail='lrt|tail '`
- `MD='mark -Idiff'`
- `vi='/usr/bin/vim '`
- `view='/usr/bin/vim -R '`

---

The *-prolog and *-epilog files are sourced, if they exist, from the start and
end, respectively, of the corresponding profile files. This supports
machine-specific behavior without having a lot of conditional logic for that
purpose in the "standard" profile files.
