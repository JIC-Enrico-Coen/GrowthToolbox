function runToButton_Callback(hObject, eventdata, handles)
    [ runTarget, ok ] = getDoubleFromDialog( handles.areaTargetText, 0 );
    if ok
        setVisualRunMode( handles, 'running', 'runToButton' );
        
        startTic = startTimingGFT( handles );
        [~,ok] = leaf_iterate( 0, 0, 'targetarea', runTarget, 'plot', 1 );
        stopTimingGFT('leaf_iterate',startTic);
        
        if ok
            setVisualRunMode( handles, 'completed', 'runToButton' );
        end
        clearstopbutton( handles );
    end
end
