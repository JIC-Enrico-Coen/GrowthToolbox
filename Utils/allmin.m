function [y,i] = allmin( x )
%[y,i] = allmin( x )
%   Return the minimum value of the vector x, and a list of indexes of all
%   elements of x having that value.

    y = min(x);
    i = find(x==y);
end
