function valid = testfeapfile(filename)
%valid = testfeapfile(filename)  Load the FEAP file and check its validity.

    param.foo = 1;
    feapstart( filename, param );
    valid = feapcmd('check');
    if valid
        fprintf( 1, 'feapcheck passed.\n' );
    else
        fprintf( 1, 'feapcheck failed.\n' );
    end
    feapcmd('quit','n');
end
