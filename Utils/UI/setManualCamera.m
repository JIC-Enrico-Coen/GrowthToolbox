function wasmanual = setManualCamera( theaxes, manual )
    if nargin < 1
        theaxes = gca;
    end
    if nargin < 2
        manual = true;
    end
    if manual
        mode = 'manual';
    else
        mode = 'auto';
    end
    wasmanual = strcmp( get( theaxes, 'CameraPositionMode' ), 'manual' ) ...
                && strcmp( get( theaxes, 'CameraPositionMode' ), 'manual' ) ...
                && strcmp( get( theaxes, 'CameraPositionMode' ), 'manual' ) ...
                && strcmp( get( theaxes, 'CameraPositionMode' ), 'manual' );
    set( theaxes, ...
        'CameraPositionMode', mode, ...
        'CameraTargetMode', mode, ...
        'CameraUpVectorMode', mode, ...
        'CameraViewAngleMode', mode );
end
