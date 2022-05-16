function ok = validRaggedArray( ra, nullvalue, msg )
%ok = validRaggedArray( ra, nullvalue )
%   A ragged array is valid if no occurrence of the null value in any row
%   precedes an occurrence of a non-null value in the same row.
%
%   NULLVALUE defaults to NaN if RA is floating-point, and otherwise to 0.
%
%   If MSG is given and is nonempty, its will be printed if there are
%   any invalid rows, together with the number of bad rows.

    switch nargin
        case 1
            defaultnull = true;
            msg = '';
        case 2
            if ischar(nullvalue)
                defaultnull = true;
                msg = nullvalue;
            else
                defaultnull = false;
                msg = '';
            end
        otherwise
            defaultnull = false;
    end
                
    if defaultnull
        if isfloat(ra)
            nullvalue = NaN;
        else
            nullvalue = 0;
        end
    end
    
    if isnan(nullvalue)
        % NaN cannot be compared for equality.
        isnull = isnan(ra);
    else
        isnull = ra==nullvalue;
    end
    
    badrows = any( isnull(:,1:(end-1)) > isnull(:,2:end) , 2 );
    ok = ~any(badrows);
    if ~ok && ~isempty(msg)
        fprintf( 1, '%s: %d invalid rows\n', msg, sum(badrows) );
    end
end
