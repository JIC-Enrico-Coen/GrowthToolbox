function [x,y] = splitInts( z, d )
%xy = splitInts( z )
%   z is an array of non-negative integers of any shape.
%   Each integer is split into the two components that, if combined with
%   pairInts, would give that integer.  x and y have the same shape as z.
%
%   If fewer than two output arguments are asked for, a single result is
%   returned, consisting of x and y concatenated along the dimension d.
%   By default d is the first dimension of z that is equal to 1, if any,
%   and otherwise is one more than the number of dimensions of z.
%
%   See also: pairInts.

    x = floor((-1 + sqrt( 1 + 8*z ))/2);
    y = z - x.*(x+1)*0.5;
    if nargout < 2
        sz = size(z);
        if nargin < 2
            [~,d] = find(sz==1,1);
        end
        if isempty(d)
            x = reshape( [ x(:)-y(:), y(:) ], [sz 2] );
        elseif d==1
            x = [ x-y; y ];
        elseif d==2
            x = [ x-y, y ];
        else
            before = prod( sz(1:(d-1)) );
            after = prod( sz((d+1):end) );
            x = reshape( x, [before,1,after] );
            y = reshape( y, [before,1,after] );
            sz(d) = 2;
            x = reshape( [x, y], sz );
        end
    end
end

