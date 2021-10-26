function d = getModelDir( m )
    if isempty(m) || isempty( m.globalProps.projectdir )
        d = '';
    else
        d = fullfile( m.globalProps.projectdir, ...
                      m.globalProps.modelname );
    end
end
