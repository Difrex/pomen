package POMEN::Cache;

use File::DesktopEntry;
use Term::ANSIColor;
use Storable;

no warnings; # Disable experimental ewarnings

sub new {
    my $class = shift;

    my $stor  = $ENV{HOME} . "/.local/cache/pomen";
    my $cache = $stor . "/cache.pomen";

    my $self = {
        stor  => $stor,
        cache => $cache,
        apps  => '/usr/share/applications'
    };
    bless $self, $class;

    return $self;
}

# Make cache
sub make_cache {
    my ($self) = @_;
    my $apps = $self->{apps};

    check($self);

    my @apps;
    opendir my $dh, $apps or die "$!\n";
    while ( my $file = readdir($dh) ) {
        if (   ( $file =~ /^\.$/ )
            or ( $file =~ /^\.\.$/ ) )
        {
            next;
        }

        if ( $file =~ /.+\.desktop$/ ) {
            my @app_name = split /\.desktop/, $file;
            push @apps, $app_name[0];
        }
    }
    closedir $dh;

    my $root = { '/' => {} };

    for my $a (@apps) {
        my $entry = File::DesktopEntry->new($a);

        eval {
            my $get        = $entry->get('Categories');
            my $name       = $entry->get('Name');
            my $exec       = $entry->get('Exec');
            my @categories = split ';', $get;

            my $app->{$name} = { 'Exec' => $exec };

            if ( $categories[1] ) {
                if (ref($root->{'/'}->{ $categories[0] }->{ $categories[1] }
                    ) eq 'ARRAY'
                    )
                {
                    push $root->{'/'}->{ $categories[0] }->{ $categories[1] },
                        $app;
                }
                else {
                    $root->{'/'}->{ $categories[0] }->{ $categories[1] } = [];
                    push $root->{'/'}->{ $categories[0] }->{ $categories[1] },
                        $app;
                }

            }
        };
        if ($@) {
            next;
        }
    }

    store_cache( $self, $root );
}

# Load cache
sub load_cache {
    my ($self) = @_;

    my $cache = retrieve( $self->{cache} );

    return $cache;
}

# Store cache
sub store_cache {
    my ( $self, $cache ) = @_;

    my %c = %$cache;

    store( \%c, $self->{cache} );
}

# Check files and dirs
sub check {
    my $self = shift;

    # Create cache dir
    if ( !( -d $self->{stor} ) ) {
        my @mk_cmd = ( 'mkdir', '-p', $self->{stor} );
        system(@mk_cmd) == 0
            or die "Cannot create " . $self->{stor} . ": $!\n";
        print colored( $self->{stor}, 'green' );
    }

    # Create initial
    if ( !( -f $self->{cache} ) ) {
        open my $f, '>', $self->{cache}
            or die "Cannot open " . $self->{cache} . " for write: $!\n";
        print $f '';
        close $f;

        my $cache = {};
        my %c     = %$cache;
        store( \%$c, $self->{cache} );
        print colored( $self->{cache}, 'yellow' );
    }
}

1;
