#! /bin/sh

tt_seedable() {
    # Check the seed generator
    (
	T_RSEED=
	[ "$( rand_seed )" != "$( rand_seed )" ]; t_prev_okfail 'rand_seed is unpredictable'
	# if you see this subtest fail twice in a row, please buy us both
	# lottery tickets immediately (or check your Perl install)
    )

    T_RSEED=123456789 rand_seed | t_stdin_is '123456789\n' 'rand_seed is fixable'

    (
	t_rand_seed_v
	num=$T_RSEED
	[ -n "$num" ]; t_prev_okfail "seed is not empty"
	[ "$( rand_seed )" = "$( rand_seed )" ]; t_prev_okfail "t_rand_seed_v ($T_RSEED)"
	t_rand_seed_v
	[ "$( rand_seed )" = "$num" ]; t_prev_okfail 't_rand_seed_v is idempotent'
	t_rand_seed_v | t_stdin_is '# exported T_RSEED=%s\n' 't_rand_seed_v is noisy' $T_RSEED
    )

    seed=$( rand_seed )
    firstsum=$( rand_stream 10240 $seed | sha1sum )
    rand_stream 10240 $seed | sha1sum | t_stdin_is \
	'%s\n' "rand_stream repeatable ($seed)" "$firstsum"
    T_RSEED=$seed rand_stream 10240 | sha1sum | t_stdin_is \
	'%s\n' "rand_stream sees T_RSEED" "$firstsum"

    # this might be handy, but isn't important
    rand_stream 20480 12345678 | stream_digest | t_stdin_is \
	'5c54442e46932f7ea5b0cce31cea3e590fe9100d\n' \
	'rand_stream repeatable for everyone? # todo'
}

tt_diagnostic() {
    # stream_digest is just a convenient way to reduce a stream of
    # data.  Check it matches these sha1sums.
    echo    'wibble me a wobble' | stream_digest | t_stdin_is \
	'a5e014e9d5e100ff319e71ba74f721c7072f068e\n' stream_digest
    echo -n 'wibble me a wobble' | stream_digest | t_stdin_is \
	'44cb43f05e22064da502dfbd0458c2ef7148e1ac\n' 'stream_digest, no lf'

    # stream_histogram should count bytes
    printf '\0\n\r\377' | stream_histogram | t_stdin_is \
	'  0 1\n 10 1\n 13 1\n255 1\n' histogram4
    echo -n 'wibble me a wobble' | stream_histogram | t_stdin_is \
	' 32 3\n 97 1\n 98 4\n101 3\n105 1\n108 2\n109 1\n111 1\n119 2\n' 'histogram string'
    yes 'A' | head -n12345 | stream_histogram | t_stdin_is \
	' 10 12345\n 65 12345\n' histogram24690
}

tt_rand_stream_content() {
    (rand_stream 1000; rand_stream 234) | wc -c | t_stdin_is '1234\n' 'rand_stream length'
    rand_stream 25600 | stream_histogram | wc -l | t_stdin_is '256\n' 'rand_stream includes all bytes'
}

main() {
    t_plan 16
    tt_diagnostic # 5
    tt_seedable   # 9
    tt_rand_stream_content # 2
}


. "$( dirname $0 )/do_shtap.sh"
