#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

use_ok 'Bot::BasicBot::Pluggable::Module::DateTimeCalc';

my $obj = eval { Bot::BasicBot::Pluggable::Module::DateTimeCalc->new };
isa_ok $obj, 'Bot::BasicBot::Pluggable::Module::DateTimeCalc';
ok !$@, 'created with no arguments';
my $x = $obj->{foo};
is $x, 'bar', "foo: $x";

$obj = Bot::BasicBot::Pluggable::Module::DateTimeCalc->new(
    foo => 'Zap!',
);
$x = $obj->{foo};
like $x, qr/zap/i, "foo: $x";

done_testing();
