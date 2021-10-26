function g = morphogenInteractions( g )
%g = morphogenInteractions( g )    Calculate the effect of morphogen
%interaction over a single time step.  g is the matrix of morphogens, with
%one row for every vertex and one column for every morphogen.

    dg = zeros(size(g));
    dg = morphint5( g );

    dt = 0.01;
  % oldgtrans = g'
  % gdgtrans = [g,dg]'
    g = max( g + dg*dt, 0 );
  % newgtrans = g'
end

function dg = morphint1( g )
%g = morphint1( g )
%   Insert whatever code you want here.

    dg = zeros(size(g));
    if size(g,2) <= 1, return; end

    diff = sqrt(g(1)*g(2))*(g(1) - g(2));
    a = 1;
    b = 1;
    dg(1) = a*diff;
    dg(2) = -b*diff;
end

function dg = morphint2( g )
%g = morphint2( g )
%   Schakenberg, as quoted in Madzvamuse et al. "A numerical approach to
%   the study of spatial pattern formation in the ligaments of arcoid
%   bivalves".

    dg = zeros(size(g));
    if size(g,2) <= 1, return; end
    
    a = 0.1;
    b = 0.9;
    gamma = 0.001;

    g112 = g(:,1) .* g(:,1) .* g(:,2);
    dg(1) = gamma*(a - g(1) + g112);
    dg(2) = gamma*(b - g112);
end

function dg = morphint3( g )
%g = morphint3( g )
%   Derived from morphint2.

    dg = zeros(size(g));
    if size(g,2) <= 1, return; end
    
    growthscale = 0.1;
    
    a = 0.01;
    b = 0.01;
    gamma = 0.1;

    g112 = g(:,1) .* g(:,1) .* g(:,2)/(growthscale*growthscale*growthscale);
    dg(:,1) = gamma*(a - g(:,1) + g112)*growthscale;
    dg(:,2) = gamma*(b - g112)*growthscale;
end

function dg = morphint4( g )
%g = morphint4( g )
%   From Andy.

    dg = zeros(size(g));
    if size(g,2) <= 1, return; end
    
    growthscale = 0.01;
    
    product = g(:,1) .* g(:,2) / (growthscale*growthscale);
    noise = randn(size(g,1),1)*0;
    
    r = 2;
    a = 1.3;
    b = 1.3;
    speed = 2;
    
    dg(:,1) = speed*growthscale*(r - b*product);
    dg(:,2) = speed*growthscale*(b*product - a*g(:,2)/growthscale - noise);
end

function dg = morphint5( g )
%g = morphint5( g )
%   From J.D.Murray "Mathematical Biology", eqn. 14,32 p.387.

    dg = zeros(size(g));
    if size(g,2) <= 1, return; end
    
    growthscale = 0.01;
    
    g112 = g(:,1) .* g(:,1) .* g(:,2) / (growthscale*growthscale*growthscale);
    
    a = 0.05;
    b = 0.3;
    speed = 0.4;
    
    dg(:,1) = speed*growthscale*(a - g(:,1)/growthscale + g112);
    dg(:,2) = speed*growthscale*(b - g112);
%    dg1 = dg(1,1)/(speed*growthscale)
%    dg2 = dg(1,2)/(speed*growthscale)
%    g112_1 = g112(1)
%    g1 = g(1,1)
%    g2 = g(1,2)
end

