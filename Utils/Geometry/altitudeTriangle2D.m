function [a,alt,foot,positive] = altitudeTriangle2D( vxs )
%[a,alt,foot] = altitudeTriangle2D( vxs )
%   Compute the altitude of the triangle VXS, whose rows are the vertexes,
%   through the first vertex.  ALT is the altitude vector from the base
%   towards that vertex, FOOT is the foot of the altitude, and A is the
%   proportion into which it divides the base: FOOT = (1-A)*V(2,:) + A*V(3,:).
%   POSITIVE is true if the triangle is right-handed.

    v21 = vxs(1,:) - vxs(2,:);
    v23 = vxs(3,:) - vxs(2,:);
    a = (v21*v23')/(v23*v23');
    foot = vxs(2,:) + a*v23;
    alt = vxs(1,:) - foot;
    if (v23(1)*v21(2) - v23(2)*v21(1)) > 0
        positive = 1;
    else
        positive = -1;
    end
    return;
    
    figure(1);
    clf;
    hold on
    plotpts( gca, vxs([1 2 3 1],:), 'k' );
    plotpts( gca, [ [0 0 0]; alt ], 'r' );
    plotpts( gca, [ vxs(1,:); foot ], 'r' );
    axis equal
    hold off
end
