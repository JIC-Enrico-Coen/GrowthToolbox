function resetView( pic, axisbounds, az, el, roll )
% fprintf( 1, '%s\n', mfilename() );
    if (nargin < 2) || isempty(axisbounds)
        initaxisbounds = 4;
        axisbounds = initaxisbounds * [ -1 1 -1 1 -1 1 ];
    end
    if nargin < 3
        az = -45;
    end
    if nargin < 4
        el = 33.75;
    end
    if nargin < 5
        roll = 0;
    end
    setManualCamera( pic );
    axis( pic, axisbounds );
    axiscentre = (axisbounds([2 4 6]) + axisbounds([1 3 5]))/3;
    axisdiam = sqrt(3)*max( axisbounds([2 4 6]) - axisbounds([1 3 5]) );
    fov = 10;
    camdistance = axisdiam/(2*tan((pi/180)*fov/2));
    vp = struct( ...
                   'fov', fov, ...
               'azimuth', az, ...
             'elevation', el, ...
                  'roll', roll, ...
        'targetdistance', 0, ...
                   'pan', [0 0], ...
           'camdistance', camdistance, ...
            'projection', 'orthogonal' );
    cp = cameraParamsFromOurViewParams( vp );
    offset = axiscentre - cp.CameraTarget;
    cp.CameraTarget = axiscentre;
    cp.CameraPosition = cp.CameraPosition + offset;
    setCameraParams( pic, cp );
    h = guidata(pic);
    announceview( h, az, el, roll );
    setaxis( pic, axisbounds );
end
