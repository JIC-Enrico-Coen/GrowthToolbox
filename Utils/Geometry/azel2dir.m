function d = azel2dir( az, el )
%d = azel2dir( az, el )
%   Convert azimuth and elevation, in degrees, to a unit vector.
%   Azimuth and elevation have the meanings given to them by the Matlab
%   function [az,el] = view().  That is, when the azimuth of the view is
%   zero, the positive Y axis points into the screen.  When the azimuth is
%   90, the negative X axis points into the screen.  When elevation is
%   zero, the positive Z axis points up the screen.  When elevation is
%   positive, the positive Z axis points upwards and out from the screen.
%   When elevation is 90, the positive z axis points directly out of the
%   screen.
%
%   See also: dir2azel.

    el = el*pi/180;
    az = az*pi/180;
    
    cel = cos(el);
    d = [ -sin(az)*cel, cos(az)*cel, -sin(el) ];
end

