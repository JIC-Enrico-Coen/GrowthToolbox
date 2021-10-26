function m = meshFromTriangles( m )
%m = meshFromTriangles( m )
%   Given a mesh of which the only fields known to exist are m.nodes and
%   m.tricellvxs, build all of the connectivity information:
%       m.celledges
%       m.edgecells
%       m.edgeends

    numvxs = size(m.nodes,1);
    numtriangles = size(m.tricellvxs,1);
    edgearray = zeros(numvxs);
    numedges = 0;
    maxedges = numvxs*(numvxs-1)/2;
    m.edgecells = zeros( maxedges, 2 );
    for ci=1:numtriangles
        v1 = m.tricellvxs(ci,1);
        v2 = m.tricellvxs(ci,2);
        v3 = m.tricellvxs(ci,3);
        if edgearray( v2, v3 )==0
            numedges = numedges+1;
            edgearray( v2, v3 ) = numedges;
            edgearray( v3, v2 ) = numedges;
        end
        if m.edgecells( numedges, 1 )
            eci = 2;
        else
            eci = 1;
        end
        m.edgecells( numedges, eci ) = ci;
        if edgearray( v3, v1 )==0
            numedges = numedges+1;
            edgearray( v3, v1 ) = numedges;
            edgearray( v1, v3 ) = numedges;
        end
        if m.edgecells( numedges, 1 )
            eci = 2;
        else
            eci = 1;
        end
        m.edgecells( numedges, eci ) = ci;
        if edgearray( v1, v2 )==0
            numedges = numedges+1;
            edgearray( v1, v2 ) = numedges;
            edgearray( v2, v1 ) = numedges;
        end
        if m.edgecells( numedges, 1 )
            eci = 2;
        else
            eci = 1;
        end
        m.edgecells( numedges, eci ) = ci;
        m.celledges(ci,:) = ...
            [ edgearray( v2, v3 ), edgearray( v3, v1 ), edgearray( v1, v2 ) ];
    end
    m.edgecells = m.edgecells( 1:numedges, : );
    for vi=1:numvxs
        if edgearray(vi,vi)
            fprintf( 1, 'Loop edge detected: edge %d from vertex %d to itself\n', ...
                edgearray(vi,vi), vi );
            edgearray(vi,vi) = 0;
        end
    end
    m.edgeends = zeros( numedges, 2 );
    for vi=1:numvxs-1
        for vj=vi+1:numvxs
            ei = edgearray(vi,vj);
            if ei
                m.edgeends( ei, : ) = [ vi, vj ];
            end
        end
    end
end

