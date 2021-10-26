function GFtboxGraphicClickHandler( hObject, eventData )
%GFtboxGraphicClickHandler( ax, ~ )
%   This is the button-down handler for a GFtbox axes object, and anything
%   drawn inside one.

    hAxes = ancestor( hObject, 'axes' );
    if isempty(hAxes), return; end
    hFigure = ancestor( hAxes, 'figure' );
    if ~isGFtboxFigure( hFigure )
        % Not a GFtbox window.
        return;
    end
    gd = guidata(hFigure);
    if ~isfield( gd, 'GFTwindow' )
        % Not a GFtbox window.
        return;
    end
    mousemode = getMouseModeFromGUI( gd );
    mousebrushmode = getMouseBrushModeFromGUI( gd );
    if isempty( mousemode ), return; end
    
    % fprintf( 1, 'GFtboxGraphicClickHandler mousemode %s\n', mousemode );
    
    trackballMode = '';
    buttonMotionFcn = [];
    isViewMode = false;
    switch mousemode
        case 'rotate'
            trackballMode = 'global';
            buttonMotionFcn = @trackballButtonMotionFcn;
            isViewMode = true;
        case 'rotupright'
            trackballMode = 'upright';
            buttonMotionFcn = @trackballButtonMotionFcn;
            isViewMode = true;
        case 'pan'
            buttonMotionFcn = @panButtonMotionFcn;
            isViewMode = true;
        case 'zoom'
            buttonMotionFcn = @zoomButtonMotionFcn;
            isViewMode = true;
        otherwise
            switch mousebrushmode
                case 'Box'
                    buttonMotionFcn = @boxSelectButtonMotionFcn;
                case 'Brush'
                    buttonMotionFcn = @brushSelectButtonMotionFcn;
            end
    end
    
    
    if isempty( buttonMotionFcn )
        % This is a plain click, not the beginning of a click-drag.
        % Invoke the appropriate ButtonDownFcn instead of this one.
        ud = get( hObject, 'UserData' );
        if isfield( ud, 'ButtonDownFcn' ) && ~isempty( ud.ButtonDownFcn )
            ud.ButtonDownFcn( hObject, eventData );
        end
        
        return;
    end
    
    full3d = usesNewFEs( gd.mesh );
    numnodes = getNumberOfVertexes( gd.mesh );
    
    
    % The click is the beginning of a click-drag action.
    % buttonMotionFcn has been set to the function that will handle the
    % effects of dragging.  Here we set up the data structure that it works
    % with, recording such things as the initial click point, the initial
    % view, the selection new/extend/subtract mode, etc.
    
    mouseSelType = get( hFigure, 'SelectionType' );
    if strcmp( mouseSelType, 'normal' )
        mouseSelType = 'extend';
    end
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
    cf = [cameraRight; cameraUp; cameraLook];
    if isfield( gd.mesh.visible, 'nodes' );
        visnodes = gd.mesh.visible.nodes;
    else
        visnodes = true(numnodes,1);
    end
    if isViewMode
        meshvxsC = [];
    else
        if full3d
            meshvxsC = gd.mesh.FEnodes(visnodes,:) * cf';
        else
            meshvxsC = gd.mesh.nodes(visnodes,:) * cf';
        end
    end
    
    
    visnodeindexes = find(visnodes);
    renumberNodes = zeros( getNumberOfVertexes( gd.mesh ), 1 );
    renumberNodes(visnodeindexes) = (1:length(visnodeindexes))';

    if isViewMode
        meshfaces = [];
    else
        if isVolumetricMesh( gd.mesh )
            meshfaces = gd.mesh.FEsets.fevxs( gd.mesh.visible.cells, : );
        else
            meshfaces = gd.mesh.tricellvxs( gd.mesh.visible.cells, : );
        end
        if size(meshfaces,1)==1
            meshfaces = renumberNodes(meshfaces)';
        else
            meshfaces = renumberNodes(meshfaces);
        end
    end

    clickData = struct( ...
        'axes', hAxes, ...
        'mousemode', mousemode, ...
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
        'brushRadius', max( 0.01, getDoubleFromDialog( gd.brushsizeText ) )/2, ...
        'oldWindowButtonMotionFcn', get( hFigure, 'WindowButtonMotionFcn' ), ...
        'oldWindowButtonUpFcn', get( hFigure, 'WindowButtonUpFcn' ), ...
        'polygonC', [], ...
        'meshvxsC', meshvxsC, ...
        'meshfaces', meshfaces );
    setClickData( clickData );
    if ~isempty(buttonMotionFcn)
        setUserdataFields( hFigure, 'clickDragItem', hAxes );
        set( hFigure, ...
             'WindowButtonMotionFcn', buttonMotionFcn, ...
             'WindowButtonUpFcn', @clickdragButtonUpFcn );
    end
    gd = guidata(hFigure);
    if isfield( gd, 'stereodata' )
        stereoTransfer( hAxes, gd.stereodata.otheraxes, gd.stereodata.vergence );
    end
end

