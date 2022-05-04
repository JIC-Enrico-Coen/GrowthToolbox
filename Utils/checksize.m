function ok = checksize( expectedsize, actualsize, msg, severity )
    if nargin < 4
        severity = 0;
    end
    numdims = min( length(expectedsize), length(actualsize) );
    ok = all( expectedsize((numdims+1):end)==1 );
    ok = ok && all( actualsize((numdims+1):end)==1 );
    ok = ok && all(expectedsize(1:numdims) == actualsize(1:numdims));
    if ~ok
        complain2( severity, ...
            '%s: Expected %s, found %s.', ...
            msg, sprintf( ' %d', expectedsize ), sprintf( ' %d', actualsize ) );
    end
end

