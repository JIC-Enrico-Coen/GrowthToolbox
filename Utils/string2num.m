function [n,ok] = string2num( s )
%[n,ok] = string2num( s )
%   Convert a string to a number.  OK is true if the string begins with
%   exactly one number.  Leading spaces are ignored.  'inf' and 'nan' (case
%   is ignored) are parsed as the numerical values Inf and NaN.
%
%   s can also be a cell array of strings or a char matrix in which each
%   row contains a number.

    ok = true;
    if iscell(s)
        n = zeros(size(s));
        for i=1:numel(s)
            [n1,ok] = string2num1(s{i});
            if ok
                n(i) = n1;
            end
        end
    elseif size(s,1) > 1
        n = zeros(size(s,1),1);
        for i=1:size(s,1)
            [n1,ok] = string2num1( s(i,:) );
            if ok
                n(i) = n1;
            end
        end
    else
        [n,ok] = string2num1( s );
    end
end

function [n,ok] = string2num1( s )
    [n,count] = sscanf( s, '%f' );
    ok = count==1;
    if ~ok, n = []; end
end
