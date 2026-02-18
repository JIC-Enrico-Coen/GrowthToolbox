function [cell,k,f] = cellFEM( cell, v, gaussInfo, C, eps0, residualScale, pressure )
%[k,f] = cellFEM( cell, v, gaussInfo, C, eps0, residualScale )
%    Calculate the K matrix and force vector for a finite element cell.
%    Calculate also the pre-strain at each Gauss point (by interpolating eps0).
%    v: cell vertexes. 3*6 matrix, one column per vertex. The three
%       vertexes on the A side are listed first, then the three on the B
%       side.
%    gaussInfo: Gauss quadrature structure in isoparametric coordinates.
%       Includes the points, and the values and gradients of the shape
%       functions there.
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
    if nargin < 7
        pressure = 0;
    end

    k = zeros(numDfs,numDfs);
    f = zeros(numDfs,1);
    index1 = [ 2, 3, 1 ];
    index2 = [ 3, 1, 2 ];
    cell.eps0gauss = eps0*gaussInfo.N;
    if residualScale ~= 0
        if size(cell.residualStrain,2)==1
            extra = cell.residualStrain * residualScale * ones( 1, numGaussPoints );
        else
            extra = cell.residualStrain * residualScale;
        end
        cell.eps0gauss = cell.eps0gauss + extra;
    end
    [cell.gnGlobal,detJ] = computeCellGNGlobal( v, gaussInfo );
    
    columnBases = 3*((1:vxsPerCell)-1);
    UNIT_NORMALS = false;
    SQRT_NORMALS = false;
    APPLY_PRESSURE_BOTH_SIDES = true;
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
        
        if pressure ~= 0
            nv = trinormal( v(:,1:3)' )/2; % Length of nv equals area of element.
            if UNIT_NORMALS
                nv = nv/norm(nv); % Dubious.
            elseif SQRT_NORMALS
                nv = nv/sqrt(norm(nv)); % Even more dubious.
            end
            nv = nv * pressure;
            if APPLY_PRESSURE_BOTH_SIDES
                f1 = f1 - repmat( nv(:), 6, 1 );
            else
                f1(1:9) = f1(1:9) - repmat( nv(:), 3, 1 );
            end
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
