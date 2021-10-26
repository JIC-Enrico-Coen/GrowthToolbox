function f = completeFrame( f )
%f = completeFrame( f )
%   f is a matrix containing 1, 2, or 3 row vectors.
%   f is completed to a 3x3 orthonormal frame of reference.

    nf = sqrt(sum(f.^2,2));
    f = f(nf ~= 0,:);
    nf = nf(nf ~= 0,:);
    if isempty(f)
        f = eye(3);
    elseif size(f,1)==1
        [a,b,c] = makeframe( f/nf );
        f = [c;a;b];
    else
        if size(f,1) > 3
            f = f(1:3,:);
        end
        f = gramschmidt( f' )';
        if size(f,1)==2
            [a,b,c] = makeframe( f(1,:), f(2,:) );
            f = [b;c;a];
        end
    end
end
