# -*- shell -*-

t_set_ulimits() { # TESTME: I poked it until it seemed to work on my machine

    # Flags & units differ.  This covers dash & bash.
    local ulim_procsflag=-p
    local ulim_filemult=2
    [ -n "$BASH_VERSION" ] && ulim_procsflag=-u ulim_filemult=1

    # Set only only those limits we have been given.
    # Assume the caller took environment variables with defaults.
    [ -n "$t_maxcpu" ] && \
	ulimit -S -t $t_maxcpu

    [ -n "$t_maxprocs" ] && \
	ulimit -S $ulim_procsflag $t_maxprocs

    [ -n "$t_maxfilesz" ] && \
	ulimit -S -f $(( $ulim_filemult * $t_maxfilesz ))

    [ -n "$t_maxfds" ] && \
	ulimit -S -n $t_maxfds

    # Set all memory limits the same, since some are documented to be
    # ignored on some systems.
    [ -n "$t_maxmem" ] && {
	ulimit -S -d $t_maxmem
	ulimit -S -m $t_maxmem
	ulimit -S -s $t_maxmem
	ulimit -S -v $t_maxmem
    }

## have never seen these do anything, and the shell makes the right
## noises when a child process is zapped
#
#   trap 'echo "shtap: out of CPU time" >&2; exit 1' XCPU
#   trap 'echo "shtap: file too big" >&2' XFSZ
#   trap 'echo "shtap: woo, segfault" >&2; exit 1' SEGV
}
