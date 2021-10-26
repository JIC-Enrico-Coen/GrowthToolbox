function [s1,s2] = splitStructRec( s, filter, prefix )
%[s1,s2] = splitStructRec( s, filter, prefix )
%   Split the struct s into two structs, whose merger will be s. Those
%   parts of s for which filter is true go to s1, the remainder to s2.
%
%   filter is a function of the form filter( value, name ), where value is
%   the value of the component of s, and name is the full hierarchical name
%   of the component in the struct. It returns 1 if the value is to be
%   selected for s1, 2 if it is to be selected for s2, and 0 if value is a
%   struct to be further split
%   prefix is used only in recursive calls, to indicate where we currently
%   are in the struct tree.
%
%   INCOMPLETE 2021 May 27

    if nargin < 3
        prefix = [];
    end
    
    if ~isstruct( s )
        if filter( s, prefix )
            s1 = s;
            s2 = [];
        else
            s2 = s;
            s1 = [];
        end
        return;
    end
    
    f = fieldnames(s);
    s1 = struct();
    s2 = struct();
   § for i=1:length(f)
        fn = f{i};
        switch filter( s.(fn), [prefix, '.', fn] )
            case 1
                s1.(fn) = s.(fn);
            case 2
                s2.(fn) = s.(fn);
            otherwise
                [s1.(fn),s2.(fn)] = splitStructRec( s.(fn), filter );
        end
    end
end
