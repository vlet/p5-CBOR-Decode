use 5.016003;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'CBOR::Decode',
    VERSION_FROM => 'lib/CBOR/Decode.pm',
    PREREQ_PM    => { 'Encode' => 0, },
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            ABSTRACT =>
              'CBOR (RFC7049) format decoder in 100 lines of source code',
            AUTHOR => 'Vladimir Lettiev <crux@cpan.org>'
          )
        : ()
    ),
);
