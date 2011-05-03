# -*- shell -*-


# Strip off test numbering so we can take another pass through TAPify
deTAPify() {
    perl -ne '
 if (/^1\.\.0\s/)	{ print "ok # skip entire file: $_" }
 elsif (/^1\.\.\d/)	{ print "# old plan: $_" }
 elsif (/^(not |)ok \d+(.*)$/)	{ print "${1}ok$2\n" }
 elsif (/^\s*#/)	{ print "#\t\t$_" }
 else			{ print "not ok - unknown input\n# input: $_" }
'
}


# Dump any relevant vars that may help the programmer figure out what
# is running.  XXX: Can't find version or ident variables for dash.
reprove_shelldebug() {
    sh -c 'echo "# Run under T_ANOTHER_SH=$T_ANOTHER_SH, BASH_VERSION=$BASH_VERSION"'
}


# Run a bunch of *.t under a shell.  Without calling ourself.
reprove() {
    with_sh=$1
    shift
    run_progs=$*

    # Avoid recursion loop & make some debug noise
    if [ -n "$T_ANOTHER_SH" ]; then
	reprove_shelldebug
#	echo "1..0 # skip Already under the influence of t/another-sh/sh"
	echo "# Skip this file - already under the influence of t/another-sh/sh"
	return 0
    fi

    echo "# Check tests ($run_progs) again under $with_sh"
    echo "# System default shell /bin/sh -> $( readlink /bin/sh )"
    echo '#'

    # Setup
    export T_ANOTHER_SH=$with_sh
    export PATH=$TDIR/another-sh:$PATH
    reprove_shelldebug

    # Run some files.  One subtest out for each in the wrapped test,
    # plus another to check the wrapped test does not whinge
    for tprog in $run_progs; do
	printf '#\n#\n'
	t_ok "==== Starting $tprog under $with_sh ===="

#	sh $tprog | deTAPify
	{
	    {
		# 10>&2 sends stdout to stderr??
		sh $tprog 3>&2 4>&2 5>&2 6>&2 7>&2 8>&2 9>&2 | deTAPify_filter >&3
	    } 2>&1 | t_stdin_is '' "^^^^ quiet on stderr and fd 3-9: $tprog under $with_sh"
	} 3>&1
	# TESTME: risk of interleaved output?  it seems to work...
    done

    t_noplan_fin
}
