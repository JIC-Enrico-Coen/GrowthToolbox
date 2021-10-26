function m = computeResidualStrains( m, retainFraction, vorticities )
%cell = computeResidualStrains( cell, retainFraction, vorticities )
%   Compute the residual strains remaining after applying the given
%   displacements to the vertexes of the cell.
%   We average this over the cell, since for a single FEM element
%   constrained to act linearly, there is no physical meaning to a strain
%   field that varies over the cell.

%     if ~isfield( m.celldata, 'residualStrain' )
%         m.celldata(1).residualStrain = zeros(6,6);
%     end
    for i=1:length(m.celldata)
        cell = m.celldata(i);
        if retainFraction > 0
            roteps0gauss = zeros(size( cell.eps0gauss ) );  % zeros(6,6);
            for j=1:size( roteps0gauss, 2 )
                roteps0gauss(:,j) = rotateGrowthTensor( cell.eps0gauss(:,j)'*retainFraction, vorticities(:,:,j,i)' )';
            end
            cell.residualStrain = roteps0gauss ...
                                  + cell.eps0gauss*(1-retainFraction) ...
                                  + cell.displacementStrain;
        else
            cell.residualStrain = cell.eps0gauss ...
                                  + cell.displacementStrain;
        end
        CONSTANT_ON_TRIANGLES = ~usesNewFEs( m );
        if CONSTANT_ON_TRIANGLES
            cell.residualStrain(:,1:3) = repmat( sum( cell.residualStrain(:,1:3), 2 )/3, 1, 3 );
            cell.residualStrain(:,4:6) = repmat( sum( cell.residualStrain(:,4:6), 2 )/3, 1, 3 );
        end

        if isfield( cell, 'actualGrowthTensor' )
            cell.actualGrowthTensor = ...
                sum( cell.displacementStrain, 2 ) / ...
                    size( cell.displacementStrain, 2 );
        end
        m.celldata(i) = cell;
    end
end
