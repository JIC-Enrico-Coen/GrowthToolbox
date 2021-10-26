#!/usr/bin/perl -w

use warnings;
use strict;

my @x = glob( '../growth/commands/*.m' );
my $outputfile = "refall.tex";
open( STDOUT, ">$outputfile" );

foreach my $f ( @x ) {
    open( IN, "<$f" );
    my $gotheader = 0;
    while (<IN>) {
        if (s/^%//) {
            if (! $gotheader) {
                print "\\begin{verbatim}\n";
                $gotheader = 1;
            }
            print $_;
        } else {
            if ($gotheader) {
                print "\\end{verbatim}\n\n";
                last;
            } else {
                if (/^function\s+[A-Z_a-z0-9]+\s*=\s*([A-Z_a-z0-9]+)/) {
                    my $name = $1;
                    my $refname = $1;
                    $name =~ s/_/\\_/g;
                    $refname =~ s/_/-/g;
                    print "\\subsection{$name}\\label{section-$refname}\n\n";
                }
            }
        }
    }
    close( IN );
}

exit 0;
