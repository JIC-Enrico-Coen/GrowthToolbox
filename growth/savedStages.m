function stageTimes = savedStages( m )
%stageTimes = savedStages( m )
%stageTimes = savedStages( modeldir )
%   Return an array of the times of all the stages for which
%   there is a saved state of the mesh, excluding the initial state.
%   The argument can be either any stage file of the project, or a path to
%   the project directory.

    global gMISC_GLOBALS
    
    if ischar( m )
        % m is the path name of a model.
        modeldir = m;
        modeldir = fullpath( modeldir );
        [~,modelname] = fileparts( modeldir );
    else
        modeldir = getModelDir( m );
        modelname = m.globalProps.modelname;
    end
    
    stageTimes = [];
    if isempty( modeldir ), return; end

%     try
%         olddir = cd( modeldir );
%     catch
%         fprintf( 1, 'Cannot find project directory %s.\n', modeldir );
%         return;
%     end
    
    setGlobals();
    matfiles = dir(fullfile( modeldir, [ modelname, gMISC_GLOBALS.stageprefix, '*.mat' ] ));
%     prefix = [ modelname, gMISC_GLOBALS.stageprefix ];
    stageTimes = zeros(1,length(matfiles));
    si = 1;
    for i=1:length(matfiles)
%         if ~isempty( regexp( matfiles(i).name, '_static\.mat$', 'once' ) )
%             continue;
%         end
%         [stagespec,ok] = removeStringPrefix( matfiles(i).name, prefix );
%         if ~ok, continue; end
%         [stagespec,ok] = removeStringSuffix( stagespec, '.mat' );
%         if ~ok, continue; end
%         t = stageStringToReal( stagespec );
        
        t = stageTimeFromFilename( matfiles(i).name );
        if ~isempty(t)
            stageTimes(si) = t;
            si = si+1;
        end
    end

    stageTimes( si:end ) = [];
    stageTimes = sort(stageTimes);
end
