function dict = setvaluesInIndex( dict, names, values )
%dict = setvaluesInIndex( dict, names, values )
%   Set the given names to be associated with the given values in the
%   dictionary.
%
%   NAMES can be either a cell array of strings or an array of indexes.
%
%   Names not found in the dictionary will be ignored, together with the
%   associated values.  To add new names and values, use addNames2Index.

    indexes = name2Index( dict, names );
    okindexes = indexes > 0;
    dict.index2Value(indexes(okindexes)) = values(okindexes);
end
