function t = renameStructFields( s, varargin )
%t = renameStructFields( s, oldname1, newname1, oldname2, newname2, ... )
%   Rename the fields of s as indicated.  s can also be a struct array of
%   any shape.  Old names not present are ignored.

    oldnames = varargin(1:2:(end-1));
    newnames = varargin(2:2:end);
    snames = fieldnames(s);
    [~,ia,~] = intersect( oldnames, snames );
    oldnames = oldnames(ia);
    newnames = newnames(ia);
    keepnames = setdiff( snames, union(oldnames,newnames) );
    t = emptystructarray( size(s), union( keepnames, newnames ) );
    for i=1:length(s)
        for j=1:length(keepnames)
            fn = keepnames{j};
            t(i).(fn) = s(i).(fn);
        end
        for j=1:length(oldnames)
            oldfn = oldnames{j};
            newfn = newnames{j};
            t(i).(newfn) = s(i).(oldfn);
        end
    end
end

