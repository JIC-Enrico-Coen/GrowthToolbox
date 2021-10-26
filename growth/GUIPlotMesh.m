function handles = GUIPlotMesh( handles )
% This must not be called while the simulation is running.

    if ~isempty( handles.mesh )
        wasBusy = setGFtboxBusy( handles, true );
        handles = processPendingData( handles );
        
        if isfield( handles.mesh, 'plothandles' ) && ~isempty( handles.mesh.plothandles )
            if isfield( handles.mesh.plothandles, 'secondlayerhandle' ) ...
                    && ~isempty( handles.mesh.plothandles.secondlayerhandle ) ...
                    && all( ishandle( handles.mesh.plothandles.secondlayerhandle(:) ) )
                set( handles.mesh.plothandles.secondlayerhandle(handles.mesh.plothandles.secondlayerhandle ~= 0), ...
                    'ButtonDownFcn', {@doSecondLayerClick} );
            end
        end

        if handles.boingNeeded==2
            boing();
            handles.boingNeeded = 0;
        end
        setGFtboxBusy( handles, wasBusy );
    end
end
