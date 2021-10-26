function ok = writefile( filename, contents, append )
%ok = writefile( filename, contents, append )
%   Write a string to a named file.  Returns true on success, false on
%   failure. If APPEND is true, it appends, otherwise overwrites. The
%   default is to overwrite.

    if nargin < 3
        append = false;
    end
    fid = fopen( filename, boolchar( append, 'a', 'w' ) );
    ok = fid ~= -1;
    if ok
        fwrite( fid, contents );
        ok = fclose( fid ) ~= -1;
    end
end
