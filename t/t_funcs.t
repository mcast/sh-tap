#! /bin/sh

# Test framework, test thyself!

tt_stdin() {
    # Check that t_stdin_is behaves: several sub-tests rolled into one
    # externally visible comparison.
    ok1=$( echo -n "foo" | t_stdin_is "foo"; echo -n x )
    ok2=$( printf 'biff\nboff' | t_stdin_is 'biff\nboff' 'named test' -ne; echo -n x )
    ok3=$(
	printf 'baff\rbam\\bop\n' | t_stdin_is 'baff\015bam\134bop\12'
	echo -n x )
    nok1=$( echo fibble | t_stdin_is wibble; echo -n x)
    nok2=$( echo fibble | t_stdin_is 'wibble\n' 'nok2 test'; echo -n x)

    got=",$ok1,$ok2,$ok3,$nok1,$nok2,"
    want=',ok
x,ok - named test
x,ok
x,not ok
# Wanted
#   00000000  77 69 62 62 6c 65                                 |wibble|
#   00000006
#
# But got
#   00000000  66 69 62 62 6c 65 0a                              |fibble.|
#   00000007
x,not ok - nok2 test
# Wanted
#   00000000  77 69 62 62 6c 65 0a                              |wibble.|
#   00000007
#
# But got
#   00000000  66 69 62 62 6c 65 0a                              |fibble.|
#   00000007
x,'
    [ "$want" = "$got" ] || echo -n "not "
    echo "ok - t_stdin_is check"

    if [ -n "$T_DEBUG" ]; then
	echo ">>|ok1|=|$ok1|<<"
	echo ">>|ok2|=|$ok2|<<"
	echo ">>|ok3|=|$ok3|<<"
	echo ">>|nok1|=|$nok1|<<"
	echo ">>|nok2|=|$nok2|<<"
	echo ">>|want|=|$want|<<"
	echo ">>|got|=|$got|<<"
    fi >&2

    printf 'miff\nmoff\nmaff\n' | \
	t_stdin_is '%s%s\n' 't_stdin word breaking' "$( printf 'miff\nmoff\nm' )" 'aff'

    printf 'miff\nmoff\nmaff\n' | \
	t_stdin_is '%s\n%s\n' 't_stdin chompage' "$( printf 'miff\nmoff\n' )" 'maff'
    # nb. Wanted-side newline after moff is lost, replaced by one in
    # format.  This is not _required_ behaviour, but is documented and
    # will cause breakage if it were fixed to work more conveniently.
}


tt_okfail() {
    # Check per-test funcs
    (
	t_ok
	t_ok "second"
	t_fail
	t_plan 7
	t_noplan_fin
	t_plan junk 2>/dev/null # supress warning
	t_fail "fourth test with    longer name" ) | t_stdin_is \
	    'ok
ok - second
not ok
1..7
fin
1..0
not ok - fourth test with    longer name
' 't_ok, t_fail and plan primitives'
}


tt_tapify() {
    # Check TAPify_filter
    printf 'ok\nok - foo\nnot ok\n1..6\n# info\nnot ok - bar\nfin\n' | TAPify_filter | t_stdin_is 'ok 1
ok 2 - foo
not ok 3
1..6
# info
not ok 4 - bar
1..4
' 'TAPify_filter does numbers and plan'

    printf 'ok\nexitcode 23\nexitcode 21\nok\nfin\n' | \
	(TAPify_filter; echo "## filter exit $?") | \
	t_stdin_is \
	'ok 1\n# nb. exitcode 23\n# nb. exitcode 21\nok 2\n1..2\n## filter exit 21\n' \
	'TAPify_filter uses final exitcode'

    # Check TAPified wrapper
    (TAPified printf 'ok\nok\nfin\n'; echo "# exit $?") | \
	t_stdin_is 'ok 1\nok 2\n1..2\n# exit 0\n' 'TAPified OK'

    (TAPified sh -c 'printf "ok\n"; echo Something broke >&2; exit 17'; echo "# exit $?") 2>/dev/null | \
	t_stdin_is 'ok 1\n# nb. exitcode 17\n# exit 17\n' 'TAPified failing'

    (TAPified subtest_seterr; echo "# exit $?") | \
	t_stdin_is 'ok 1 - first inner\n# nb. exitcode 67\n# exit 67\n' 'TAPified with "set -e"'
}

# Inner test runs as a function from main, to ensure that we can
# handle "set -e" correctly
subtest_seterr() {
    set -e
    t_ok "first inner"
    subtest_the_error
    t_fail "should have stopped before this"
}
# TESTME: all sh-tap functions need to work with+without "set -e"

subtest_the_error() {
    return 67
}


tt_helpers() {
    # Comment indenter
    printf 'whee\nwhoo\nwah\n' | t_comment_indent | \
	t_stdin_is '# whee\n# whoo\n# wah\n' t_comment_indent

    printf 'whee\nwhoo\nwah\n' | t_comment_indent '##  ' | \
	t_stdin_is '##  whee\n##  whoo\n##  wah\n' 't_comment_indent(##  )'

    # Examples (XXX: copied)
    (echo foo; echo bar) | t_stdin_is "%s\n%s\n" "t_stdin_is printf" foo bar

    # Broken under dash, wanted-printf broken
    echo -n A | t_stdin_is '\x41' 'hexchar printf in dash # TODO'

    # Weirdness remaining/suspected, needs better tests
    printf 'nul\0byte' | t_stdin_is 'nul\0byte' 'nul ok'
    printf 'back\10space' | t_stdin_is 'back\10space' 'backspace eating chars'
}



main() {
    echo "1..15"

    tt_stdin
    tt_okfail
    tt_tapify
    tt_helpers
}


TDIR="$(dirname $0)"
. "$TDIR/t_funcs.sh"
main | TAPify_filter
