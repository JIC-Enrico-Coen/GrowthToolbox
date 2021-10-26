function [cell,k,f] = cellFEM( cell, v, gaussInfo, C, eps0, residualScale )
%[k,f] = cellFEM( cell, v, gaussInfo, C, eps0, residualScale )
%    Calculate the K matrix and force vector for a finite element cell.
%    Calculate also the pre-strain at each Gauss point (by interpolating eps0).
%    v: cell vertexes. 3*6 matrix, one column per vertex.
%    gaussInfo: Gauss quadrature structure in isoparametric coordinates.  Includes
%       the points, and the values and gradients of the shape functions there.
%    C: stiffness matrix. 6*6.
%    eps0: pre-strain at each vertex (calculated from thermal expansion).
%        6*6, one column for each vertex.  Each column is a 6-vector
%        representing a 3*3 symmetric tensor.
%    This also returns in the cell structure the interpolated strains, the
%    Jacobian of the isoparametric coordinates at each Gauss point, and the
%    gradients of the shape functions with respect to the global
%    coordinates at each Gauss point.

global gJacobianMethod

    numGaussPoints = size(gaussInfo.points,2);
    dfsPerNode = 3;
    vxsPerCell = 6;
    numDfs = dfsPerNode * vxsPerCell;

    k = zeros(numDfs,numDfs);
    f = zeros(numDfs,1);
    index1 = [ 2, 3, 1 ];
    index2 = [ 3, 1, 2 ];
    if size(cell.residualStrain,2)==1
        cell.eps0gauss = eps0*gaussInfo.N + ...
            cell.residualStrain * residualScale * ones( 1, numGaussPoints );
    else
        cell.eps0gauss = eps0*gaussInfo.N + ...
            cell.residualStrain * residualScale;
    end
    [cell.gnGlobal,detJ] = computeCellGNGlobal( v, gaussInfo );
    
    columnBases = 3*((1:vxsPerCell)-1);
    for i=1:numGaussPoints
        sn = zeros( 6, numDfs );
        for j=1:3
            sn(j,j+columnBases) = cell.gnGlobal(j,:,i);
            j1 = index1(j);
            j2 = index2(j);
            sn(j1+3,j2+columnBases) = cell.gnGlobal(j,:,i);
            sn(j2+3,j1+columnBases) = cell.gnGlobal(j,:,i);
        end
        snC = sn'*C;
        if gJacobianMethod
            k1 = snC * sn * detJ(i);
            f1 = snC * cell.eps0gauss(:,i) * detJ(i);
        else
            k1 = snC * sn;
            f1 = snC * cell.eps0gauss(:,i);
        end
        k = k + k1;
        f = f + f1;
    end
    k = k/numGaussPoints;
    f = f/numGaussPoints;


%         if gJacobianCorrection
%             snC = sn(:,:,i)'*C;
%             k1 = snC*sn(:,:,i) * weightedJacobians(i);
%             f1 = snC*(cell.eps0gauss(:,i)) * weightedJacobians(i);
%         else
%             snC = sn(:,:,i)'*(C*fe.quadratureWeights(i));
%             k1 = snC*sn(:,:,i);
%             f1 = snC*(cell.eps0gauss(:,i));
%         end
end
