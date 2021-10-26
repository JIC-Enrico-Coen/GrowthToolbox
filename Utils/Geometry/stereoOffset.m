function [cameraPosition, cameraRight] = stereoOffset( cameraPosition, cameraTarget, cameraUp, cameraRight, offset )
%[cameraPosition, cameraRight] = ...
%   stereoOffset( cameraPosition, cameraTarget, cameraUp, cameraRight, offset )
% Rotate cameraPosition and cameraRight by offset about cameraUp through cameraTarget.
% offset is in degrees.  The vectors should be row vectors.

    m = matRot( cameraUp, offset*pi/180 )';
    cameraPosition = (cameraPosition - cameraTarget)*m + cameraTarget;
    cameraRight = cameraRight*m;
end
