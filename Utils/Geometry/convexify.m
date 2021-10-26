function [vxs,ok] = convexify( vxs )
%vxs = convexify( vxs )
%   vxs is an N*2 array of points in the plane defining a polygon.
%   They are modified to force the polygon to be convex.

    ok = true;
    npts = size(vxs,1);
    hullindexes = convhull( vxs(:,1), vxs(:,2) )';
    hullindexes = extractgoodsubset( hullindexes, npts );
    if length(hullindexes)==size(vxs,2)
        % Polygon is already convex.
        return;
    end
    if length( hullindexes ) <= 2
        % Could not extract good hull.
        ok = false;
        return;
    end
    for i=1:(length(hullindexes)-1)
        h1 = hullindexes(i);
        h2 = hullindexes(i+1);
        if h1 < h2
            vis = (h1+1):(h2-1);
        else
            vis = [ (h1+1):npts, 1:(h2-1) ];
        end
        dv = vxs( [vis,h2], : ) - vxs( [h1,vis], : );
        lengths = sqrt(sum( dv.*dv, 2 ));
        lengths = lengths/sum(lengths);
        ratios = cumsum(lengths);
        for pi=1:length(vis)
            vi = vis(pi);
            %fprintf( 1, 'Fixing point %d between %d and %d\n', vi, h1, h2 );
            beta = ratios(pi);
            alpha = 1 - beta;
            vxs(vi,:) = vxs(h1,:)*alpha + vxs(h2,:)*beta;
        end
    end
end

function hi = extractgoodsubset( hi, npts )
    while true
        hdiffs = hi(2:end) - hi(1:(end-1));
        hdiffs = mod( hdiffs + npts, npts );
        goodedges = hdiffs <= npts/2;
        if all(goodedges)
            return;
        end
        hi = hi( goodedges );
        hi = [ hi, hi(1) ];
    end
end
