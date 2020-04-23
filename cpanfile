requires 'perl', '5.014';

requires 'List::Util', '1.45';
requires 'Term::ReadKey';
requires 'Getopt::EX', 'v1.16.0';
requires 'App::sdif', '4.13.7';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

