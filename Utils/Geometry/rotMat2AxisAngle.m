function [ax,angle] = rotMat2AxisAngle( m )
%[ax,angle] = rotMat2AxisAngle( m )
%   Convert a 3D rotation matrix to a vector ax and an angle, where ax is a
%   unit vector along the axis of rotation and th is the angle of rotation.
%   If the matrix is the identity, i.e. no rotation, then the result is
%   [0 0 1 0], the choice of axis being conventional.
%
%   The matrix m is assumed to expect to be applied to vector v as v*m, not
%   m*v.
%
%   The angle is always in the range [0,pi).
%
%   Formulas obtained from
%   https://en.wikipedia.org/wiki/Rotation_matrix#Conversion_from_and_to_axis-angle
%
%   See also: axisAngle2RotMat

    ax = [ m(2,3)-m(3,2), m(3,1)-m(1,3), m(1,2)-m(2,1) ];
    nax = norm(ax);
    if nax==0
        ax = [0 0 1];
        angle = 0;
    else
        tr = sum(diag(m));
        c = (tr-1)/2;
        angle = acos(c);
        ax = ax/nax;
    end
end
