function c = cylinderCurvature( radius, angle )
%c = cylinderCurvature( radius, angle )
%   Calculate the curvature of the surface of a cylinder of given RADIUS,
%   in a direction at the given ANGLE to the cylinder's axis.
%
%   RADIUS and ANGLE can be arrays of compatible size.

    c = (sin(angle).^2)/radius;
end
