function ok = checkarraysize( a, sz, emptyok, msg )
    complain = (nargin >= 3) && ~isempty(msg);
    ok = true;
    if isempty(a)
        if ~emptyok
            ok = false;
            if complain
                fprintf( 1, '%s: is empty where non-empty array is required.\n', ...
                    msg );
            end
        end
        return;
    end
    a_sz = size(a);
    if length(a_sz) ~= length(sz)
        ok = false;
        if complain
            fprintf( 1, '%s: %d-dimensional array expected, size is [%s ].\n', ...
                msg, length(sz), sprintf( ' %d', a_sz ) );
        end
        return;
    end
    bad_dims = (sz ~= -1) & (a_sz ~= sz);
    if any(bad_dims)
        ok = false;
        if complain
            for i=find(bad_dims)
                fprintf( 1, '%s: dimension %d has length %d, %d expected.\n', ...
                    msg, i, a_sz(i), sz(i) );
            end
        end
        return;
    end
end
