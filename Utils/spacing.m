function spacing( f, n )
%spacing( f, n )
%   Print n spaces to file id f.
    fprintf( f, '%*s', n, '' );
end
