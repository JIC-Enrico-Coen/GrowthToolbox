function notifyPlotChange( handles, varargin )
%notifyPlotChange( handles, varargin )
%   Set a flag to indicate that the mesh needs to be replotted.
%   Replot the mesh if the simulation is not currently running.

    setFlag( handles, 'plotFlag' );
    plotAlreadyPending = false;
    if nargin > 1
        ud = get( handles.plotFlag, 'UserData' );
        if isempty(ud)
            [ud,ok] = safemakestruct( '', varargin );
        else
            [s,ok] = safemakestruct( '', varargin );
            ud = setFromStruct( ud, s );
            plotAlreadyPending = true;
        end
        set( handles.plotFlag, 'UserData', ud );
    end
    simRunning = get( handles.runFlag, 'Value' );
    if (~simRunning) && ~plotAlreadyPending
        handles = GUIPlotMesh( handles );
        guidata( handles.output, handles );
    end
end

