function [tokenstream,token,eos] = readtoken( tokenstream )
%[tokenstream,token] = readtoken( tokenstream )
%   Read a token from a stream.  EOS is returned if the stream has ended,
%   in which case TOKEN is empty.  Note that an empty token can be validly
%   returned even if the stream has not ended, for example if the
%   underlying file contains an empty quoted string.  Therefore to test
%   whether no token was found, test EOS. 

    eos = false;
    if tokenstream.curtok <= length(tokenstream.tokens)
        token = tokenstream.tokens{tokenstream.curtok};
        if tokenstream.curtok == length(tokenstream.tokens)
            tokenstream.curtok = 1;
            tokenstream.tokens = {};
        else
            tokenstream.curtok = tokenstream.curtok+1;
        end
    else
        tokenstream = refillbuffer( tokenstream );
        if ~isempty(tokenstream.tokens)
            token = tokenstream.tokens{1};
            if length(tokenstream.tokens)==1
                tokenstream.tokens = {};
            else
                tokenstream.curtok = 2;
            end
        else
            token = '';
            eos = true;
        end
    end
end
