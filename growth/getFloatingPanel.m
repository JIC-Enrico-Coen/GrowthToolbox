function ph = getFloatingPanel( h, panelName )
%ph = getFloatingPanel( h, panelName )
%   Find the floating panel of the given name.  H is the handle of
%   the GFtbox window, the floating panel, or any of the GUI objects within either.
    ph = [];
    
    if ~ishghandle( h )
        return;
    end
    
    h = ancestor(h,'figure');
    if isempty(h)
        return;
    end
    
    tag = get(h,'Tag');
    
    if strcmp(tag,[panelName '_figure'])
        ph = h;
        return;
    end
    
    if ~strcmp(tag,'GFTwindow')
        return;
    end
    
    ud = get( h, 'Userdata' );
    if ~isfield( ud, 'floatingpanels' )
        return;
    end
    
    if ~isfield( ud.floatingpanels, panelName )
        return;
    end
    
    ph = ud.floatingpanels.(panelName);
    if ~ishghandle(ph)
        ph = [];
    end
end