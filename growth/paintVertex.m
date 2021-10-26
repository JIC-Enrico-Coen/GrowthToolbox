function handles = paintVertex( handles, vi, adding )
  % if strcmp( selectionType, 'open' ), return; end
    output = handles.output;
    [paintamount,ok1] = getDoubleFromDialog( handles.paintamount );
    if ~ok1
        return;
    end
    if adding
        mode = 'add';
    else
        mode = 'set';
    end
    attemptCommand( handles, false, false, ... % WARNING: Does not always need redraw.
        'paintvertex', ...
        handles.mesh.globalProps.displayedGrowth, ...
        'vertex', vi, ...
        'amount', paintamount, ...
        'mode', mode );
    handles = guidata( output );
end
