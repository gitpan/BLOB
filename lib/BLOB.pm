package BLOB;
use strict;
use Carp qw(carp);

our $VERSION = '1.00';

# Fallback for pre-5.8 Perl versions
*utf8::downgrade = sub { 1 } if not defined &utf8::downgrade;

sub mark {
    my $class = shift;
    my $blob_ref = \shift;
    if (not utf8::downgrade($$blob_ref, 1)) {
        carp "Wide character outside byte range in BLOB, encoding data with UTF-8";
        utf8::encode($$blob_ref);
    }
    bless $blob_ref, $class;
}

use base 'Exporter';
our @EXPORT = qw(is_blob);

sub is_blob {
    my $blob_ref = \shift;
    return undef if not eval { $blob_ref->isa('BLOB') };
    if (not utf8::downgrade($$blob_ref, 1)) {
        carp "Wide character outside byte range in BLOB, encoding data with UTF-8";
        utf8::encode($$blob_ref);
    }
    return 1;
}

1;

__END__

=head1 NAME

BLOB - Perl extension for explicitly marking binary strings

=head1 SYNOPSIS

    use BLOB;

    BLOB->mark($jpeg_data);
    print is_blob($jpeg_data);  # 1

    my $bytes = is_blob($foo) ? $foo : encode_utf8($foo);

=head1 DESCRIPTION

In general it is better if text operations and binary operations are separated
into different functions.

But sometimes a single function needs to support both text strings and binary
strings. Because the two string types are fundamentally different, it may be
necessary for the function to know what it is dealing with.

This package aims to be B<the> single way of indicating that a string is
binary, not text. Now CPAN module authors don't have to reinvent this wheel,
and module users do not have to learn a plethora of different syntaxes.

The name F<BLOB> historically stands for Binary Large OBject, but small strings
are of course also supported.

BLOB supports Perl versions all the way back to 5.000 and has no external
dependencies.

=head1 FUNCTIONS

The following functions are provided by this module:

=over 4

=item BLOB->mark($string)

Marks the string as a blob. The string can be used as before; it should be safe
to mark strings as blobs in existing code.

Note that a copy of a blob is not marked automatically.

=item is_blob($string)

Returns true if the string is a blob, false if the string is not a blob.

Exported by default.

=back

=head1 PROGRAMMING LOGIC ERRORS

Byte operations should be separated from text operations in programming, with
only explicit conversion (through decoding and encoding) allowed between them.

Perl programmers who fail to do this, might end up with characters greater than
255 in their byte strings. Because a byte can only store a value in the 0..255
range, a string with a character greater than 255 cannot be used as a byte
string.

Also, for efficiency and compatibility with older Perl modules, the functions
provided by this module downgrade strings to ensure that the internal
representation is a raw octet sequence.

=head1 DIAGNOSTICS

This module can produce the following warnings:

=over 4

=item Wide character outside byte range in BLOB, encoding data with UTF-8

A string with at least one character greater than 255 was marked as BLOB.
Because a byte cannot hold a value greater than 255, the string was changed to
its UTF-8 encoding to allow further binary data processing.

Find out why this character got into this string, and repair the programming
logic error.

=back

If the warning is reported in the module you are using, set $Carp::Verbose = 1
for a stack trace.

=head1 CAVEATS

Marking as a BLOB is done by blessing the string. Do not bless the string
again. Blessing existing binary strings is extremely uncommon, but not
impossible.

=head1 TO DO

It would be nice if BLOB would intercept internal string encoding upgrades, and
downgrade immediately. This would allow a warning to be emitted at the point
where the source of the problem is, making debugging unintended text+binary
concatenations easier.

=head1 AUTHOR

Juerd Waalboer <#####@juerd.nl>

=cut
