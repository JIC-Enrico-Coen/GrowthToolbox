function aa = movingAverage( a, dim, width )
%aa = movingAverage( a, dim, width )
%   Take a moving average of A along dimension DIM.
%   A is assumed to be padded with enough zeros at its left-hand end so
%   that the final values of AA are the average of the last WIDTH values of
%   A.
%
%   If WIDTH is 0 or 1 then no averaging is done.
%
%   If WIDTH is -1, then the average for each item is over all the items
%   from the first to that position. For example:
%
%       movingAverage( 1:5, 2, -1 )
%
%       ans =
%
%           1.0000    1.5000    2.0000    2.5000    3.0000

    if width==-1
        width = size(a,dim);
    end

    if (width==0) || (width==1)
        aa = a;
        return;
    end
    
    % Reshape A so the the dimension of interest is the 2nd.
    sz = size(a);
    if length(sz) < 3
        sz(3) = 1;
    end
    sz1 = prod( sz(1:(dim-1)) );
    sz2 = prod( sz((dim+1):end) );
    len = sz(dim);
    a = reshape( a, sz1, len, sz2 );
    
    % Pad A with zeros for its first HALFWIDTH places.
    halfwidth = floor( width/2 );
    a( end, len+halfwidth, end ) = 0;
    a = a( :, [(len+1):end, 1:len], : );
    
    % Apply the averaging filter.
    aa = imfilter( a, ones(1,width)/width );
    
    % Trim A to its original size.
    aa = aa(:,1:len,:);
    
    % Correct for the zero padding.
    w = min( width, len+1 );
    aa(:,1:(w-1),:) = aa(:,1:(w-1),:) .* (width ./ (1:(w-1)));
    
    % Reshape A to its original shape.
    aa = reshape( aa, sz );
end

