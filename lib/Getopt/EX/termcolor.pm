=encoding utf-8

=head1 NAME

Getopt::EX::termcolor - Getopt::EX termcolor module

=head1 VERSION

Version 1.02

=head1 SYNOPSIS

    use Getopt::EX::Loader;
    my $rcloader = new Getopt::EX::Loader
        BASECLASS => [ 'App::command', 'Getopt::EX' ];

    or

    use Getopt::EX::Long qw(:DEFAULT ExConfigure);
    ExConfigure BASECLASS => [ "App::command", "Getopt::EX" ];

    then

    $ command -Mtermcolor::bg=

=head1 DESCRIPTION

This is a common module for command using L<Getopt::EX> to manipulate
system dependent terminal color.

Actual action is done by sub-module under L<Getopt::EX::termcolor>,
such as L<Getopt::EX::termcolor::Apple_Terminal>.

Each sub-module is expected to have C<&get_color> function which
returns RGB value list between 0 and 65535.  If the sub-module was
found and C<&get_color> function exists, its result with C<background>
parameter is taken as a background color of the terminal.

Luminance is caliculated from RGB values by this equation and produces
decimal value from 0 to 100.

    ( 30 * R + 59 * G + 11 * B ) / 65535

If the environment variable C<TERM_LUMINANCE> is defined, its value is
used as a luminance without calling sub-modules.  The value of
C<TERM_LUMINANCE> is expected in range of 0 to 100.

You can set C<TERM_LUMINANCE> in you start up file of shell, like:

    export TERM_LUMINANCE=`perl -MGetopt::EX::termcolor=luminance -e luminance`
    : ${TERM_LUMINANCE:=100}

=head1 MODULE FUNCTION

=over 7

=item B<bg>

Call this function with module option:

    $ command -Mtermcolor::bg=

If the terminal luminance is unkown, nothing happens.  Otherwise, the
module insert B<--light-terminal> or B<--dark-terminal> option
according to the luminance value.  These options are defined as
C$<move(0,0)> in this module and do nothing.  They can be overridden
by other module or user definition.

You can change the behavior of this module by calling C<&set> function
with module option.  It takes some parameters and they override
default values.

    threshold : threshold of light/dark  (default 50)
    default   : default luminance value  (default none)
    light     : light terminal option    (default "--light-terminal")
    dark      : dark terminal option     (default "--dark-terminal")

Use like this:

    option default \
        -Mtermcolor::bg(default=100,light=--light,dark=--dark)

=back

=head1 SEE ALSO

L<Getopt::EX>

L<Getopt::EX::termcolor::Apple_Terminal>

L<Getopt::EX::termcolor::iTerm>

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright (C) 2020 Kazumasa Utashiro.

You can redistribute it and/or modify it under the same terms
as Perl itself.

=cut

package Getopt::EX::termcolor;

use v5.14;
use strict;
use warnings;
use Data::Dumper;

our $VERSION = "1.02";

use Exporter 'import';
our @EXPORT      = qw();
our %EXPORT_TAGS = ();
our @EXPORT_OK   = qw(rgb_to_luminance rgb_to_brightness luminance);

#
# For backward compatibility.
#
sub rgb_to_brightness {
    goto &rgb_to_luminance;
}

sub rgb_to_luminance {
    my $opt = ref $_[0] ? shift : {};
    my $max = $opt->{max} || 65535;
    my($r, $g, $b) = @_;
    int(($r * 30 + $g * 59 + $b * 11) / $max); # 0 .. 100
}

my $mod;
my $argv;

sub initialize {
    ($mod, $argv) = @_;
    set_luminance();
}

our $debug = 0;

sub debug {
    $debug ^= 1;
}

sub set_luminance {
    if (defined $ENV{TERM_LUMINANCE}) {
	warn "TERM_LUMINANCE=$ENV{TERM_LUMINANCE}\n" if $debug;
	return;
    }
    if (defined $ENV{TERM_BRIGHTNESS}) {
	warn "TERM_BRIGHTNESS=$ENV{TERM_BRIGHTNESS}\n" if $debug;
	$ENV{TERM_LUMINANCE} = $ENV{TERM_BRIGHTNESS};
	return;
    }
    if (defined $ENV{BRIGHTNESS}) {
	warn "BRIGHTNESS=$ENV{BRIGHTNESS}\n" if $debug;
	$ENV{TERM_LUMINANCE} = $ENV{BRIGHTNESS};
	return;
    }
    my $brightness = get_luminance();
    $ENV{TERM_LUMINANCE} = $brightness // return;
}

sub get_luminance {
    if (my $term_program = $ENV{TERM_PROGRAM}) {
	warn "TERM_PROGRAM=$ENV{TERM_PROGRAM}\n" if $debug;
	my $submod = $term_program =~ s/\.app$//r;
	my $mod = __PACKAGE__ . "::$submod";
	my $get_color = "$mod\::get_color";
	if (eval "require $mod" and defined &$get_color) {
	    no strict 'refs';
	    my @rgb = $get_color->('background');
	    if (@rgb >= 3) {
		return rgb_to_luminance(@rgb);
	    }
	}
    }
    undef;
}

use List::Util qw(pairgrep);

#
# FOR BACKWARD COMPATIBILITY
# DEPELICATED IN THE FUTURE
#
sub set { goto &bg }

my %bg_param = (
    light => "--light-terminal",
    dark  => "--dark-terminal",
    default => undef,
    threshold => 50,
    );

sub bg {
    my %param =
	(%bg_param, pairgrep { exists $bg_param{$a} } @_);
    my $luminance =
	$ENV{TERM_LUMINANCE} // $param{default} // return;
    my $option = $luminance > $param{threshold} ?
	$param{light} : $param{dark};

#   $mod->setopt($option => '$<move(0,0)>');
    $mod->setopt(default => $option);
}

sub luminance {
    my $l = get_luminance() // return;
    say $l;
}

1;

__DATA__

#  LocalWords:  termcolor
