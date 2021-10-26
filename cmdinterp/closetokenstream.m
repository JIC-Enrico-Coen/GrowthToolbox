function tokenstream = closetokenstream( tokenstream )
%tokenstream = closetokenstream( tokenstream )
%Close the token stream and the underlying file, discarding any unused
%data.
    if tokenstream.fid ~= -1
        fclose( tokenstream.fid );
        tokenstream.fid = -1;
    end
    tokenstream.tokens = [];
    tokenstream.curtok = 1;
    tokenstream.curline = 0;
end
