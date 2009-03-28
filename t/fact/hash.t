# Copyright (c) 2008 by Ricardo Signes. All rights reserved.
# Licensed under terms of Perl itself (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://dev.perl.org/licenses/

use strict;
use warnings;

use Test::More;
use Test::Exception;
use JSON;

use lib 't/lib';

plan tests => 11;

require_ok( 'FactSubclasses.pm' );

#--------------------------------------------------------------------------#
# fixtures
#--------------------------------------------------------------------------#    

my ($obj, $err);

my $struct = {
  first => 'alpha',
  second => 'beta',
};

my $meta = {
  size => [ Num => 2 ],
};

my $args = {
  resource => "JOHNDOE/Foo-Bar-1.23.tar.gz",
  content  => $struct,
};

my $as_struct = {
  resource          => $args->{resource},
  core_metadata     => {
    type           => [ Str => 'FactFour' ],
    schema_version => [ Num => 1 ],
  },
  content           => to_json($struct),
};

lives_ok{ $obj = FactFour->new( $args ) } 
    "new( <hashref> ) doesn't die";

isa_ok( $obj, 'CPAN::Metabase::Fact::Hash' ); 

lives_ok{ $obj = FactFour->new( %$args ) } 
    "new( <list> ) doesn't die";

isa_ok( $obj, 'CPAN::Metabase::Fact::Hash' );
is( $obj->type, "FactFour", "object type is correct" );

is( $obj->resource, $args->{resource}, "object refers to distribution" );
is_deeply( $obj->content_metadata, $meta, "object content_metadata() correct" );
is_deeply( $obj->content, $struct, "object content correct" );
is_deeply( $obj->as_struct, $as_struct, "object as_struct() correct"); 
# remove this? -- dagolden, 2009-03-28 
ok( ! $obj->is_submitted, "object is_submitted() is false" );

