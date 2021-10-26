function t = timeFromVelGrad( v1, v2, d )
%t = timeFromVelGrad( v1, v2, d )
%   Given a straight path of length d, suppose that the velocity of a
%   particle on the path varies linearly with distance, being v1 at the
%   start and v2 at the end. Calculate how long it takes to traverse the
%   distance.

    vsum = v1+v2;
    t = 2*d./vsum;
    LINEAR_RANGE = 1e-7;
    uselog = abs(v2-v1) > LINEAR_RANGE*v1;
    t(uselog) = d*(log(v2(uselog))-log(v1(uselog)))./(v2(uselog)-v1(uselog));
end
