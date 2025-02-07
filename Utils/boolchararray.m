function c = boolchararray( b, yes, no )
    if nargin < 2
        yes = {'T'};
    end
    if nargin < 3
        no = {'F'};
    end
    if ischar(yes)
        yes = {yes};
    end
    if ischar(no)
        no = {no};
    end
    c = cell(size(b));
    c(:) = no;
    c(b) = yes;
end
