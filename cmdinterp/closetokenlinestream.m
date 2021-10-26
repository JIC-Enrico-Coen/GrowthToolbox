function tokenstream = closetokenlinestream( tokenstream )
%tokenstream = closetokenlinestream( tokenstream )
%Close the token-line stream and the underlying file, discarding any unused
%data.
    if tokenstream.fid ~= -1
        fclose( tokenstream.fid );
        tokenstream.fid = -1;
    end
    tokenstream.curline = 0;
end
