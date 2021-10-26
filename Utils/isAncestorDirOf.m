function result = isAncestorDirOf( a, d )
%result = isAncestorDirOf( a, d )
%   Return TRUE if the pathname A is a prefix of pathname D.

    if isempty(a)
        result = false;
        return;
    end
    aparts = allfileparts( a );
    dparts = allfileparts( d );
    if length(aparts) > length(dparts)
        result = false;
        return;
    end
    for i=1:length(aparts)
        if ~strcmp( aparts{i}, dparts{i} )
            result = false;
            return;
        end
    end
    result = true;
end

