function m = axisAngle2RotMat( ax, angle )
%m = axisAngle2RotMat( ax, angle )
%   Convert an axis and an angle of rotation about that axis to a rotation
%   matrix, in three dimensions.
%
%   If angle is omitted, then the norm of ax is taken to be the rotation
%   angle. If angle is provided, ax does not have to be normalised. ax can
%   be a row or column vector.
%
%   Formula obtained from
%   https://en.wikipedia.org/wiki/Rotation_matrix#Conversion_from_and_to_axis-angle
%
%   See also: axisAngle2RotMat

    if nargin==1
        angle = norm(ax);
        ax = ax/angle;
    else
        ax = ax/norm(ax);
    end
    if isnan(angle) || (angle==0) || any(isnan(ax))
        m = eye(3);
    else
        c = cos(angle);
        s = sin(angle);
        m = c*eye(3) ...
          + s*[0, ax(3), -ax(2); -ax(3), 0, ax(1); ax(2), -ax(1), 0 ] ...
          + (1-c)*ax(:)*ax(:)';
    end
end
