# profile
I maintain accounts on lots of machines, and not all of them mount the same
home directories. Keeping my profile files in a repository like this helps me
maintain profiles across all the machines I need to do work on. Since I don't
want bin, sbin, lib, man, and share directories directly in my home directory,
I gather them all under a ~/my directory. This just helps me to keep my home
directory a little neater. So I have ~/my/bin, ~/my/sbin, etc.

## .zshenv (and .env-prolog and .env-epilog)
Zshell sources this file first for all instances (in the absence of -f). This
is where I set up the environment I want *everything* to run in. Particularly,
this is where the architechure-specific logic is.

The architecture awareness is based on information from uname and culminates in
the value of the ARCHOS environment varaible. I use it to hold the name of the
directory for architecture-specific files, which comes in handy when sharing
filespace among disparate hosts and building architecture dependent projects.
Under the $ARCHOS directory are the usual bin, sbin, lib, man, and share
direcories. On my Mac, ARCHOS=/Users/jclough/my/archos/Darwin_14.3_x86_64.

| I called it ARCHOS because it combines architecture and OS information. Happy accident: It's also Latin for **ruler** (*noun* a person exercising government or dominion). |
|:----------------------------------------------|



### Environment Variables
- `fg_black=30`
- `fg_red=31`
- `fg_green=32`
- `fg_yellow=33`
- `fg_blue=34`
- `fg_magenta=35`
- `fg_cyan=36`
- `fg_white=37`
- `bg_black=40`
- `bg_red=41`
- `bg_green=42`
- `bg_yellow=43`
- `bg_blue=44`
- `bg_magenta=45`
- `bg_cyan=46`
- `bg_white=47`
- `colorNorm="0"`
- `colorDebug="$bg_blue;$fb_white"`
- `colorInfo="1;$bg_black;$fg_green"`
- `colorNotice="1;$bg_black;$fg_cyan"`
- `colorWarning="1;$bg_black;$fg_yellow"`
- `colorError="1;$bg_black;$fg_red
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

- `archos [-hnrka]` Outputs the OS name (-n), OS release (-r), kernel version (-k), and/or architecture (-a) we're running under.
- `date [ARGS]` Output the current date formatted as "+%Y-%m-%d %H:%M:%S" _UNLESS_ there are any command line argumnents, in which case this is just like the regular `date` command.
- `debug TEXT ...` Outputs a timestamp and message in the colorDebug color if SCRIPT_DEBUG is not empty.
- `echo_tc COLOR_CODE TEXT ...` Outputs text in using the ANSI color code. See `error`, `warning`, and `info` for examples.
- `error TEXT ...` Outputs a timestamp and message in the colorError color if SCRIPT_ERROR is not empty.
- `info TEXT ...` Outputs a timestamp and message in the colorInfo color if SCRIPT_INFO is not empty.
- `notice TEXT ...` Outputs a timestamp and message in the colorNotice color if SCRIPT_NOTICE is not empty.
- `prepend_path`
- `prepend_paths`
- `realpath`
- `warning TEXT ...` Outputs a timestamp and message in the colorWarning color if SCRIPT_WARNING is not empty.

## .zprofile (and .profile-prolog and .profile-epilog)
Zshell sources .zprofile after .zshenv and before .zshrc. Other than that, it's
just like .zlogin (which I don't actually use). At the moment, I'm only using
.zprofile to correct an svn-related command completion bug in the stock
distributeion of Zshell.

### Shell functions:

- `_pip_completion`

## .zshrc (and .rc-prolog and .rc-epilog)
Zshell sources .zshrc in interactive shells. I set up things like LSCOLORS,
command history options, command aliases, and window title management here.

### Environment Variables:

- `HISTFILE`
- `HISTSIZE`
- `SAVEHIST`
- `CLICOLOR`
- `LSCOLORS`
- `LS_COLORS`

### Shell functions:

- `anagram TEXT` Output all anagrams of the given word.
- `tabtitle TEXT` Set the title of the current session tab. (Requires iTerm2 integration)
- `windowtitle TEXT` Set the title of the current terminal window. (Requires iTerm2 integration)
- `precmd` Manages the shell prompt, and if iTerm2 integration is enabled, set the terminal tab text and window title.
- `ML [RE_to_grep_for] FILE` Colors (and optionally filters) log output from the given file.

### Aliases:

- `R='sudo /bin/zsh -c "source ~jclough/z"'` (available under RHEL7)
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
- `R='sudo /bin/zsh -c "source ~$USER/z"'`
- `pt='ps -H'`

---

The *-prolog and *-epilog files are sourced, if they exist, from the start and
end, respectively, of the corresponding profile files. This supports
machine-specific behavior without having a lot of conditional logic for that
purpose in the "standard" profile files.

---

There are also **.inputrc** (to turn on vi editing for readline-based input) and
**.vimrc** (to bend vim to my capricious will) files in this project. They're
handy to take with me and troublesome to recreate from scratch.

## iTerm2 and its Shell Integration
This project supports iTerm2's shell integration. If needed, those scripts
can be installed with the following command:

```
curl -L https://iterm2.com/misc/install_shell_integration_and_utilities.sh | bash
```
  
Or if your system is sadly without curl, you can try wget like this:

```
wget --no-check-certificate -qO- https://iterm2.com/misc/install_shell_integration_and_utilities.sh |\
sed 's/curl -SsL/wget --no-check-certificate -qO-/' | bash
```

**IN EITHER CASE,** be *SURE* to remove the line that's added to the end of .zshenv that sources ~/.iterm2_shell_integration.$SHELL. We do this semi-intelligently in .zshrc (or .bashrc) instead so that we can keep the .bash and .zsh versions from being sourced from the wrong shell. **FAILURE TO REMEMBER THIS AFTER UPDATING THE SHELL INTEGRATION SCRIPTS CAN SERIOUSLY MESS UP YOUR ABILITY TO LOG IN.**
