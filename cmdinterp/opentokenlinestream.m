function tokenstream = opentokenlinestream( filename )
%tokenstream = opentokenlinestream( filename )
%   Create a token-line input stream from a filename.
%   Each read from this returns a cell array of tokens, consisting of the
%   contents of a nonempty line.
    fid = fopen( filename );
    if fid == -1
        tokenstream = [];
    end
    tokenstream.name = filename;
    tokenstream.fid = fid;
    tokenstream.curline = 0;
end
