#! /bin/sh

# Test framework, test thyself!

main() {
    echo "1..7"

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

    # Check TAPify
    printf 'ok\nok - foo\nnot ok\n1..6\n# info\nnot ok - bar\nfin\n' | TAPify | t_stdin_is 'ok 1
ok 2 - foo
not ok 3
1..6
# info
not ok 4 - bar
1..4
' 'the TAPify filter'

    # Examples (XXX: copied)
    (echo foo; echo bar) | t_stdin_is "%s\n%s\n" "t_stdin_is printf" foo bar

    # Broken under dash, wanted-printf broken
    echo -n A | t_stdin_is '\x41' 'hexchar printf in dash # TODO'

    # Weirdness remaining/suspected, needs better tests
    printf 'nul\0byte' | t_stdin_is 'nul\0byte' 'nul ok'
    printf 'back\10space' | t_stdin_is 'back\10space' 'backspace eating chars'
}


. "$(dirname $0)/t_funcs.sh"
main | TAPify
