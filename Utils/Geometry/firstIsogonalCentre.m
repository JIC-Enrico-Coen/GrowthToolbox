function [v,bcs,n] = firstIsogonalCentre( vxs, n, testing )
%[v,bcs,n] = firstIsogonalCentre( vxs, n, doplot )
%   Given three points as the three rows of the matrix vxs (in 2 or 3
%   dimensions), find the first isogonal centre of the triangle.
%
%   This point can be defined by the following construction. Erect an
%   equilateral triangle on the outside of each side of the given triangle.
%   Draw a line from the exterior vertex of eahc of these to the opposite
%   vertex of the triangle. These three lines meet at the first isogonal
%   point.
%
%   This point lies within the triangle if and only if no angle exceeds 120
%   degrees. In this case it coincides with the Fermat point (also known as
%   the Torricelli point, or Fermat-Torricelli point). This is the point
%   that minimises the sum of the perpendicular distances of the point to
%   the sides of the triangle. It is also the point from which each side of
%   the triangle subtends an angle of 120 degrees.
%
%   The point is X(13) in the Encyclopedia of Triangle Centres.
%   https://faculty.evansville.edu/ck6/encyclopedia/ETC.html
%
%   N, if provided and nonempty, should be a normal vector to the triangle,
%   with respect to which the vertexes are listed in right-handed order. If
%   not provided, it will be calculated. If an incorrect value for N is
%   provided, the results may not be meaningful. If VXS is 3*2, N will be
%   either [0 0 1] or [0 0 -1].
%
%   If TESTING is provided and true, a new figure will be created and the
%   construction that this procedure uses will be drawn. Several other
%   equivalent ways of calculating the point are also carried out.
%
%   BCS will be the barycentric coordinates of v with respect to the
%   triangle. N will be a unit normal vector to the triangle (identical to
%   the one provided, if it was).
%
%   If the Fermat point is specifically required, when this differs from
%   the isogonal point, check for a barycentric coordinate greater than 1.
%   Set that coordinate equal to 1 and the other two to 0.
%
%   If the points are collinear then BCS will be [NaN NaN NaN]. However,
%   V will still be well-defined if N is provided as a vector normal to the
%   degenerate triangle. Otherwise, V will also be [NaN NaN NaN].

    if nargin < 3
        testing = false;
    end
    dims = size(vxs,2);
    if dims==2
        vxs(3,3) = 0;
    end
    v3 = vxs(3,:);
    v31 = vxs(1,:)-v3;
    v32 = vxs(2,:)-v3;
    if (nargin < 2) || isempty(n)
        n = cross( v31, v32 );
        n = n/norm(n);
    end
    if any(isnan(n))
        v = nan(1,dims);
        bcs = nan(1,3);
        return;
    end
    
    c1 = v3 + rotateVecAboutVec( v31, n, -pi/6 ) / sqrt(3);
    c2 = v3 + rotateVecAboutVec( v32, n, pi/6 ) / sqrt(3);
    % c1 and c2 are the circumcentres of the equilateral triangles erected
    % on these two sides of the triangle
    
    [~,pp,~] = pointLineDistance( [c1;c2], v3, true );
    % pp is the perpendicular projection of v3 onto the line joining c1 and
    % c2.
    
    v = 2*pp - v3;
    % v is the reflection of v3 in that line. This is the first isogonal
    % point.
    
    [~,bcs] = projectPointToPlane( vxs, v );
    % bcs is the barycentric coordinates of v with respect to vxs.
    
    if length(bcs)==2
        % This happens if the three points are collinear.
        bcs = nan(1,3);
    end
    
    if testing
        % These are tests of some other ways of calculating the first isogonal
        % centre.
        edgevecs = vxs([3 1 2],:) - vxs([2 3 1],:);
        angles = vecangle( edgevecs([3 1 2],:), -edgevecs([2 3 1],:), n );
        angles = abs( angles );
        zbcs = isogonicTL( angles );

        sidelengthsq = sum( edgevecs.^2, 2 );
        xbcs = isogonicBC( sidelengthsq );
        xbcs = xbcs/sum(xbcs);

        zxbcs = zbcs .* sqrt(sidelengthsq);
        zxbcs = zxbcs/sum(zxbcs);
    
        fprintf( 1, 'bcs:   %7f %7f %7f\n', bcs ); % Our original calculation
        fprintf( 1, 'zbcs:  %7f %7f %7f\n', zbcs ); % Trilinear coords. Formula from ETC.
        fprintf( 1, 'xbcs:  %7f %7f %7f\n', xbcs ); % Barycentric coords. Formula from ETC.
        fprintf( 1, 'zxbcs: %7f %7f %7f\n', zxbcs ); % Trilinear converted to barycentric.
    
        [f,ax] = getFigure();
        hold on
    %     plotpts( vxs, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'Color', 'k' );
        plotlines( [1 2;2 3;3 1], vxs, 'LineStyle', '-', 'Marker', '.', 'MarkerSize', 20, 'Color', 'k' );
        plotpts( [c1;c2], 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'Color', 'b' );
        plotlines( [1 2;1 3;4 2;4 3], [v3;c1;c2;v], 'LineStyle', '-', 'Marker', 'none', 'Color', 'b' );
        plotpts( v, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'Color', 'r' );
        plotlines( [1 2;1 3;1 4], [v;vxs], 'LineStyle', '-', 'Marker', 'none', 'Color', 'g' );
        hold off;
        axis equal
        v = v(1:dims);
    end
end

function z = isogonicTL( angles )
    z = csc(angles + pi/3);
    z = z/sum(z);
end

function z = isogonicBC( asl2 )
    sidelengths = sqrt(asl2);
    s = sum(sidelengths)/2;
    area = sqrt( prod( [s; s-sidelengths] ) );
    asl4 = asl2.^2;
    bsl2 = asl2([2 3 1]);
    csl2 = asl2([3 1 2]);
    z = asl4 - 2*(bsl2 - csl2).^2 + asl2.*(bsl2 + csl2 + 4*sqrt(3)*area);
end

