function [ts,toks] = readtokenline( ts )
%[ts,toks] = readtokens( ts )
%   Read a nonempty line of tokens.
%   Returns an empty cell array at end of file.

    if ts.fid == -1
        toks = {};
    else
        while 1
            s = fgetl( ts.fid );
            if s == -1
                ts.fid = -1;
                toks = {};
                return;
            else
                ts.curline = ts.curline+1;
                toks = tokeniseString( s );
                if ~isempty(toks)
                    while strcmp( toks{length(toks)}, '...' )
                        toks = { toks{1:(length(toks)-1)} };
                        s = fgetl( ts.fid );
                        if s == -1
                            ts.fid = -1;
                            return;
                        else
                            moretoks = tokeniseString( s );
                            if isempty(moretoks)
                                return;
                            end
                            toks = { toks{:} moretoks{:} };
                        end
                    end
                    return;
                end
            end
        end
    end
end
