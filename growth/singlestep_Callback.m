function singlestep_Callback(hObject, eventdata, handles)
% --- Executes on button press in singlestep.

    setVisualRunMode( handles, 'running', 'singlestep' );
    
    startTic = startTimingGFT( handles );
    [~,ok] = leaf_iterate( 0, 1, 'plot', 1 );
    stopTimingGFT('leaf_iterate',startTic);
    
    if ok
        setVisualRunMode( handles, 'completed', 'singlestep' );
    end
    clearstopbutton( handles );
end


