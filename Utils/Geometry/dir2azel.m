function [ az, el ] = dir2azel( d )
%[ az, el ] = dir2azel( d )
%   Convert a unit direction vector to azimuth and elevation in degrees.
%   Azimuth and elevation have the meanings given to them by the Matlab
%   function [az,el] = view().  That is, when the azimuth of the view is
%   zero, the positive Y axis points into the screen.  When the azimuth is
%   90, the negative X axis points into the screen.  When elevation is
%   zero, the positive Z axis points up the screen.  When elevation is
%   positive, the positive Z axis points upwards and out from the screen.
%   When elevation is 90, the positive z axis points directly out of the
%   screen.
%
%   See also: azel2dir.

    az = atan2( -d(1), d(2) )*180/pi;
    el = atan2( -d(3), sqrt( d(1)*d(1) + d(2)*d(2) ) )*180/pi;
end

