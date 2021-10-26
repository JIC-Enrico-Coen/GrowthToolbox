function m = splitSeams( m )
%m = splitSeams( m )
%   Split the mesh along its seams.
%   Each vertex on the seam gets S-E new copies, where S is the number
%   of seam edges it lies on and E is 0 for vertexes on the edge of the
%   mesh and 1 elsewhere.  Each seam edge becomes two edges, except for
%   seam edges, both of whose ends fail to split.  Those seam edges don't
%   split at all and should be removed from the seams.

% First, split the edges.  Each edge that is split belongs to two cells.
% Assign the old edge to the first cell and the new edge to the second.
% This means updating m.edgecells and m.celledges.

% Second, split the vertexes.  For this we need to compute the list of
% cells and edges in order around the node.  When we divide the list of
% edges at the seam edges, we get a set of connected components.  Assign
% the old vertex to the first of these and the new vertexes to the
% remainder.  Update tricellvxs for every cell, and update edgeends for
% those cells' edges.

% Thirdly, duplicate all per-vertex information:
%   morphogens
%   fixed degrees of freedom

% Finally, validate the mesh.
end
