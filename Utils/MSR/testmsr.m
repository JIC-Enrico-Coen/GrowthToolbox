function testmsr( filename )
    [r,e] = msrfilereader( filename );
    [p,f,ext] = fileparts( filename );
    filename2 = fullfile( p, [f '_1', ext] );
    msrfilewriter( filename2, r );
    fprintf( 1, 'Differences in first pass:\n' );
    system( [ 'diff -b ', filename, ' ', filename2 ] );
    [r,e] = msrfilereader( filename2 );
    filename3 = fullfile( p, [f '_2', ext] );
    msrfilewriter( filename3, r );
    fprintf( 1, 'Differences in second pass:\n' );
    system( [ 'diff ', filename2, ' ', filename3 ] );
end
