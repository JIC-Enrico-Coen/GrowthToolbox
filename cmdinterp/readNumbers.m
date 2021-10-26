function [ts,argarray] = readNumbers( ts )
%[ts,argarray] = readNumbers( ts )
%   Read numbers from the token stream ts until end of stream or a
%   non-number is detected.  Return the numbers in the one-dimensional
%   array argarray.

    argarray = [];
    i = 0;
    while 1
        [ts,t] = readtoken( ts );
        n = textscan( t, '%d' );
        n = n{1};
        ok = ~isempty(n);
        if ok
            i = i+1;
            argarray(i) = n;
        else
            ts = putback( ts, t );
            break;
        end
    end
end

