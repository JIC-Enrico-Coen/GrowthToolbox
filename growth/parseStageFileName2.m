function result = parseStageFileName2( sfn )
%[projectname, projectpathname, stagetime, runindex, varindex, repindex]
    result = struct( ...
        'projectname', '', ...
        'projectpathname', '', ...
        'stagetime', '', ...
        'runindex', '', ...
        'varindex', '', ...
        'repindex', '', ...
        'ok', true, ...
        'errmsg', false );
    [meshespath,result.stagefilebasename,ext] = fileparts( sfn );
    result.stagefilebasename = [ result.stagefilebasename, ext ];
    result1 = regexp( result.stagefilebasename, '_s(?<stagetime>[0-9.m]+)\.mat$', 'names' );
    if isempty(result1)
        result.ok = false;
        result.errmsg = sprintf( 'Stage time not found in stage file name %s.', result.stagefilebasename );
    else
        result.stagetime = result1.stagetime;
    end
    if isGFtboxProjectDir( meshespath )
        result.projectpathname = meshespath;
    else
        [rundirpath, meshesbasename] = fileparts( meshespath );
        if ~strcmp( meshesbasename, 'meshes' )
            result.errmsg = sprintf( 'Meshes dir should me called ''meshes'', is called %s.', meshesbasename );
        end
        [allrunsdirpath, rundirbasename] = fileparts( rundirpath );
        [projectdir, allrunsdirbasename] = fileparts( allrunsdirpath );
        if ~strcmp( allrunsdirbasename, 'runs' )
            result.errmsg = sprintf( 'Runs dir should me called ''runs'', is called %s.', allrunsdirbasename );
        end
        if isGFtboxProjectDir( projectdir )
            result.projectpathname = projectdir;
            [~,result.projectname] = fileparts( result.projectpathname );
            result1 = regexp( rundirbasename, '^(?<projectname>.+)_e(?<runindex>[0-9]+)_V(?<varindex>[0-9]+)R(?<repindex>[0-9]+)$', 'names' );
            if isempty( result1 )
                result.ok = false;
                result.errmsg = sprintf( 'Cannot parse run dir name: %s.', rundirbasename );
            else
                projectnamesagree = strcmp( result1.projectname, result.projectname );
                if ~projectnamesagree
                    result.ok = false;
                    result.errmsg = sprintf( 'Not a GFtbox project directory: %s.', result.projectpathname );
                end
                result1 = rmfield( result1, 'projectname' );
                result = setFromStruct( result, result1 );
            end
        else
            result.ok = false;
            result.errmsg = sprintf( 'Not a GFtbox project directory: %s.', result.projectpathname );
        end
    end
    [~,result.projectname] = fileparts( result.projectpathname );
end

