function names = index2Name( dict, indexes )
    if ischar( indexes )
        if isfield( dict.name2IndexMap, indexes )
            names = indexes;
        else
            names = {};
        end
    elseif iscell( indexes )
        names = intersect( indexes, dict.index2NameMap );
    else
        indexes = indexes( (indexes>0) & (indexes <= length(dict.index2NameMap)) );
        names = dict.index2NameMap(indexes);
    end
    if iscell(names) && (length(names)==1)
        names = names{1};
    end
end
