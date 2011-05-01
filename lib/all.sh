# -*- shell -*-

if [ -z "$SHTAP_HOME" ] || [ ! -d "$SHTAP_HOME" ]; then
    echo "$0: SHTAP_HOME must be set before calling <sh-tap>/lib/all.sh" >&2
    exit 1
fi

# TDIR is often set, but we must not require it


# Load all sh-tap functions
. "$SHTAP_HOME/lib/t_funcs.sh"
. "$SHTAP_HOME/lib/reprove.sh"
