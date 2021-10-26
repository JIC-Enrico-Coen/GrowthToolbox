function nameToIndex = invertNameArray( indexToName )
    for i=1:length(indexToName)
        nameToIndex.(indexToName{i}) = int32(i);
    end
end
