function [a,alt,foot] = altitudeTriangle( vxs )
%[a,alt,foot] = altitudeTriangle( vxs )
%   Compute the altitude of the triangle VXS, whose rows are the vertexes,
%   through the first vertex.  ALT is the altitude vector from the base
%   towards that vertex, FOOT is the foot of the altitude, and A is the
%   proportion into which it divides the base: FOOT = (1-A)*V(2,:) + A*V(3,:).

    v21 = vxs(1,:) - vxs(2,:);
    v23 = vxs(3,:) - vxs(2,:);
    a = (v21*v23')/(v23*v23');
    foot = vxs(2,:) + a*v23;
    alt = vxs(1,:) - foot;
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
