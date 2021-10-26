function perFE = ConvertCellFactorToElementFactor( m, perCell )
%perFE = ConvertCellFactorToElementFactor( m, perCell )
%   Convert a value per biological cell to a value per finite element.
%
%   This only applies to foliate meshes having a biological layer.  Other
%   meshes return a value that is everywhere zero.
%
%   See also: perCellToperFEVertex, perCellToperFEVertex2.

    if isVolumetricMesh(m) || ~hasNonemptySecondLayer(m)
        perFE = zeros( getNumberOfFEs(m), 1 );
        return;
    end
    
    perCellVx = perCellToPerCellVertex( m, perCell );
    
    numFEs = getNumberOfFEs(m);
    perFE = zeros( numFEs, 1 );
    numPerFE = zeros( numFEs, 1 );
    for i=1:length(m.secondlayer.vxFEMcell)
        fei = m.secondlayer.vxFEMcell(i);
        perFE(fei) = perFE(fei) + perCellVx(i);
        numPerFE(fei) = numPerFE(fei)+1;
    end
    
    perFE = perFE ./ numPerFE;
    
    missingFEs = find(numPerFE==0);
    for i=missingFEs(:)'
        cells = findCellForPoint( m, m.nodes(m.tricellvxs(i,:),:) );
        perFE(i) = mean(perCell( cells ));
    end
end
