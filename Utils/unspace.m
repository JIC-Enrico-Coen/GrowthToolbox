function s = unspace( s )
%s = unspace( s )
%   Remove the spaces from the string or cell array of strings s.

    if iscell(s)
        for i=1:length(s)
            s{i} = regexprep( s{i}, ' ', '' );
        end
    else
        s(s==' ') = '';
    end
end
