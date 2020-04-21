# NAME

Getopt::EX::termcolor - Getopt::EX termcolor module

# VERSION

Version 1.02

# SYNOPSIS

    use Getopt::EX::Loader;
    my $rcloader = new Getopt::EX::Loader
        BASECLASS => [ 'App::command', 'Getopt::EX' ];

    or

    use Getopt::EX::Long qw(:DEFAULT ExConfigure);
    ExConfigure BASECLASS => [ "App::command", "Getopt::EX" ];

    then

    $ command -Mtermcolor::bg=

# DESCRIPTION

This is a common module for command using [Getopt::EX](https://metacpan.org/pod/Getopt::EX) to manipulate
system dependent terminal color.

Actual action is done by sub-module under [Getopt::EX::termcolor](https://metacpan.org/pod/Getopt::EX::termcolor),
such as [Getopt::EX::termcolor::Apple\_Terminal](https://metacpan.org/pod/Getopt::EX::termcolor::Apple_Terminal).

Each sub-module is expected to have `&get_color` function which
returns RGB value list between 0 and 65535.  If the sub-module was
found and `&get_color` function exists, its result with `background`
parameter is taken as a background color of the terminal.

Luminance is caliculated from RGB values by this equation and produces
decimal value from 0 to 100.

    ( 30 * R + 59 * G + 11 * B ) / 65535

If the environment variable `TERM_LUMINANCE` is defined, its value is
used as a luminance without calling sub-modules.  The value of
`TERM_LUMINANCE` is expected in range of 0 to 100.

You can set `TERM_LUMINANCE` in you start up file of shell, like:

    export TERM_LUMINANCE=`perl -MGetopt::EX::termcolor=luminance -e luminance`
    : ${TERM_LUMINANCE:=100}

# MODULE FUNCTION

- **bg**

    Call this function with module option:

        $ command -Mtermcolor::bg=

    If the terminal luminance is unkown, nothing happens.  Otherwise, the
    module insert **--light-terminal** or **--dark-terminal** option
    according to the luminance value.  These options are defined as
    C$<move(0,0)> in this module and do nothing.  They can be overridden
    by other module or user definition.

    You can change the behavior of this module by calling `&set` function
    with module option.  It takes some parameters and they override
    default values.

        threshold : threshold of light/dark  (default 50)
        default   : default luminance value  (default none)
        light     : light terminal option    (default "--light-terminal")
        dark      : dark terminal option     (default "--dark-terminal")

    Use like this:

        option default \
            -Mtermcolor::bg(default=100,light=--light,dark=--dark)

# SEE ALSO

[Getopt::EX](https://metacpan.org/pod/Getopt::EX)

[Getopt::EX::termcolor::Apple\_Terminal](https://metacpan.org/pod/Getopt::EX::termcolor::Apple_Terminal)

[Getopt::EX::termcolor::iTerm](https://metacpan.org/pod/Getopt::EX::termcolor::iTerm)

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright (C) 2020 Kazumasa Utashiro.

You can redistribute it and/or modify it under the same terms
as Perl itself.
