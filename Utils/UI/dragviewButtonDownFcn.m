function dragviewButtonDownFcn( hObject, eventData )
%dragviewButtonDownFcn( hObject, eventData )
%   Installing this as the ButtonDownFcn for an axes object or its children
%   will cause a click on the object to produce panning, zooming, or
%   trackball-like behaviour when the mouse is dragged.
%   This routine temporarily stores all the information it needs to process the
%   mouse movement, in the field 'clickData' of the guidata of the figure.
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
%   it by 2 radians.

%     fprintf( 1, 'dragviewButtonDownFcn\n' );
    GFtboxGraphicClickHandler( hObject, eventData );
    return;

    % Find the axes and the figure.
    hAxes = ancestor( hObject, 'axes' );
    if ~ishandle(hAxes), return; end
    hFigure = ancestor( hAxes, 'figure' );
    if ~ishandle(hFigure), return; end
    
    % Get all the information we need.
    camParams = getCameraParams( hAxes );
    hitPointParent = get( hFigure, 'CurrentPoint' );
    oldUnits = get( hAxes, 'Units' );
    set( hAxes, 'Units', 'pixels' );
    axespos = get( hAxes, 'Position' );
    set( hAxes, 'Units', oldUnits );
    axessizepixels = min(axespos([3 4]));
    axessizeunits = getViewWidth( camParams );
    setManualCamera( hAxes );

    [cameraLook, cameraUp, cameraRight] = cameraFrame( ...
        camParams.CameraPosition, ...
        camParams.CameraTarget, ...
        get( hAxes, 'CameraUpVector' ) );

    trackballScale = pi;
    trackballMode = '';
    axesUserData = get( hAxes, 'UserData' );
    if (~isempty(axesUserData)) && isstruct(axesUserData) && isfield(axesUserData,'dragmode')
        dragmode = axesUserData.dragmode;
    else
        dragmode = 'rotate';
    end
    switch dragmode
        case 'rotate'
            trackballMode = 'global';
            buttonMotionFcn = @trackballButtonMotionFcn;
        case 'rotupright'
            trackballMode = 'upright';
            buttonMotionFcn = @trackballButtonMotionFcn;
        case 'pan'
            buttonMotionFcn = @panButtonMotionFcn;
        case 'zoom'
            buttonMotionFcn = @zoomButtonMotionFcn;
        otherwise
            buttonMotionFcn = '';
    end
    mouseSelType = get( hFigure, 'SelectionType' );
    clickData = struct( ...
        'axes', hAxes, ...
        'mousemode', dragmode, ...
        'mouseSelType', mouseSelType, ...
        'moved', false, ...
        ... % 'dragmode', dragmode, ...
        'startpoint', hitPointParent, ...
        'currentpoint', hitPointParent, ...
        'startstabline', get( hAxes, 'CurrentPoint' ), ...
        'axessizepixels', axessizepixels, ...
        'axessizeunits', axessizeunits, ...
        'cameraParams', camParams, ...
        'cameraLook', cameraLook, ...
        'cameraUp', cameraUp, ...
        'cameraRight', cameraRight, ...
        'cameraTarget', camParams.CameraTarget, ...
        'cameraPosition', camParams.CameraPosition, ...
        'startCameraPosition', camParams.CameraPosition, ...
        'startCameraTarget', camParams.CameraTarget, ...
        'startCameraViewAngle', get( hAxes, 'CameraViewAngle' ), ...
        'trackballScale', trackballScale, ...
        'trackballMode', trackballMode, ...
        'brushRadius', 0.1, ... % To be replaced by value from dialog.
        'oldWindowButtonMotionFcn', get( hFigure, 'WindowButtonMotionFcn' ), ...
        'oldWindowButtonUpFcn', get( hFigure, 'WindowButtonUpFcn' ), ...
        'highlightedpts', [], ... % Not implemented yet.
        'highlighthandle', [], ... % Not implemented yet.
        'polygonC', [], ... % Not implemented yet.
        'meshvxsC', [], ... % Not implemented yet.
        'meshfaces', [] ); % Not implemented yet.
    setClickData( clickData );
    set( hFigure, ...
         'WindowButtonMotionFcn', buttonMotionFcn, ...
         'WindowButtonUpFcn', @clickdragButtonUpFcn );
    gd = guidata(hFigure);
    if isfield( gd, 'stereodata' )
        stereoTransfer( hAxes, gd.stereodata.otheraxes, gd.stereodata.vergence );
    end
end

