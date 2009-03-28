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

my $string = "Who am I?";

my $meta = {
  'length' => [ Num => length $string ],
};

my $args = {
    resource => "JOHNDOE/Foo-Bar-1.23.tar.gz",
    content  => $string,
};

my $as_struct = {
  resource          => $args->{resource},
  core_metadata     => {
    type           => [ Str => 'FactThree' ],
    schema_version => [ Num => 1 ],
  },
  content           => $string,
};

lives_ok{ $obj = FactThree->new( $args ) } 
    "new( <hashref> ) doesn't die";

isa_ok( $obj, 'CPAN::Metabase::Fact::String' ); 

lives_ok{ $obj = FactThree->new( %$args ) } 
    "new( <list> ) doesn't die";

isa_ok( $obj, 'CPAN::Metabase::Fact::String' );
is( $obj->type, "FactThree", "object type is correct" );

is( $obj->resource, $args->{resource}, "object refers to distribution" );
is_deeply( $obj->content_metadata, $meta, "object content_metadata() correct" );
is( $obj->content, $string, "object content correct" );
is_deeply( $obj->as_struct, $as_struct, "object as_struct() correct"); 
# remove this? -- dagolden, 2009-03-28 
ok( ! $obj->is_submitted, "object is_submitted() is false" );

