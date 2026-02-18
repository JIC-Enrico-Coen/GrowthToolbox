function rotD = rotateGrowthTensor( D, J )
%rotD = rotateGrowthTensor( D, J )
%   D is a rank 2 tensor in either 3*3 matrix or 1*6 vector form.  The
%   result is the rotation of D by J, a 3*3 rotation matrix in column
%   vector form.
%
%   Otherwise put, D is the expression of the tensor in the frame J, and
%   the result is the tensor represented in the global frame.
%
%   D may also be 3*3*N or N*6, in which case the transformation is applied
%   to every 3*3 or 1*6 slice.
%
%   For any column 3-vector v, we should have v'*D*v = (r*v)' * rotD * r*v.
%
%   THIS IS THE BASIC TENSOR-ROTATION FUNCTION. There are several others in
%   GFtbox, but they are never used and should not be trusted.

    TEST = false;
    if TEST
        testvec = rand(3,1);
        testvecJ = J*testvec;
    end
    
    rotD = zeros( size(D) );
    if isempty(D)
        return;
    end
    if size(D,2)==6
        numTensors = size(D,1);
        if TEST
            a = zeros( 1, numTensors );
            b = a;
        end
        symmetrycount = 2;
        for i=1:numTensors
            DM = [ [ D(i,1), D(i,6)/symmetrycount, D(i,5)/symmetrycount ];
                   [ D(i,6)/symmetrycount, D(i,2), D(i,4)/symmetrycount ];
                   [ D(i,5)/symmetrycount, D(i,4)/symmetrycount, D(i,3) ] ];
            rotDM = J * DM * J';
            if TEST
                a(i) = testvec' * DM * testvec;
                b(i) = testvecJ' * rotDM * testvecJ;
            end
            rotD(i,:) = [ rotDM(1,1), rotDM(2,2), rotDM(3,3), ...
                          rotDM(2,3)*symmetrycount, rotDM(3,1)*symmetrycount, rotDM(1,2)*symmetrycount ];
        end
    else
        numTensors = size(D,3);
        if TEST
            a = zeros( 1, numTensors );
            b = a;
        end
        for i=1:numTensors
            rotD(:,:,i) = J * D(:,:,i) * J';
            if TEST
                a(i) = testvec' * D(:,:,i) * testvec;
                b(i) = testvecJ' * rotD(:,:,i) * testvecJ;
            end
        end
    end
    
    if TEST
        rotateGrowthTensor_maxError = max(abs(a-b))
    end
    
    xxxx = 1;
end
