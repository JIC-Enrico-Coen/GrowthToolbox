function [s,v] = getSurfaceVolumeFlags( flag )
%[s,v] = getSurfaceVolumeFlags( flag )
%   FLAG specifies whether some decoration should be plotted on the surface
%   of the mesh or throughout its volume.  Volume plotting only applies to
%   volumetric meshes.
%
%   If FLAG is logical or numerical, s and v are both set to its logical
%   value.
%
%   If FLAG is a string, s is set to whether it contains an 's' or 'S', and
%   v to whether it contains a 'v' or 'V'.

    if ischar(flag)
        flag = lower(flag);
        s = any(flag=='s');
        v = any(flag=='v');
    else
        s = logical(flag);
        v = s;
    end
end
