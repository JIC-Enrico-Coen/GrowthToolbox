function m = resetInteractionHandle( m, msg )
%m = resetInteractionHandle( m, msg )
%   Get a handle to the interaction function.  This should be called
%   whenever M has been loaded from a file or a new interaction function
%   has been created.

fprintf( 1, '%s\n', mfilename() );

    ok = true;
    added = false;
    ifdir = getModelDir( m );
    if ~exist(ifdir,'dir')
        return;
    end
    ifname = makeIFname( m.globalProps.modelname );
    m.globalProps.mgen_interactionName = '';
    m.globalProps.mgen_interaction = [];
    m.globalProps.interactionValid = true;

    if isempty(ifname)
        ok = false;
    end
    
    fh = '';

    if ok
        added = addpathif( ifdir );
        if exist(fullfile( ifdir, ifname ),'file')==2
            try
                fh = str2func( ifname );
            catch e
                fprintf( 1, '%s: "%s" is not a valid function name:\n', msg, ifname );
                simpleExceptionMessage( e );
                ok = false;
            end
        end
    end
    
    if ok && ~isempty(fh)
        m.globalProps.mgen_interaction = fh;
        m.globalProps.mgen_interactionName = ifname;
        try
            fh( [] );
        catch e
            m.globalProps.interactionValid = false;
            fprintf( 1, '%s: interaction function %s is not working:\n', msg, ifname );
            simpleExceptionMessage( e );
            ok = false;
        end
    end
    
    if ok
        if added
            m.globalProps.addedToPath = true;
        elseif ~strcmp( ifdir, getModelDir( m ) )
            m.globalProps.addedToPath = false;
        end
    else
      % if added
      %     fprintf( 1, 'Deleting %s from path.\n', ifdir );
      %     rmpath( ifdir );
      % end
    end
end
