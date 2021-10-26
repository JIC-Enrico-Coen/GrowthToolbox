function v = validindexes( a )
    if isinteger(a)
        v = a ~= -1;
    else
        v = ~isnan(a);
    end
end
