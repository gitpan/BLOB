# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl BLOB.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 7;
BEGIN { use_ok('BLOB') };

ok(BLOB->mark(my $foo));
ok(is_blob($foo));

ok(!is_blob(my $bar));
ok(!is_blob(undef));
ok(!is_blob(0));
ok(!is_blob(""));
#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

