function ok = appendFileToStream( fid, filename )
%ok = appendFileToStream( fid, filename )
%   Append the contents of the named file to the open output stream.
%   The result is true if the operation succeeds, false otherwise.  No
%   error messages are generated if the operation fails.

    ok = false;
    if exist( filename, 'file' ) ~= 2
        return;
    end
    fid_in = fopen( filename, 'r' );
    if fid_in == -1
        return;
    end
    contents = fread( fid_in, inf );
    fwrite( fid, contents );
    fclose( fid_in );
    ok = true;
end
