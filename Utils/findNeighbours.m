function [nbvxs,nbedges] = findNeighbours( edgevxs, nv )
%nbs = findNeighbours( edgevxs, nv )
% EDGEVXS is an N*2 array of indexes in the range 1:NV.
% NV defaults to max(EDGEVXS(:)).
%
%   NBVXS is an NV*1 cell array listing for each index in the range 1:NV, its
%   neighbours in EDGEVXS, i.e. the other indexes in the rows that the
%   index appears in.
%
%   NBEDGES is a array similarly listing the edges corresponding to the
%   neighbour vertexes.
%
%   The orderings of these are consistent, i.e. the edge NBEDGES{vi}(ni)
%   joins vertex vi to vertex NBVXS{vi}(ni) (in one order or the other).

    if nargin<2
        nv = max(edgevxs(:));
    end
    biedgevxs = sortrows( [ [ edgevxs; edgevxs(:,[2 1]) ], repmat( (1:size(edgevxs,1))', 2, 1 ) ] );
    [starts,ends] = runends( biedgevxs(:,1) );
    nbvxs = cell( nv, 1 );
    nbedges = cell( nv, 1 );
    for i=1:length(starts)
        s = starts(i);
        e = ends(i);
        nbvxs{ biedgevxs(s,1) } = biedgevxs(s:e,2);
        nbedges{ biedgevxs(s,1) } = biedgevxs(s:e,3);
    end
end
