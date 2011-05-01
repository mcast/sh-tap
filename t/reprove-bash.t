#! /bin/sh

main() {
    reprove bash $TDIR/*.t
}

. "$(dirname $0)/do_shtap.sh"
