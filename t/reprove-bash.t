#! /bin/sh

TDIR="$(dirname $0)"
. "$TDIR/t_funcs.sh"
. "$TDIR/reprove.sh"

reprove bash $TDIR/*.t | TAPify_filter
