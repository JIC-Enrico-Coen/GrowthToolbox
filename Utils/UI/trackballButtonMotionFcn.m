function trackballButtonMotionFcn( hObject, eventData )
    ax = getUserdataField( hObject, 'clickDragItem' );
    clickData = getClickData( ax );
    if isempty( clickData ), return; end
    if ~isfield( clickData, 'trackballMode' )
      % fprintf( 1, '** Warning: trackballButtonMotionFcn called but no trackball data available.\n' );
        return;
    end
    currentpoint = get( hObject, 'CurrentPoint' );
    switch clickData.trackballMode
        case 'global'
            delta = (currentpoint - clickData.startpoint)/clickData.axessizepixels;
        otherwise % case { 'local', 'upright' }
            delta = (currentpoint - clickData.currentpoint)/clickData.axessizepixels;
    end
    [cameraPos,cameraUp,cameraRight] = ...
        trballView( clickData, [-delta(1), delta(2)], ...
                    clickData.trackballScale );
    if strcmp( clickData.trackballMode, 'upright' )
        cameraUp = [0 0 1];
    end
    clickData.currentpoint = currentpoint;
    switch clickData.trackballMode
        case 'global'
            %nothing
        otherwise % case { 'local', 'upright' }
            clickData.cameraPosition = cameraPos;
            clickData.cameraUp = cameraUp;
            clickData.cameraRight = cameraRight;
    end
    set( clickData.axes, ...
        'CameraPosition', cameraPos, ...
        'CameraUpVector', cameraUp );
    
    gd = guidata( hObject );
    if isfield( gd, 'stereodata' )
        stereoTransfer( gd.stereodata.otheraxes, ...
                        cameraPos, ...
                        get( clickData.axes, 'CameraTarget' ), ...
                        cameraUp, ...
                        gd.stereodata.vergence );
    end
    if isfield( gd, 'picture' )
        gd = updateAziElScrollFromView( gd );
        guidata( hObject, gd );
    end
    clickData.moved = true;
    setClickData( clickData );
end

function [cameraPos,cameraUp,cameraRight] = trballView( trdata, trball, trballscale )
%[cameraPos,cameraUp] = trballView( initview, trball, trballscale )
%   initview is a structure containing
%       cameraRight
%       cameraUp
%   trball is a pair of real numbers indicating the amount of trackball
%   movement in two dimensions.  These represent a rotation about an axis
%   in the view plane perpendicular to the trball vector.  The scaling is 1
%   unit = trballscale radians. cameraPos and cameraUp are set to the new
%   camera position and up-vector specified by the trackball value.

    if all(trball==0)
        cameraPos = trdata.cameraPosition;
        cameraUp = trdata.cameraUp;
        cameraRight = trdata.cameraRight;
    else
        rotAxis = trball(2)*trdata.cameraRight + trball(1)*trdata.cameraUp;
        rotAxis = rotAxis/norm(rotAxis);
        rotAmount = norm(trball) * trballscale;

        % Rotate cameraPosition about rotAxis through cameraTarget by
        % rotAmount.
        cameraPos = rotVec( trdata.cameraPosition, trdata.cameraTarget, rotAxis, rotAmount );

        % Rotate cameraPosition about rotAxis by rotAmount.
        cameraUp = rotVec( trdata.cameraUp, [0 0 0], rotAxis, rotAmount );

        % Rotate cameraRight about rotAxis by rotAmount.
        cameraRight = rotVec( trdata.cameraRight, [0 0 0], rotAxis, rotAmount );
    end
end

