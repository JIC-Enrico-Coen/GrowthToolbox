function [z,sense] = pairInts( x, symmetric )
%[z,sense] = pairInts( x, symmetric )
%   x is an N*2 array of non-negative integers.
%   Each pair is combined into a single non-negative integer in such a way
%   that different pairs map to different integers, and every non-negative
%   integer encodes some pair.
%
%   Note that integer overflow is possible, since the result has the order
%   of magnitude of the product of the two integers.  For example, if the
%   input values are uint8 and use the full range, then you would need to
%   convert them to at least int32 or uint32, because pairInts([255 255])
%   needs to return 130815.
%
%   If the second argument is present and true (the default is false), then
%   [x,y] and [y,x] are mapped to the same integer as [min(x,y), max(x,y)].
%
%   The sense output is an array of N*1 booleans.  If symmetric is false,
%   sense is true everywhere.  Otherwise it is true when x <= y, i.e.
%   when the values were not swapped.
%
%   See also: splitInts.

    if nargin < 2
        symmetric = false;
    end
    if symmetric
        a = min(x,[],2);
        b = max(x,[],2);
%         z = 0.5*a.*(a+1) + b;
        if nargout >= 2
            sense = a==x(:,1);
        end
    else
        a = x(:,1);
        b = x(:,2);
        if nargout >= 2
            sense = true(length(a),1);
        end
    end
    apb = a+b;
%     z = (apb.*(apb+1))/2 + b;
    apb_p = mod(apb,2);
    apb_h = (apb-apb_p)/2;
    z = apb_h.*(apb+1+apb_p) + apb_p + b;
    
end











