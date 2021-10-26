function getAxisBoundsFromPicture_Callback( varargin )
    curitem = gcbo();  % This is the button that was clicked.
    fig = ancestor( curitem, 'figure' );
    ud = get( fig, 'userdata' );
    handles = ud.handles;
    if isempty( handles.mesh )
        useAxisBounds = true;
    else
        useAxisBounds = strcmp( get(curitem,'Tag'), 'axisbounds' );
    end
    if useAxisBounds
        axisRange = [ get( handles.picture, 'XLim' ), ...
                      get( handles.picture, 'YLim' ), ...
                      get( handles.picture, 'ZLim' ) ];
    else
        axisRange = unionBbox( meshbbox( handles.mesh, true, 0.2 ), visibleBbox( handles.mesh.pictures(1) ) );
    end
    h = guidata( fig );
    setAxisBoundsInAxisBoundsDialog( h, axisRange );
end

