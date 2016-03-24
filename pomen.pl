#!/usr/bin/perl 

use strict;
no warnings;    # Disable experimental ewarnings

use POMEN::Cache;
use Term::ANSIColor;

use Data::Dumper;

my $cache = POMEN::Cache->new();

# Parse command line. Wothout getopts
if ( $ARGV[0] eq '/' ) {
    my $root = $cache->load_cache();

    for my $entry ( sort keys $root->{'/'} ) {
        print colored( "/", 'red' ) . colored( "$entry\n", "yellow" );
    }
}

if ( $ARGV[0] =~ '^/.+' ) {
    my $root = $cache->load_cache();

    my @entries = split /\//, $ARGV[0];
    if ( @entries == 2 ) {
        print colored( "/", 'red' ) . colored( $entries[1] . "\n", "yellow" );
        for my $entry ( sort keys $root->{'/'}->{ $entries[1] } ) {
            print colored( "\t/",    'red' )
                . colored( "$entry", 'green' )
                . colored( "/\n",    'red' );
        }
    }
    elsif ( @entries > 2 ) {
        print colored( "/",         'red' )
            . colored( $entries[1], "yellow" )
            . colored( "/\n",       'red' );
        print colored( "\t" . $entries[2], 'green' )
            . colored( "/\n",              'red' );

        foreach
            my $app ( @{ $root->{'/'}->{ $entries[1] }->{ $entries[2] } } )
        {
            for my $name ( sort keys $app ) {
                print colored( "\t\t$name", "white" );
                print colored( "\t" . $app->{$name}->{Exec} . "\n",
                    "magenta" );
            }
        }
    }
}

if ( $ARGV[0] eq 'makecache' ) {
    $cache->make_cache();
}

