function setMeshParams( h, params )
% fprintf( 1, '%s\n', mfilename() );
    global MESH_PARAMS;
    if isstruct(params)
        if isfield( params, 'type' )
            meshtype = params.type;
        else
            meshtype = 'unknown';
        end
    else
        meshtype = regexprep( lower(params), '[^a-z0-9]', '' );
        params = [];
    end
    if strcmp( meshtype, 'unknown' )
        return;
    end
    if ~isfield( MESH_PARAMS, meshtype )
        fprintf( 1, '%s: Unknown mesh type ''%s''.\n', ...
            mfilename(), meshtype );
        return;
    end
    guiparams = MESH_PARAMS.(meshtype);
    guiparams = safermfield( guiparams, 'otherparams' );
    menulabel = guiparams.menuname;
    ok = selectMenuByLabel( h.generatetype, menulabel );
    if ~ok
        complain( '%s: Cannot find mesh type ''%s'' in menu ''%s''.\n', ...
            menulabel, get( h.generatetype, 'Tag' ) );
        return;
    end
    NUMROWS = 3;
    NUMCOLS = 3;
    visibility = false( NUMROWS, NUMCOLS );
    f = fieldnames( guiparams );
    for i=1:length(f)
        fn = f{i};
        fieldparams = guiparams.(fn);
        if isstruct( fieldparams ) && (isempty( params ) || isfield( params, fn ))
            if isempty( params )
                val = fieldparams.default;
            else
                val = params.(fn);
            end
            if (fieldparams.row > 0) && (fieldparams.col > 0)
                paramtag = sprintf( 'geomparam%d%d', fieldparams.row, fieldparams.col );
                paramtexttag = [ paramtag 'Text' ];
                try
                    paramitem = h.(paramtag);
                    paramtextitem = h.(paramtexttag);
                    set( paramitem, 'String', num2string( val ), 'Visible', 'on', ...
                         'Tooltip', fieldparams.tooltip );
                    set( paramtextitem, 'String', fieldparams.guiname, 'Visible', 'on', ...
                         'Tooltip', fieldparams.tooltip );
                    visibility(fieldparams.row,fieldparams.col) = true;
                  % fprintf( 1, 'Set item ''%s'' to ''%s''.\n', ...
                  %     paramitem, num2string( val ) );
                catch e
                    fprintf( 1, '%s: something went wrong: %d %s %s %s:\n    %s\n', ...
                        mfilename(), i, fn, paramtag, paramtexttag, e.message );
                end
            end
        end
    end
    for r=1:NUMROWS
        for c=1:NUMCOLS
            if ~visibility(r,c)
                paramtag = sprintf( 'geomparam%d%d', r, c );
                paramtexttag = [ paramtag 'Text' ];
                tryset( h.(paramtag), 'Visible', 'off', 'Tooltip', '' );
                tryset( h.(paramtexttag), 'Visible', 'off', 'Tooltip', '' );
            end
        end
    end
end
