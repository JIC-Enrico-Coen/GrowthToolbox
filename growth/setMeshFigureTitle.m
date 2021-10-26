function setMeshFigureTitle( h, m )
    if ishandle( h ) && ~isempty( m )
        if isempty( m.globalProps.modelname )
            modelname = '(untitled)';
        else
            modelname = m.globalProps.modelname;
        end
        figtitle = [ 'Growth toolbox: ', modelname ];
        if ~isempty( m.globalProps.savedrundesc )
            figtitle = [ figtitle, '/', m.globalProps.savedrundesc ];
        end
        set( h, 'Name', figtitle );
    end
end
