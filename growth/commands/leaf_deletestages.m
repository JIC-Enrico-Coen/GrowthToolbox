function m = leaf_deletestages( m, varargin )
%m = leaf_deletestages( m )
%   Delete all the stage files for m, and optionally, the stage times.
%   Deleted files are gone at once, not put in the wastebasket.
%   Bounds can be placed on the times for which stages are to be deleted.
%
%   Options:
%   'times'     Boolean.  Default false.
%   'stages'    Boolean.  Default true.
%   'from'      Real number.  Only stages at or after this time.
%   'to'        Real number.  Only stages not later that this.
%   'after'     Real number.  Only stages after this time.
%   'before'    Real number.  Only stages before this.
%
%   If 'stages' and 'times' are both true, then all stage files and stage
%   times will be deleted.
%
%   If 'stages' is true and 'times' is false, then the stage files will be
%   deleted, but all stage times will be retained.
%
%   If 'stages' is false and 'times' is true, then the stage files will be
%   preserved, and all times will be deleted for which there is no stage
%   file.
%
%   If 'stages' and 'times' are both false, nothing happens.
%
%   Equivalent GUI operation: the "Delete All Stages..." and "Delete Stages
%   and Times" commands on the Stages menu.
%
%   Topics: Project management.

    if isempty(m), return; end
    setGlobals();
    global gMISC_GLOBALS

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
            'times', false, ...
            'stages', true, ...
            'from', -Inf, ...
            'to', Inf, ...
            'after', -Inf, ...
            'before', Inf );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
            'times', 'stages', 'from', 'to', 'after', 'before' );
    if ~ok, return; end

    if (~s.stages) && (~s.times)
        % Nothing to do.
        return;
    end
    if isempty( m.globalProps.projectdir )
        % Not a project.
        return;
    end
    
    timefilter = @(t) (~isempty(t) & (t >= s.from) & (t > s.after) & (t <= s.to) & (t < s.before) );
    [fdesc,haveFilter,emptyFilter] = filterDescription( s );
    if emptyFilter
        return;
    end

    saveStatic = false;
    modeldir = getModelDir( m );
    if s.stages
        fprintf( 1, 'Deleting files from %s: %s\n', modeldir, fdesc );
        filepattern = fullfile( modeldir, ...
                          [ m.globalProps.modelname gMISC_GLOBALS.stageprefix '*.mat' ] );
        filepattern2 = fullfile( modeldir, ...
                          'snapshots', ...
                          [ 'Stage' gMISC_GLOBALS.stageprefix '*.png' ] );
%         filepattern3 = fullfile( modeldir, ...
%                           'snapshots', ...
%                           [ 'Stage' gMISC_GLOBALS.stageprefix '*.txt' ] );
        timesDeleted1 = processFiles( modeldir, dirnames(filepattern), timefilter, true );
        [~] = processFiles( fullfile( modeldir, 'snapshots' ), dirnames(filepattern2), timefilter, false );
%         processFiles( modeldir, dirnames(filepattern3), timefilter, false );
        if s.times
            if haveFilter
                m.stagetimes = setdiff( m.stagetimes, timesDeleted1 );
            else
                m.stagetimes = [];
            end
        end
        m.globalProps.savedrunname = '';
        m.globalProps.savedrundesc = '';
        saveStatic = true;
    else
        oldStageTimes = m.stagetimes;
        if haveFilter
            m.stagetimes = timefilter( m.stagetimes );
        else
            m.stagetimes = savedStages( m );
        end
        saveStatic = (length(oldStageTimes)~=length(m.stagetimes)) || any(oldStageTimes~=m.stagetimes);
    end
    if saveStatic
        saveStaticPart( m );
    end
end

function [fdesc,haveFilter,emptyFilter] = filterDescription( s )
    haveFilter = true;
    emptyFilter = false;
    if s.from > s.after
        s1 = sprintf( 'from %g', s.from );
    elseif s.after > -Inf
        s1 = sprintf( 'after %g', s.after );
    else
        s1 = '';
    end
    if s.to < s.before
        s2 = sprintf( 'to %g', s.to );
    elseif s.before < Inf
        s2 = sprintf( 'after %g', s.before );
    else
        s2 = '';
    end
    if isempty(s1)
        if isempty(s2)
            fdesc = 'all stages';
            haveFilter = false;
        else
            fdesc = s2;
        end
    elseif isempty(s2)
        fdesc = s1;
    else
        fdesc = [ s1, ' and ', s2 ];
    end
    lower = max( s.from, s.after );
    upper = min( s.to, s.before );
    if lower > upper
        fdesc = 'no stages';
        emptyFilter = true;
    elseif lower==upper
        if (s.after >= lower) || (s.before <= upper)
            fdesc = 'no stages';
            emptyFilter = true;
        end
    end
end

function timesDeleted = processFiles( directory, filenames, timefilter, verbose )
    timesDeleted = zeros(1,length(filenames));
    n = 0;
    for i=1:length(filenames)
        t = stageTimeFromFilename( filenames{i} );
        if timefilter(t)
            filetodelete = fullfile( directory, filenames{i} );
            if verbose
                fprintf( 1, '%s\n', filenames{i} );
            end
            delete( filetodelete );
            n = n+1;
            timesDeleted(n) = t;
        end
    end
    timesDeleted( (n+1):end ) = [];
    if verbose
        fprintf( 1, '%d stage files deleted.\n', n );
    end
end
