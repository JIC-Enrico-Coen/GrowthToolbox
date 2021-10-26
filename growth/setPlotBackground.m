function setPlotBackground( handles, color )
    if isempty( handles.mesh )
        setGUIPlotBackground( handles, color );
    else
        attemptCommand( handles, false, false, 'setbgcolor', color );
    end
end
