function brushSelectButtonMotionFcn( hObject, varargin )
    ax = getUserdataField( hObject, 'clickDragItem' );
    clickData = getClickData( ax );
    if isempty( clickData ), return; end
    if ~isfield( clickData, 'axes' ), return; end
%     hFigure = ancestor( hObject, 'figure' );
%     selectionType = get(hFigure,'SelectionType');
%     clickData.addpoints = strcmp(selectionType,'extend');
    % fprintf( 1, 'brushSelectButtonMotionFcn\n' );
    
    % startstabline = clickData.startstabline;
    stabline = get( clickData.axes, 'CurrentPoint' );
    cf = [clickData.cameraRight; clickData.cameraUp; clickData.cameraLook];
    bounds = axis(clickData.axes);
    if length(bounds)==4
        bounds([5 6]) = [ min(bounds(1,[1 3])), max(bounds(1,[2 4])) ];
    end
    bounds = reshape( bounds, 2, 3 );
    w = getViewWidth( clickData.cameraParams );
    
    circleptsG = getBrushCircle( stabline, clickData, w, cf );
    clickData.polygonC = circleptsG * cf';
    
    linepts = zeros(0,3);
    for i=1:3
        x = clickData.cameraLook(i);
        if x ~= 0
            newpts = projectPtsToAAPlane( circleptsG, clickData.cameraLook, i, bounds(1 + (x<0),i) );
            linepts = [ linepts; newpts; nan(1,3) ];
        end
    end
    
    xvals = linepts(:,1);
    yvals = linepts(:,2);
    zvals = linepts(:,3);
    if strcmp(clickData.mouseSelType,'extend')
        linecolor = 'r';
    else
        linecolor = 'b';
    end
    haveLineHandle = isfield( clickData, 'boxselection' ) && ~isempty( clickData.boxselection );
    if haveLineHandle
        set( clickData.boxselection, 'Xdata', xvals, 'Ydata', yvals, 'Zdata', zvals, 'Color', linecolor );
    else
        clickData.boxselection = line( xvals, yvals, zvals, ...
            'Parent', clickData.axes, 'Color', linecolor, 'LineStyle', ':', 'LineWidth', 2, 'Marker', 'none' );
        setClickData( clickData );
    end
    
    updateBoxSelection( clickData );
end

function polygon = getBrushCircle( currentstab, clickData, w, cf )
    numpts = 13;
    theta = linspace(0,pi*2,numpts+1)';
    circleptsC = [ [cos(theta), sin(theta)]*(w*clickData.brushRadius), zeros(length(theta),1)];
    polygon = circleptsC * cf + repmat( currentstab(1,:), length(theta), 1 );
end
