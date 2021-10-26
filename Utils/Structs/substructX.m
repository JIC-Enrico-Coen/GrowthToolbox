function s1 = substructX( s, varargin )
%s1 = substructX( s, ... )
%   Set s1 to a new structure whose fields are those fields of s whose
%   names are given as arguments.
%
%   The X on the end of the name is to prevent a clash with the Matlab
%   built-in function substruct().

    s1 = struct();
    for i=1:length(varargin)
        f = varargin{i};
        s1.(f) = s.(f);
    end
end
