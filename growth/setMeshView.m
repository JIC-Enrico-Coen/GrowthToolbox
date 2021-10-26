function setMeshView( m, camparams )
    if isempty( m.pictures )
        return;
    end
    
    if isfield( camparams, 'CameraTarget' )
        cp = camparams;
        vp = ourViewParamsFromCameraParams( cp );
    else
        vp = camparams;
        cp = cameraParamsFromOurViewParams( vp );
    end
    
    ax = m.pictures(1);
    h = guidata(ax);
    setCameraParams( ax, cp );
    if isfield( h, 'azimuth' ) && ishandle(h.azimuth)
        set( h.azimuth, 'Value', trimnumber( get(h.azimuth,'Min'), -vp.azimuth, get(h.azimuth,'Max'), 1e-8 ) );
    end
    if isfield( h, 'elevation' ) && ishandle(h.elevation)
        set( h.elevation, 'Value', trimnumber( get(h.elevation,'Min'), -vp.elevation, get(h.elevation,'Max'), 1e-8 ) );
    end
    if isfield( h, 'roll' ) && ishandle(h.roll)
        set( h.roll, 'Value', trimnumber( get(h.roll,'Min'), -vp.roll, get(h.roll,'Max'), 1e-8 ) );
    end
end
