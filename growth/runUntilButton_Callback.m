function runUntilButton_Callback(hObject, eventdata, handles)
    [ targettime, ok ] = getDoubleFromDialog( handles.simtimeText, 0 )
    if ok
        setVisualRunMode( handles, 'running', 'runUntilButton' );
        
        startTic = startTimingGFT( handles );
        [~,ok] = leaf_iterate( 0, 0, 'until', targettime, 'plot', 1 );
        stopTimingGFT('leaf_iterate',startTic);
        
        if ok
            setVisualRunMode( handles, 'completed', 'runUntilButton' );
        end
        clearstopbutton( handles );
    end
end
