function m = addCell( m, a, b, c )
%m = addCell( m, a, b, c )
%   Add to m a cell whose corners are the existing vertexes a, b, and c.
%   No error checking is done; it is assumed that the operation is
%   sensible.  a and b, and a and c, are assumed to be connected by edges,
%   and b-a-c is assumed to be the positive orientation.

    numcells = size(m.tricellvxs,1);
    numedges = size(m.edgeends,1);
    m.tricellvxs(numcells+1,:) = [a b c];
    eab = findedge( m, a, b );
    eac = findedge( m, a, c );
    cab = m.edgecells(eab,1);
    cac = m.edgecells(eac,1);
    m.celledges(numcells+1,:) = [ numedges+1, eab, eab ];
    m.edgecells(numedges+1,:) = [ numcells+1, 0 ];
    m.edgecells([eab eac],2) = numcells+1;
    m.edgeends(numedges+1,:) = [b c];
    % Add 3d stuff, morphogens, etc.
end

function m = XaddCell( m, a, b, c )
%m = addCell( m, a, b, c )
%   Add to m a cell whose corners are the existing vertexes a, b, and c.
%   If this would make the mesh non-orientable, the cell is not added.

    numcells = size(m.tricellvxs,1);
    numedges = size(m.edgeends,1);
    aedges = findfoo1( m.edgeends, a )
    abedges = findfoo2( m.edgeends, aedges, b )
    acedges = findfoo2( m.edgeends, aedges, c )
    bedges = findfoo1( m.edgeends, b )
    bcedges = findfoo2( m.edgeends, bedges, c )
    if ~all(sort( [ length(abedges), length(acedges), length(bcedges) ] )==[0 1 1])
        fprintf( 1, 'No such cell can be made.\n' );
        return;
    end
    
end

function e = findedge( m, a, b )
%e = findedge( m, a, b )
%   Find the edge whose endpoints are a and b.  Returns 0 if no such edge.
    aedges = findfoo1( m.edgeends, a )
    abedges = findfoo2( m.edgeends, aedges, b )
    if isempty(abedges)
        e = 0;
    else
        e = abedges(1);
    end
end

function r = findfoo1( array, a )
    r = mod( find(array==a)-1, size(array,1) )+1;
end

function r = findfoo2( array, subrange, a )
    x = find(array(subrange,:)==a);
    y = mod( x-1, length(subrange) )+1;
    r = subrange( y );
end
