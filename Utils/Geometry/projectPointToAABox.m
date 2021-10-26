function [ipt,k] = projectPointToAABox( pt, dir, bounds )
%projectPointToAACube( pt, dir, bounds )
%   Starting from the point PT and moving in the direction DIR (a unit
%   vector), find the first intersection of the ray with the axis-aligned
%   box defined by BOUNDS = [ XMIN XMAX YMIN YMAX ZMIN ZMAX ].

    bounds = reshape( bounds, 2, 3 );
    ka = (bounds(1,:) - pt)./dir;
    kb = (bounds(2,:) - pt)./dir;
    kk = [ka, kb];
    kk = kk(isfinite(kk));
    kk = sort( kk );
    for i=1:length(kk)
        cpt = pt + kk(i)*dir;
        if all(cpt >= bounds(1,:)) && all(cpt <= bounds(2,:))
            ipt = cpt;
            k = kk(i);
            return;
        end
    end
    ipt = [];
    k = 0;
end
