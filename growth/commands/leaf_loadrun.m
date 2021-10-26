function [m,ok] = leaf_loadrun( m, varargin )
%[m,ok] = leaf_loadrun( m, ... )
%   Load a run that was previously saved with leaf_saverun.
%   m can be either a mesh belonging to a project, or the full path name of
%   a project directory.
%
%   Options:
%       name:   The name of the run. This will be looked for in the model's
%           run directory.
%
%   The result OK is true if it succeeded, false if it failed for any
%   reason.
%
%   See also: leaf_saverun

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'name', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'name' );
    if ~ok, return; end
    
    ok = false;
    
    if isempty( s.name )
        fprintf( 1, '%s: No run name given.\n', mfilename() );
        return;
    end
    
    runname = s.name;
    
    if ischar(m)
        modeldir = fullpath( m );
        m = [];
        handles = [];
    else
        modeldir = fullfile( m.globalProps.projectdir, m.globalProps.modelname );
        if isempty( modeldir )
            fprintf( 1, '%s: The mesh does not belong to a project.\n', mfilename() );
            return;
        end
        handles = getGFtboxHandles( m );
    end
    [projectdir,modelname,ext] = fileparts( modeldir );
    modelname = [ modelname, ext ];
    
    % Check to see that everything we need exists.
    if ~exist( modeldir, 'dir' )
        fprintf( 1, '%s: There is no project directory %s\n', mfilename(), modeldir );
        return;
    end
    
    rundir = fullfile( modeldir, 'runs', runname );
    if ~exist( rundir, 'dir' )
        fprintf( 1, '%s: There is no runs directory %s\n', mfilename(), rundir );
        return;
    end
    
    meshdir = fullfile(rundir,'meshes');
    
    allmeshnames = dir(fullfile(meshdir,'*_s0*.mat'));
    if isempty(allmeshnames)
        fprintf( 1, 'No stage files found in remote directory\n    %s\nOld stage files not deleted.\n', ...
            meshdir );
        return;
    end
    
    % Load the initial mesh.
    [m,ok] = leaf_loadmodel( m, modelname, projectdir );
    if ~ok
        fprintf( 1, '%s: Cannot load initial state of project %s\n', mfilename(), modeldir );
        m = [];
        return;
    end
    
    % Remove stage files from project directory.
    m = leaf_deletestages( m, 'stages', true, 'times', true );
    
    % Copy stage files from experiment into project directory.
    numstages = length(allmeshnames);
    stagetimes = inf(1,numstages);
    for i = 1:numstages
        result = allmeshnames(i).name;
        stagefilename = fullfile(meshdir,result);
        copyfile(stagefilename,modeldir);
        [~,~,stagetimes(i)] = parseStageFileName( stagefilename );
    end
    stagetimes(isinf(stagetimes)) = [];
    m.stagetimes = addStages( m.stagetimes, stagetimes );
    m.globalProps.savedrunname = runname;
    m.globalProps.savedrundesc = runname;
    
    isGFtbox = ~isempty( handles ) && isfield( handles, 'GFtboxRevision' );
    if isGFtbox
        installNewMesh( handles, m );
        m = handles.mesh;
    end
    
    ok = true;
end

