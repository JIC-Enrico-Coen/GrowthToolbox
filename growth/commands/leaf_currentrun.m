function [m,curname] = leaf_currentrun( m, varargin )
%[m,curname] = leaf_currentrun( m, varargin )
%   Set or report current run directory.
%
%   OPTIONS:
%
%   'name'  The name of the run that you want to use or create. If this
%           option is omitted, the full path of the current run directory
%           will be returned in curname. If 'name' is empty, then the
%           current run directory will be unset and curname will be empty.
%
%   'create'  If true (the default is false) then if a nonempty name is
%           supplied, the run directory will be created if it does not
%           exist.
%
%   'timestamp'  If name is nonempty, then if timestamp is true, a unique
%           timestamp will be appended to the name to force it to be a
%           directory not currently existing.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'create', true, 'timestamp', false );
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'name', 'create', 'timestamp' );
    if ~ok, return; end
    
    if ~isfield( s, 'name' )
        % Nothing.
    elseif isempty( s.name )
        m.globalProps.currentrun = '';
    else
        [rundirname,exists] = makeGFtboxRunDirname( m, s.name, s.timestamp, s.create );
        if exists
            m.globalProps.currentrun = rundirname;
        end
    end
    
    curname = m.globalProps.currentrun;
end

function [rundirname,exists] = makeGFtboxRunDirname( m, runname, timestamp, create )
    if timestamp
        runname = [ runname, '_', datestr(clock,'yyyymmdd_HHMMSS') ];
    end
    fp = findNamedGFTboxProject( fullfile( m.globalProps.projectdir, m.globalProps.modelname ) );
    if isempty(fp)
        rundirname = '';
        exists = false;
    else
        rundirname = fullfile( fp, 'runs', runname );
        meshesdirname = fullfile( rundirname, 'meshes' );
        exists = exist( meshesdirname, 'dir' );
        if ~exists && create
            [~,~,~] = mkdir( meshesdirname );
            exists = exist( meshesdirname, 'dir' );
        end
    end
end