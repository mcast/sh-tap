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
# t_bailout "message"
#
#    Send the "abort all remaining tests" string 'Bail out!', with
#    optional explanatory message.  Does not call exit, you should
#    probably do this immediately afterwards.
#
#
# t_ok "name"
# t_fail "name"
#
#    Pass or fail one test, with optional name.
#
#    These may run in subshells, so cannot influence state of the
#    parent process.  For this reason they do no output the test
#    number and so must be used with TAPify_filter before prove(1)
#    will accept them.
#
#    Suffix the name with " # skip" or " # todo" to mark skipped or
#    not-expected-to-pass tests.
#
#
# do_something; t_prev_okfail "name"
#
#    Pass or fail one test, with optional name, according to the
#    return code of the previous operation.  (Hence the conditional is
#    pushed into the test framework.)
#
#
# t_skip $n
#
#    Fail/skip that many tests.
#
#    This allows some subtests to be in a conditional code path
#    without disrupting an up-front testing plan (t_plan).  It is of
#    little value under a post-hoc plan (t_noplan_fin).
#
#
# echo stuff | t_stdin_is 'stuff'
# echo -n stuff | t_stdin_is "%s" "name" "$stuffvar"
# (echo foo; echo bar) | t_stdin_is "%s\n%s\n" "name" foo bar
#
#    Compare stdin with the wanted string, with optional name and
#    optional replacement flags for the internal printf.
#
#    Calls t_ok, or calls t_fail and formats up a comment explaining
#    the problem.
#
#    Trailing newlines beware!  $( foo ) chomps the last newline.  Use
#    a guard character such as $(foo; echo -n x) if this is
#    significant.
#
#
# main | TAPify_filter
#
#    Assuming shellfunction main() contains all your tests - append
#    test numbers and translate t_noplan_fin output into a post-hoc
#    test plan.  Does not maintain the exit code!
#
#
# TAPified main 'args'...
#
#    Run main with a TAPify_filter (as above), passing any arguments
#    and return with the exit code from main.



t_plan() {
    printf "1..%d\n" "$1"
}
t_ok() {
    descr=${1:+" - "}$1
    echo "ok$descr"
}
t_fail() {
    descr=${1:+" - "}$1
    echo "not ok$descr"
}
t_prev_okfail() {
    [ $? -eq 0 ] || printf 'not '
    descr="${1:+" - "}$1"
    echo "ok$descr"
}

t_skip() {
    n=$1
    for i in $( seq $n ); do
	echo "not ok # skip"
    done
}

t_noplan_fin() {
    echo "fin"
}
t_bailout() {
    printf 'Bail out!%s\n' ${1:+" # $1"}
}

TAPify_filter() {
    awk -- '
 /^(not )?ok/ { n++; sub(/ok/,"ok " n) }
 /^fin$/ { $0 = "1.." n }
 /^exitcode [0-9]+$/ { will_exit=substr($0, 9)+0; $0 = "# nb. " $0 }
 { print }
 END { exit will_exit }
'
}

TAPified() {
    prog=$1
    shift
    ( ($prog "$@")
	progret=$?
	if [ "$progret" != 0 ]; then
	    printf 'exitcode %s' $progret
	fi ) | TAPify_filter
}

t_stdin_is() {
    wantfmt="$1"
    descr="$2"
    shift; [ -n "$descr" ] && shift
    want=$( printf "$wantfmt" "$@" | hd )
    got=$( hd )
    if [ "$want" = "$got" ]; then
	t_ok "$descr"
    else
	t_fail "$descr"
	(
	    printf '# Wanted\n%s\n' "$want"
	    # XXX: print (nil)s when empty
	    echo "#"
	    printf '# But got\n%s\n' "$got"
	    ) | awk -- '/^#/ { print }  !/^#/ { print "#   " $0 }'
    fi
}

t_comment_indent() {
    indent_with=${1:-'# '}
    awk -- "{ print \"$indent_with\" \$0 }"
}
