function [ok,handles,m,savedstate] = prepareForGUIInteraction( m, allowRunning )
%[ok,handles,m,savedstate] = prepareForGUIInteraction( m, allowRunning )
%   This is called at the beginning of leaf_* commands that are designed to
%   be invocable from the command line and operate on the mesh currently
%   active in GFtbox (hereafter called "the active mesh").
%
%   M is either 0 (a special value signifying the active mesh), empty, or a
%   mesh structure that may or may not be the active mesh.
%
%   ALLOWRUNNING is true if, in the case where the active mesh is to be
%   operated on, the subsequent procedure should be executed even if the
%   simulation is currently running.  If false, then in that situation OK
%   will be returned as false.  The default for ALLOWRUNNING is false.
%
%   OK is returned as false it either m==0 but there is no active mesh, or
%   if the active mesh is to be operated on, ALLOWRUNNING is false, and
%   GFtbox is currently busy.
%
%   If M==0, the active mesh, if any, is returned in M, otherwise M is
%   returned unchanged.
%
%   If the active mesh is to be operated on, HANDLES is returned as the
%   guidata structure for the GFtbox window. Otherwise, is it empty.
%
%   If the active mesh is to be operated on, SAVEDSTATE is a structure
%   which will be passed to concludeGUIInteraction at the end of the
%   procedure calling prepareForGUIInteraction.  Typically it will include
%   the cursor to restore, but may include whatever other information is
%   necessary to reverse any temporary changes to the GUI made by the
%   procedure.  If the active mesh is not being operated on, SAVEDSTATE is
%   empty.
%
%   See also: concludeGUIInteraction

    global GFtboxFigure
    
    if nargin < 2
        allowRunning = false;
    end
    
    handles = [];
    savedstate = [];
    ok = false;
    if isempty(m)
        ok = true;
        return;
    end
    
    findGUI = isnumeric(m) && (numel(m)==1) && (m == 0);
    haveGFtbox = false;
    
    if findGUI
        if isempty( GFtboxFigure )
            fprintf( 1, 'GFtbox is not running.\n' );
            return;
        end
        handles = guidata( GFtboxFigure );
        m = handles.mesh;
        if isempty( m )
            fprintf( 1, 'There is no current mesh in GFtbox.\n' );
            return;
        end
        haveGFtbox = true;
    elseif ~isempty( m.pictures )
        fig = ancestor( m.pictures(1), 'figure' );
        if isGFtboxFigure(fig)
            haveGFtbox = true;
            handles = guidata( fig );
        end
    end
    
    if haveGFtbox
        if findGUI && (~allowRunning) && get( handles.runFlag, 'Value' )
            fprintf( 1, 'GFtbox is busy.\n' );
            beep;
            return;
        end
        savedstate = guiBusyStart( handles );
        fprintf( 1, '%s\n', mfilename() );
    end
    
    ok = true;
end
