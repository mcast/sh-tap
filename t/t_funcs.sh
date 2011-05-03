# -*- shell -*-

# TAP (test anything protocol) / prove(1) compatible shell functions.
#
# They seem to work OK for safe data, but they have NOT been tested
# for use with untrusted input!
#
#
# t_plan $N
#
#    Tell prove how many tests we intend to run.
#
#
# t_noplan_fin
#
#    Tell prove how many tests we did run, after the fact.
#    prove(1) insists we have exactly one plan.
#
#
# t_ok "name"
# t_fail "name"
#
#    Pass or fail one test, with optional name.
#
#    These may run in subshells, so cannot influence state of the
#    parent process.  For this reason they do no output the test
#    number and so must be used with TAPify before prove(1) will
#    accept them.
#
#    Suffix the name with " # skip" or " # todo" to mark skipped or
#    not-expected-to-pass tests.
#
#
# echo -n stuff | t_stdin_is "stuff" "name"
# (echo stuff; echo nonsense) | t_stdin_is "stuff\nnonsense" "name" -e
#
#    Compare stdin with the wanted string, with optional name and
#    optional replacement flags for the internal echo.
#
#    Calls t_ok, or calls t_fail and formats up a comment explaining
#    the problem.
#
#
# main | TAPify
#
#    Assuming shellfunction main() contains all your tests



t_plan() {
    echo "1..$1"
}
t_ok() {
    descr=${1:+" - "}$1
    echo "ok$descr"
}
t_fail() {
    descr=${1:+" - "}$1
    echo "not ok$descr"
}
t_noplan_fin() {
    echo "fin"
}

TAPify() {
    awk -- '
 /^(not )?ok/ { n++; sub(/ok/,"ok " n) }
 /^fin$/ { $0 = "1.." n }
 { print }
'
}

t_stdin_is() {
    eflag=${3:--n}
    want=$( echo $eflag "$1" | hd )
    descr="$2"
    got=$( hd )
    if [ "$want" == "$got" ]; then
	t_ok "$descr"
    else
	t_fail "$descr"
	(
	    echo "# Wanted"; echo "$want"
	    echo "#"
	    echo "# But got"; echo "$got"
	    ) | awk -- '/^#/ { print }  !/^#/ { print "#   " $0 }'
    fi
}
