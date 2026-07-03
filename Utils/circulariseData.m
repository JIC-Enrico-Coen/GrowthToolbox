function data = circulariseData( data, range, dim, mode )
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
%   Infinite values in DATA are replaced by NaN. NaN values, including
%   those that replace infinite values, are skipped over.
%
%   Example:
%
%   d = [ 0 0.2000 0.4000 0.6000 NaN 0 0.2000 Inf 0.6000 0.8000 0 ];
%   d = circulariseData( d, [0 1] );
%
%   The result is:
%
%   [ 0 0.2000 0.4000 0.6000 NaN 1.0000 1.2000 NaN 1.6000 1.8000 2.0000 ];

    if isempty(data)
        % Nothing to do.
        return;
    end
    
    sz = size(data);
    
    if nargin < 3
        data = reshape( data, 1, [] );
        len1 = 1;
        len2 = 1;
        lenwork = numel(data);
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
        lenwork = sz(dim);
        data = reshape( data, len1, lenwork, len2 );
    end
    cumdim = 2;
    
    % For each block of NaNs, replace them by the last non-NaN value
    % preceding them, or if there isn't one, the first non-NaN value after
    % them.
    data(isinf(data)) = NaN;
    data_nan = isnan(data);
    
    for i1=1:len1
        for i2=1:len2
            [not_nan_value,first_not_nan] = find( ~data_nan(i1,:,i2), 1 );
            if isempty( first_not_nan )
                continue;
            end
            data( i1, 1:(first_not_nan-1), i2 ) = data( i1, first_not_nan, i2 );
            for i3=(first_not_nan+1):lenwork
                if data_nan( i1, i3, i2 )
                    data(i1,i3,i2) = not_nan_value;
                else
                    not_nan_value = data(i1,i3,i2);
                end
            end
        end
    end
    
    period = range(2)-range(1);
    delta = mod( data(:,2:end,:) - data(:,1:(end-1),:), period );
    toobig = delta >= period/2;
    delta(toobig) = delta(toobig) - period;
    data = data(:,1,:) + [ zeros(len1,1,len2), cumsum(delta,cumdim) ];
    % Replace the original NaN values.
    data(data_nan) = NaN;
    
    % Restore original shape.
    data = reshape( data, sz );
    
%     if ~isempty(baddatavalues)
%         data(~baddataindexes) = data;
%         data(baddataindexes) = baddatavalues;
%     end
end
