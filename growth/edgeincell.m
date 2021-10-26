function cei = edgeincell( m, ci, ei )
%cei = edgeincell( m, ci, ei )
%   Return the index of edge ei in cell ci of m.  If ei is not an edge os
%   ci, return zero.  ci and ei can be vectors of the same length.

    cei = zeros( size(ci) );
    for i=1:length(ci)
        if ci(i)
            cei1 = find( m.celledges(ci(i),:)==ei(i) );
            if cei1
                cei(i) = cei1;
            end
        end
    end
end
