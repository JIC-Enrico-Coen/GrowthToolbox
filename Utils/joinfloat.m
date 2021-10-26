function s = joinfloat( f, sep, fmt )
%s = join( sep, f, fmt )
%   Concatenate the numbers in f together, separated by sep (by default a
%   single space).  The numbers are converted to strings by the format fmt,
%   (default %.3f). 


    if isempty(f)
        s = '';
    else
        if nargin < 2
            sep = ' ';
        end
        if nargin < 3
            fmt = '%.3f';
        end
        s = [ sprintf( fmt, f(1) ), sprintf( [sep, fmt], f(2:numel(f)) ) ];
    end
end