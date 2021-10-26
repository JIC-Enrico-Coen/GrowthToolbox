function [m,ok] = leaf_saverun( m, varargin )
%[m,ok] = leaf_saverun( m, ... )
%   Save all the current stage files and the static file to a new directory
%   runs/NAME/meshes,  where NAME is supplied in the arguments.  Add a file
%   runs/NAME/CommandLine.txt containing a one-line description of the set
%   of files, provided in one of the options.
%
%   Options:
%       name:   The name of the directory to store this run.
%       desc:   A one-line description of the run.  This is used by
%               the "Import Experimental Stages..." menu command, which
%               reads all of the CommandLine.txt files and displays their
%               contents in a listbox for the user to select one.  desc
%               defaults to name.
%       verbose:    In case of error, if this is true then error messages
%               will be written to the console, if false then not.  The
%               default is true.
%
%   The result OK is true if it succeeded, false if it failed for any
%   reason.
%
%   See also: leaf_loadrun

global gMISC_GLOBALS

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'name', '', 'desc', '', 'verbose', true );
    ok = checkcommandargs( mfilename(), s, 'exact', 'name', 'desc', 'verbose' );
    if ~ok, return; end

    if isempty(s.desc)
        s.desc = s.name;
    end
    s.name = makefilename( s.name );
    if isempty(s.name)
        return;
    end
    if isempty( m.globalProps.projectdir )
        % Not bound to a project.
        return;
    end
    if isempty( m.globalProps.modelname )
        % Not bound to a project.
        return;
    end

    RUNSDIR = 'runs';
    MESHESDIR = 'meshes';
    DESCFILE = 'CommandLine.txt';
    modeldir = fullfile( m.globalProps.projectdir, m.globalProps.modelname );
    allrunsdir = fullfile( modeldir, RUNSDIR );
    thisrundir = fullfile( allrunsdir, s.name );
    thisrunmeshesdir = fullfile( thisrundir, MESHESDIR );
    commandfile = fullfile( thisrundir, DESCFILE );
    testexist = exist( thisrunmeshesdir, 'file' );
    ok = false;
    switch testexist
        case 0
            % Does not exist: create it.
            try
                mkdir( thisrunmeshesdir );
                ok = true;
            catch
                if s.verbose
                    complain( 'Cannot create directory "%s".\n', thisrunmeshesdir );
                    x = lasterror();
                    warning( x.identifier, x.message );
                end
            end
        case 2
            % Bad -- file exists with same name.
            fprintf( 1, 'Cannot create directory "%s"\nbecause a file of that name exists.\n', ...
                thisrunmeshesdir );
        case 7
            % Good: directory already exists.
            ok = true;
        otherwise
            % Bad -- unknown error.
            if s.verbose
                complain( 'Cannot create directory "%s"\nbecause an entity of that name (type %d) exists.\n', ...
                    thisrunmeshesdir, testexist );
            end
    end
    if ~ok
        return;
    end
    % Find all existing stage files and copy them across.
    stagepattern = fullfile( modeldir, ...
        [ m.globalProps.modelname, '_s*.mat' ] );
    stagelisting = dir( stagepattern );
    for i=1:length(stagelisting)
        stagename = stagelisting(i).name;
        if isempty( regexp( stagename, '_static.mat$', 'once' ) )
            [success, msg, msgid] = copyfile( ...
                fullfile( modeldir, stagename ), ...
                fullfile( thisrunmeshesdir, stagename ), ...
                'f' );
            if ~success
                ok = false;
                if s.verbose
                    fprintf( 1, 'Could not copy stage file %s to project subdirectory %s.\n', ...
                        stagename, thisrunmeshesdir );
                    warning( msgid, msg );
                end
            end
            stagelabel = regexp( stagename, [ gMISC_GLOBALS.stageprefix '(' gMISC_GLOBALS.stageregexp ')\.mat$'], 'tokens' );
            if ~isempty( stagelabel ) && ~isempty( stagelabel{1} )
                origsnapshotname = [ 'Stage_s', stagelabel{1}{1}, '.png' ];
                stagesnapshotname = [ m.globalProps.modelname, '_s', stagelabel{1}{1}, '.png' ];
                fullsnapname = fullfile( modeldir, fullfile( 'snapshots', origsnapshotname ) );
                if exist( fullsnapname, 'file' )
                    [success, msg, msgid] = copyfile( ...
                        fullsnapname, ...
                        fullfile( thisrunmeshesdir, stagesnapshotname ), ...
                        'f' );
                    if ~success
                        if s.verbose
                            fprintf( 1, 'Could not copy stage snapshot file %s to project subdirectory %s.\n', ...
                                origsnapshotname, thisrunmeshesdir );
                            warning( msgid, msg );
                        end
                    end
                end
            end
        end
    end
    % Copy the static file.
    staticfilename = staticBaseName( m.globalProps.modelname );
    staticfullfilename = fullfile( modeldir, staticfilename );
    savedstaticfullfilename = fullfile( thisrunmeshesdir, staticfilename );
    [success, msg, msgid] = copyfile( ...
        staticfullfilename, ...
        savedstaticfullfilename, ...
        'f' );
    if ~success
        if s.verbose
            fprintf( 1, 'Could not copy static file %s to project subdirectory %s.\n', ...
                staticfullfilename, thisrunmeshesdir );
            warning( msgid, msg );
        end
    end
    
    
    
    
    if ~isempty( m.globalProps.mgen_interactionName )
        ifname = [ m.globalProps.mgen_interactionName, '.m' ];
        ifstagename = [ m.globalProps.mgen_interactionName, '.txt' ];
        [success, msg, msgid] = copyfile( ...
            fullfile( modeldir, ifname ), ...
            fullfile( thisrunmeshesdir, ifstagename ), ...
            'f' );
        if ~success
            ok = false;
            if s.verbose
                fprintf( 1, 'Could not copy interaction function file %s to project subdirectory %s.\n', ...
                    ifname, thisrunmeshesdir );
                warning( msgid, msg );
            end
        end
    end

    m.globalProps.savedrunname = s.name;
    m.globalProps.savedrundesc = s.desc;
    if (~isempty( m.pictures )) && ishandle( m.pictures(1) )
        fig = ancestor( m.pictures(1), 'figure' );
        setMeshFigureTitle( fig, m );
    end

    % Insert the description into the command line file.
    fid = fopen( commandfile, 'w' );
    if fid==-1
        % Complain
        if s.verbose
            complain( 'Cannot write to command-line file %s.\n', commandfile );
        end
        ok = false;
    else
        % Remove trailing spacing.
        s.desc = regexprep( s.desc, '\s+$', '' );
        fprintf( fid, '%s\n', s.desc );
        fclose( fid );
    end
end
