function setMultiView( pics, az, el, roll, camdistance )
    noaz = isempty(az);
    noel = isempty(el);
    if nargin < 4
        roll = [];
    end
    noroll = isempty(roll);
    if nargin < 5
        camdistance = [];
    end
    nocamdistance = isempty(camdistance);
    if noaz && noel && noroll && nocamdistance, return; end
    
    for i=1:length(pics)
        h = guidata(pics(i));
        [oldaz,oldel,oldroll] = getview(h.picture);
        if noaz, az = oldaz; end
        if noel, el = oldel; end
        if noroll, roll = oldroll; end
        stereooffset = fieldvalue( h, 'stereooffset', 0 );
        setview( h.picture, az + stereooffset, el, roll, camdistance );
        if isfield( h, 'azimuth' ) && ishandle(h.azimuth)
            set( h.azimuth, 'Value', trimnumber( get(h.azimuth,'Min'), -az, get(h.azimuth,'Max'), 1e-8 ) );
        end
        if isfield( h, 'elevation' ) && ishandle(h.elevation)
            set( h.elevation, 'Value', trimnumber( get(h.elevation,'Min'), -el, get(h.elevation,'Max'), 1e-8 ) );
        end
        if isfield( h, 'roll' ) && ishandle(h.roll)
            set( h.roll, 'Value', trimnumber( get(h.roll,'Min'), -roll, get(h.roll,'Max'), 1e-8 ) );
        end
    end
end
