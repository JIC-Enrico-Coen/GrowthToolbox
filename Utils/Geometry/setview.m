function setview( theaxes, az, el, roll, camdistance )
%setview( theaxes, vp )
%setview( theaxes, az, el )
%setview( theaxes, az, el, roll )
%setview( theaxes, az, el, roll, camdistance )
%   Set the view parameters of the axes handle.
%   Either the whole view parameters structure can be given, or just
%   azimuth and elevation, or azimuth, elevation, and roll.

    if nargin==2
        vp = az;
    else
        cp = getCameraParams( theaxes );
        azradians = (az-90)*pi/180;
        elradians = el*pi/180;
        caz = cos(azradians);
        saz = sin(azradians);
        cel = cos(elradians);
        sel = sin(elradians);
%         lookvec = cp.CameraPosition - cp.CameraTarget;
%         newdirection = [ caz*cel, saz*cel, sel ];
%         newlookvec = newdirection * norm(lookvec);
        vp = ourViewParamsFromCameraParams( cp );
        if (nargin >= 2) && ~isempty(az)
            vp.azimuth = az;
        end
        if (nargin >= 3) && ~isempty(el)
            vp.elevation = el;
        end
        if (nargin >= 4) && ~isempty(roll)
            vp.roll = roll;
        end
        if (nargin >= 5) && ~isempty(camdistance)
            vp.camdistance = camdistance;
        end
    end
    if isfield( vp, 'azimuth' ) 
        cp = cameraParamsFromOurViewParams( vp );
    else
        cp = vp;
        vp = ourViewParamsFromCameraParams( cp );
    end
    setCameraParams( theaxes, cp );
    h = guidata(theaxes);
    announceview( h, vp.azimuth, vp.elevation, vp.roll );
end
