function [m,ok,stageid] = loadLastValidStage( runsdir, runname, projectbasename, includeStatic, lastvalid )
%[m,ok,stageid] = loadLastValidStage( runsdir, runname, projectbasename, includeStatic, offset )
%   Load the last valid stage file for a given run.
%
%   RUNSDIR is a directory containing some runs. If this is a full path
%       name it need not be within a project. Otherwise it will be searched
%       for 
%
%   RUNNAME is the name of the particular run.
%
%   PROJECTBASENAME is the name of the project. This is only used to
%       identify the stage files of the run.
%
%   INCLUDESTATIC specifies whether to load the static file for the
%       project. Default is true.
%
%   LASTVALID is true of the last stage file is guaranteed to be valid.
%       Default is false.

    m = [];
    ok = false;
    stageid = [];
    if (nargin < 4) || isempty( includeStatic )
        includeStatic = true;
    end
    
    if nargin < 5
        lastvalid = false;
    end
    
%     [projectParentDir,b,c] = fileparts( project );
%     projectbasename = [ b c ];
%     if isempty(projectParentDir)
%         [projectfullpath,projectexists] = findGFtboxProject( projectParentDir );
%     end
    
    if exist( runsdir, 'dir' )
        % Use it as the runs dir.
    elseif isFullPathname( runsdir )
        % Fail.
        timedFprintf( 'Cannot find runs dir "%s".\n', runsdir );
        return;
    else
        [projectfullpath,status] = findGFtboxProject( projectbasename );
        if ~isempty(status)
            timedFprintf( 'Cannot find project "%s".\n', projectbasename );
            return;
        end
        fullrunsdir = fullfile( projectfullpath, runsdir );
        if ~exist( runsdir, 'dir' )
            % Fail
            timedFprintf( 'Cannot find runs dir "%s".\n', fullrunsdir );
            return;
        end
        runsdir = fullrunsdir;
    end
    
    meshesdir = fullfile( runsdir, runname, 'meshes' );
    meshpattern = fullfile( meshesdir, [ projectbasename, '_s*.mat' ] );
    sfdata = dir( meshpattern );
    sfnames = { sfdata.name };
    numStageFiles = length(sfnames);
    if numStageFiles==0
        % Fail.
        timedFprintf( 'No stage files in "%s".\n', runsdir );
        return;
    end
    if regexp( sfnames{1}, '_s0+\.mat$' )
        sfnames(1) = [];
        numStageFiles = numStageFiles-1;
        if numStageFiles==0
            % Fail.
            timedFprintf( 'No stage files except s000000 in "%s".\n', runsdir );
            return;
        end
    end
    if lastvalid || (numStageFiles==1)
        % Take the last
        stagefilename = sfnames{end};
    else
        % Take the penultimate.
        stagefilename = sfnames{end-1};
    end
    zz = regexp( stagefilename, '(_s[0-9]+)\.mat$', 'tokens' );
    stageid = zz{1}{1};
    stagefullname = fullfile( meshesdir, stagefilename );
    try
        if includeStatic
            [m,ok] = leaf_load( [], stagefullname, 'checkvalidity', false );
        else
            m = load( stagefullname );
            ok = true;
        end
    catch e %#ok<NASGU>
        m = [];
        ok = false;
    end
    
    
    
    
    
%     for si=(length(sfnames)-lastvalid):-1:1
%         stagefilename = sfnames{si};
%         zz = regexp( stagefilename, '(_s[0-9]+)\.mat$', 'tokens' );
%         if isempty(zz) || isempty( zz{1} )
%             continue;
%         end
%         stageid = zz{1}{1};
%         if e
%             continue;
%         end
%         stagefullname = fullfile( meshesdir, stagefilename );
%         try
%             if includeStatic
%                 [m,ok] = leaf_load( [], stagefullname, 'checkvalidity', false );
%             else
%                 m = load( stagefullname );
%                 ok = true;
%             end
%         catch e %#ok<NASGU>
%             m = [];
%             ok = false;
%         end
%         if ok
%             break;
%         end
%     end
    
    if ~ok
        timedFprintf( 'Could not find any valid stage file in %s\n', meshesdir );
    end
end

