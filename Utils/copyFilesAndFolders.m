function ok = copyFilesAndFolders( oldpath, newpath, includepats, excludepats, excludeprefixes )
%copyFilesAndFolders( oldpath, newpath, includes, excludes )
%
%   Copy all files and folders from OLDPATH to NEWPATH that match any of
%   the patterns in INCLUDES and do not match any of the patterns in
%   EXCLUDES.
%
%   OLDPATH must exist. NEWPATH will be created.
%   INCLUDES and EXCLUDES are cell arrays of regular expressions.
%   If INCLUDES is empty, it matches everything.

    ok = true;
    FOR_REAL = true;
    VERBOSE = 2;
    
    % Preprocess arguments.
    if nargin < 3
        includepats = {};
    end
    if nargin < 4
        excludepats = {};
    end
    if ischar(includepats)
        includepats = { includepats };
    end
    if ischar(excludepats)
        excludepats = { excludepats };
    end
    for i=1:length(includepats)
        includepats{i} = lower( includepats{i} );
    end
    for i=1:length(excludepats)
        excludepats{i} = lower( excludepats{i} );
    end
    
    % OLDPATH must exist.
    if ~exist( oldpath, 'file' )
        if VERBOSE >= 1
            fprintf( 1, '%s: %s does not exist.\n', mfilename(), oldpath );
        end
        ok = false;
        return;
    end
    
    % If OLDPATH is not a directory, it must be a file, in which cse we
    % copy it and return.
    if ~exist( oldpath, 'dir' )
        if exist( newpath, 'dir' )
            if VERBOSE >= 1
                warning( [mfilename(), ': cannot copy a file onto the directory ', ...
                          newpath]);
            end
            ok = false;
            return;
        end
        if VERBOSE >= 2
            fprintf( 1, 'Copying %s to %s\n', oldpath, newpath );
        end
        if FOR_REAL
            [success,msg,msgid] = copyfile( oldpath, newpath );
            if ~success
                if VERBOSE >= 1
                    warning(msgid, [mfilename(), ': ', msg]);
                end
                ok = false;
            end
        end
        return;
    end
    
    % If NEWPATH does not exist, create it.  If creation fails or if there
    % is already a file called NEWPATH, return.
    if ~exist( newpath, 'dir' )
        if exist( newpath, 'file' )
            if VERBOSE >= 1
                warning( [mfilename(), ': cannot copy a directory onto the file ', ...
                          newpath] );
            end
            ok = false;
            return;
        end
        if FOR_REAL
            [success, msg, msgid] = mkdir( newpath );
        else
            success = true;
        end
        if success
            if VERBOSE >= 2
                fprintf( 1, 'Created directory %s\n', newpath );
            end
        else
            if VERBOSE >= 1
                warning(msgid, [mfilename(), ': ', msg]);
            end
            ok = false;
            return;
        end
    end
    
    % List the contents of OLDPATH and copy each element over to NEWPATH.
    x = dir( oldpath );
    for i=1:length(x)
        n = x(i).name;
        
        % Never copy '.' or '..'.
        if strcmp( n, '.' ), continue; end
        if strcmp( n, '..' ), continue; end
        
        % If INCLUDES is given, only copy things that match at least one
        % item.
        if isempty( includepats )
            include = true;
        else
            include = false;
            for j=1:length(includepats)
                if regexpi( n, includepats{j} )
                    include = true;
                    break;
                end
            end
        end
        if ~include
            if VERBOSE >= 2
                fprintf( 1, '%s did not match the include patterns.\n', fullfile( oldpath, n ) );
            end
            continue;
        end
        
        % If EXCLUDES is given, do not copy anything which matches at least
        % one item.
        if ~isempty( excludepats )
            for j=1:length(excludepats)
                if regexpi( n, excludepats{j} )
                    include = false;
                    if VERBOSE >= 2
                        fprintf( 1, '%s matched the exclude patterns.\n', fullfile( oldpath, n ) );
                    end
                    break;
                end
            end
            if ~include, continue; end
        end
        
        if ~isempty( excludeprefixes )
            for j=1:length(excludeprefixes)
                if beginsWithString( n, excludeprefixes{j} )
                    include = false;
                    if VERBOSE >= 2
                        fprintf( 1, '%s matched an exclude prefix.\n', fullfile( oldpath, n ) );
                    end
                    break;
                end
            end
            if ~include, continue; end
        end
        
        % Do the copy.  If it's a file, copy it.  If it's a directory, make
        % a new directory and recursively copy the contents, but without
        % the include and exclude lists.
        ox = fullfile( oldpath, n );
        nx = fullfile( newpath, n );
        if exist( ox, 'dir' )
            if VERBOSE >= 2
                fprintf( 1, 'Creating directory %s\n', nx );
            end
            if FOR_REAL
                [success, msg, msgid] = mkdir( nx );
            else
                success = true;
            end
            if success
                copyFilesAndFolders( ox, nx );
            else
                if VERBOSE >= 1
                    warning(msgid, [mfilename(), ': ', msg]);
                end
                ok = false;
            end
        else
            if VERBOSE >= 2
                fprintf( 1, 'Copying %s to %s\n', ox, nx );
            end
            if FOR_REAL
                [success,msg,msgid] = copyfile( ox, nx );
                if ~success
                    if VERBOSE >= 1
                        warning(msgid, [mfilename(), ': ', msg]);
                    end
                    ok = false;
                end
            end
        end
    end
end
