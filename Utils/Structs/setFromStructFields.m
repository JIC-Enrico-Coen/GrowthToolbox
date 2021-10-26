function s = setFromStructFields( s, t, varargin )
%s = setFromStructFields( s, t, varargin )
%   The variable arguments must be field names of t.
%   Set those fields of s to their values in t.

    for i=1:length(varargin)
        fn = varargin{i};
        s.(fn) = t.(fn);
    end
end
