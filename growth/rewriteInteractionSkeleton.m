function [m,ok] = rewriteInteractionSkeleton( m, newIFname, newIFdir, msg )
%ok = rewriteInteractionSkeleton( m, newIFname, newIFdir, msg )
%   Regenerate the interaction function for M.
%
%JAB removed requirement for a leading \n since some editors insert spaces
%automatically
%Also, it seems that some versions of Matlab return tokenExtents as a cell
%array of one element from which the matrix must be extracted.

    ok = false;
    oldIFname = makeIFname( m.globalProps.modelname );
    oldIFdir = getModelDir( m );
    oldIFfullname = fullfile( oldIFdir, [ oldIFname, '.m' ] );
    if ~exist( oldIFfullname, 'file' )
        % No interaction function.  Don't create one.
        ok = true;
        return;
    end
    
    fprintf( 1, '%s\n', mfilename() );

    oldIFbakfullname = fullfile( oldIFdir, [ oldIFname, 'BAK.m' ] );
    if isempty( newIFname )
        newIFname = oldIFname;
    end
    if isempty( newIFdir )
        newIFdir = oldIFdir;
    end
    newIFfullname = fullfile( newIFdir, [ newIFname, '.m' ] );

    [success,msg1,msgid] = copyfile( oldIFfullname, oldIFbakfullname, 'f' );
    if ~success
        fprintf( 1, 'Cannot make backup of interaction function %s.\n  Proceeding to overwrite it anyway.\n', ...
            oldIFfullname );
        warning( msgid, msg1 );
    end
    fid = fopen( oldIFfullname, 'r' );
    if fid == -1
        fprintf( 1, '%s: Cannot find interaction function %s.m in %s.\n', ...
            msg, oldIFname, oldIFdir );
        return;
    end
    contents = fread( fid, inf, '*char' )';
    fclose( fid );
    userCodeSections = getUserCode( contents );
    [s,e,tokenExtents] = regexp( contents, ...
        '^function (m|\[\s*m\s*,\s*result\s*\])\s*=\s*([A-Za-z_][A-Za-z_0-9]*)[^\n]*\s*%(m|\[\s*m\s*,\s*result\s*\])\s*=\s*([A-Za-z_][A-Za-z_0-9]*)', ...
        'once' );
    if any( size(tokenExtents) ~= [4 2] )
        beep;
        fprintf( 1, ...
            '%s: Function header not found: interaction function not copied.\n', ...
            msg );
        m.globalProps.mgen_interactionName = [];
        m = resetInteractionHandle( m, msg );
        return;
    end
    if iscell(tokenExtents)
        tokenExtents=tokenExtents{1};
    end
    if isempty( userCodeSections )
        fid = fopen( newIFfullname, 'w' );
        if fid == -1
            beep;
            fprintf( 1, '%s: Cannot write to file %s.m in %s.\n', ...
                msg, newIFname, newIFdir );
            m.globalProps.mgen_interactionName = [];
            m = resetInteractionHandle( m, msg );
            return;
        end
        beep;
        fprintf( 1, ...
            ['%s: Delimiters for user code section not found.  The interaction\n', ...
             'function has been copied and renamed, but could not be updated with any new\n', ...
             'or renamed morphogens.\n' ], ...
            msg );
        m.globalProps.mgen_interactionName = newIFname;
        [m.globalProps.projectdir,m.globalProps.modelname] = dirparts( newIFdir );
        if m.globalProps.newcallbacks
            results = '[m,results]';
        else
            results = 'm';
        end
        contents = [ contents(1:(tokenExtents(1,1)-1)), ...
                     results, ...
                     contents((tokenExtents(1,2)+1):(tokenExtents(2,1)-1)), ...
                     newIFname, ...
                     contents((tokenExtents(2,2)+1):(tokenExtents(3,1)-1)), ...
                     newIFname, ...
                     contents((tokenExtents(3,2)+1):end) ];
        fwrite( fid, contents );
    else
        validateUserCode( newIFname, userCodeSections );
        fid = fopen( newIFfullname, 'w' );
        if fid == -1
            fprintf( 1, '%s: Cannot write to file %s.m in %s.\n', ...
                msg, newIFname, newIFdir );
            return;
        end
        try
            m.globalProps.mgen_interactionName = newIFname;
            [m.globalProps.projectdir,m.globalProps.modelname] = dirparts( newIFdir );
            generateInteractionFunction( fid, m, userCodeSections );
        catch e
            beep;
            e = lasterror();
            fprintf( 1, '** Failed to generate the interaction function:\n    %s.\nRestoring original.\n', ...
                e.message );
            [success,msg1,msgid] = copyfile( oldIFbakfullname, newIFfullname, 'f' );
            if ~success
                fprintf( 1, '**** Restoration of original interaction function failed.\n**** The  project is in a corrupt state.\n**** This problem must be fixed outside of GFtbox.\n' );
                error( msgid, msg1 );
            end
        end
    end
    fclose( fid );
    clear(m.globalProps.mgen_interactionName);
    m.rewriteIFneeded = false;
    writeUserCodeBackup( newIFdir, userCodeSections, 'init' );
    writeUserCodeBackup( newIFdir, userCodeSections, 'mid' );
    writeUserCodeBackup( newIFdir, userCodeSections, 'final' );
    writeUserCodeBackup( newIFdir, userCodeSections, 'subfunctions' );
    if m.globalProps.addedToPath && ~strcmp( oldIFdir, newIFdir );
        fprintf( 1, '%s: Removing %s from path.\n', mfilename(), oldIFdir );
        rmpath( oldIFdir );
    end
    
    ok = true;
    
    m = resetInteractionHandle( m, msg );
end

function ok = validateUserCode( filename, userCodeSections )
    ok = true;
    uf = fieldnames( userCodeSections );
    for fi=1:length(uf)
        fn = uf{fi};
        if ~isempty( regexp( userCodeSections.(fn), 'absKvector' ) )
            ok = false;
            break;
        end
    end
    if ~ok
        fprintf( 1, ['WARNING: The interaction function %s contains ', ...
            '"absKvector",\n  an obsolete component of the mesh stucture.\n', ...
            'It should be replaced by a call of leaf_mgen_conductivity or\n', ...
            'leaf_mgen_get_conductivity.\n' ], filename );
    end
end

function userCodeSections = getUserCode( contents )
    LINEEND = '(\r\n|\r|\n)';
    FINALJUNK = '[^\r\n]*';
    WHITESPACE = '\s*';
    VERTICALSPACE = '[\r\n\s]*';
    
    yourCodeOldStartDelim = [LINEEND WHITESPACE '%%% YOUR CODE BEGINS HERE' FINALJUNK LINEEND];
    yourCodeOldEndDelim = [LINEEND WHITESPACE '%%% END OF YOUR CODE'];
    yourCodeStart = regexp( contents, yourCodeOldStartDelim, 'end' );
    yourCodeEnd = regexp( contents, yourCodeOldEndDelim, 'start' );
    if ~(isempty( yourCodeStart ) || isempty( yourCodeEnd ))
        % Old-style i.f.
        userCodeSections.init = '';
        userCodeSections.mid = contents( (yourCodeStart+1) : yourCodeEnd );
        userCodeSections.final = '';
        userCodeSections.subfunctions = '';
        return;
    end
    
    userCodeStartDelim = [LINEEND WHITESPACE '%%% USER CODE' FINALJUNK LINEEND];
    userCodeEndDelim = [LINEEND WHITESPACE '%%% END OF USER CODE' FINALJUNK LINEEND];
    userCodeStart = regexp( contents, userCodeStartDelim, 'end' );
    userCodeEnd = regexp( contents, userCodeEndDelim, 'start' );
    
    if (length(userCodeStart)==3) && (length(userCodeEnd)==3)
        userCodeSections.init = contents( (userCodeStart(1)+1) : (userCodeEnd(1)-1) );
        userCodeSections.mid = contents( (userCodeStart(2)+1) : (userCodeEnd(2)-1) );
        userCodeSections.final = contents( (userCodeStart(3)+1) : (userCodeEnd(3)-1) );
        remainderpos = regexp( contents( userCodeEnd(3):end ), ...
            [LINEEND '\s*end\s*' LINEEND VERTICALSPACE], 'end' );
        userCodeSections.subfunctions = contents( (userCodeEnd(3)+remainderpos):end );
    elseif (length(userCodeStart)==4) && (length(userCodeEnd)==3)
        userCodeSections.init = contents( (userCodeStart(1)+1) : (userCodeEnd(1)-1) );
        userCodeSections.mid = contents( (userCodeStart(2)+1) : (userCodeEnd(2)-1) );
        userCodeSections.final = contents( (userCodeStart(3)+1) : (userCodeEnd(3)-1) );
        userCodeSections.subfunctions = contents( (userCodeStart(4)+1) : end );
    else
        complain( 'Error in interaction function: improper user code delimiters.' );
        userCodeStart
        userCodeEnd
        userCodeSections = [];
    end
end

function writeUserCodeBackup( dir, userCodeSections, fieldname );
    if isfield( userCodeSections, fieldname ) ...
            && ~isempty( userCodeSections.(fieldname) )
        ok = writefile( ...
                fullfile( dir, [ fieldname '.txt' ] ), ...
                userCodeSections.(fieldname) );
    end
end
