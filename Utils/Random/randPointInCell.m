function bcs = randPointInCell( eps, n )
%bcs = randPointInCell( eps )
%   Return a random point in a triangle in barycentric coordinates, subject
%   to the point not lying close to the sides or medians of the triangle.
%   n is the number of points, defaulting to 1.
%   eps should be in the range 0...0.1.
    if nargin < 1, eps = 0; end
    if nargin < 2, n = 1; end
    onethird = 1/3;
    sqrtthree = sqrt(3);
    bcs1 = [ [ 1-4*eps, 3*eps, eps ];
            [ 0.5+eps/2, 0.5-3*eps/2, eps ];
            [ onethird+eps*(2/3+sqrtthree/2), ...
              onethird+eps*(-2/3+sqrtthree/2), ...
              onethird-eps*sqrtthree ] ];
    bcs2 = randBaryCoords(n);
    bcs = bcs2*bcs1;
    if 1
    for i=1:n
        p = rand;
        if p <= onethird
            if rand <= 0.5
                % 1 3 2
                bcs(i,:) = bcs(i,[1,3,2]);
            else
                % 1 2 3
            end
        else
            if rand <= 0.5
                % 2 ...
                if rand <= 0.5
                    % 2 1 3
                    bcs(i,:) = bcs(i,[2 1 3]);
                else
                    bcs(i,:) = bcs(i,[2 3 1]);
                end
            else
                % 3 ...
                if rand <= 0.5
                    bcs(i,:) = bcs(i,[3 1 2]);
                else
                    bcs(i,:) = bcs(i,[3 2 1]);
                end
            end
        end
    end
    end
end
