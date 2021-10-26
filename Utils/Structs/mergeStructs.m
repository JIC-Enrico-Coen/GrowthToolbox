function s = mergeStructs( s1, s2, ignoreempty )
%s = mergeStructs( s1, s2, ignoreempty )
%   Merge two structs (whose fields may also be structs, which will be
%   processed recursively). Where both define a field, and they are not
%   both structs, s1 takes priority.
%
%   If ignoreempty is present and true, then empty fields is either struct
%   are equivalent to missing fields for the purpose of comparison. By
%   default ignoreempty is false.
%
%   UNTESTED 2021 May 27

    if nargin < 3
        ignoreempty = false;
    end

    if ignoreempty && isempty(s1)
        s = s2;
        return;
    end
    
    s = s1;
    if ~isstruct( s1 ) || ~isstruct( s2 )
        return;
    end
    
    f1 = fieldnames(s1);
    f2 = fieldnames(s2);
    f21 = setdiff(f2,f1);
    fboth = intersect(f1,f2);

    for i=1:length(f21)
        fn = f21{i};
        s.(fn) = s2.(fn);
    end

    for i=1:length(fboth)
        fn = fboth{i};
        s.(fn) = mergeStructs( s.(fn), s2.(fn) );
    end
end
