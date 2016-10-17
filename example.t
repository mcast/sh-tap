#! /bin/sh

tt_sum() {
    [ $(( $1 + $2 )) = $3 ]; t_prev_okfail "sum($1+$2==$3)"
}

main() {
    t_plan 4
    tt_sum 1 1 2
    tt_sum 2 2 4
    tt_sum 2 6 8
    tt_sum 8 10 18
}

SHTAP_HOME="$(dirname $0)"
. "$SHTAP_HOME/lib/all.sh"
TAPified main
