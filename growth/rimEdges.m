function [re,ei,ci] = rimEdges( m )
%re = rimEdges( m )
%   This returns information about the edges on the rim of the mesh.
%   re is an N*2 array of the vertex indexes of those edges.
%   ei is a list of the edge indexes.
%   ci is a list of the indexes of the cells they belong to.
%   For each pair of vertexes in ri, they are ordered consistently with
%   their ordering as vertexes of the corresponding cell.
%   The edges are listed in no particular order.

    reindexes = m.edgecells(:,2)==0;
    re = m.edgeends(reindexes,:);
    ce = m.edgecells(reindexes,1);
    s1 = (m.tricellvxs(ce,3)==re(:,1)) & (m.tricellvxs(ce,2)==re(:,2));
    s2 = (m.tricellvxs(ce,1)==re(:,1)) & (m.tricellvxs(ce,3)==re(:,2));
    s3 = (m.tricellvxs(ce,2)==re(:,1)) & (m.tricellvxs(ce,1)==re(:,2));
    s = s1 | s2 | s3;
    re(s,:) = re(s,[2 1]);
    if nargout >= 2
        ei = find(reindexes);
    end
    if nargout >= 3
        ci = m.edgecells(ei,1);
    end
end

