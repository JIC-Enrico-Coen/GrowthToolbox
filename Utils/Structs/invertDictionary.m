function s = invertDictionary( a )
%s = invertDictionary( a )
%   a is a cell array of strings.  s is set to a structure whose fields are
%   those strings, and whose value for each field is the index of that
%   string in the cell array.  The strings must be all different and valid
%   Matlab field names.

    s = struct();
    for i=1:length(a)
        s.(a{i}) = i;
    end
end
