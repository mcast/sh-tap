#! /bin/sh

main() {
    reprove dash $TDIR/*.t
}

. "$(dirname $0)/do_shtap.sh"
