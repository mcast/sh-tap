# About
## What is it?
Shell script functions for a TAP Producer (Test Anything Protocol).

## POSIX compliant?
It aims to be POSIX-compliant (in this particular case, somewhat
justifying Ubuntu's approach to dash vs. bash in 2006).

This is more of an intention than something I diligently pursue.
There is support for re-running all tests under multiple shells, but
this is only likely to see the current dash and bash on my machines.

## Constraints on test scripts
sh-tap tries not to place extra constraints on the test scripts.

There is no need to emit all TAP output (ok/not ok/plan) from one
process because these functions do not keep global state, and thus
there is no problem with trying to inherit variables back up the
sub-shell tree.

Subtest numbers and post-hoc plans are added by a command-prefix-style
function, with the state for this held in another process which wraps
the test script.

## Let `prove(1)` do the work
sh-tap does not ensure the test script's exitcode is set to match the
overall pass/fail state.  That saves keeping some state.

# How to use it
## Example test script

`cat `[`example.t`](./example.t)

```
#! /bin/sh

tt_sum() {
    [ $(( $1 + $2 )) = $3 ]; t_prev_okfail "sum($1+$2==$3)"
}

main() {
    t_plan 4
    tt_sum 1 1 2
    tt_sum 2 2 4
    tt_sum 2 6 8
    tt_sum 8 10 18
}

SHTAP_HOME="$(dirname $0)"
. "$SHTAP_HOME/lib/all.sh"
TAPified main
```

The most useful functions are defined and documented in [lib/t_funcs.sh](./lib/t_funcs.sh), others are loaded from [lib/all.sh](./lib/all.sh).

## Run it

```
$ prove -v ./example.t 
./example.t .. 
1..4
ok 1 - sum(1+1==2)
ok 2 - sum(2+2==4)
ok 3 - sum(2+6==8)
ok 4 - sum(8+10==18)
ok
All tests successful.
Files=1, Tests=4,  0 wallclock secs ( 0.06 usr +  0.00 sys =  0.06 CPU)
Result: PASS
```

# History
## Inception
It started life as "I'll just write some tests for this (shell script)
app.  I guess I will need 'ok' and 'fail'".  It then ballooned into a
monster yak-shaving.

I saw

* http://testanything.org/wiki/index.php/TAP_Producers#SH_.2F_Shell_Script
* http://svn.solucorp.qc.ca/repos/solucorp/JTap/trunk/

but decided, after skim-reading it, that I liked mine better.  NIH.

After that, the early commit history was already a mess so it got
rebased until "history" is not the right word for it.

## v0.10
It works well enough.  Selftests pass.  Stop messing about with it!

However, some (names of) functions might have to change.  There are
neater solutions to common idioms, so refactoring or deprecation are
likely.

## See also

* http://www.illusori.co.uk/projects/bash-tap/
  *  https://github.com/illusori/bash-tap
* https://github.com/sstephenson/bats
* In xUnit world,
  * shunit [website](http://shunit.sourceforge.net/) [sourceforge](https://sourceforge.net/projects/shunit/), version 1.5 released 2008-11-02
  * shunit2 [sourceforge](https://sourceforge.net/projects/shunit2/), last update 2013-04-23
      * [In Debian](http://packages.debian.org/shunit2)
      * [Blog](http://www.mikewright.me/blog/2013/10/31/shunit2-bash-testing/)
  * http://stackoverflow.com/questions/971945/unit-testing-for-shell-scripts

Where I have put a date, doesn't mean the project hasn't moved since I looked!
