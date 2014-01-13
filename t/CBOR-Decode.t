# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl CBOR.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More;
BEGIN { use_ok('CBOR::Decode') }

# Array
my $val = eval { decode_cbor( pack( "C*", 0x82, 0x01, 0x82, 0x02, 0x03 ) ) };
is $@, '';
note explain $val;
is_deeply $val, [ 1, [ 2, 3 ] ];

# Ints
$val = eval { decode_cbor( pack( "CSCN", 0x19, 500, 0x1a, 32000 ) ) };
is $@, '' or exit;
note explain $val;
is_deeply $val, [ 500, 32000 ];

# Floats
$val = eval { decode_cbor( pack( "CfCd", 0xFA, 1.2222, 0xFB, 1.3333 ) ) };
is $@, '';
note explain $val;
is_deeply [ map { sprintf "%.4f", $_ } @$val ], [ 1.2222, 1.3333 ];

# Indefinite string
$val = eval {
    decode_cbor(
        pack(
            "C*", 0x5F, 0x43, 0x41, 0x42, 0x43, 0x42, 0x44, 0x45, 0x40, 0xFF
        )
    );
};
is $@, '';
note explain $val;
is $val, 'ABCDE';

# Indefinite array
$val = eval {
    decode_cbor(
        pack( "C*",
            0x9F, 0x02, 0x42, 0x41, 0x42, 0x9F, 0x01, 0x02, 0xFF, 0x05, 0xFF )
    );
};
is $@, '';
note explain $val;
is_deeply $val, [ 2, 'AB', [ 1, 2 ], 5 ];

# Indefinite Hash
$val = eval {
    decode_cbor(
        pack(
            "C*", 0xBF, 0x41, 0x41, 0xf7, 0x41, 0x42, 0x82, 0x01, 0x02, 0xFF
        )
    );
};
is $@, '';
note explain $val;
is_deeply $val, { 'A' => undef, 'B' => [ 1, 2 ] };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

done_testing;
