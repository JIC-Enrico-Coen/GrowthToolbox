function [txt,ok] = readtextfile( filename )
%[txt,ok] = readtextfile( filename )
%   Read the entire contents of a file into a string. OK is false if the
%   file could not be opened.
%
%   See also readFileToStrings.

    fid = fopen( filename, 'r' );
    ok = fid ~= -1;
    if ok
        txt = fread( fid, Inf, 'uint8=>char' )';
        fclose(fid);
    else
        txt = [];
    end
end