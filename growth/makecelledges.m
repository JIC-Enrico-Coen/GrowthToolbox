function m = makecelledges( m )
%m = makecelledges( m )
%   Reconstruct the edgecells array, assuming that all the
%   other connectivity information is valid.

    numcells = size( m.tricellvxs, 1 );
    m.edgecells = zeros( size(m.edgeends,1), 2 );
    for ci = 1:numcells
        for ei = m.celledges( ci, : )
            if m.edgecells(ei,1)==0
                eci = 1;
            else
                eci = 2;
            end
            m.edgecells( ei, eci ) = ci;
       end
    end
end
