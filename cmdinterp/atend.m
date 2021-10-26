function [tokenstream,ended] = atend( tokenstream )
%[tokenstream,ended] = atend( tokenstream )
%   Test whether a token stream is at the end.

    [tokenstream,t] = readtoken( tokenstream );
    ended = isempty(t);
    if ~ended
        tokenstream = putback( tokenstream, t );
    end
end
