function ph = openGFtboxPanel( gh, panelName, initvals )
%ph = openGFtboxPanel( gh, panelLayout )
%   Open a panel of GFtbox controls.  It is created in front if it does not
%   exist, and brought to the front if it exists already.
%   gh is a handle to the main GFtbox window.  panelLayout is the name of a
%   dialog layout file.
%   If the panel does not exist, and the guidata of gh holds a struct with
%   initial values, those values will be inserted into the panel.

    ph = [];
    if ~ishghandle( gh )
        % Not a handle.
        return;
    end
    ud = get( gh, 'Userdata' );
    if isempty(ud)
        ud.floatingpanels = struct();
    end
        
    h = guidata(gh);
    if ~isfield( h, 'mesh' )
        % Not a GFtbox window.
        return;
    end
    if isfield( ud.floatingpanels, panelName )
        ph = ud.floatingpanels.(panelName);
        if ishghandle(ph)
            figure(ph);
            return;
        end
    end
    if nargin < 3
        initvals = ph;
        ph = [];
    end
    ph = modelessRSSSdialogFromFile( [ panelName '_layout.txt' ], initvals );
    if isempty(ph)
        return;
    end
    set( ph, 'tag', [panelName '_figure'], 'CloseRequestFcn', @floatingPanelClose );
    if isfield( h, 'guicolors' )
        setGUIColors( ph, h.guicolors.greenBack, h.guicolors.greenFore );
    end
    addUserData( ph, 'GFtboxHandle', gh );
    ud.floatingpanels.(panelName) = ph;
    set( gh, 'Userdata', ud );
end
