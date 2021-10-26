function [img,trimmed] = trimimageborders( img, val )
    if nargin < 2
        [img,trimmed] = trimimageborders( img, 0 );
        if ~trimmed
            [img,trimmed] = trimimageborders( img, 255 );
        end
    else
        wd1 = size(img,1);
        wd2 = size(img,2);

        lo1 = wd1+1;
        for i=1:wd1
            if any( any( img(i,:,:) ~= val, 2 ), 3 )
                lo1 = i;
                break;
            end
        end
        hi1 = lo1;
        for i=wd1:-1:(lo1+1)
            if any( any( img(i,:,:) ~= val, 2 ), 3 )
                hi1 = i;
                break;
            end
        end

        lo2 = wd2+1;
        for i=1:wd2
            if any( any( img(:,i,:) ~= val, 1 ), 3 )
                lo2 = i;
                break;
            end
        end
        hi2 = lo2;
        for i=wd2:-1:(lo2+1)
            if any( any( img(:,i,:) ~= val, 1 ), 3 )
                hi2 = i;
                break;
            end
        end
        
        if lo1 > hi1
            lo1 = 1;
            hi1 = wd1;
        end
        if lo2 > hi2
            lo2 = 1;
            hi2 = wd2;
        end
        
        trimmed = (lo1 > 1) || (hi1 < wd1) || (lo2 > 1) || (hi2 < wd2);
        if ~trimmed
            return;
        end

        img = img( lo1:hi1, lo2:hi2, : );
        w1 = size(img,1);
        w2 = size(img,2);
        delta = w1-w2;
        if delta > 0
            a = floor(delta/2);
            b = delta-a;
            img = [ val*ones( size(img,1), a, size(img,3) ), ...
                    img, ...
                    val*ones( size(img,1), b, size(img,3) ) ];
        elseif delta < 0
            a = floor((-delta)/2);
            b = -delta-a;
            img = [ val*ones( a, size(img,2), size(img,3) ); ...
                    img; ...
                    val*ones( b, size(img,2), size(img,3) ) ];
        end
    end
end

function [lo,hi] = expandinterval( lo, hi, extra, maxhi )
    % Split the extra into two parts, as equal as possible.
    a = floor(extra/2);
    b = extra - a;
    
    % Adjust lo and hi.
    lo = lo - a;
    hi = hi + b;
    
    % If hi is too big, shift both hi and lo downwards.
    if hi > maxhi
        lo = lo - (hi - extra);
        hi = maxhi;
    end
    
    % If lo is now too small, shift both lo and hi upwards.
    if lo < 1
        hi = hi - (1 - lo);
        lo = 1;
    end
    
    % If hi is now too big, set it to its maximum.
    if hi > maxhi
        hi = maxhi;
    end
end
