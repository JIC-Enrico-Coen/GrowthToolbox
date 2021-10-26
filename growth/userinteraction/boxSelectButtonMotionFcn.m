function boxSelectButtonMotionFcn( hObject, ~ )
    ax = getUserdataField( hObject, 'clickDragItem' );
    clickData = getClickData( ax );
    if isempty( clickData ), return; end
    % fprintf( 1, 'boxSelectButtonMotionFcn\n' );
    
    cf = [clickData.cameraRight; clickData.cameraUp; clickData.cameraLook];
    bounds = axis(ax);
    if length(bounds)==4
        bounds([5 6]) = [ min(bounds(1,[1 3])), max(bounds(1,[2 4])) ];
    end
    bounds = reshape( bounds, 2, 3 );

    startstabpointG = clickData.startstabline(1,:);
    stabpointG = get( ax, 'CurrentPoint' );
    stabpointG = stabpointG(1,:);
    [polygonG,polygonC] = getDragRect( startstabpointG, stabpointG, cf );
    
    stride = size(polygonG,1)+2;
    linepts = nan(stride*3,3);
    numlinepts = 0;
    for i=1:3
        x = clickData.cameraLook(i);
        if x ~= 0
            newpts = projectPtsToAAPlane( polygonG([1:end 1],:), clickData.cameraLook, i, bounds(1 + (x<0),i), bounds );
            if ~isempty(newpts)
                linepts((numlinepts+1):(numlinepts+stride),:) = [ newpts; nan(1,3) ];
                numlinepts = numlinepts + stride;
            end
        end
    end
    linepts( (numlinepts+1):end,: ) = [];
    
    xvals = linepts(:,1);
    yvals = linepts(:,2);
    zvals = linepts(:,3);
    if strcmp(clickData.mouseSelType,'extend')
        linecolor = 'r';
    else
        linecolor = [0.0 0.3 1.0];
    end
    haveLineHandle = isfield( clickData, 'boxselection' ) && ~isempty( clickData.boxselection );
    if haveLineHandle
        set( clickData.boxselection, 'Xdata', xvals, 'Ydata', yvals, 'Zdata', zvals, 'Color', linecolor );
    else
        clickData.boxselection = line( xvals, yvals, zvals, ...
            'Parent', ax, 'Color', linecolor, 'LineStyle', ':', 'LineWidth', 2, 'Marker', 'none' );
    end
    % setManualCamera( ax, manual );
    
    clickData.polygonC = polygonC;
%     guidata( hObject, gd );
    setClickData( clickData );
    
    updateBoxSelection( clickData );
end

function [polygonG,polygonC] = getDragRect( startstab, currentstab, cf )
    startstabpointG = startstab(1,:);
    stabpointG = currentstab;
    stabpointG = stabpointG(1,:);
    startstabpointCF = startstabpointG * cf';
    stabpointCF = stabpointG * cf';
    zCF = startstabpointCF(3);
    stabCorner1CF = [ startstabpointCF(1), stabpointCF(2), zCF ];
    stabCorner2CF = [ stabpointCF(1), startstabpointCF(2), zCF ];
    stabCorner1G = stabCorner1CF * cf;
    stabCorner2G = stabCorner2CF * cf;
    polygonG = [ startstabpointG;
                 stabCorner1G;
                 stabpointG;
                 stabCorner2G ];
    polygonC = [ startstabpointCF;
                 stabCorner1CF;
                 stabpointCF;
                 stabCorner2CF ];
end
