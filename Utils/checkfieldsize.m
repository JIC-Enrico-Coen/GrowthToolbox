function errs = checkfieldsize( s, field, data, sz1, sz2 )
%errs = checkfieldsize( s, field, data, sz1, sz2 )
%   Check that S.(FIELD)

    errs = 0;
    if isempty(data)
        if isfield( s, field )
            data = s.(field);
        else
            errs = errs+1;
            % Error.
            return;
        end
    end
    sz = size( data );
    if length(sz) > 2
        errs = errs+1;
        timedFprintf( 1, 2, 'Field %s has %d dimensions, expect 2.\n', field, length(sz) );
    end
    if sz1 ~= sz(1)
        % error
        errs = errs+1;
        timedFprintf( 1, 2, 'Field %s has %d rows, expect %d.\n', field, sz1, sz(1) );
    end
    if (sz2 ~= 0) && (sz2 ~= sz(2))
        % error
        errs = errs+1;
        timedFprintf( 1, 2, 'Field %s has %d columns, expect %d.\n', field, sz2, sz(2) );
    end
end
