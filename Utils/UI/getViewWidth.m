function w = getViewWidth( p )
    if isfield( p, 'camdistance' )
        w = 2*p.camdistance*tan( (pi/180)*p.fov/2 );
    else
        w = 2 * norm( p.CameraTarget - p.CameraPosition ) ...
              * tan( (pi/180)*p.CameraViewAngle/2 );
    end
end
