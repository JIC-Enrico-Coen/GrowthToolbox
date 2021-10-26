function pname = fullpath( fname, relto )
%pname = fullpath( fname, relto )
%   Find the full path name of a given file name.  If the filename is
%   relative, it is taken to be relative to the directory relto, which
%   defaults to the current directory.  If relto is itself a relative name,
%   it will be interpreted relative to the current directory.

    if ~isempty(regexp( fname, '^[A-Za-z]:', 'once' )) || ~isempty(regexp( fname, '^[/\\]', 'once' ))
        % fname is an absolute path.
        pname = fname;
        return
    end
    
    if (nargin < 2) || isempty(relto)
        relto = pwd;
    else
        relto = fullpath( relto );
    end
    
    % Remove all trailing directory separators.
    relto = regexprep( relto, '[/\\]*$', '' );
    if isempty(relto)
        % If there is nothing left, set relto to the root.
        relto = '/';
    end
    
    if strcmp( fname, '.' )
        % fname is the current directory.
        pname = relto;
        return;
    end
    
    if strcmp( fname, '..' )
        % fname is the parent of the current directory.
        [pname,f,e] = fileparts( relto );
        return;
    end
    
    resti = regexp( fname, '^\.[/\\]+', 'end' );
    if resti
        % fname is explicitly relative to the current directory.  Take off
        % the first element and try again.
        pname = fullpath( fname((resti+1):end), relto );
        return;
    end
    
    resti = regexp( fname, '^\.\.[/\\]+', 'end' );
    if resti
        % fname is explicitly relative to the parent of the current
        % directory.  Take off the first element of fname and the last
        % element of relto and try again.
        [p,f,e] = fileparts( relto );
        pname = fullpath( fname((resti+1):end), p );
        return;
    end
    
    endfirst = regexp( fname, '^[^/\\]+[/\\]*', 'end' );
    
    if isempty(endfirst)
        pname = fullfile( relto, fname );
        return;
    end
    
    pname = fullpath( fname((endfirst+1):end), fullfile( relto, fname(1:endfirst) ) );
end
