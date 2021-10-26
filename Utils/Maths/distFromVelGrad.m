function x = distFromVelGrad( v1, v2, d, t )
%d1 = distFromVelGrad( v1, v2, d, t )
%   Given a straight path of length d, suppose that the velocity of a
%   particle on the path varies linearly with distance, being v1 at the
%   start and v2 at the end. Calculate how far it will go in time t.
%
%   v1, v2, and d must be single values. t may be an array of times of any
%   shape. x will be the same shape as t.

    vsum = v1+v2;
    vdiff = v2-v1;
    LINEAR_RANGE = 1e-7;
    useexp = abs(v2-v1) > LINEAR_RANGE*v1;
    if useexp
        x = (exp(vdiff*(t/d)) - 1)*(v1*d/vdiff);
    else
        x = (vsum/2)*t;
    end
end
