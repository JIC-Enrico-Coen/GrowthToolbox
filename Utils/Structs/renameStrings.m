function s = renameStrings( s, renameindex )
%s = renameStrings( s, renameindex )
%   s is either a single string or a cell array of strings.  renameindex is
%   a struct mapping strings to strings.  Every string in s which is a
%   field name of renameindex is replaced by the value renameindex
%   associates to it.
    if ischar(s)
        if isfield( renameindex, s )
            s = renameindex.(s);
        end
    else
        for i=1:length(s)
            if isfield( renameindex, s{i} )
                s{i} = renameindex.(s{i});
            end
        end
    end
end
