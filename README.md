# profile
I maintain accounts on lots of machines, and not all of them mount the same home
directories. Keeping my profile files in a repository like this helps me maintain
profiles across all the machines I need to do work on.

###.zshenv (and .env-prolog and .env-epilog)
Zshell sources this file first for all instances (in the absence of -f). This is
where I set up the environment I want EVERYTHING to run in.

###.zprofile (and .profile-prolog and .profile-epilog)
Zshell sources .zprofile after .zshenv and before .zshrc. Other than that, it's
just like .zlogin (which I don't actually use). At the moment, I'm only using
.zprofile to correct a command completion bug in the stock Zshell.

###.zshrc (and .rc-prolog and .rc-epilog)
Zshell sources .zshrc in interactive shells. I set up things like LSCOLORS, command
history options, command aliases, and window title management here.

=======================

The *-prolog and *-epilog files are sourced, if they exist, from the start and end,
respectively, of the corresponding profile files. This supports machine-specific
behavior without having a lot of conditional logic for that purpose in the "standard"
profile files.
