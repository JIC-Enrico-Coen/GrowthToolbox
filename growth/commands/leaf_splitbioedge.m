function m = splitBioEdge( m, ei )
%m = splitBioEdge( m, ei )
%   Split the bio edge ei into two parallel edges.
%   There are various special cases to be considered.
%   Maybe we can reduce the special cases if we require that this only be
%   applied to edges, each of whose ends is a border edge (typically an
%   internal air space).

% TO BE IMPLEMENTED.

    % If the whole edge is a border edge then we do nothing.
    % Otherwise the edge has a cell on each side.
    % We need to duplicate the edge and the vertexes at its ends.
    % One cell gets the old edge and its vertexes, the other the new.
    % We need to update the edge data for the edges incident on this edge,
    % of which there should be exactly two at each end, belonging to the
    % two cells.
    % The edges need to be moved apart from each other.
end
