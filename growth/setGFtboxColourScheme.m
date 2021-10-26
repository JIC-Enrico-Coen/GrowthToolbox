function setGFtboxColourScheme( h, handles )
    if ishghandle(h) && isfield( handles, 'guicolors' ) && isfield( handles.guicolors, 'greenBack' ) && isfield( handles.guicolors, 'greenFore' )
        setGUIColors( h, handles.guicolors.greenBack, handles.guicolors.greenFore );
    end
end
