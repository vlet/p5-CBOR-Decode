package CBOR::Decode;
use strict;
use warnings;
use Carp;
use Encode qw(decode_utf8);
require Exporter;

our @ISA     = qw( Exporter );
our @EXPORT  = qw( decode_cbor );

our $VERSION = '0.01';

sub decode_cbor {
    my $s = shift;
    my ($el) = decode_element( \$s );
    return $el unless length $s;
    my $ret = [$el];
    push @$ret, ( decode_element( \$s ) )[0] while length $s;
    return $ret;
}

sub indefinite {
    my ( $mt, $s ) = @_;
    my $res;
    if ( $mt == 2 || $mt == 3 ) {
        $res = '';
        while ( my ( $val, $type ) = decode_element($s) ) {
            croak "expected type $mt, got $type" if $type != $mt;
            $res .= $val;
        }
    }
    elsif ( $mt == 4 || $mt == 5 ) {
        $res = [];
        while ( my ( $val, $type ) = decode_element($s) ) {
            push @$res, $val;
        }
        $res = {@$res} if $mt == 5;
    }
    else {
        croak "wrong indefinite mt $mt";
    }
    return $res, $mt;
}

sub decode_element {
    my $s   = shift;
    my $ib  = unpack( 'C', substr $$s, 0, 1, '' );
    my $mt  = $ib >> 5;
    my $val = my $ai = $ib & 0x1f;
    if ( $ai == 24 ) {
        $val = unpack( 'C', substr $$s, 0, 1, '' );
    }
    elsif ( $ai == 25 ) {
        $val = unpack( 'S', substr $$s, 0, 2, '' );
    }
    elsif ( $ai == 26 ) {
        $val = unpack( $mt == 7 ? 'f' : 'N', substr $$s, 0, 4, '' );
    }
    elsif ( $ai == 27 ) {
        $val = unpack( $mt == 7 ? 'd' : 'Q', substr $$s, 0, 8, '' );
    }
    elsif ( $ai == 31 ) {
        return $mt == 7 ? () : indefinite( $mt, $s );
    }
    elsif ( $ai > 27 ) {
        croak "wrong ai $ai for mt $mt";
    }
    if ( $mt == 2 || $mt == 3 ) {
        $val = substr $$s, 0, $val, '';
        $val = decode_utf8($val) if $mt == 3;
    }
    elsif ( $mt == 4 || $mt == 5 ) {
        my $res = [];
        for my $i ( 1 .. ( $mt == 5 ? 2 * $val : $val ) ) {
            push @$res, ( decode_element($s) )[0];
        }
        $val = $mt == 5 ? {@$res} : $res;
    }
    elsif ( $mt == 6 ) {
        return decode_element($s);
    }
    elsif ( $mt == 7 && $ai < 26 ) {
        croak "16-bit float not implemented, sorry" if $ai == 25;
        if ( $val == 20 ) {
            $val = 0;
        }
        elsif ( $val == 21 ) {
            $val = 1;
        }
        elsif ( $val == 22 || $val == 23 ) {
            $val = undef;
        }
        else {
            croak "unknown simple value $val";
        }
    }
    return $val, $mt;
}

1;
