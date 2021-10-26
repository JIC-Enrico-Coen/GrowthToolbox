function setCamlight( theaxes, az, el, on )
%setCamlight( theaxes, az, el, force )
%   Set the position of a light relative to the camera in terms of azimuth
%   and elevation.  The values of az and el will be stored in the UserData
%   of theaxes, and these values will be used as defaults.  The on argument
%   can be either true, false, or empty.  The default is empty.  If true, a
%   light will be created if none exists.  If false, any light will be
%   deleted and none will be created.  If empty (the default), a light will
%   be created only if none exists.

    ud = get( theaxes, 'Userdata' );
    if isempty( ud )
        ud = struct();
    end
    ud = defaultfields( ud, 'az', -80, 'el', 20 );
    if (nargin < 2) || isempty(az)
        az = ud.az;
    else
        ud.az = az;
    end
    if (nargin < 3) || isempty(el)
        el = ud.el;
    else
        ud.el = el;
    end
    if nargin < 4
        on = [];
    end
    set( theaxes, 'UserData', ud );
    lights = findobj( theaxes, 'Type', 'light' );
    havelights = ~isempty(lights);
    if havelights
        if isempty(on) || on
            delete( lights(2:end) );
            myCamlight( lights(1), ud.az, ud.el, 'infinite' );
        else
            delete( lights );
        end
    else
        if on
            myCamlight( theaxes, az, el, 'infinite' );
        end
    end
end

function safeCamlight( theaxes, varargin )
%     oldaxes = findCurrentAxesIfAny();
%     axes( theaxes );
    myCamlight( theaxes, varargin{:} );
%     if ~isempty( oldaxes )
%         axes( oldaxes );
%     end
end
