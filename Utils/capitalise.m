function s1 = capitalise( s )
    if isempty(s)
        s1 = '';
    else
        s1 = [ upper(s(1)), s(2:end) ];
    end
end
