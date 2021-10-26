function edges = borderedges( m, cellmap )
%edges = borderedges( m, cellmap )
%   M is a mesh.  CELLMAP is a boolean map of cells.
%   All of the border edges of the set of cells are found, that
%   is, every edge which has one of the given cells on exactly one side.
%   The set of edges is returned as an array of edge indexes.  If you need
%   a boolean map, call borderedgemap( m, cells );
%
%   See also: borderedgemap

    if nargin < 2
        cellmap = true(1, size(m.tricellvxs,1));
    end
    edges = find( borderedgemap( m, cellmap ) );
end
