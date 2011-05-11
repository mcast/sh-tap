#! /bin/sh

(
    set -e
    main() {
	t_plan 1
    }
    . "$(dirname $0)/do_shtap.sh"
)

# sh-tap provides functions (t_ok t_bailout t_prev_okfail) to do these
# things, but we cannot rely on them in a "did it lad?" test!
if [ $? = 0 ]; then
    echo 'ok 1 - functions loaded'
else
    echo 'Bail out! # some problem loading the TAP functions?'
fi
