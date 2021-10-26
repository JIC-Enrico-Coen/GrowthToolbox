function d = makedictionary( names, indexes )
% Make a dictionary mapping between names, and indexes.

    if (nargin < 1) || isempty(names)
        d.nameToIndex = containers.Map();
        d.indexToName = cell(1,0);
    else
        if nargin < 2
            indexes = 1:length(names);
        end
        d.nameToIndex = containers.Map( names, indexes );
        d.indexToName = names;
    end
end
