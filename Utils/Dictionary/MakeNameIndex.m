function ni = MakeNameIndex( names, values )
    ni.case = -1;
    if nargin < 1
        names = {};
    end
    names = setcase( ni.case, names );
    ni.name2IndexMap = struct();
    ni.index2NameMap = names;
    for i=1:length(names)
        ni.name2IndexMap.(names{i}) = i;
    end
    if nargin >= 2
        ni.index2Value = values;
    end
end
