function forces = fourpointforce( torque, vxs, n3, n4 )
%forces = fourpointforce( torque, vxs, n3, n4 )
%   Given a 4*3 matrix of points [v1;v2;v3;v4] and equal and opposite
%   torques TORQUE about the line V1 V2, find a set of forces on the four
%   vertexes equivalent to those torques.  The torques are assumed to be
%   trying to move vertexes v3 and v4 in the direction of the normal
%   vectors n3 and n4.  If n3 and n4 are not supplied, they are calculated
%   from the vertexes, assuming that v1 v2 v3 ans v4 v2 v1 are
%   anticlockwise enumerations.

    if nargin < 4
        [area3,n3] = findAreaAndNormal( vxs([1 2 3],:) );
        [area4,n4] = findAreaAndNormal( vxs([4 2 1],:) );
    end
    [a3,alt3] = altitudeTriangle( vxs([3 1 2],:) );
    [a4,alt4] = altitudeTriangle( vxs([4 1 2],:) );
    altlen3 = sqrt(alt3*alt3');
    altlen4 = sqrt(alt4*alt4');
    edgelen = sqrt(sum((vxs(2,:)-vxs(1,:)).^2));
    f3 = (torque*edgelen/altlen3)*n3;
    f4 = (torque*edgelen/altlen4)*n4;
    if det([n3;n4;vxs(2,:)-vxs(1,:)]) > 0
        sense = 1;
    else
        sense = -1;
    end
    forces = sense * [ ...
        -f3*(1-a3) - f4*(1-a4); ...
        -f3*a3 - f4*a4; ...
        f3; ...
        f4 ];
    return;
    
    figure(1);
    clf;
    hold on
    plotpts( gca, vxs([1 2 3 1 4 2],:), 'k' );
    colors = 'rgbc';
    for i=1:4
        plotpts( gca, [ vxs(i,:); vxs(i,:)+forces(i,:) ], colors(i) );
    end
    c3 = sum(vxs([1 2 3],:),1)/3;
    c4 = sum(vxs([1 2 4],:),1)/3;
    plotpts( gca, [c3; c3+n3], 'k' );
    plotpts( gca, [c4; c4+n4], 'k' );
    axis equal
    hold off
    sum(forces,1)
end
