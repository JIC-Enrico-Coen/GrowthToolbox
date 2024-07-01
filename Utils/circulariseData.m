function data = circulariseData( data, range, dim )
%data = circulariseData( data, range )
%   DATA is an array of values of any shape, but will be processed as if it
%   were one-dimensional. The result has the same shape as the original.
%
%   RANGE is a pair of numbers [low,high]. If there is only one number x,
%   then the range is taken to be [x 0] is x is negative, otherwise [0 x].
%
%   The values in DATA are assumed to vary without large discontinuities.
%   The first item is translated to lie in RANGE by adding some multiple of
%   RANGE(2)-RANGE(1). Each subsequent item after the first is translated
%   by multiples of that interval, in such a way as to minimise the
%   absolute difference between it and the previous item.
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
%
%   NaN and infinite values will throw off the computation, from where they
%   first occur to the end.

    if isempty(data)
        % Nothing to do.
        return;
    end
    
    sz = size(data);
    
    if length(range)==1
        if range >= 0
            range = [0 range];
        else
            range = [range 0];
        end
    end
    if nargin < 3
        data = reshape( data, 1, [] );
        len1 = 1;
        len2 = 1;
    else
        if (dim < 1) || (dim > length(sz))
            % No change. Note that dim can validly be greater than
            % length(sz). The length of the data along that dimension is 1.
            return;
        end
        if sz(dim) <= 1
            % No work to do.
            return;
        end
        len1 = prod(sz(1:(dim-1)));
        len2 = prod(sz((dim+1):end));
        data = reshape( data, len1, sz(dim), len2 );
    end
    cumdim = 2;
    
    period = range(2)-range(1);
    delta = mod( data(:,2:end,:) - data(:,1:(end-1),:), period );
    toobig = delta >= period/2;
    delta(toobig) = delta(toobig) - period;
    data = data(:,1,:) + [ zeros(len1,1,len2), cumsum(delta,cumdim,'omitnan') ];
    data = reshape( data, sz );
    
%     if ~isempty(baddatavalues)
%         data(~baddataindexes) = data;
%         data(baddataindexes) = baddatavalues;
%     end
end
