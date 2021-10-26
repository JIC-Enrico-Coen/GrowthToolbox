function m = makeCellFrames( m )
%m = makeCellFrames( m )
%   Calculate the preferred frame of reference of every finite element.  Column 1 is
%   the polarisation gradient, column 2 the perpendicular in the plane of
%   the cell, and column 3 the normal to the element.
%
%   The results are stored in m.cellFrames, and for two-sided polarisation,
%   also in m.cellFramesA and m.cellFramesB.

    full3d = usesNewFEs( m );
    if full3d
        numcells = size(m.FEsets(1).fevxs,1);
    else
        numcells = size(m.tricellvxs,1);
    end
    
    if ~isempty( m.growthanglepervertex )
        m.growthangleperFE = perVertexToperFE( m, m.growthanglepervertex );
    end
    
    haveMultipleAngles = (size(m.growthangleperFE,2)==2) && any( m.growthangleperFE(:,1) ~= m.growthangleperFE(:,2) );
    
    numpol = size( m.gradpolgrowth, 3 );
    
    if m.globalProps.twosidedpolarisation || haveMultipleAngles
        % calculate m.cellFrames, m.cellFramesA, and m.cellFramesB
        % polgrad = rotateVecAboutVec( m.gradpolgrowth, m.unitcellnormals, sum(m.growthangleperFE,2)/2 );
        if numpol > 1
            polgradA = m.gradpolgrowth(:,:,1);
            polgradB = m.gradpolgrowth(:,:,2);
        else
            polgradA = m.gradpolgrowth;
            polgradB = m.gradpolgrowth;
        end
        if ~isempty(m.growthangleperFE)
            if haveMultipleAngles
                polgradA = rotateVecAboutVec( polgradA, m.unitcellnormals, m.growthangleperFE(:,1) );
                polgradB = rotateVecAboutVec( polgradB, m.unitcellnormals, m.growthangleperFE(:,2) );
            else
                polgradA = rotateVecAboutVec( polgradA, m.unitcellnormals, m.growthangleperFE(:,1) );
                polgradB = rotateVecAboutVec( polgradB, m.unitcellnormals, m.growthangleperFE(:,1) );
            end
        end
        polgrad = (polgradA+polgradB)/2;
        if isempty( m.cellFrames )
            m.cellFrames = zeros( 3, 3, numcells );
            m.cellFramesA = zeros( 3, 3, numcells );
            m.cellFramesB = zeros( 3, 3, numcells );
        end
        if isVolumetricMesh( m )
            for ci=1:numcells
                m.cellFrames(:,:,ci) = makebasis( polgrad(ci,:) );
                m.cellFramesA(:,:,ci) = makebasis( polgradA(ci,:) );
                m.cellFramesA(:,:,ci) = makebasis( polgradA(ci,:) );
            end
        else
            for ci=1:numcells
                m.cellFrames(:,:,ci) = ...
                    getCellFrame( m.unitcellnormals(ci,:), polgrad(ci,:) );
                m.cellFramesA(:,:,ci) = ...
                    getCellFrame( m.unitcellnormals(ci,:), polgradA(ci,:) );
                m.cellFramesB(:,:,ci) = ...
                    getCellFrame( m.unitcellnormals(ci,:), polgradB(ci,:) );
            end
        end
    else
        % calculate m.cellFrames only.
        if ~isempty( m.growthangleperFE )
            polgrad = rotateVecAboutVec( m.gradpolgrowth, m.unitcellnormals, m.growthangleperFE(:,1) );
        else
            polgrad = m.gradpolgrowth;
        end
        if isempty( m.cellFrames )
            m.cellFrames = zeros( 3, 3, numcells );
        end
        if isVolumetricMesh( m )
            if isfield( m, 'gradpolgrowth2' )
                polgrad2 = m.gradpolgrowth2;
            else
                polgrad2 = zeros(size(m.gradpolgrowth));
            end
            for ci=1:numcells
                m.cellFrames(:,:,ci) = makebasis( polgrad(ci,:), polgrad2(ci,:) );
            end
        else
            for ci=1:numcells
                m.cellFrames(:,:,ci) = ...
                    getCellFrame( m.unitcellnormals(ci,:), polgrad(ci,:) );
            end
        end
        m.cellFramesA = [];
        m.cellFramesB = [];
    end
end
