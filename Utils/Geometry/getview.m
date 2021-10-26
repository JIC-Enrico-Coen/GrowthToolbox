function [az,el,roll] = getview( theaxes )
%vp = getview( theaxes )
%[az,el] = getview( theaxes )
%[az,el,roll] = getview( theaxes )
%   Get the view parameters from the axes handle.
%   With one output, the whole view structure is returned.  With two, only
%   the azimuth and elevation are returned, and with three, roll is also
%   returned.
%
%   See also: setview.

    cp = getCameraParams( theaxes );
    vp = ourViewParamsFromCameraParams( cp );
    if nargout == 1
        az = vp;
    else
        az = vp.azimuth;
        if nargout >= 2
            el = vp.elevation;
        end
        if nargout >= 3
            roll = vp.roll;
        end
    end
end
