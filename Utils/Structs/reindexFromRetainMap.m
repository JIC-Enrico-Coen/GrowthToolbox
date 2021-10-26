function s = reindexFromRetainMap( s, fn, retainmap )
    oldToNew = zeros( size(s.(fn),1), 1 );
    oldToNew(retainmap) = (1:sum(retainmap))';
    newToOld = find(retainmap);
    
    reindexStruct( s, fn, oldToNew, newToOld );
end
