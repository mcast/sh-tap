#! /bin/sh

# Want to ensure the conversion processes are clean for binary data.
# Plan A was to tee a random data stream,
#
#    (data) -- tee -- (DUT) -- sha1sum
#                  \- sha1sum
#
# but use of "tee >( sha1sum >&3 )" is not very portable, neither is
# /dev/fd/3 .  dd options may also be unportable, and trite use of
# /dev/urandom is not so good.
#
# Plan B is to use a seedable soft-random data stream generator.

tt_binary_clean() { # XXX: extract+test this for general use; check exit code
    datalen=$1
    lineprefix="$2"

    ( # subshell allows each invocatin to have an independent seed
	t_rand_seed_v

	datasum=$( rand_stream $datalen | stream_digest )
	rand_stream $datalen | \
	    ( # device under test
	    t_stdin_is moo DUT1 | tail -n+5 | \
		$SHTAP_HOME/bin/unhd ) | \
		stream_digest | t_stdin_is '%s\n' "binary clean ($datalen,'$lineprefix')" $datasum
# insert " tee dut.$datasum |" to snaffle the data
    )
}

tt_repeatrow() {
    # TESTME: include a repeat sequence in the data stream (it will break)

    yes 'abc' | head -n100 | t_stdin_is moo DUT2 | \
	( # feed it some 4-byte repeating data
	$SHTAP_HOME/bin/unhd 2>&1 >/dev/null; echo "exit $?" ) | \
	    t_stdin_is '%s\nexit 255\n' 'repeat rows are broken, but not silently' \
	    't/../bin/unhd: repeat rows are not implemented'
}

main() {
    t_plan 8

    echo -n A | t_stdin_is moo DUT0 | tail -n+5 | \
	t_stdin_is '%s\n' "check device-under-test ignores 'wanted'" \
'#
# But got
#   00000000  41                                                |A|
#   00000001'

    tt_binary_clean 16 ''
    tt_binary_clean 160 '##  '
    tt_binary_clean 161 '  #  '
    tt_binary_clean 159 '  #  '

    # Enough data to cover all digraphs ~10 times each.
    # <4 sec on this old netbook (three times for t/*.t)
    tt_binary_clean $(( 256 * 256 * 5 )) '#'

    tt_repeatrow

    # Without the "tail -n+5", we concatenate
    echo 'string we give' | t_stdin_is 'wantand' DUT3 | \
	$SHTAP_HOME/bin/unhd | t_stdin_is 'wantandstring we give\n' concatenate


    # unhd slurps all input before emitting any output is a
    # convenience for those who paste into xterms.  It's hard to test,
    # would probably require wallclock sleeping (which is wicked in a
    # test suite) and probably not worth bothering.
}


. "$(dirname $0)/do_shtap.sh"
