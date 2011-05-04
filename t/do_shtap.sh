# -*- shell -*-


# This shell fragment sets variables, loads sh-tap functions and runs
# the tests.  It is a shared boilerplate invocation, considered part
# of the tests rather than part of the sh-tap code.


# TDIR is often handy, but not actually required by sh-tap.
#    TESTME: a grep should be enough to prove this, but using another variable in our tests would be a neater demonstration
#
TDIR="$(dirname $0)"
# $0 is the calling script, not this sourced shell fragment!  Test
# scripts in subdirectories will need something else.


# sh-tap must know its location.
#
SHTAP_HOME="$TDIR/.."
# Easy for us.  Other project must find their own way.  Possible
# mechanisms include,
#
#   - sh-tap provides program to echo SHTAP_HOME's value, and this is installed or added to PATH
#   - project maintains a symlink among its source
#   - project uses autoconf, Module::Build ...



# Load functions
. "$SHTAP_HOME/lib/all.sh"

# Assume main was defined already, and run it as the test.
TAPified main