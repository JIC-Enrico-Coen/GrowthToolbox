function v = roundestBetween( v0, v1 )
%v = roundestBetween( v0, v1 )
%
% Find the roundest number (base 10) lying between the two given values.
%
% This is the number in that range (including the endpoints) that has the
% greatest number of trailing zeros, and subject to that, having the
% smallest absolute value. If the range includes 0, the result is always
% zero.
%
% v0 and v1 may be given in either order.

    if (v0==0) || (v1==0) || ((v0 <= 0) ~= (v1 <= 0))
        % 0 is included in the interval.
        v = 0;
    elseif v0==v1
        % The interval is a single point.
        v = v0;
    else
        % The numbers are different, non-zero, and have the same sign.
        
        % Save the sign and make the numbers positive with v0 < v1.
        s = sign(v1);
        minv = min(v0,v1);
        maxv = max(v0,v1);
        if s==-1
            v0 = -maxv;
            v1 = -minv;
        else
            v0 = minv;
            v1 = maxv;
        end
        
        % Make changeable copies to work with.
        v0a = v0;
        v1a = v1;
        
        % Now find the roundest number in the interval.
        n = ceil(log10(v1));
        tn = 10^n;
        v0a = v0a / tn;
        v1a = v1a / tn;
        while (ceil(v0a - 10*eps(v0a)) > floor(v1a + 10*eps(v1a))) && (n > -100)
            v0a = v0a*10;
            v1a = v1a*10;
            n = n-1;
        end
        v = ceil(v0a - 10*eps(v0a)) * 10^n;
        
        % In case of rounding errors, force v to lie in the original
        % interval.
        v = max( min(v,v1), v0 );
        
        % Restore the sign.
        v = v * s;
    end
end

