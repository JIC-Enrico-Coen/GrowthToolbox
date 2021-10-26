function m = computeResidualStrainsAA( m, scale, vorticities, unusedResidualStrain )
%cell = computeResidualStrainsAA( cell, scale )
%   Compute the residual strains remaining after applying the given
%   displacements to the vertexes of the cell.
%   We average this over the cell, since for a single FEM element
%   constrained to act linearly, there is no physical meaning to a strain
%   field that varies over the cell.

    if nargin < 2
        scale = 1;
    end
    
    if ~isfield( m.celldata, 'residualStrain' )
        m.celldata(1).residualStrain = zeros(6,6);
    end
    for i=1:length(m.celldata)
        cell = m.celldata(i);
        % Should eps0gauss be rotated into the new cell frame?
        rs = cell.eps0gauss + cell.displacementStrain;
        if (nargin > 2) && (m.globalDynamicProps.freezing > 0)
            rotResid = zeros(6,6);
            for j=1:6
                rotResid(j,:) = rotateGrowthTensor( m.globalDynamicProps.freezing*unusedResidualStrain(j,:,i), vorticities(:,:,j,i) );
            end
            cell.residualStrain = rs * scale + rotResid;
        else
            cell.residualStrain = rs * scale;
        end

        if isfield( cell, 'actualGrowthTensor' )
            cell.actualGrowthTensor = ...
                sum( cell.displacementStrain, 2 ) / ...
                    size( cell.displacementStrain, 2 );
        end
        m.celldata(i) = cell;
    end
    
    % New version, to be enabled when the celldata structure has been
    % eliminated.
    if false
        rs = m.eps0gauss + m.displacementStrain;
        m.residualStrain = rs * scale;

        if isfield( m, 'actualGrowthTensor' )
            m.actualGrowthTensor = ...
                sum( m.displacementStrain, 3 ) / ...
                    size( m.displacementStrain, 3 );
        end
    end
end
