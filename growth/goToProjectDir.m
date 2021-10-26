function olddir = goToProjectDir( m, subdir )
    olddir = '';
    if ~isempty(m.globalProps.modelname)
        modeldir = getModelDir( m );
        if ~exist( modeldir, 'dir' )
            beep;
            fprintf( 1, '** Cannot find model folder %s.\n', modeldir );
        else
            if (nargin < 2) || isempty(subdir)
                olddir = trycd( modeldir );
            else
                targetdir = fullfile( modeldir, subdir );
                olddir = trymkdircd( targetdir );
            end
        end
    end
end
