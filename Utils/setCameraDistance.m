function newcp = setCameraDistance( cp, d )
%setCameraDistance( cp, s )
%   Modify the given camera params (as returned by getCameraParams) to
%   set the distance of the camera from its target, without changing the
%   width of view.
%
%setCameraDistance( ax, s )
%   For an axes object AX, get the camera params, modify them as for
%   scaleCameraDistance( cp, s ), and apply the modified parameters to AX.
%
%   The new camera params are returned. NEWCP will be empty if CP is empty.

    if isempty(cp)
        newcp = [];
        return;
    end

    if ishandle( cp )
        ax = cp;
        cp = getCameraParams( ax );
    else
        ax = [];
    end
    camdistance = norm( cp.CameraPosition - cp.CameraTarget );
    s = d/camdistance;
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
