function [cameraLook, cameraUp, cameraRight] = cameraFrame( cp, CameraTarget, CameraUp )
%[cameraLook, cameraUp, cameraRight] = cameraFrame( ...
%       CameraPosition, CameraTarget, CameraUp )
%   Construct the camera orthonormal frame of reference.  The arguments are
%   fields of an axes object.
%   If called as [cameraLook, cameraUp, cameraRight] = cameraFrame( axes ),
%   the position, target, and up vectors are taken from the axes object.
%   Calling it with no arguments is equivalent to cameraFrame( gca ).
%   Note that cameraUp will not necessarily coincide with CameraUp, since
%   cameraUp is constrained to be orthogonal to the look direction, while
%   CameraUp is not.
%
%   cameraFrame can be called with a single argument, which is either a
%   struct containing the three camera parameters, or an axes handle.  In
%   the latter case the camera parameters will be taken from the axes.  If
%   omitted, it defaults to the current axes.

    if nargin==0
        cp = getCameraParams( gca );
    elseif nargin==3
        cp = struct( 'CameraPosition', cp, ...
                     'CameraTarget', CameraTarget, ...
                     'CameraUpVector', CameraUp );
    elseif ishandle(cp)
        cp = getCameraParams(cp);
    end

    cameraLook = cp.CameraTarget - cp.CameraPosition;
    cameraLook = cameraLook/norm(cameraLook);

    cameraUp = makeperp( cameraLook, cp.CameraUpVector );
    cameraUp = cameraUp/norm(cameraUp);

    cameraRight = cross( cameraLook, cameraUp );
end
