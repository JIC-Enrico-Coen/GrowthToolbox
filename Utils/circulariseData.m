function data = circulariseData( data, range, dim )
%data = circulariseData( data, range )
%   DATA is an array of values of any shape, but will be processed as if it
%   were one-dimensional. The result has the same shape as the original.
%
%   RANGE is a pair of numbers [low,high]. If there is only one number x,
%   then the range is taken to be [0 x] is x is positive, otherwise [x 0].
%
%   The values in DATA are assumed to vary without large discontinuities.
%   The first item is translated to lie in RANGE by adding some multiple of
%   RANGE(2)-RANGE(1). Each subsequent item is translated by multiples of
%   that interval, in such a way as to minimise the absolute difference
%   between it and the previous item.
%
%data = circulariseData( data, range, dim )
%   This will apply circulariseData along dimension DIM, separately for
%   each value of the other indexes.
%
%   For both ways of calling this, the result has the same shape as the
%   input DATA. If the result is DATA1, it will satisfy:
%
%       MOD(DATA1,range(2)-range(1)) == MOD(DATA,range(2)-range(1))
%
%   For the first method, it will also satisfy DATA1(1)==DATA(1), and the
%   the second, DATA1(...,1,...)==DATA(...,1,...), where the "..."
%   represent the dimensions before and after DIM.

    data( isnan(data) ) = 0;
    if length(range)==1
        if range >= 0
            range = [0 range];
        else
            range = [range 0];
        end
    end
    sz = size(data);
    if nargin < 3
        data = data(:);
        cumdim = 1;
    else
        if (dim < 1) || (dim > length(sz))
            return;
        end
        len1 = prod(sz(1:(dim-1)));
        len2 = prod(sz((dim+1):end));
        data = reshape( data, len1, sz(dim), len2 );
        cumdim = 2;
    end
    
    period = range(2)-range(1);
    if nargin < 3
        delta = mod( data(2:end) - data(1:(end-1)), period );
    else
        delta = mod( data(:,2:end,:) - data(:,1:(end-1),:), period );
    end
    toobig = delta >= period/2;
    delta(toobig) = delta(toobig) - period;
    if nargin < 3
        data = data(1) + [ 0; cumsum(delta,'omitnan') ];
    else
        data = data(:,1,:) + [ zeros(len1,1,len2), cumsum(delta,cumdim,'omitnan') ];
    end
    data = reshape( data, sz );
end
