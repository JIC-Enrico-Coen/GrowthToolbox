function x = firstOnPath( p )
%x = firstOnPath()
%   Return the first directory on the Matlab command path.
%   Returns the empty string if the path is empty (which should never happen).

    if nargin < 1
        p = path();
    end
    x = regexp(p,'^(?<first>[^;]*);','names','once');
    if isempty(x)
        x = '';
    else
        x = x.first;
    end
end
