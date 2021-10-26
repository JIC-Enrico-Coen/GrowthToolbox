function doEdgeClick( varargin )
fprintf( 1, '%s\n', mfilename() );
    if nargin < 1, return; end
    hitObject = varargin{1};
    handles = guidata( hitObject );
    if (~isstruct(handles)) || ~isfield( handles, 'mesh' )
        % Not running in GFtbox.
        return;
    end
    parent = get( hitObject, 'Parent' );
    ud = get( hitObject, 'UserData' )
    if isstruct( ud ) && isfield( ud, 'edgeindexes' )
        ei = ud.edge;
      % fprintf( 1, 'Click detected on edge %d.\n', ei );
        selectionType = getSelectionType( hitObject );
        handles = edgeClick( handles, ei, selectionType );
        guidata( parent, handles );
    end
end
