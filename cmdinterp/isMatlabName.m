function ok = isMatlabName( s )
    if regexp( s, '[A-Za-z][A-Za-z0-9_]*' )
        ok = 1;
    else
        ok = 0;
    end
end
