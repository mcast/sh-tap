#! /bin/sh

tt_taboo_grep() { # XXX: fix calling convention, extract+test this for general use
    local grep_for="$*"
    local t_todo="${TODO:+" # TODO"}"

    # XXX: push $TODO check into t_ok and friends, and acks to "shell-functions"
    {
	(! grep $grep_for; t_prev_okfail "taboo keywords (grep $grep_for)$t_todo" >&3) | t_comment_indent >&3
    } 3>&1
}
# TESTME: grep args lost (making false pass) under dash

main() {
    t_plan 3

    # sh-tap promises it will not assume that $TDIR is defined
    tt_taboo_grep -r   '$TDIR'    $SHTAP_HOME/lib

    # we should be using TAPified, not TAPify_filter
    tt_taboo_grep -r   '[m]ain.*TAPify' $TDIR

    TODO=1
    tt_taboo_grep -rni '[T]ESTME' $SHTAP_HOME/lib $TDIR
    tt_taboo_grep -ri '[X]XX'     $SHTAP_HOME/lib $TDIR
}


. "$(dirname $0)/do_shtap.sh"
