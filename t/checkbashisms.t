#! /bin/sh

tt_checkbashisms() {
    file="$1"
    {
	checkbashisms -f -x "$file" 2>&1 | {
	    $TDIR/checkbashisms_filter.pl; t_prev_okfail "$file" >&3
	} | t_comment_indent
    } 3>&1
}

list_sh_files() {
    (cd $SHTAP_HOME; find . -type f) | $TDIR/non_sh_filter.pl
}

main() {
    if ! checkbashisms --version >/dev/null 2>&1; then
	echo "1..0 # SKIP checkbashisms(1) not found"
	echo "# see devscripts (Debian)"
	exit 0
    fi

    # Plan size will need updating with each file in the package.
    # Annoying but safe?
    t_plan $( cat $TDIR/sh_file_count.txt )

    for file in $( list_sh_files ); do
	tt_checkbashisms "$file"
    done
}


. "$(dirname $0)/do_shtap.sh"
