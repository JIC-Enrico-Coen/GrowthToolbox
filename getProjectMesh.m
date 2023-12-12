function [m,mfullpath] = getProjectMesh( varargin )
%m = getProjectMesh( m )
%   m must be either a mesh or the pathname of a mesh.
%
%m = getProjectMesh( project, stage )
%   project must be a GFtbox project or run directory. stage must be the
%   timestamp of a stage stored there. This time may be goven as a number
%   or a string. stage may also be 'first' or 'last' with the obvious
%   meaning.
%
%m = getProjectMesh( project, run, stage )
%   project must be a GFtbox project or run directory. run must be the
%   index of a run in that project's run directory. stage is the timestamp
%   of a stage in that run directory. It can also be 'first' or 'last'. run
%   and stage can be given as either numbers or strings.

    m = [];
    mfullpath = '';

    switch nargin
        case 1
            project = '';
            runcode = '';
            stage = varargin{1};
        case 2
            project = varargin{1};
            runcode = '';
            stage = varargin{2};
        case 3
            project = varargin{1};
            runcode = varargin{2};
            stage = varargin{3};
        otherwise
            timedFprintf( 1, '%d arguments found, 1 to 3 expected.\n', nargin() );
            return;
    end
    
    if isempty(project)
        if ischar( stage )
            mname = stage;
            m = load( mname );
            mfullpath = makerootpath( mname );
        elseif isGFtboxMesh( stage )
            m = stage;
            mfullpath = '';
        else
            timedFprintf( 'Mesh given is neither a filename mor a GFtbox mesh.\n' );
        end
        return;
    end
    
    if isstring( project )
        project = char( project );
    end
    
    if ~ischar( project )
        timedFprintf( 'Project directory name expected, value of type %s found.\n', class(project) );
        return;
    end
        
    [projectfullpath,status] = findGFtboxProject( project, false, false );
    if isempty( projectfullpath )
        return;
    end
    [~,projectbasename] = fileparts( projectfullpath );
    
    if ~isempty( runcode )
        s = regexprep( runcode, '\D+', ' ' );
        rcpts = sscanf( s, '%d%d%d' );
        if numel( rcpts ) ~= 3
            timedFprintf( 'Runcode "%s% has wrong format, three numbers expected.\n', runcode );
            return;
        end
        runstring = sprintf( '%06d_V%03dR%03d', rcpts );
        runbasename = [ projectbasename, '_e', runstring ];
        runpathname = fullfile( projectfullpath, 'runs', runbasename );
        xxxx = 1;
    end
    
end
