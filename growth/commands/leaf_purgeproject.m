function m = leaf_purgeproject( m, varargin )
% m = leaf_purgeproject( m )
%   Purge the project directory of generated files.
%   The movies directory and its entire contents will be deleted.
%   The snapshots directory and its entire contents will be deleted.
%   The runs directory and its entire contents will be deleted.
%   All stage files will be deleted.
%   No other files will be affected.
%
%   m can be either a mesh belonging to a project, or the name of a project
%   directory.
%
%   Options:
%       'purge'      A string or a cell array of strings, indicating which
%                    classes of files are to be purged. By default,
%                    everything.
%       'preserve'   A string or a cell array of strings, indicating which
%                    classes of files are not to be purged. By default,
%                    nothing. Anything appearing in both 'purge' and
%                    'preserve' will be preserved.
%
%       For 'purge' and 'preserve', the following strings are recognised:
%       'movies', 'snapshots', 'runs', 'stages'.
%
%       'recycle'    A boolean.  If true (the default) then deleted files
%                    are sent to the wastebin.  If false, they are
%                    irrevocably deleted immediately.
%       'confirm'    A boolean.  If true (the default is false), the user
%                    will be asked to confirm the operation.
%
%   For example:
%
%   leaf_purgeproject( m, 'purge', 'movies' );    % Purge only the movies.
%
%   leaf_purgeproject( m, 'preserve', 'movies' ); % Purge everything except the movies.


    global gMISC_GLOBALS
    if isempty(m)
        return;
    end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'purge', [], 'preserve', [], 'recycle', true, 'confirm', false );
    ok = checkcommandargs( mfilename(), s, 'exact', 'purge', 'preserve', 'recycle', 'confirm' );
    if ~ok, return; end
    
    setGlobals();
    
    if ischar(m)
        modeldir = m;
    else
        modeldir = getModelDir( m );
    end
    [~,modelname] = fileparts( modeldir );

    if isempty( modeldir )
        return;
    end
    if ~exist( modeldir, 'dir' )
        return;
    end
    
    s.purge = lower(s.purge);
    if ischar( s.purge )
        s.purge = { s.purge };
    end
    s.preserve = lower(s.preserve);
    if ischar( s.preserve )
        s.preserve = { s.preserve };
    end
    purgetypes = { 'movies', 'snapshots', 'runs', 'stages' };
    if isempty(s.purge)
        s.purge = purgetypes;
    end
    s.purge = setdiff( s.purge, s.preserve );
    if isempty( s.purge )
        return;
    end
    
    for i=1:length(purgetypes)
        whichToPurge.(purgetypes{i}) = false;
    end
    for i=1:length(s.purge)
        whichToPurge.(s.purge{i}) = true;
    end
    
    if s.confirm
        result = queryDialog( {'Purge', 'Cancel'}, 'Purge project', ...
            'Are you sure?  This will delete the movies directory, the snapshots directory, and all stage files from the project.' );
        if result ~= 1
            fprintf( 1, 'Purge operation cancelled by user.\n' );
            return;
        end
    end

    oldrecycle = recycle();
    if s.recycle
        recycle( 'on' );
    else
        recycle( 'off' );
    end
    
    somethingDeleted = false;
    if whichToPurge.movies
        d = deleteProjectDir( modeldir, 'movies' );
        somethingDeleted = somethingDeleted | d;
    end
    if whichToPurge.snapshots
        d = deleteProjectDir( modeldir, 'snapshots' );
        somethingDeleted = somethingDeleted | d;
    end
    if whichToPurge.runs
        d = deleteProjectDir( modeldir, 'runs' );
        somethingDeleted = somethingDeleted | d;
    end
    if whichToPurge.stages
        stagepattern = fullfile( modeldir, [modelname, '_s*.mat'] );
        stagelist = dir( stagepattern );
        announced = false;
        for i=1:length(stagelist)
            stagename = fullfile( modeldir, stagelist(i).name );
            if regexp( stagename, [ gMISC_GLOBALS.stageprefix gMISC_GLOBALS.stageregexp '\.mat$' ] )
                if ~announced
                    fprintf( 1, 'Deleting stage files.\n' );
                    announced = true;
                    somethingDeleted = true;
                end
                fprintf( 1, 'Deleting %s\n', stagename );
                try
                    delete( stagename );
                catch
                end
            end
        end
    end
    
    if ~somethingDeleted
        fprintf( 1, '%s: No files to delete.\n', mfilename() );
    end
    
    recycle( oldrecycle );
end

function somethingDeleted = deleteProjectDir( modeldir, subdir )
    somethingDeleted = false;
    if isempty( modeldir )
        return;
    end
    fulldirname = fullfile( modeldir, subdir );
    if exist( fulldirname, 'dir' )
        somethingDeleted = true;
        fprintf( 1, 'Deleting %s and all its contents.\n', fulldirname );
        try
            rmdir( fulldirname, 's' );
        catch
        end
    end
end

