function [l,r] = lobeedges( nrings, nrows )
%[l,r] = lobeedges( nrings, nrows )
% Return two column vectors containing the indexes of the nodes on the left
% and right edge of the rectangular part of a lobe mesh.

    nodesPerSeg = nrings*(nrings+1)/2;
    semicirclenumnodes = nodesPerSeg*3 + 1 + nrings;
    extrarectnodes = (nrings+nrings+1)*nrows;
    totalnumnodes = semicirclenumnodes + extrarectnodes;
    part_r = ((totalnumnodes - (nrows-1)*(nrings+nrings+1)) : ...
          (nrings+nrings+1) : ...
          totalnumnodes)';
    l = [ semicirclenumnodes-1; part_r - (nrings+nrings) ];
    r = [ nrings; part_r ];
end
