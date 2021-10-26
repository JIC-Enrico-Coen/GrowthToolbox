function m = makeVertexConnections( m )
%m = makeVertexConnections( m )
%   Construct m.nodecelledges, given that all of trinodevxs, edgecells,
%   edgeends, and celledges are valid.
%
%   m.nodecelledges is a cell array indexed by vertexes.
%   m.nodecelledges{vi} is a list of all of the edges and cells contacting
%   vertex vi, listed in the same order as are the vertexes of each cell.
%   Edges and cells alternate; in the sequence e c e', e and e' are edges
%   of c.  Where there is no cell between e and e' (because they are on the
%   edge of the mesh, c is zero.  If the node is on an edge of the mesh,
%   m.nodecelledges{vi} begins with an edge on the edge of the mesh and
%   ends with zero.

    numnodes = size(m.nodes,1);
    numcells = size(m.tricellvxs,1);
    m.nodecelledges = cell( numnodes, 1 );
    numwedges = numel(m.tricellvxs);
    wedges = zeros( numwedges, 4 );
    wi = 0;
    for ci = 1:numcells
        wi = wi+3;
        wedges((wi-2):wi, : ) = ...
          [ m.tricellvxs(ci,:)', ...
            [ci; ci; ci], ...
            m.celledges(ci,[3 1 2])', ...
            m.celledges(ci,[2 3 1])' ];
    end
    wedges = sortrows( wedges );
    wi = 1;
    while wi <= numwedges
        wj = wi+1;
        while (wj <= numwedges) && (wedges(wj,1)==wedges(wi,1))
            wj = wj+1;
        end
        m.nodecelledges{wedges(wi,1)} = makechains( wedges( wi:(wj-1), [2 3 4] ) );
        wi = wj;
    end
    validateChains( m );
end

