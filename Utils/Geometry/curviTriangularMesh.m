function m = curviTriangularMesh( r0, r1, n0, n1, n2, theta, halfH )
%m = curvitrangularMesh( r0, r1, n0, n1, n2 )
%   Make a mesh of triangles (it will not here be completed to a GFtbox
%   mesh) whose shape is a sector of an annulus.
%
%   r0: inner radius
%   r1: outer radius
%   n0, n1: number of steps on inner/outer side.
%   n2L number of steps from inner to outer.
%   theta: angle of sector (which goes from 0 to theta).
%   halfH: offset from the radial lines.

    m = [];

    ns = round( linspace( n0, n1, n2+1 ) );
    radii = linspace( r0, r1, n2+1 );
    vxindexes = cumsum( ns+1 );
    starts = [ 0, vxindexes( 1:(end-1) ) ];
    ends = vxindexes;
    
    thetaA = atan2( halfH, radii );
    thetaB = atan2( -halfH, radii ) + theta;
    vxsPerRow = cell( n2+1, 1 );
    ptsPerRow = cell( n2+1, 1 );
    for ri=1:length(radii)
        anglesInRow = linspace( thetaA(ri), thetaB(ri), ns(ri)+1 )';
        vxsPerRow{ri} = anglesInRow;
        ptsPerRow{ri} = radii(ri) * [ cos(anglesInRow), sin(anglesInRow) ];
    end
    allpts = cell2mat( ptsPerRow );
    
    edgeends = cell( n2, 1 );
    triangles = cell( n2, 1 );
    for ri=1:n2
        [ edgeends{ri}, triangles{ri} ] = triangulateStrip( ptsPerRow{ri}, ptsPerRow{ri+1}, starts(ri), starts(ri+1) );
    end
    
    innervxs = (1 : vxindexes(1))';
    outervxs = ((vxindexes(end-1)+1) : vxindexes(end))';
    circumedgeends = [ [ innervxs(1:(end-1)), innervxs(2:end) ];
                       [ outervxs(1:(end-1)), outervxs(2:end) ] ]; 
    
    rowedgeends = cell(n2,1);
    for ri=1:n2
        rowvxindexes = ((starts(ri)+1):ends(ri))';
        rowedgeends{ri} = [ rowvxindexes(1:(end-1)), rowvxindexes(2:end) ];
    end
    rowedgeends = cell2mat( rowedgeends );
    
    alledgeends = cell2mat( [ edgeends; rowedgeends; circumedgeends ] );
    alltriangles = cell2mat( triangles );
    
    % Plotting tests indicate that this is all correct.
    
    xxxx = 1;
end

function [edgeends,triangles] = triangulateStrip( pts1, pts2, base1, base2 )
    n1 = size(pts1,1);
    n2 = size(pts2,1);
    pi1 = 1;
    pi2 = 1;
    edgeends = zeros( n1+n2-1, 2 );
    triangles = zeros( n1+n2-2, 3 );
    numedges = 1;
    edgeends(numedges,:) = [ base1+pi1, base2+pi2 ];
    while true
        if pi1 < n1
            d1 = norm( pts1(pi1+1,:)-pts2(pi2,:) );
        else
            d1 = Inf;
        end
        if pi2 < n2
            d2 = norm( pts1(pi1,:)-pts2(pi2+1,:) );
        else
            d2 = Inf;
        end
        if (d1==Inf) && (d2==Inf)
            break;
        end
        if d1 < d2
            pi3 = pi1+base1;
            pi1 = pi1+1;
            triangles(numedges,:) = [ base1+pi1-1, base2+pi2, base1+pi1 ];
        else
            pi2 = pi2+1;
            triangles(numedges,:) = [ base1+pi1, base2+pi2-1, base2+pi2 ];
        end
        numedges = numedges+1;
        edgeends(numedges,:) = [ base1+pi1, base2+pi2 ];
    end
    
end