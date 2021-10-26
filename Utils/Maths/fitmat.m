function [m,t,c] = fitmat( p0, p1 )
%[m,t] = fitmat( p0, p1 )
%   P0 and P1 are N*2 or N*3 arrays of 2D or 3D vectors.
%   [M,T] are the linear transformation and translation that best
%   approximate the transformation of P0 to P1.
%   T is P1mean-P0mean, and M is chosen to minimise the squared error of
%   (P1-P1mean) - (P0-P0mean)*M.
%   If M is close to singular, it is returned as the identity matrix instead.

    numpts = size(p0,1);
    avp0 = sum(p0,1)/numpts;
    avp1 = sum(p1,1)/numpts;
    t = avp1 - avp0;
    
    p0z = p0 - repmat( avp0, size(p0,1), 1 );
    p1z = p1 - repmat( avp1, size(p0,1), 1 );
    M = p0z'*p0z;
    c = cond(M);
    if c > 10000
        c = cond(M([1 2],[1 2]));
        if c > 10000
            m = eye(3);
        else
            V = p0z'*p1z;
            m = [ M([1 2],[1 2])\V([1 2],:); V(3,:)];
        end
    else
        V = p0z'*p1z;
        m = M\V;
    end
end
