function run_Callback(hObject, eventdata, handles)
    [simsteps,ok] = getIntFromDialog( handles.simsteps, 0 );
    if ok
        setVisualRunMode( handles, 'running', 'run' );
        
        startTic = startTimingGFT( handles );
        [~,ok] = leaf_iterate( 0, simsteps, 'plot', 1 );
        stopTimingGFT('leaf_iterate',startTic);
        
        if ok
            setVisualRunMode( handles, 'completed', 'run' );
        end
        clearstopbutton( handles );
    end
end
