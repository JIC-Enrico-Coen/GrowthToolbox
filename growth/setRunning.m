function oldrunning = setRunning( handles, running )
    oldrunning = false;
    if isempty(handles) || ~isfield( handles, 'runFlag' )
        return;
    end
    oldrunning = get( handles.runFlag, 'Value' );
    set( handles.runFlag, 'Value', running );
    if isfield( handles, 'runColors' )
        setGFtboxBusy( handles, running );
        if running
            theColor = handles.runColors.runningColor;
        else
            theColor = handles.runColors.readyColor;
            clearFlag( handles, 'runFlag' );
        end
        set( handles.runPanel, 'BackgroundColor', theColor );
        c = get( handles.runPanel, 'Children' );
        for i=1:length(c)
            style = get( c(i), 'Style' );
            if strcmp( style, 'text' ) || strcmp( style, 'radiobutton' )
                set( c(i), 'BackgroundColor', theColor );
            end
        end
    end
    drawnow;
end
