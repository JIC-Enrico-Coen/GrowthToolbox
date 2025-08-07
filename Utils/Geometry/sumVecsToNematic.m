function nt = sumVecsToNematic( v )
%nt = sumVecsToNematic( v )
%   v is an N*3 matrix of row vectors.
%   Each vector is converted to a nematic tensor, and the resulting
%   matrices are summed together.



    numNonZero = sum(v ~= 0, 2);
    
    d2 = size(v,2)==2;
    if d2
        v(:,3) = 0;
    end
    
    nt = diag( sum( v(numNonZero==1,:), 1 ) );
    
    v1 = v(numNonZero>1,:);
    normv1 = sqrt(sum(v1.^2,2));
    ctheta = v1(:,1)./normv1;
    for vi=1:size(v1,1)
        ax = makeframe( v1(vi,:), [1 0 0] );
        rotmat = axisAngle2RotMat( ax, acos(ctheta(vi)) );
        ntx = zeros(3,3);
        ntx(1,1) = normv1(vi);
        ntx = rotmat * ntx * rotmat';
        nt = nt + ntx;
    end
    
    if d2
        nt = nt([1 2],[1 2]);
    end
end