function x = scalenumber( lo, x, hi )
%x = scalenumber( lo, x, hi )
%   Scale and translate the values in x to lie within lo..hi.  x may be a
%   numerical array of any size, shape, and type.  If all values in x are
%   equal, they are all set to lo. If there are at least two different
%   values, then the result will contain at least one occurrence of lo and
%   at least one of hi.

    c = class(x);
    x = double(x);
    lo = double(lo);
    hi = double(hi);
    x = x - min(x(:));
    xmax = max(x(:));
    if xmax ~= 0
        x = x*((hi-lo)/xmax);
    end
    x = x + lo;
    setclass = str2func(c);
    x = setclass(x);
end
