function draggableItemButtonDown_Callback(hObject, eventdata) %#ok<INUSD>
%draggableItemButtonDown_Callback(hObject, eventdata)
%   Handle a button-down event in a gui item that is supposed to be
%   draggable in the gui, e.g. the legend or the scalebar.
%
%   This can be directly installed in the item by writing:
%
%      set( hObject, 'ButtonDownFcn', @draggableItemButtonDown_Callback );
%
%   or one can call makeDraggable( hObject ) to specify how much of the
%   item must remain visible.

    hFigure = ancestor( hObject, 'figure' );
    if hFigure==hObject
        % This should never be the ButtonDownFcn of a figure.
        return;
    end
    hParent = get( hObject, 'Parent' );
    
    % We do all calculations in pixels, so we save the old units and set
    % the units to pixels.
    olditemunits = get( hObject, 'Units' );
    oldfigureunits = get( hFigure, 'Units' );
    set( [hObject hFigure], 'Units', 'pixels' );
    if hParent ~= hFigure
        oldparentunits = get( hParent, 'Units' );
        set( hParent, 'Units', 'pixels' );
    end
    
    % Save all the required data.
    % mousemode tells clickdragButtonUpFcn what sort of operation the
    % click-drag was performing, so that it can do any finalisation
    % actions.
    % We save all the old item units and the old button-motion and
    % button-up handlers.
    % The start point and current point are both set to the click point.
    hitPointParent = get( hFigure, 'CurrentPoint' );
    clickData = ...
        struct( ...
                'mousemode', 'dragitem', ...
                'olditemunits', olditemunits, ...
                'oldfigureunits', oldfigureunits, ...
                'oldWindowButtonMotionFcn', get( hFigure, 'WindowButtonMotionFcn' ), ...
                'oldWindowButtonUpFcn', get( hFigure, 'WindowButtonUpFcn' ), ...
                'originalPosition', get( hObject, 'Position' ), ...
                'startpoint', hitPointParent, ...
                'currentpoint', hitPointParent ...
              );
    if hParent ~= hFigure
        clickData.oldparentunits = oldparentunits;
    end
    setUserdataFields( hObject, 'clickData', clickData );

    % Store a reference to this object in the figure, where the
    % button-motion and button-up handlers can find it.
    setUserdataFields( hFigure, 'clickDragItem', hObject );
    
    % Install button-motion and button-up handlers.
    set( hFigure, ...
         'WindowButtonMotionFcn', @draggableButtonMotionFcn, ...
         'WindowButtonUpFcn', @clickdragButtonUpFcn );
end


function draggableButtonMotionFcn( hFigure, eventdata ) %#ok<INUSD>
% eventdata (in Matlab 2015b) is a struct containing only the figure and
% the name of the event: 'WindowMouseMotion'.  We therefore do not need it.

    % Retrive the item that we are click-dragging in, and get its parent
    % and the click-drag structure.
    hObject = getUserdataField( hFigure, 'clickDragItem' );
    if isempty( hObject )
        return;
    end
    hParent = get( hObject, 'Parent' );
    clickDragObject = getUserdataField( hFigure, 'clickDragItem' );
    clickData = getUserdataField( clickDragObject, 'clickData' );
%     fprintf( 1, 'B drag %s sp[%f %f] ocp[%f %f] ncp[%f %f]\n', ...
%         hFigure.Tag, clickData.startpoint, clickData.currentpoint, get( hFigure, 'CurrentPoint' ) );

    % Calculate where to move the item to.
    clickData.currentpoint = get( hFigure, 'CurrentPoint' );
    newpos = clickData.originalPosition([1 2]) + clickData.currentpoint - clickData.startpoint;
    itemsize = clickData.originalPosition([3 4]);
    parentsize = get( hParent, 'Position' );
    parentsize = parentsize([3 4]);
    minvis = defaultFromStruct( ...
                getUserdataFields( hObject, {'minVisFraction', 'minVisPixels'} ), ...
                struct( 'minVisFraction', 0, 'minVisPixels', 40 ) );
    visiblePixels = max( min( itemsize, minvis.minVisPixels ), itemsize*minvis.minVisFraction );
    minpos = visiblePixels - itemsize;
    maxpos = parentsize - visiblePixels;
    newpos = max( min( newpos, maxpos ), minpos );
    
    % Set the position.
    set( hObject, 'Position', [ newpos, itemsize ] );
end