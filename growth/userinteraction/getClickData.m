function clickData = getClickData( hObject )
%clickData = getClickData( hObject )
%   Get the click data from the userdata of the axes object that is an
%   ancestor of the given handle.  If there is no such ancestor, use the
%   current object.  Return [] if anything goes wrong.

    clickData = [];
    if isempty( hObject ), return; end
    if ~ishandle( hObject ), return; end
    clickDataObject = ancestor( hObject, 'axes' );
    if isempty( clickDataObject )
        clickDataObject = hObject;
    end
    clickData = getUserdataField( clickDataObject, 'clickData' );
end
