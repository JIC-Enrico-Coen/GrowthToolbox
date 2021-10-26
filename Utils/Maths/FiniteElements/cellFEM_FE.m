function [cell,k,f] = cellFEM_FE( cell, fe, vxcoords, C, eps0, residualScale, residualStrain )
% Updating of cellFEM to use general finite elements with old-style
% meshes.  This assumes it is dealing with pentahedra.

% eps0 comes from makeMeshGrowthTensors, which calculates celldata.Gglobal
% eps0 = -(m.celldata(ci).Gglobal * m.globalProps.timestep)'

global gJacobianMethod

    numGaussPoints = size(fe.quadraturePoints,1);
    dfsPerNode = size(vxcoords,2);
    tensorlength = dfsPerNode*(dfsPerNode-1);
    vxsPerCell = size(vxcoords,1);
    numDfs = dfsPerNode * vxsPerCell;
    k = zeros(numDfs,numDfs);
    f = zeros(numDfs,1);
    
    cell.eps0gauss = eps0*fe.shapequad';
    if (nargin >= 7) && (residualScale ~= 0) && any(residualStrain(:) ~= 0)
        residualStrain = residualStrain * residualScale;
        if size(residualStrain,2)==1
            residualStrain = repmat( residualStrain, 1, numGaussPoints );
        else
            % residualStrain = residualStrain * fe.shapequad';
        end
        cell.eps0gauss = cell.eps0gauss + residualStrain;
    end
    
    [~,gradNeuc,weightedJacobians] = interpolationData( fe, vxcoords );
    
    % permute(fe.shapederivquad,[2,1,3]) is the same as gGAUSS_INFO.gradN
    % fe.shapequad is equal to gGAUSS_INFO.N. (But is symmetric, so not
    %       sure if we need transpose.)
    % isograd is the same as J.
    % permute(gradNeuc,[2,1,3]) is the same as cell.gnGlobal
    
    cell.gnGlobal = permute(gradNeuc,[2,1,3]);

    sn = zeros( tensorlength*dfsPerNode, vxsPerCell, numGaussPoints );
    sn([1 8 15 17 6 10 12 16 5],:,:) = cell.gnGlobal([1 2 3 1 2 3 1 2 3],:,:);
    sn = reshape( sn, [tensorlength, numDfs, numGaussPoints]);
    for i=1:numGaussPoints
        if gJacobianMethod
            snC = sn(:,:,i)' * C;
            k1 = snC * sn(:,:,i) * weightedJacobians(i);
            f1 = snC * (cell.eps0gauss(:,i)) * weightedJacobians(i);
        else
            snC = sn(:,:,i)' * (C*fe.quadratureWeights(i));
            k1 = snC * sn(:,:,i);
            f1 = snC * cell.eps0gauss(:,i);
        end
        k = k + k1;
        f = f + f1;
    end
end
