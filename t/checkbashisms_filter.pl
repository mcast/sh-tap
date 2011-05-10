#! /usr/bin/perl

use strict;
use warnings;

=head1 DESCRIPTION

Post-processing filter for L<checkbashisms(1)> output.  Some
"problems" have excuses (for us), so mark them.

Exit code is the problem count (max 100).

(This would be unnecessary if checkbashisms took more flags allowing
exceptions.  Maybe there is a whitelist mechanism in lintian?  But
this works for me.)

=cut

my ($bad, $ignore) = (0, 0);

while (<>) {
  chomp;
  if (m{^script .* does not appear to have a #! interpreter line;$} ||
      m{^you may get strange results$}) {
    # Our shell function files don't have shebang lines.
    # Non-shell files should have been excluded already.

  } elsif (my ($file, $ln, $prob) =
	   m{^possible bashism in (.*) line (\d+) \(([^()]+)\):$}) {

    # that is what it does, you don't have to use it
    $ignore = ($file eq "lib/ulimits.sh" && $prob eq "ulimit");

    # balanced by a check in the quoted text
    $ignore ||= ($prob eq '$BASH_SOMETHING');

    if (!$ignore) {
      sfx("<== !!");
      $bad ++;
    } else {
      sfx("IGNORE");
    }

  } elsif (m{^  |^\t}) {
    # checkbashisms does not indent lines it quotes from scripts, but
    # all our excused problems are inside functions so that is enough
    if (m{BASH_(\w+)} && $1 ne 'VERSION') {
      $bad ++;
      sfx("<== !!");
    }
  } else {
    # something else. weird = bad.
    $bad ++;
    sfx("(??)");
  }
  print "$_\n";
}

$bad = 100 if $bad > 100;
exit $bad;


sub sfx {
  my $sfx = shift;
  $_ .= " " x (70 - length($_));
  $_ .= $sfx;
}
