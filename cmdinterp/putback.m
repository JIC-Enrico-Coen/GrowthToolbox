function tokenstream = putback( tokenstream, token )
%tokenstream = putback( tokenstream, token )
% Put a token back into the stream, so that that token will be the next
% token read.  Note that the token is not inserted into the underlying
% file.
    if tokenstream.curtok > 1
        tokenstream.curtok = tokenstream.curtok-1;
        tokenstream.tokens{tokenstream.curtok} = token;
    elseif isempty(tokenstream.tokens)
        tokenstream.tokens = { token };
    else
        tokenstream.tokens = [ token, tokenstream.tokens ];
    end
end
