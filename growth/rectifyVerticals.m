function m = rectifyVerticals( m )
%m = rectifyVerticals( m )
%   Adjust the positions of the prism nodes on either side of each triangle
%   node, so that the line joining them is parallel to the average of the
%   cell normals of the adjoining cells.  The thickness of the mesh at each
%   point is left unchanged.
%
%   Not applicable to volumetric meshes.

    if isVolumetricMesh( m ), return; end

    numNodes = size(m.nodes,1);
    numCells = size(m.tricellvxs,1);
    nodeNormals = zeros( numNodes, 3 );
    nodeCellCounts = zeros(1,numNodes);
    for ci=1:numCells
        for ni=m.tricellvxs(ci,:)
            nodeCellCounts(ni) = nodeCellCounts(ni) + 1;
            nodeNormals(ni,:) = nodeNormals(ni,:) + m.unitcellnormals(ci,:);
        end
    end
    for ni=1:numNodes
        if nodeCellCounts(ni) > 0
            nn = nodeNormals(ni,:); % / nodeCellCounts(ni);
            nn = nn / norm(nn);
            pi = ni+ni;
            pn1 = m.prismnodes(pi-1,:);
            pn2 = m.prismnodes(pi,:);
            pmid = (pn1+pn2)/2;
            pnorm = (norm( pn1-pn2 )/2);
            pnorm = nn * pnorm;
            m.prismnodes(pi-1,:) = pmid - pnorm;
            m.prismnodes(pi,:) = pmid + pnorm;
        end
    end
end
