function doVxClick( varargin )
% NEEDS FIXING TO ACCOUNT FOR NEW MANAGEMENT OF PLOT HANDLES.
fprintf( 1, '%s\n', mfilename() );
    if nargin < 1, return; end
    hitObject = varargin{1};
    handles = guidata( hitObject );
    if ~isstruct(handles)
        % Not running in GFtbox.
        return;
    end
    if isfield( handles, 'runFlag' ) && get( handles.runFlag, 'Value' )
        beep;
        fprintf( 1, '** Cannot edit leaf while simulation in progress.\n' );
        return;
    end
    parent = get( hitObject, 'Parent' );
    ud = get( hitObject, 'UserData' );
    if isstruct( ud ) && isfield( ud, 'vertex' )
        vi = ud.vertex;
        fprintf( 1, 'Click detected on vertex %d.\n', vi );
        selectionType = getSelectionType( hitObject );
        handles = vertexClick( handles, vi, selectionType );
        guidata( parent, handles );
    end
end
