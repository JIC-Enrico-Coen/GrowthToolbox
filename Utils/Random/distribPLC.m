function distrib = distribPLC ( density )
%distrib = distribPLC ( density )
%   density is an N*2 matrix of (x,y) coordinates, defining a piecewise linear
%   continuous function.  The result is the corresponding piecewise quadratic
%   distribution function, i.e. the integral of the density (but not scaled to have
%   range 0...1).  This function is represented as an N*4 matrix.  For each
%   tuple (x,y,y',a), (x,y') is the value of the distribution function corresponding
%   to the point (x,y) in the density function, and a expresses the quadratic
%   component between that point and the next: distrib( x+eps ) = y' + y*eps + a*eps^2.

    numpts = size( density, 1 );
    numintervals = numpts-1;
    distrib = [ density(:,1:2), zeros( numpts, 2 ) ];
    delta_ys = density(2:numpts,2) - density(1:numintervals,2);
    delta_xs = density(2:numpts,1) - density(1:numintervals,1);
    stripareas = density(1:numintervals,2) .* delta_xs;
    triangleareas = delta_ys .* delta_xs/2;
    total = 0;
    for i=1:numintervals
        distrib(i,3) = total;
        total = total + stripareas(i) + triangleareas(i);
    end
    distrib(numpts,3) = total;
    xnz_steps = delta_xs ~= 0;
    distrib(xnz_steps,4) = ...
        [ triangleareas(xnz_steps) ./ (delta_xs(xnz_steps) .* delta_xs(xnz_steps)) ];
  % distrib(:,4) = [ triangleareas ./ (delta_xs .* delta_xs); 0 ];
    distrib = [ distrib, density(:,3:4) ];
end
