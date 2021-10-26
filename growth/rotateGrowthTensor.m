function rotD = rotateGrowthTensor( D, J )
%rotD = rotateGrowthTensor( D, J )
%   D is a rank 2 tensor in either 3*3 matrix or 1*6 vector form.  The
%   result is the rotation of D by J, a 3*3 rotation matrix in column
%   vector form.
%   Otherwise put, D is the expression of the growth tensor in the frame J,
%   and the result is the growth tensor represented in the global frame.
%   D may also be 3*3*N or N*6, in which case the transformation is applied
%   to every 3*3 or 1*6 slice.

    rotD = zeros( size(D) );
    if isempty(D)
        return;
    end
    if size(D,2)==6
        symmetrycount = 2;
        for i=1:size(D,1)
            rotDM = J * [ [ D(i,1), D(i,6)/symmetrycount, D(i,5)/symmetrycount ];
                          [ D(i,6)/symmetrycount, D(i,2), D(i,4)/symmetrycount ];
                          [ D(i,5)/symmetrycount, D(i,4)/symmetrycount, D(i,3) ] ] * J';
            rotD(i,:) = [ rotDM(1,1), rotDM(2,2), rotDM(3,3), ...
                          rotDM(2,3)*symmetrycount, rotDM(3,1)*symmetrycount, rotDM(1,2)*symmetrycount ];
        end
    else
        for i=1:size(D,3)
            rotD(:,:,i) = J * D(:,:,i) * J';
        end
    end
end
