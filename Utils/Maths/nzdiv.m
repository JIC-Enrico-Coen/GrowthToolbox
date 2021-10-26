function v = nzdiv( num, denom, zeroval )
%v = nzdiv( num, denom, zeroval )
%   For vectors num and denom of the same shape, this is equivalent to
%   v = num ./ denom, except that where denom is zero, v will be zeroval.
%   zeroval defaults to 0.

    if nargin < 3
        zeroval = 0;
    end
    num(denom==0) = zeroval;
    denom(denom==0) = 1;
    v = num ./ denom;
end
