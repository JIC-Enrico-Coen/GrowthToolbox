function s = defaultFromStructRecursive( s, d )
%s = defaultFromStructRecursive( s, d )
%   Set nonexistent fields of S to the corresponding values of D, and do
%   simmilarly for all subfields of s that are structs.

    fns = intersect( fieldnames(s), fieldnames(d) );
    s = defaultFromStruct( s, d );
    if ~isempty(d)
        for i = 1:length(fns)
            fn = fns{i};
            if isstruct( d.(fn) )
                for j=1:length(s)
                    if isstruct( s(j).(fn) )
                        s(j).(fn) = defaultFromStructRecursive( s(j).(fn), d.(fn) );
                    end
                end
            end
        end
    end
end
