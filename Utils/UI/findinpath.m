function x = findinpath( d, p )
%x = findinpath( d, p )
%   Returns 0 if d is not a directory on the path p, otherwise the index of
%   d's position in p.  If p is not supplied the current command path is
%   used.

    if nargin < 2
        p = path();
    end
    plist = splitString(';',p);
    for i=1:length(plist)
        if strcmp(d,plist{i})
            x = i;
            return;
        end
    end
    x = 0;
end
