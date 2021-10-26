function [k,f] = KgaussX( v, gauss, C, eps0 )
%[k,f] = Kgauss( v, gauss, C, eps0 )
%    Calculate the K matrix and force vector for a finite element cell.
%    v: cell vertexes. 3*6 matrix, one column per vertex.
%    gauss: Gauss quadrature structure in isoparametric coordinates.  Includes
%       the points, and the values and gradients of the shape functions there.
%    C: compliance matrix. 6*6.
%    eps0: pre-strain at each vertex (calculated from thermal expansion).
%        6*6, one column for each vertex.  Each column is a 6-vector
%        representing a 3*3 symmetric tensor.

    numGaussPoints = size(gauss.points,2);
    dfsPerNode = 3;
    vxsPerCell = 6;
    numDfs = dfsPerNode * vxsPerCell;

    k = zeros(numDfs,numDfs);
    f = zeros(numDfs,1);
    index1 = [ 2, 3, 1 ];
    index2 = [ 3, 1, 2 ];
    eps0gauss = eps0*gauss.N;
    
    for i=1:numGaussPoints
        J = PrismJacobian( v, gauss.points(:,i) );
        gnGlobal = inv(J)' * gauss.gradN(:,:,i);
        sn = zeros( 6, numDfs );
        if 1
            % This version avoids the outer loop of the other version.
            for j=1:3
                columnBases = 3*((1:vxsPerCell)-1);
                sn(j,j+columnBases) = gnGlobal(j,:);
                j1 = index1(j);
                j2 = index2(j);
                sn(j1+3,j2+columnBases) = gnGlobal(j,:);
                sn(j2+3,j1+columnBases) = gnGlobal(j,:);
            end
        else
            % This version explicitly iterates over the cell vertexes.
            for a=1:vxsPerCell
                columnBase = 3*(a-1);
                for j=1:3
                    gnGlobalJA = gnGlobal(j,a);
                    sn(j,j+columnBase) = gnGlobalJA;
                    j1 = index1(j);
                    j2 = index2(j);
                    sn(j1+3,j2+columnBase) = gnGlobalJA;
                    sn(j2+3,j1+columnBase) = gnGlobalJA;
                end
            end
        end
        snC = sn'*C;
        k1 = snC*sn;
        k = k + k1;
      % f1 = snC*(eps0*gauss.N(:,i));
        f1 = snC*(eps0gauss(:,i));
        f = f + f1;
    end
    k = k/numGaussPoints;
    f = f/numGaussPoints;
end
