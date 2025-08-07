function newcp = scaleCameraDistance( cp, s )
%scaleCameraDistance( cp, s )
%   Modify the given camera params (as returned by getCameraParams) to
%   scale the distance of the camera from its target, without changing the
%   width of view.
%
%scaleCameraDistance( ax, s )
%   For an axes object AX, get the camera params, modify them as for
%   scaleCameraDistance( cp, s ), and apply the modified parameters to AX.

    if ishandle( cp )
        ax = cp;
        cp = getCameraParams( ax );
    else
        ax = [];
    end
    camdistance = norm( cp.CameraPosition - cp.CameraTarget );
    viewHalfWidthAtTarget = camdistance * tan( cp.CameraViewAngle*pi/360 );
    newposition = cp.CameraTarget + s * (cp.CameraPosition - cp.CameraTarget);
    newViewAngle = atan2( viewHalfWidthAtTarget, camdistance * s ) * (360/pi);
    
    newcp = cp;
    newcp.CameraPosition = newposition;
    newcp.CameraViewAngle = newViewAngle;
    if ~isempty(ax)
        setCameraParams( ax, newcp );
    end
end
