function [dictionary,ok] = renameInDict( dictionary, oldnames, newnames )
%dictionary = renameInDict( dictionary, oldnames, newnames )

    ok = true;
    oldnames = setcase( dictionary.case, oldnames );
    newnames = setcase( dictionary.case, newnames );
    if ~iscell(oldnames)
        oldnames = { oldnames };
    end
    if ~iscell(newnames)
        newnames = { newnames };
    end
    
    oldindexes = name2Index( dictionary, oldnames );
    present = oldindexes ~= 0;
    oldindexes = oldindexes( present );
    oldnames = index2Name( dictionary, oldindexes );
    if ~iscell(oldnames)
        oldnames = { oldnames };
    end
    newnames = newnames( present );
    [oldindexes,p] = unique( oldindexes );
    oldnames = oldnames(p);
    newnames = newnames(p);
    [newnames,p] = unique( newnames );
    oldindexes = oldindexes(p);
    oldnames = oldnames(p);
    
    badnewnames = intersect( setdiff( fieldnames(dictionary.name2IndexMap), oldnames ), newnames );
    if ~isempty(badnewnames)
        ok = false;
        return;
    end
    
    dictionary.name2IndexMap = rmfield( dictionary.name2IndexMap, oldnames );
    
    for i=1:length(oldnames)
        dictionary.name2IndexMap.(newnames{i}) = oldindexes(i);
        dictionary.index2NameMap{oldindexes(i)} = newnames{i};
    end
end
