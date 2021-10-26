function [ss,ok] = readFileToStrings( fid )
%[ss,ok] = readFileToStrings( fid )
%   From the file descriptor FID for an open text file, read every line,
%   excluding the line terminator, and return the result as a cell array of
%   char arrays. Close the file at the end.
%
%ss = readFileToStrings( filename )
%   The named file will be opened, then read as above.
%
%   See also readtextfile.

    if ischar(fid)
        filename = fid;
        fid = fopen( filename, 'r' );
    end
    ok = fid ~= -1;
    
    if ~ok
        ss = {};
        return;
    end
    
    sslen = 100;
    ss = cell( 1, sslen );
    ln = 0;
    while true
        line = fgetl(fid);
        if iseof( line )
            break;
        else
            ln = ln + 1;
            if ln > sslen
                sslen = sslen*2;
                ss{sslen} = '';
            end
            ss{ln} = line;
        end
    end
    ss((ln+1):end) = [];
    fclose(fid);
end