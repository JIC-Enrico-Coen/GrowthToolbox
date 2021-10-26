function m = rotateAllTensors( m, r, cells )
    if nargin < 3
        cells = 1:getNumberOfFEs(m);
    end
    if size(r,3)==1
        r = repmat( r, [1, 1, length(cells)] );
    end
    outputfns = { 'specifiedstrain', 'actualstrain', 'residualstrain' };
    for i=1:length(cells)
        ci = cells(i);
        m.celldata(ci).eps0gauss = ...
            rotateGrowthTensor( m.celldata(ci).eps0gauss', r(:,:,i) )';
        m.celldata(ci).cellThermExpGlobalTensor = ...
            rotateGrowthTensor( m.celldata(ci).cellThermExpGlobalTensor', r(:,:,i) )';
        m.celldata(ci).actualGrowthTensor = ...
            rotateGrowthTensor( m.celldata(ci).actualGrowthTensor', r(:,:,i) )';
        m.celldata(ci).displacementStrain = ...
            rotateGrowthTensor( m.celldata(ci).displacementStrain', r(:,:,i) )';
        m.celldata(ci).residualStrain = ...
            rotateGrowthTensor( m.celldata(ci).residualStrain', r(:,:,i) )';
        for fi=1:length(outputfns)
            fn = outputfns{fi};
            if isstruct(m.outputs.(fn))
                m.outputs.(fn).A(i,:) = ...
                    rotateGrowthTensor( m.outputs.(fn).A(i,:), r(:,:,i) )';
                m.outputs.(fn).B(i,:) = ...
                    rotateGrowthTensor( m.outputs.(fn).B(i,:), r(:,:,i) )';
            else
                m.outputs.(fn)(i,:) = ...
                    rotateGrowthTensor( m.outputs.(fn)(i,:), r(:,:,i) )';
            end
        end
    end
    
    if ~isempty( m.cellFrames )
        for i=1:length(cells)
            ci = cells(i);
            m.cellFrames(:,:,ci) = r(:,:,i) * m.cellFrames(:,:,ci);
        end
    end
    
    if ~isempty( m.cellFramesA )
        for i=1:length(cells)
            ci = cells(i);
            m.cellFramesA(:,:,ci) = r(:,:,i) * m.cellFramesA(:,:,ci);
        end
    end
    
    if ~isempty( m.cellFramesB )
        for i=1:length(cells)
            ci = cells(i);
            m.cellFramesB(:,:,ci) = r(:,:,i) * m.cellFramesB(:,:,ci);
        end
    end
end
