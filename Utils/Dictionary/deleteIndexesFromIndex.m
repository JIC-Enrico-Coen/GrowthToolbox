function [ni,oldnew,newold] = deleteIndexesFromIndex( ni, indexes )
    indexes = indexes( (indexes>0) & (indexes <= length(ni.index2NameMap)) );
    oldnew = 1:length(ni.index2NameMap);
    newold = oldnew;
    oldnew(indexes) = 0;
    newold(indexes) = [];
    oldnew(oldnew>0) = 1:length(newold);
    ni.name2IndexMap = safermfield( ni.name2IndexMap, ni.index2NameMap(indexes) );
    ni.index2NameMap( indexes ) = [];
    for i=1:length(ni.index2NameMap)
        ni.name2IndexMap.(ni.index2NameMap{i}) = i;
    end
    if isfield( ni, 'index2Value' )
        ni.index2Value( indexes ) = [];
    end
end
