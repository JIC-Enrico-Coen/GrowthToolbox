function x = randInLinearGradient( weights, sz )
%x = randInLinearGradient( [a,b], sz )
%   Select a matrix of points in the unit interval, of size SZ, distributed
%   according to a probability density that is linearly interpolated from A
%   at 0 to B at 1.
%
%   If SZ is a single number the result is a column vector.

    a = weights(1);
    b = weights(2);
    if length(sz)==1
        sz = [sz,1];
    end
        
    x = rand(sz);
    if a==b
        % Uniform distribution. No more to do.
    else
        swap = a>b;
        if swap
            c = b; b = a; a = c;
        end
        
        area1 = a;
        area2 = (b-a)/2;
        % The distribution can be divided into a uniform part, of size
        % area1, and a triangular part, of size area2. If the random event
        % is in the latter region, transform it to the triangular
        % distribution.
        isarea2 = rand(sz) >= area1/(area1+area2);
        x = rand(sz);
        x(isarea2) = sqrt(x(isarea2));
        
        if swap
            x = 1-x;
        end
    end
end
