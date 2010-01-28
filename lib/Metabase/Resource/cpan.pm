package Metabase::Resource::cpan;
use 5.006;
use strict;
use warnings;
use Carp ();
use CPAN::DistnameInfo ();

our $VERSION = '0.001';
$VERSION = eval $VERSION;

use Metabase::Resource;
our @ISA = qw(Metabase::Resource);

sub validate {
  my ($self) = @_;
  my $scheme = $self->scheme;
  my $content = $self->content;
  my ($type, $string) = $content =~ m{\A$scheme:///([^/]+)/(.+)\z};
  unless ( defined $type && length $type ) {
    Carp::confess("Could not determine $scheme subtype from '$content'")
  }
  $self->_cache->{type} = $type;
  my $method = "_validate_$type";
  if ( $self->can($method) ) {
    $self->$method($string);
  }
  else {
    Carp::confess("Unknown $scheme subtype '$type' in '$content'");
  }
  return 1;
}


# XXX should really validate AUTHOR/DISTNAME-DISTVERSION.SUFFIX 
# -- dagolden, 2010-01-27
#
# my $suffix = qr{\.(?:tar\.(?:bz2|gz|Z)|t(?:gz|bz)|zip)};
#
# for now, we'll use CPAN::DistnameInfo;
#

# map DistnameInfo calls to our names
my %distfile_map = (
  cpanid  => 'cpan_id',
  dist    => 'dist_name',
  version => 'dist_version',
);

sub _validate_distfile {
  my ($self, $string) = @_;
  my $d = eval { CPAN::DistnameInfo($string) };
  my $bad = defined $d ? 0 : 1;

  $self->_cache->{dist_file} = $string;

  for my $k ( keys %distfile_map ) {
    my $value = $d->$k;
    defined $value or $bad++ and last;
    $self->_cache->{$distfile_map{$k}} = $value
  }

  if ($bad) {
    Carp::confess("'$string' can't be parsed as a CPAN distfile");
  }
  return 1;
}

my %metadata_types = (
  user => {
    cpan_id       => '//str',
    dist_file     => '//str',
    dist_name     => '//str',
    dist_version  => '//str',
  },
);

sub metadata_types {
  my ($self) = @_;
  return {
    scheme  => '//str',
    type    => '//str',
    %{ $metadata_types{ $self->_cache->{type} } },
  };
}

sub metadata {
  my ($self) = @_;
  my $type = $self->_cache->{type};
  my $method = "_metadata_$type";
  return {
    scheme  => $self->scheme,
    type    => $type,
    %{ $self->$method },
  };
}

sub _metadata_distfile {
  my ($self) = @_;
  return {
    cpan_id       => $self->_cache->{cpan_id},
    dist_file     => $self->_cache->{dist_file},
    dist_name     => $self->_cache->{dist_name},
    dist_version  => $self->_cache->{dist_version},
  };
}

1;

__END__

=head1 NAME

Metabase::Resource::metabase - class for Metabase resources

=head1 SYNOPSIS

  my $resource = Metabase::Resource->new(
    'cpan:///distfile/RJBS/Metabase-Fact-0.001.tar.gz',
  );

  my $resource_meta = $resource->metadata;
  my $typemap       = $resource->metadata_types;

=head1 DESCRIPTION

Generates resource metadata for resources of the scheme 'cpan'.

The L<Metabase::Resource::cpan> class supports the followng sub-type(s).

=head2 distfile

  my $resource = Metabase::Resource->new(
    'cpan:///distfile/RJBS/URI-cpan-1.000.tar.gz',
  );

For the example above, the resource metadata structure would contain the
following elements:

  scheme       => cpan
  type         => distfile
  dist_file    => RJBS/URI-cpan-1.000.tar.gz
  cpan_id      => RJBS
  dist_name    => URI-cpan
  dist_version => 1.000

=head1 BUGS

Please report any bugs or feature using the CPAN Request Tracker.
Bugs can be submitted through the web interface at
L<http://rt.cpan.org/Dist/Display.html?Queue=Metabase-Fact>

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

=head1 AUTHOR

Primary Authors and other Contributors are listed below:

  * David A. Golden (DAGOLDEN)
  * Ricardo Signes  (RJBS)

=head1 COPYRIGHT AND LICENSE

  Copyright (c) 2010 by David A. Golden, Ricardo Signes and Contributors

Licensed under the same terms as Perl itself (the "License").
You may not use this file except in compliance with the License.
A copy of the License was distributed with this file or you may obtain a
copy of the License from http://dev.perl.org/licenses/

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

