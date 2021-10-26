function m = concludeGUIInteraction( handles, m, savedstate )
%m = concludeGUIInteraction( handles, m, savedstate )
%   This is called at the end of leaf_* commands that are designed to
%   be invocable from the command line and operate on the mesh currently
%   active in GFtbox (hereafter called "the active mesh").
%
%   Every such procedure will have called
%       [ok,handles,m,savedstate] = prepareForGUIInteraction( m, allowRunning )
%   at the start.  The HANDLES, M, and SAVEDSTATE returned there should be
%   supplied here.
%
%   If HANDLES is empty or there is no GFtbox figure, this procedure does
%   nothing.  Otherwise, it restores saved state as specified by the
%   SAVEDSTATE structure.  M can be changed by doing this, which is why M
%   is returned as a result.
%
%   See also: prepareForGUIInteraction

    if isempty(handles)
        return;
    end
    global GFtboxFigure
    if isempty(GFtboxFigure)
        return;
    end
    
    fprintf( 1, '%s\n', mfilename() );

    if ~isempty( savedstate )
        updateM = false;
        if isfield( savedstate, 'update' )
            handles = updateMesh( handles, m );
            updateM = true;
        end
        if isfield( savedstate, 'install' )
            handles = installNewMesh( handles, m );
            updateM = true;
        elseif isfield( savedstate, 'replot' )
            handles.mesh = leaf_plot( handles.mesh );
            updateM = true;
        end
        if updateM
            m = handles.mesh;
        end
    end
    guiBusyEnd( handles, savedstate );
end
