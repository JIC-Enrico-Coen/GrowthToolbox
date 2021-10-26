function c = boolchar( b, yes, no )
    if nargin < 2
        yes = 'T';
    end
    if nargin < 3
        no = 'F';
    end
    if b
        c = yes;
    else
        c = no;
    end
end
