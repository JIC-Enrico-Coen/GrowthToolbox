function s = makeedgedata( s )
%s = makeedgedata( s )
%   Given a second layer s containing just the cell vertex index data,
%   construct the cell edge data.

% The second layer contains the following information:
% For each clone cell ci:
%       cells(ci).vxs(:)       A list of all its vertexes, in clockwise order.
%       cells(ci).edges(:)     A list of all its edges, in clockwise order.
% For each clone edge ei:
%       edges(ei,1:4)          The indexes of the clone vertexes at its ends
%           and the clone cells on either side (the second one is 0 if absent).
%           This can be computed from the other data.

    numcells = size( s.cells, 1 );
    maxedges = 0;
    for ci=1:numcells
        maxedges = maxedges + length( s.cells(ci).vxs );
    end
    edgevxs = zeros( maxedges, 2 );
    edgecells = zeros( maxedges, 1 );
    ei = 0;
    for ci=1:numcells
        numedgesthiscell = length( s.cells(i).vxs );
        edgevxs( ei+1:ei+numedgesthiscell,[1 2] ) = ...
            sort( ...
                [ s.cells(i).vxs', ...
                  s.cells(i).vxs([(2:numedgesthiscell),1])' ], ...
                2 );
        s.cells(ci).edges = ei+1:ei+numedgesthiscell;
        edgecells( ei+1:ei+numedgesthiscell ) = ci;
        ei = ei + numedgesthiscell;
    end
    edgehashes = edgevxs(:,1) * maxedges + edgevxs(:,2);
    [e,i,j] = unique( edgehashes );
    
end
