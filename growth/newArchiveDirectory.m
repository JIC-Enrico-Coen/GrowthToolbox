function a = newArchiveDirectory( adir, basename )
%a = newArchiveDirectory( adir, basename )
%   Create a directory whose name has the form basename_Annn.
%   nnn is chosen to be 1 if no such directory exists, or 1 more than the   
%   highest number for which such a directory does exist.

    oldcd = cd(adir);
    x = ls;
    e = [];
    for i = 1:size(x,1)
        s = regexp( x(i,:), '_A([0-9]+)$', 'tokens' );
        if ~isempty(s)
            n = sscanf( s{1}{1}, '%d', 1 );
            if ~isempty(n)
                e(length(e)+1) = n;
            end
        end
    end
    if isempty(e)
        an = 1;
    else
        an = max(e)+1;
    end
    a = sprintf( '%s_A%03d', basename, an );
    cd(oldcd);
end
