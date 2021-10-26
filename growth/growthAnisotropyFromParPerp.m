function [g,a] = growthAnisotropyFromParPerp( gpar, gperp )
    g = (gpar+gperp)/2;
    a = (gpar-gperp)/2;
end
