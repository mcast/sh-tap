# -*- shell -*-

if [ -z "$SHTAP_HOME" ] || [ ! -d "$SHTAP_HOME" ] || [ ! -f "$SHTAP_HOME/t_funcs.sh" ]; then
    echo "$0: SHTAP_HOME must be set before calling <sh-tap>/all.sh" >&2
    exit 1
fi

# TDIR is often set, but we must not require it


# Load all sh-tap functions
. "$SHTAP_HOME/t_funcs.sh"
. "$SHTAP_HOME/reprove.sh"
. "$SHTAP_HOME/rand.sh"
. "$SHTAP_HOME/ulimits.sh"
