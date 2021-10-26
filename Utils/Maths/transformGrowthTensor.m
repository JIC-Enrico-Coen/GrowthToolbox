function rotD = transformGrowthTensor( D, J )
%rotD = rotateGrowthTensor( D, J )
%   D is a rank 2 tensor in row 6-vector form.  The result is the
%   transformation of D by J, a 3*3 matrix in column vector form.
%   Otherwise put, D is the expression of the growth tensor in the frame J,
%   and the result is the growth tensor represented in the global frame.
%   This is computed by converting D to a matrix, transforming by J,
%   then converting back to a row 6-vector.
%   If D is an N*6 matrix, this transformation is applied to every row of D.

    rotD = zeros( size(D) );
    for i=1:size(D,1)
        rotDM = J * [ [ D(i,1), D(i,6), D(i,5) ];
                      [ D(i,6), D(i,2), D(i,4) ];
                      [ D(i,5), D(i,4), D(i,3) ] ] * inv(J);
        rotD(i,:) = [ rotDM(1,1), rotDM(2,2), rotDM(3,3), ...
                      rotDM(2,3), rotDM(3,1), rotDM(1,2) ];
    end
end
