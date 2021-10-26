function tokenstream = opentokenstream( filename )
%Create a token input stream from a filename.

    fid = fopen( filename );
    if fid == -1
        tokenstream = [];
    else
        tokenstream = emptytokenstream();
        tokenstream.name = filename;
        tokenstream.fid = fid;
    end
end
