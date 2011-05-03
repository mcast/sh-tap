#! /bin/sh


tt_safeclean_tmpdir() {
    (
	# use mocks, don't set an exit trap
	export PATH="$TDIR/t_mocks:$PATH"
	export T_DEBUG=1
	export T_MOCK_MKTEMP=kaploo

	# See the mock working
	testtmp="$( mktemp --wibble 2>&1 )"
	if [ "$testtmp" = 'kaploo' ]; then
	    t_ok 'safeclean_tmpdir: mock working'
	else
	    t_fail "safeclean_tmpdir: mockery failure, '$testtmp'"
	    t_skip 7
	    return 1
	fi

	(export T_MOCK_MKTEMP_EXIT=1
	    safeclean_tmpdir__stdout 2>&1
	    echo "exit $?") | \
		t_stdin_is 'mktemp failed\nexit 5\n' 'safeclean_tmpdir: exitcode'
	(safeclean_tmpdir__stdout 2>/dev/null; echo "exit $?") | \
	    t_stdin_is 'exit 4\n' 'safeclean_tmpdir: -d'

	export T_MOCK_MKTEMP=/tmp/t_funcs.$$.kaploo
	# We could lose a race making this path.
	#
	# We only call touch, find, "rm $foo/.safeclean", mkdir, chmod
	# & rmdir on it.  Possible damage should be small.
	if mkdir $T_MOCK_MKTEMP; then
	    t_ok "safeclean_tmpdir mkdir"
	else
	    t_fail "mkdir $T_MOCK_MKTEMP failed"
	    t_skip 4
	    return 1
	fi

	mkdir "$T_MOCK_MKTEMP/not-empty"
	(safeclean_tmpdir__stdout 2>/dev/null; echo "exit $?") | \
	    t_stdin_is 'exit 3\n' 'safeclean_tmpdir: not empty'
	rmdir "$T_MOCK_MKTEMP/not-empty"

	# chmods are private so a symlink attack cannot be used to
	# publish user's files; but could still DoS something
	chmod 0500 "$T_MOCK_MKTEMP"
	(safeclean_tmpdir__stdout 2>/dev/null; echo "exit $?") | \
	    t_stdin_is 'exit 2\n' 'safeclean_tmpdir: filecount unreliable'
	chmod 0700 "$T_MOCK_MKTEMP"

	(safeclean_tmpdir__stdout 2>/dev/null; echo "  exit $?") | \
	    t_stdin_is '%s  exit 0\n' \
	    'safeclean_tmpdir: answer' "$T_MOCK_MKTEMP"

	rmdir "$T_MOCK_MKTEMP"; t_prev_okfail 'safeclean_tmpdir: no cruft'
	)

    if [ -n "$T_MOCK_MKTEMP" ]; then
	# should never happen, right?
	t_bailout 'mockery escape'
	exit 1
    else
	t_ok 'mockery containment'
    fi

    # Now do it for real & check clean up
    printf %s "$safeclean_dir" | t_stdin_is '' 'pre-mktemp'
    {
	made_dir=$( safeclean__for_real )
    } 4>&1
    printf '# made_dir=%s (after subshell)\n' "$made_dir"
    [ -n "$made_dir" ] && [ ! -d "$made_dir" ]; t_prev_okfail 'mktemp cleaned'
}

# safeclean_tmpdir sets a variable, but is quiet.
# Printing the directory is more convenient for us.
safeclean_tmpdir__stdout() {
    safeclean_tmpdir
    printf '%s' "$safeclean_dir"
}

safeclean__for_real() { # stdout = test results, fd3 = made directory
    {
	safeclean_tmpdir; t_prev_okfail 'real mktemp'
	[ -n "$safeclean_dir" ] && [ -d "$safeclean_dir" ] && \
	    [ -w "$safeclean_dir" ]; t_prev_okfail 'mktemp writable dir'
	cp /bin/sh "$safeclean_dir" && [ -f "$safeclean_dir/sh" ] && \
	    [ -x "$safeclean_dir/sh" ]; t_prev_okfail 'cp sh tmpdir'
	printf '# safeclean_dir=%s\n' "$safeclean_dir"
    } >&4 # test output
    printf %s "$safeclean_dir"
}


main() {
    t_plan 14

    tt_safeclean_tmpdir # 9+5
}


TDIR="$(dirname $0)"
. "$TDIR/t_funcs.sh"
TAPified main
