# -*- shell -*-


# safeclean_tmpdir
#
#    Create a tempdir named for the script, do some checks to be sure
#    we got a new empty directory, then (unless T_DEBUG is set)
#    install an exit trap to remove it.
#
#    Any failures cause non-zero return, output to stderr and no
#    stdout.  (i.e. you still need to check the return or run with
#    "set -e")



# The problem to solve here is: make a race-safe tempdir, give us the
# name and set a exit-cleanup trap iff we succeeded.  The caller of
# mkdir(2) is best placed to guarantee this.
#
# Sadly we must talk to the cheeky monkeys inbetween.  Thus we risk
# littering files and/or blowing away the wrong directory.
safeclean_tmpdir() {
    tmpdir_template="$( basename "$0" | tr -d '\012' | tr -c '_a-zA-Z0-9,.-' _ )"
    new_tmpdir="$( mktemp -d --tmpdir "t__$tmpdir_template.XXXXXX" )"
    if [ "$?" != '0' ]; then
	echo 'mktemp failed' >&2
	return 5
    elif [ -z "$new_tmpdir" ] || ! [ -d "$new_tmpdir" ]; then
	echo "mktemp did not give us a directory '$new_tmpdir'" >&2
	return 4
    elif [ "$( safeclean_dircount "$new_tmpdir" )" != '1' ]; then
	echo "mktemp gave us a non-empty directory '$new_tmpdir'" >&2
	return 3
    elif [ "$( touch "$new_tmpdir/.safeclean" && safeclean_dircount "$new_tmpdir" )" != '2' ]; then
	echo "safeclean_dircount unreliable? mktemp gave us '$new_tmpdir'" >&2
	return 2
    else
	rm "$new_tmpdir/.safeclean"
	# Fairly confident we have a new empty directory
	if [ -n "$T_DEBUG" ]; then
	    echo "Leaving $new_tmpdir/ behind because T_DEBUG is set" >&2
	else
	    trap 'rm -rf "$new_tmpdir"' EXIT
	fi
	printf '%s' "$new_tmpdir"
    fi
}

safeclean_dircount() {
    find "$1" -print | wc -l
}
