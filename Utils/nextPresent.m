function i = nextPresent( i, retained )
%i = nextPresent( i, retained )
%   RETAINED is a list of booleans.  I is an index into that list.
%   If RETAINED(I) is true, I is returned.
%   Otherwise, the index of the first element of RETAINED after I is
%   returned, if any.
%   Otherwise, the index of the last element of RETAINED before I is
%   returned, if any.
%   Otherwise, 0 is returned.

    if retained(i)
        return;
    end
    
    j = find( retained( (i+1):end ), 1 );
    if ~isempty(j)
        i = i+j;
        return;
    end
    
    j = find( retained( (i-1):-1:1 ), 1 );
    if ~isempty(j)
        i = i-j;
        return;
    end

    i = 0;
end
