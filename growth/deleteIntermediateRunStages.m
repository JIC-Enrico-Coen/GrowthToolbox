function numdeleted = deleteIntermediateRunStages( projectname, runcode, dryrun )
%numdeleted = deleteIntermediateRunStages( projectname, runcode )
%
%   Delete all stages of specified runs except the first and the last.
%
%   If RUNCODE is omitted, all runs in the given project have this done.

    if nargin < 3
        dryrun = false;
    end
    numdeleted = 0;
    [projectfullpath,status] = findGFtboxProject( projectname );
    if ~isempty(status)
        timedFprintf( 'Cannot find GFtbox project %s: %s.\n', projectname, status );
        return;
    end
    [~,projectBaseName] = fileparts( projectfullpath );
    
    runsdir = fullfile( projectfullpath, 'runs' );
    if ~exist( runsdir, 'dir' )
        timedFprintf( 'No runs directory in project %s.\n', projectname );
        return;
    end
    
    if (nargin < 2) || isempty(runcode)
        runcode = [0 0 0];
        runsdirlist = dir( runsdir );
    else
        runsdirlist = dir( fullfile( runsdir, [ projectBaseName, '*' ] ) );
    end
    runnames = { runsdirlist.name }';
    isdir = false( length(runnames), 1 );
    for ri=1:length(runnames)
        isdir(ri) = (runnames{ri}(1) ~= '.') && exist( fullfile( runsdir, runnames{ri}, 'meshes' ), 'dir' );
    end
    runnames = runnames(isdir);

    if size(runcode,2)==2
        runcode = [ runcode, zeros(length(runcode,2)) ];
    end
    
    bytesDeleted = 0;
        
    for ri=1:size(runcode,1)
        runindex = runcode(ri,1);
        variantindex = runcode(ri,2);
        repindex = runcode(ri,3);
        if all( [ runindex variantindex repindex ] == 0 )
            selectedSubruns = runnames;
        else
            if runindex==0
                runPattern = '_e[0-9]+';
            else
                runPattern = sprintf( '_e%06d', runindex );
            end
            if variantindex==0
                variantPattern = 'V[0-9]*';
            else
                variantPattern = sprintf( 'V%03d', variantindex );
            end
            if repindex==0
                repPattern = 'R[0-9]+';
            else
                repPattern = sprintf( 'R%03d', repindex );
            end
            subrunsPattern = [ runPattern, '_', variantPattern, repPattern, '$' ];
            subrunMatching = regexp( runnames, subrunsPattern );
            subrunNonEmpty = false( length(subrunMatching), 1 );
            for sri=1:length(subrunMatching)
                subrunNonEmpty(sri) = ~isempty( subrunMatching{sri} );
            end
            selectedSubruns = runnames( subrunNonEmpty );
        end
        
        for ssri=1:length(selectedSubruns)
            subrunbasename = selectedSubruns{ssri};
            subrundir = fullfile( runsdir, subrunbasename );
            meshesdir = fullfile( subrundir, 'meshes' );
            if ~exist( meshesdir, 'dir' )
                timedFprintf( 'No meshes dir for sub-run %s of project %s.\n', subrundir, projectname );
                continue;
            end
            mesheslist = dir( fullfile( meshesdir, [ projectBaseName, '*.mat' ] ) );
            meshnames = { mesheslist.name };
            meshnames = sort( meshnames )';
            okmeshname = false( length(meshnames), 1 );
            stagestring = cell( length(meshnames), 1 );
            for mni=1:length(meshnames)
                [ stagestring{mni}, okmeshname(mni) ] = removeStringPrefix( meshnames{mni}, projectBaseName );
                if okmeshname(mni)
                    okmeshname(mni) = ~isempty( regexp( stagestring{mni}, '^_s[0-9md]+\.mat$', 'once' ) );
                end
            end
            meshnames = meshnames( okmeshname );
            if isempty(meshnames)
                continue;
            end
            
%             if subrunbasename(1) ~= 'G'
%                 xxxx = 1;
%             end
            
            timedFprintf( 'Not deleting first stage %s\n    or last stage %s\n', meshnames{1}, meshnames{end} );
            meshnames( [1 end] ) = [];
            for mni=1:length(meshnames)
                meshToDeleteBaseName = meshnames{mni};
                meshToDeleteFullPath = fullfile( meshesdir, meshToDeleteBaseName );
                s = dir(meshToDeleteFullPath);
                bytesDeleted = bytesDeleted + s.bytes;
                timedFprintf( '%s file %s from sub-run %s\n', ...
                    boolchar( dryrun, 'Dry run: not deleting', 'Deleting' ), ...
                    meshToDeleteBaseName, ...
                    subrunbasename );
                if ~dryrun
                    delete( meshToDeleteFullPath );
                end
                numdeleted = numdeleted+1;
                pngToDeleteBaseName = regexprep( meshToDeleteBaseName, '\.mat$', '.png' );
                pngToDeleteFullPath = fullfile( meshesdir, pngToDeleteBaseName );
                if exist( pngToDeleteFullPath, 'file' )
                    numdeleted = numdeleted+1;
                    s = dir(pngToDeleteFullPath);
                    bytesDeleted = bytesDeleted + s.bytes;
                    timedFprintf( '%s image file %s from sub-run %s\n', ...
                        boolchar( dryrun, 'Dry run: not deleting', 'Deleting' ), ...
                        pngToDeleteBaseName, ...
                        subrunbasename );
                    if ~dryrun
                        delete( pngToDeleteFullPath );
                    end
                end
            end
            xxxx = 1;
        end
        xxxx = 1;
    end
    timedFprintf( '%d files %s, %.3f GB.\n', numdeleted, boolchar( dryrun, 'found to delete', 'deleted' ), bytesDeleted/(1024*1048576) );
end

