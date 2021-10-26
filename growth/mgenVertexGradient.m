function g = mgenVertexGradient( m, mgen )
%g = mgenVertexGradient( m, mi )
%   For a mesh m, and morphogen field mgen defined at each vertex of m,
%   compute the gradient of mgen for each vertex.

    cg = mgenCellGradient( m, mgen );
    
    % Why not use FEtoFEVertex for the rest of this?
    numnodes = size(m.nodes,1);
    g = zeros(numnodes,3);
    for i=1:numnodes
        nce = m.nodecelledges{i};
        cellnbs = nce(2,:);
        cellnbs = cellnbs(cellnbs ~= 0);
        areanbs = m.cellareas( cellnbs );
        g(i,:) = sum(repmat(areanbs,1,size(cg,2)) .* cg(cellnbs,:),1)/sum(areanbs);
    end
end

