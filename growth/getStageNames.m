function result = getStageNames( varargin )
%result = getStageNames( projectdir, meshesdir )
%   In directory MESHESDIR, find the full path names of the stage files for
%   project PROJECTDIR. If MESHESDIR is not a full path name, it will be
%   looked for first in the project directory, then in the "runs"
%   subdirectory of the project directory.
%
%result = getStageNames( projectdir, meshesdir, tt )
%   In directory MESHESDIR, find the full path names of the stage files for
%   project PROJECTDIR with time stamps TT.
%
%result = getStageNames( projectdir )
%   In project PROJECTDIR, find the full path names of the stage files.
%
%result = getStageNames( projectdir, tt )
%   In project PROJECTDIR, find the full path names of the stage files
%   with time stamps TT.
%
%result = getStageNames()
%   In the currently open project, find the full path names of the stage
%   files.
%
%result = getStageNames( tt )
%   In the currently open project, find the full path names of the stage
%   files with time stamps TT.
%
%   If any of the arguments is empty, it is equivalent to not supplying
%   them.
%
%   The result is a struct with the following fields:
%
%   projectdir: The full path name of the project.
%   projectname: The base name of the project.
%   meshesdir: The full path name of the directory where the meshes were
%       found.
%   meshnames: The base names of the stage files.
%   stagetimes: The times of the stage files.
%
%   An empty project name defaults to the project currently open in GFtbox,
%   if any. An empty meshesdir defaults to the project directory. An empty
%   list of times tt defaults to selecting all of the available stage
%   files.
%
%   If the project or meshes directory cannot be found, result is empty.
%
%   The stage file names are returned in increasing order of time stamp. If
%   a time occurs more than once in TT, only one file name will be returned
%   for it.
%
%   If a time stamp is requested for a stage file that does not exist, it
%   will be omitted from the results.
%
%   An error message will be written if the projects directory, the meshes
%   directory, or any of the requested stage times do not exist.

    result = [];
    
    haveProjectDir = (nargin > 0) && ischar( varargin{1} ) && ~isempty( varargin{1} );
    haveMeshesDir = (nargin >= 2) && ischar( varargin{2} ) && ~isempty( varargin{2} );
    haveTimes = (nargin > 0) && isnumeric( varargin{end} ) && ~isempty( varargin{end} );
    
    if haveProjectDir
        projectdir = varargin{1};
    else
        projectdir = [];
    end
    
    fullprojectpath = findGFtboxProject( projectdir, false, false );
    haveProject = ~isempty( fullprojectpath ) && exist( fullprojectpath, 'dir' );
    if ~isempty( fullprojectpath ) && ~haveProject
        if isempty( projectdir )
            fprintf( 'No current project.\n' );
        else
            fprintf( 'Cannot find project directory %s.\n', projectdir );
        end
        return;
    end
    
    if haveProject
        [~,projectbasename] = fileparts( fullprojectpath );
    else
        projectbasename = '';
        if ~haveMeshesDir
            fprintf( 1, 'No project dir and no meshes dir.\n' );
            return;
        end
    end
    
    if haveMeshesDir
        meshesdir = varargin{2};
        if haveProject
            meshesdir1 = fullfile( fullprojectpath, meshesdir );
            if exist( meshesdir1, 'dir' )
                meshesdir = meshesdir1;
            else
                meshesdir1 = fullfile( fullprojectpath, 'runs', meshesdir, 'meshes' );
                if exist( meshesdir1, 'dir' )
                    meshesdir = meshesdir1;
                else
                    fprintf( 'Cannot find meshes directory %s.\n', meshesdir );
                    return;
                end
            end
        else
            meshesdir = fullpath( meshesdir );
        end
    else
        meshesdir = fullprojectpath;
    end
    
    if ~exist( meshesdir, 'dir' )
        fprintf( 'Cannot find meshes directory %s.\n', meshesdir );
        return;
    end
    
    if haveTimes
        tt = varargin{end};
    else
        tt = [];
    end
    
    zz = dir( meshesdir );
    filenames = { zz.name };
    stagefilenames = filenames( beginsWithString( filenames, projectbasename ) );
    matchings = regexp( stagefilenames, '(_s[0-9d]+)\.mat$', 'tokens', 'once' );
    isstagefile = false( 1, length(matchings) );
    stagesuffixes = cell(1,length(matchings));
    si = 0;
    for i=1:length(matchings)
        isstagefile(i) = ~isempty( matchings{i} );
        if isstagefile(i)
            si = si+1;
            stagesuffixes{si} = matchings{i}{1};
        end
    end
    stagesuffixes((si+1):end) = [];
    stagefilenames = stagefilenames(isstagefile);
    
    if haveTimes
        givenStageSuffixes = cell(1,length(tt));
        for i=1:length(tt)
            givenStageSuffixes{i} = makestagesuffixf( tt(i) );
        end
        [~,ia,ib] = intersect( stagesuffixes, givenStageSuffixes, 'sorted' );
        usingStagefilenames = stagefilenames(ia);
        stagetimes = tt(ib);
        numMissing = length(tt) - length(ib);
        if numMissing > 0
            fprintf( 1, 'Stage files for %d of the %d times were not found.\n', numMissing, length(tt) );
        end
    else
        usingStagefilenames = stagefilenames;
        stagetimes = zeros( 1, length(usingStagefilenames) );
        for i = 1:length(usingStagefilenames)
            [~,~,stagetimes(i)] = parseStageFileName( usingStagefilenames{i} );
        end
    end
    
%     for i=1:length(usingStagefilenames)
%         usingStagefilenames{i} = fullfile( meshesdir, usingStagefilenames{i} );
%     end
    
    result.projectdir = fullprojectpath;
    result.projectname = projectbasename;
    result.meshesdir = meshesdir;
    result.meshnames = usingStagefilenames;
    result.stagetimes = stagetimes;
end
