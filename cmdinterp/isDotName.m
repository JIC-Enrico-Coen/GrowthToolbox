function ok = isDotName( s )
    t = splitString( '\.', s );
    for i=1:length(t)
        if ~isMatlabName( t{i} )
            ok = 0;
            return;
        end
    end
    ok = 1;
end

