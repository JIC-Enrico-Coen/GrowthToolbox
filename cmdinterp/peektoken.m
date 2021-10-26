function [ts,t] = peektoken( ts )
    [ts,t] = readtoken( ts );
    if ~isempty(t)
        ts = putback( ts, t );
    end
end
