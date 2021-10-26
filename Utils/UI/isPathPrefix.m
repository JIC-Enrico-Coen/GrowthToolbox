function isprefix = isPathPrefix( shorter, longer )
%isprefix = isPathPrefix( shorter, longer )
%   SHORTER and LONGER are paths to files.  This procedure
%   determines whether SHORTER is a path prefix of LONGER.
%   This is true if SHORTER is a prefix of LONGER, and either SHORTER ends
%   with a file separator ('/' or '\'), or the next character of LONGER,
%   if there is one, is a file separator.

    if isempty(shorter)
        isprefix = true;
    elseif length(shorter) > length(longer)
        isprefix = false;
    elseif length(shorter) == length(longer)
        isprefix = all(shorter==longer);
    elseif ~all(shorter==longer(1:length(shorter)))
        isprefix = false;
    else
        c = shorter(end);
        if (c=='/') || (c=='\')
            isprefix = true;
        else
            c = longer(1+length(shorter));
            isprefix = (c=='/') || (c=='\');
        end
    end
end

