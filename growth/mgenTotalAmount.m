function result = mgenTotalAmount( m, mgen )
%result = mgenTotalAmount( m, mgen )
%   Calculate the total amount of a morphogen.  Morphogen values are
%   understood as concentration per unit area.  The total amount in a
%   single finite element is the area of that element multiplied by the
%   average of the morphogen values at its vertexes.  The sum of these
%   over all finite elements is the result of this procedure.
%
%   The morphogen can be specified either as an index or a name.  It is
%   also possible to specify a vector of values, one per vertex of the
%   triangle mesh, instead of a morphogen.
%
%   Multiple morphogens can be specified.  In this case, they must be
%   either all indexes, or all names, or an N*K array of values where N is
%   the number of vertexes and K is the number of morphogens.
%
%   See also:
%       mgenTotalLength, mgenTotalArea.

    if ~ischar(mgen) && (size(mgen,1)==size(m.morphogens,1))
        val = mgen;
    else
        mgen = FindMorphogenIndex( m, mgen );
        if isempty(mgen)
            result = 0;
            return;
        end
        val = m.morphogens(:,mgen);
    end
    
    result = zeros(1,size(val,2));
    for i=1:size(val,2)
        result(i) = sum( sum( reshape( val( m.tricellvxs, i ), ...
                                       size( m.tricellvxs ) ), ...
                              2 ) ...
                         .* m.cellareas ) ...
                    / size( m.tricellvxs, 2 );
    end
end
