function trackballButtonDownFcn( hObject, eventData )
%trackballButtonDownFcn( hObject, eventData )
%
%   NEVER USED
%
%   Installing this as the ButtonDownFcn for an axes object or its children
%   will cause a click on the object to produce trackball-like behaviour
%   when the mouse is dragged.
%   This routine temporarily stores all the information it needs to process the
%   mouse movement, in the field 'trackballData' of the guidata of the figure.
%   The field is deleted when the mouse button is released.
%   As a side-effect, all of the camera mode properties of the axes are set
%   to manual.
%
%   There is more than one way to map mouse movement to rotation, and the
%   choice is a matter of design.  Three mappings are implemented, and the choice
%   can be specified by setting the 'trackballMode' field of guidata.
%   'global' (the default) maps trackball coordinates [x,y] to a rotation about
%   an axis perpendicular to that vector in the (cameraright,cameraup) plane, by
%   an amount proportional to the length of the vector.
%   'local' maps incremental motion of the mouse to incremental rotation in
%   the same way.
%   'upright' maps trackball coordinates [x,y] to azimuth and elevation,
%   maintaining the camera up vector equal to [0 0 1].  This is equivalent
%   to the trackball mode available from the standard camera toolbar,
%   except that the scaling may be different.
%
%   Global and Upright mode have the advantage that mouse positions are uniquely
%   mapped to rotations: moving the mouse back to its starting point
%   restores the axes to its original orientation.
%   Local mode has the advantage that the current rotation axis is always
%   perpendicular to the current mouse velocity.
%   There is no mapping of trackball data to axes rotation that allows both
%   of these.
%
%   The scaling factor is currently set so that movement by a distance
%   equal to the smaller of the width and height of the axes object rotates
%   it by 2 radians.  A different value can be set by setting the
%   'trackballScale' field of the figure's guidata to the requried value.

    % Find the axes.
    while ~(isempty(hObject)) && ishandle(hObject) && ~strcmp(get(hObject,'Type'), 'axes')
        hObject = get( hObject, 'Parent' );
    end
    if ~ishandle(hObject), return; end

    % Find the figure.
    hFigure = get( hObject, 'Parent' );
    while ishandle(hFigure) && ~strcmp(get(hFigure,'Type'), 'figure')
        hFigure = get( hFigure, 'Parent' );
    end
    if ~ishandle(hFigure), return; end
    
    % Get all the information we need.
    hitPointParent = get( hFigure, 'CurrentPoint' );
    oldUnits = get( hObject, 'Units' );
    set( hObject, 'Units', 'pixels' );
    axespos = get( hObject, 'Position' );
    set( hObject, 'Units', oldUnits );
    axessize = min(axespos([3 4]));

    cameraTarget = get( hObject, 'CameraTarget' );
    cameraPosition = get( hObject, 'CameraPosition' );
    [cameraLook, cameraUp, cameraRight] = cameraFrame( ...
        cameraPosition, ...
        cameraTarget, ...
        get( hObject, 'CameraUpVector' ) );

    % Store it in guidata.
    gd = guidata(hFigure);
    if isfield( gd, 'trackballScale' )
        trackballScale = gd.trackballScale;
    else
        trackballScale = 2;
    end
    fprintf( 1, '%s\n', mfilename() );
    if isfield( gd, 'trackballMode' )
        trackballMode = gd.trackballMode;
    else
        trackballMode = 'global';
    end
    gd.trackballData = struct( 'axes', hObject, ...
        'startpoint', hitPointParent, ...
        'currentpoint', hitPointParent, ...
        'axessize', axessize, ...
        'cameraLook', cameraLook, ...
        'cameraUp', cameraUp, ...
        'cameraRight', cameraRight, ...
        'cameraTarget', cameraTarget, ...
        'cameraPosition', cameraPosition, ...
        'trackballScale', trackballScale, ...
        'trackballMode', trackballMode, ...
        'oldWindowButtonMotionFcn', get( hFigure, 'WindowButtonMotionFcn' ), ...
        'oldWindowButtonUpFcn', get( hFigure, 'WindowButtonUpFcn' ) );
    guidata( hFigure, gd );
    set( hFigure, ...
         'WindowButtonMotionFcn', @trackballButtonMotionFcn, ...
         'WindowButtonUpFcn', @trackballButtonUpFcn );
    set( hObject, ...
        'CameraPositionMode', 'manual', ...
        'CameraTargetMode', 'manual', ...
        'CameraUpVector', cameraUp, ...
        'CameraUpVectorMode', 'manual', ...
        'CameraViewAngleMode', 'manual' );
    if isfield( gd, 'stereodata' )
        stereoTransfer( hObject, gd.stereodata.otheraxes, gd.stereodata.vergence );
    end
end

function trackballButtonMotionFcn( hObject, eventData )
    gd = guidata( hObject );
    if isempty( gd ) || ~isfield( gd, 'trackballData' ), return; end
    currentpoint = get( hObject, 'CurrentPoint' );
    switch gd.trackballData.trackballMode
        case 'global'
            delta = (currentpoint - gd.trackballData.startpoint)/gd.trackballData.axessize;
        otherwise % case { 'local', 'upright' }
            delta = (currentpoint - gd.trackballData.currentpoint)/gd.trackballData.axessize;
    end
    [cameraPos,cameraUp,cameraRight] = ...
        trballView( gd.trackballData, [-delta(1), delta(2)], ...
                    gd.trackballData.trackballScale );
    if strcmp( gd.trackballData.trackballMode, 'upright' )
        cameraUp = [0 0 1];
    end
    gd.trackballData.currentpoint = currentpoint;
    switch gd.trackballData.trackballMode
        case 'global'
            %nothing
        otherwise % case { 'local', 'upright' }
            gd.trackballData.cameraPosition = cameraPos;
            gd.trackballData.cameraUp = cameraUp;
            gd.trackballData.cameraRight = cameraRight;
    end
    set( gd.trackballData.axes, ...
        'CameraPosition', cameraPos, ...
        'CameraPositionMode', 'manual', ...
        ... % 'CameraTarget', ??, ...
        'CameraTargetMode', 'manual', ...
        'CameraUpVector', cameraUp, ...
        'CameraUpVectorMode', 'manual', ...
        ... % 'CameraViewAngle', ??, ...
        'CameraViewAngleMode', 'manual', ...
        'DataAspectRatio', [1 1 1], ...
        'DataAspectRatioMode', 'manual', ...
        'PlotBoxAspectRatio',[1 1 1], ...
        'PlotBoxAspectRatioMode', 'manual' );
    if isfield( gd, 'stereodata' )
        stereoTransfer( gd.stereodata.otheraxes, ...
                        cameraPos, ...
                        get( gd.trackballData.axes, 'CameraTarget' ), ...
                        cameraUp, ...
                        gd.stereodata.vergence );
    end
    % Only do this if you have azimuth, elevation, and roll scroll bars.
%     cameraViewAngle = get( gd.trackballData.axes, 'CameraViewAngle' );
%     cameraTarget = get( gd.trackballData.axes, 'CameraTarget' );
%     cameraProjection = get( gd.trackballData.axes, 'Projection' );
%     ovp = ourViewParamsFromCameraParams( struct( ...
%                 'CameraViewAngle', cameraViewAngle, ...
%                 'CameraTarget', cameraTarget, ...
%                 'CameraPosition', cameraPos, ...
%                 'CameraUpVector', cameraUp, ...
%                 'Projection', cameraProjection ) );
%     set( gd.azimuth, 'Value', -ovp.azimuth );
%     set( gd.elevation, 'Value', -ovp.elevation );
%     set( gd.roll, 'Value', -ovp.roll );
    guidata( hObject, gd );
end

function trackballButtonUpFcn( hObject, eventData )
    % Process the final mouse position.
    % Tests indicate that this is not necessary -- the final mouse position
    % always generates a ButtonMotion event.
    % trackballButtonMotionFcn( hObject, eventData )

    % Restore the original ButtonMotion and ButtonUp functions.
    % Delete the trackball data.
    gd = guidata( hObject );
    if ~isempty(gd) && isfield( gd, 'trackballData' )
        set( hObject, 'WindowButtonMotionFcn', gd.trackballData.oldWindowButtonMotionFcn );
        set( hObject, 'WindowButtonUpFcn', gd.trackballData.oldWindowButtonUpFcn );
        gd = rmfield( gd, 'trackballData' );
        guidata( hObject, gd );
    end
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

