function ok = checksize( expectedsize, actualsize, msg, complainer )
    numdims = min( length(expectedsize), length(actualsize) );
    ok = all( expectedsize((numdims+1):end)==1 );
    ok = ok && all( actualsize((numdims+1):end)==1 );
    ok = ok && all(expectedsize(1:numdims) == actualsize(1:numdims));
    if ~ok
        complainer( ['validmesh:bad ', msg], ...
            '%s: Expected %s, found %s.', ...
            msg, sprintf( ' %d', expectedsize ), sprintf( ' %d', actualsize ) );
    end
end

