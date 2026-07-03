function s = selectFromStructOfArrays( s, selected )
%s = selectFromStructOfArrays( s, selected )
%   S is a struct, each of whose elements is an array of not more than two
%   dimensions, which all have the same length in their first dimension.
%   SELECTED is a map (either a bitmap or a list of indexes). Each field F
%   of S for which S.(F) is nonempty is replaced by S.(F)(SELECTED,:).
%
%   If SELECTED is empty, all the data is deleted.

    fns = fieldnames(s);
    for fi=1:length(fns)
        fn = fns{fi};
        if ~isempty( s.(fn) )
            s.(fn) = s.(fn)(selected,:);
        end
    end
end
