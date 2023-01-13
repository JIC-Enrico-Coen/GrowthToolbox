function [projectfullpath,runname,meshesdir,filename] = findGFtboxProjectFile( varargin )
%[projectfullpath,runname,meshesdir,filename] = findGFtboxProjectFile( option, value, ... )
%
%   This is a general procedure to find files within a project: stage
%   files, the interaction function, the initial mesh, and the static file.
%   They can be looked for at the top level of a project or in saved runs.
%
%   Options:
%
%   'project'  A project base name or full path name. If omitted, it
%       defaults to the project currently open in GFtbox, if any.
%
%   'run'  The name of a run within the project. If empty or absent, the
%       base level of the project is specified. If it is '*', it specifies
%       the set of all subdirectories of the runs directory.
%
%   'file'  This specifies which file to retrieve. It can be 'if' (the
%       interaction function), 'initial' (the initial mesh of the project),
%       'static' (the static file), 'last' (the last existing stage file),
%       or a stage time (as a number). It can also be the complete base
%       name of a file.
%
%   Multiple values can be given for the 'run' and 'file' options.
%
%   The results are:
%
%   PROJECTFULLPATH: The full pathname of the project. This will be empty if
%   the project could not be found.
%
%   RUNNAME: The name of the run within the project. Empty for the project
%   itself.
%
%   MESHESDIR: The full pathname of the directory containing the requested
%   stage files. This will be the same as PROJECTFULLPATH if stage files
%   directly within the project are being requested.
%
%   FILENAME: The base name of the file.
%
%   If multiple values are given for the 'run' option, then RUNNAME is
%   returned as a N*1 cell array of strings.
%
%   If multiple values are given for the 'file' option, then FILENAME is
%   returned as an N*M cell array of strings, where N is the number of runs
%   and M is the number of files. All of the files are looked for in all of
%   the runs.
%
%   In all cases, missing projects, runs, or files are indicated by empty
%   results.
%
%   Note that for reasons, saved runs of a project do not include the
%   project's initial file. They do include the interaction function (but
%   with the .m extension replaced by .txt) and the static file.

    projectfullpath = '';
    runname = '';
    meshesdir = '';
    filename = '';

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'project', '', 'run', '', 'file', '' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
         'project', 'run', 'file' );
    if ~ok, return; end
    
    [projectfullpath,status] = findGFtboxProject( s.project );
    if ~isempty( status )
        timedFprintf( 1, '%s.\n', status );
        return;
    end
    
    [~,projectbasename] = fileparts( projectfullpath );
    
    runsdir = fullfile( projectfullpath, 'runs' );
    haveRunsdir = exist( runsdir, 'dir' ) == 7;
    complainedNoRunsdir = false;

    if ischar( s.run )
        if strcmp( s.run, '*' )
            if haveRunsdir
                runlist = dir( runsdir );
                runs = { runlist.name };
                bad = true( 1, length(runs) );
                for i=1:length(runs)
                    bad(i) = isempty( runs{i} ) || (runs{i}(1)=='.');
                end
                runs(bad) = [];
                s.run = runs;
                xxxx = 1;
            else
                timedFprintf( 1, 'Cannot find runs folder %s.\n', runsdir );
                complainedNoRunsdir = true;
            end
        else
            s.run = { s.run };
        end
    end
    if ischar( s.file )
        s.file = { s.file };
    end
    
    runname = s.run(:);

    runpath = cell( length(s.run), 1 );
    meshesdir = cell( length(s.run), 1 );
    filename = cell( length(s.run), length(s.file) );
    for ri=1:length( s.run )
        run1 = s.run{ri};
        if isempty( run1 )
            % Base level.
            runfullpath = projectfullpath;
        elseif ~haveRunsdir && ~complainedNoRunsdir
            timedFprintf( 1, 'Cannot find runs folder %s.\n', runsdir );
            complainedNoRunsdir = true;
            continue;
        else
            runfullpath = fullfile( runsdir, run1 );
            if exist( runfullpath, 'dir' ) ~= 7
                timedFprintf( 1, 'Cannot find run %s in runs folder %s.\n', run1, runfullpath );
                continue;
            end
        end
        runpath{ri} = runfullpath;
        if isempty( run1 )
            meshesdir{ri} = projectfullpath;
        else
            meshesdir{ri} = fullfile( runfullpath, 'meshes' );
            if exist( meshesdir{ri}, 'dir' ) ~= 7
                timedFprintf( 1, 'No meshes directory in run %s of project %s.\n', run1, projectfullpath );
                meshesdir{ri} = [];
                continue;
            end
        end
        if isnumeric( s.file )
            stagenames = append( append( projectbasename, makestagesuffixf( s.file ) ), '.mat' );
            if ischar(stagenames)
                stagenames = {stagenames};
            end
            filename(ri,:) = stagenames;
        else
            for fi=1:length( s.file )
                fn = s.file{fi};
                switch fn
                    case 'if'
                        % Interaction function.
                        if isempty( run1 )
                            fn = [ makeIFname( projectbasename ), '.m' ];
                        else
                            fn = [ makeIFname( projectbasename ), '.txt' ];
                        end
                    case 'init'
                        % Initial stage of project or run.
                        fn = [ projectbasename, '.mat' ];
                    case 'static'
                        % Static file of project or run.
                        fn = [ projectbasename, '_static.mat' ];
                    case 'last'
                        % Last stage file of project or run.
                        allstages = { dir( fullfile( meshesdir{ri}, [ projectbasename, '_s*.mat' ] ) ).name };
                        actuallystages = regexp( allstages, '_s[m0-9]*.mat$', 'once' );
                        stagetimes = -inf( 1, length(actuallystages) );
                        for si=1:length(actuallystages)
                            t = stageTimeFromFilename( allstages{si} );
                            if isempty(t)
                                stagetimes(si) = -Inf;
                            else
                                stagetimes(si) = t;
                            end
                        end
                        [~,li] = max( stagetimes );
                        if isempty(li) || isinf(li)
                            fn = '';
                        else
                            fn = allstages{li};
                        end
                    otherwise
                        % Stage specification.
                        if isnumeric( fn )
                            filename{ri,fi} = [ projectbasename, makestagesuffixf( fn ), '.mat' ];
                        elseif ischar( fn )
                            filename{ri,fi} = fn;
                        else
                            timedFprintf( 1, 'Unrecognised file specification of type ''%s''.\n', class( fn ) );
                            continue;
                        end
                end
                filename{ri,fi} = fn;
            end
        end
    end

    for ri=1:length(meshesdir)
        for fi=1:size(filename,2)
            if ~isempty( meshesdir{ri} ) && ~isempty( filename{ri,fi} )
                fullfilename = fullfile( meshesdir{ri}, filename{ri,fi} );
                if exist( fullfilename, 'file' ) ~= 2
                    timedFprintf( 1, 'Cannot find file %s.\n', fullfilename );
                    filename{ri,fi} = [];
                end
            end
        end
        if exist( runpath{ri}, 'dir' ) ~= 7
            runname{ri} = [];
        end
    end

    if numel( runname )==1
        runname = runname{1};
    end
    
    if numel( meshesdir )==1
        meshesdir = meshesdir{1};
    end
    
    if numel( filename )==1
        filename = filename{1};
    end
end
