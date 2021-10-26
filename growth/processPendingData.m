function h = processPendingData( h )
    ud = get( h.plotFlag, 'UserData' );
    if isempty(ud)
        h.mesh = leaf_plot( h.mesh );
        ud = get( h.plotFlag, 'UserData' );
    end
    while ~isempty(ud)
        set( h.plotFlag, 'UserData', [] );
        if ~isempty( h.mesh )
            h.mesh = leaf_plot( h.mesh, ud );
        end
        ud = get( h.plotFlag, 'UserData' );
    end
    guidata( h.output, h );
end
