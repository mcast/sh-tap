#! /bin/sh

# Test framework, test thyself!

main() {
    echo "1..3"

    # Check that t_stdin_is behaves: several sub-tests rolled into one
    # externally visible comparison.
    ok1=$( echo -n "foo" | t_stdin_is "foo"; echo -n x )
    ok2=$( echo -ne "biff\nboff" | t_stdin_is "biff\nboff" 'named test' -ne; echo -n x )
    ok3=$(
        # beware literal \r
	echo -e 'baff\rbam\\bop' | t_stdin_is "baffbam\bop
"
	echo -n x )
    nok1=$( echo fibble | t_stdin_is wibble; echo -n x)
    nok2=$( echo fibble | t_stdin_is wibble 2 ' '; echo -n x)

    got=",$ok1,$ok2,$ok3,$nok1,$nok2,"
    want=",ok
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
x,not ok - 2
# Wanted
#   00000000  77 69 62 62 6c 65 0a                              |wibble.|
#   00000007
#
# But got
#   00000000  66 69 62 62 6c 65 0a                              |fibble.|
#   00000007
x,"
    [ "$want" == "$got" ] || echo -n "not "
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
    ( t_ok; t_ok "second"; t_fail; t_plan 7; t_noplan_fin; t_fail "fourth test with    longer name" ) | t_stdin_is 'ok
ok - second
not ok
1..7
fin
not ok - fourth test with    longer name
' 't_ok, t_fail and plan primitives'

    # Check TAPify
    echo -e 'ok\nok - foo\nnot ok\n1..6\n# info\nnot ok - bar\nfin' | TAPify | t_stdin_is 'ok 1
ok 2 - foo
not ok 3
1..6
# info
not ok 4 - bar
1..4
' 'the TAPify filter'
}


source "$(dirname $0)/t_funcs.sh"
main | TAPify
