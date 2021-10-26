function [ni,indexes] = addNames2Index( ni, names, values )
%[ni,indexes] = addNames2Index( ni, names )
%   NI is a dictionary, i.e. a structure with fields index2NameMap (a cell
%   array of strings) and name2IndexMap (a structure mapping strings to
%   their indexes into that array.  The second argument is a cell array of
%   strings to be added to the dictionary.  The optional third argument is
%   a cell array of values to be associated with the names.
%
%   The result are the new dictionary and the indexes of the strings in the
%   dictionary.
%   Strings already in the dictionary are not added, but their values, if
%   given, will be updated.

    if isempty(names)
        return;
    end
    
    haveValues = nargin >= 3;
    j = length(ni.index2NameMap);
    indexes = zeros(1,length(names));
    names = setcase( ni.case, names );
    for i=1:length(names)
        s = names{i};
        if isfield( ni.name2IndexMap, s )
            indexes(i) = ni.name2IndexMap.(s);
        else
            j = j+1;
            ni.name2IndexMap.(s) = j;
            ni.index2NameMap{j} = s;
            indexes(i) = j;
        end
        if haveValues
            if iscell(values)
                ni.index2Value{indexes(i)} = values{i};
            else
                ni.index2Value(indexes(i)) = values(i);
            end
        end
    end
end
