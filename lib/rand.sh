# -*- sh -*-


# Random seed + stream generators are intended to be portable
# (enough), simple, seedable and supply the requested bytes.
#
# They are neither crypto quality, nor very efficient.

rand_seed() {
    if [ -n "$T_RSEED" ]; then
	echo $T_RSEED
    else
	perl -we 'use 5.004; printf("%u\n", rand(2**32-1))' || {
	    echo "$0: $SHTAP_HOME/lib/rand.sh: failed to make rand_seed" >&2
	    exit 1
	}
    fi
}

t_rand_seed_v() { # v: verbose, sets a variable
    export T_RSEED=$( rand_seed )
    echo "# exported T_RSEED=$T_RSEED"
}

rand_stream() {
    local nbyte=$1
    local seed=${2:-$T_RSEED}
    perl -w - $nbyte $seed <<'EOF'
 my ($nbyte, $seed) = @ARGV;
 # could accept a "set of characters to use in output" but doesn't,
 # mostly because I can't think of a concise and easy to quote spec

 use strict;
 srand($seed) if defined $seed && $seed ne ''; # default: self-seeding
 while ($nbyte--) {
   print chr(int(rand(256)));
 }
EOF
}

stream_histogram() {
    perl -we '
 use strict;
 my %n; # key=asc, val=count
 while (1) {
   my $buf;
   my $nread = read(STDIN, $buf, 1024);
   die "byte_histogram read failed: $!" unless defined $nread;
   last unless $nread; # eof?
   for (my $i=length($buf)-1; $i>=0; $i--) {
     $n{ ord(substr($buf, $i, 1)) } ++;
   }
 }
 for (my $i=0; $i<256; $i++) {
   next unless defined $n{$i};
   printf("%3d %d\n", $i, $n{$i});
 }
'
}

stream_digest() {
    sha1sum | cut -f1 -d' '
}
