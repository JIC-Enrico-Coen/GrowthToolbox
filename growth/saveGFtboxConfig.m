function saveGFtboxConfig( handles )
global GFTboxConfig

    [~,~] = makeGFtboxUserConfigDir();
    
    % These fields are deliberately not saved, so we mark them as having
    % already been dealt with.
    processedFields = { 'defaultConfigFilename', 'userConfigFilename' };
    
    fid = fopen( handles.userConfigFilename, 'w' );
    if fid == -1
        fprintf( 1, 'Cannot write to %s.\n', handles.userConfigFilename );
    else
        fprintf( 1, 'Writing config to %s.\n', handles.userConfigFilename );
        saveconfigline( 'revnum', int32(handles.GFtboxRevision) );
        saveconfigline( 'revdate', handles.GFtboxRevisionDate );
        numdirs = length( handles.userProjectsDirs );
        for i=1:numdirs
            if (numdirs > 1) && strcmp( handles.userProjectsDirs{i}, handles.userProjectsDir )
                s = '* ';
            else
                s = '';
            end
            writeconfigline( fid, 'projectsdir', [s, handles.userProjectsDirs{i}] );
        end
        GFTboxConfig.projectsdir = handles.userProjectsDirs;
        processedFields{end+1} = 'projectsdir';
        
        saveconfigline( 'defaultprojectdir', handles.userProjectsDir );
        
        recentprojectsItems = getMenuChildren( handles.recentprojectsMenu );
        recentprojectdirs = cell(1,length(recentprojectsItems));
        rpdi = 0;
        for i=1:length(recentprojectsItems)
            ud = get( recentprojectsItems(i), 'UserData' );
            if ~isempty(ud) && isfield( ud, 'modeldir' )
                rpdi = rpdi+1;
                recentprojectdirs{rpdi} = ud.modeldir;
            end
        end
        recentprojectdirs( (rpdi+1):end ) = [];
        saveconfigline( 'recentproject', recentprojectdirs );
        
        saveconfigline( 'compressor', getSelectedCompressor( handles.codecMenu ) )
        if isfield( handles, 'fontdetails' )
            if ~isfield(handles.fontdetails,'FontName')
                handles.fontdetails.FontName=get(0,'FixedWidthFontName');
            end
            saveconfigline( 'FontName', handles.fontdetails.FontName );
            saveconfigline( 'FontUnits', handles.fontdetails.FontUnits );
            saveconfigline( 'FontSize', handles.fontdetails.FontSize );
            saveconfigline( 'FontWeight', handles.fontdetails.FontWeight );
            saveconfigline( 'FontAngle', handles.fontdetails.FontAngle );
        end
        saveconfigline( 'bioedgethickness', get(handles.bioAlinesizeText,'String') );
        saveconfigline( 'biovertexsize', get(handles.bioApointsizeText,'String') );
        saveconfigline( 'Renderer', handles.Renderer );
        saveconfigline( 'usegraphicscard', ischeckedMenuItem( handles.useGraphicsCardItem ) );
        saveconfigline( 'catchIFExceptions', handles.catchIFExceptions );
        saveconfigline( 'remotehost', GFTboxConfig.remotehost );
        saveconfigline( 'remoteuser', GFTboxConfig.remoteuser );
        fclose( fid );
    end
    
    UNPROCESSEDFIELDS = setdiff( fieldnames(GFTboxConfig), processedFields );
    if ~isempty( UNPROCESSEDFIELDS )
        fprintf( 1, 'Warning: these items were not saved to the config file:\n    ''%s''\n', ...
            joinstrings( ''', ''', UNPROCESSEDFIELDS ) );
    end

function saveconfigline( field, value )
    writeconfigline( fid, field, value );
    GFTboxConfig.(field) = value;
    processedFields{end+1} = field;
end
end

function writeconfigline( fid, field, value )
    if iscell( value )
        for i=1:length(value)
            writeconfigline( fid, field, value{i} );
        end
        return;
    end
    
    if isinteger( value )
        format = '%d';
    elseif isfloat( value )
        format = '%f';
    elseif ischar( value )
        format = '%s';
    elseif islogical( value )
        value = boolchar( value, 'true', 'false' );
        format = '%s';
    else
        format = '%s';
    end
    fprintf( fid, ['%s ' format '\n'], field, value );
end

    
