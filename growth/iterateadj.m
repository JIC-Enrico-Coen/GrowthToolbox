function [mesh,vels,force,totallinstrain,totalhingestrain] = ...
    iterateadj(mesh,vels,dt)
%[MESH,vels,force] =
%ITERATEADJ(MESH,VELS,DT)
%Perform a single iteration step of a spring graph.
% PTS is the set of points, VELS is the set of their velocities, and EDGES is
% the edge data matrix.

totallinstrain = 0;
totalhingestrain = 0;
force = zeros(size(mesh.nodes,1),3);

for i=1:size(mesh.edgeends,1)
    % Calculate forces between ends due to spring along edge.
    
    % Find end points of edge.
    p1 = mesh.edgeends(i,1);
    p2 = mesh.edgeends(2,i,2);
    v1 = mesh.nodes(p1:3);
    v2 = mesh.nodes(p2,1:3);
    v12 = v2 - v1;
    
    % Get edge length and squared length.
    v12lensq = dotproc2(v12,v12);
    mesh.edgelinsprings(i,1) = v12lensq;
    v12len = sqrt(v12lensq);
    mesh.edgelinsprings(i,2) = v12len;
    
    % Calculate linear spring force.
    strain = v12len/mesh.edgelinsprings(i,3) - 1; % For physical realism.
    % strain = 1 - mesh.edgelinsprings(i,3)/v12len; % For ill-behaved meshes.
    totallinstrain = totallinstrain + abs(strain);
    f = strain*mesh.edgelinsprings(i,4);
    force(p1,:) = force(p1,:) + v12 * f;
    force(p2,:) = force(p2,:) - v12 * f;
    
    % Calculate forces due to angle between cells on either side of the
    % edge.
    
    % Get cells on either side of edge.
    f1 = mesh.edgecells(i,1);
    f2 = mesh.edgecells(i,2);
    % If there is a cell on only one side, there is no hinge force.
    if (f2 ~= 0) && (f1 ~= 0)
        % Get the other vertexes of cells f1 and f2.
        p3 = mesh.tricellvxs(f1,findcelledge( mesh.celledges(f1,:), i ));
        p4 = mesh.tricellvxs(f2,findcelledge( mesh.celledges(f2,:), i ));
        
        % Get the altitude of cell 1 (v53) and its length.
        v3 = mesh.nodes(p3,1:3);
        v13 = v3 - v1;
        a3 = (v13' * v12) / v12lensq;
        v15 = v12 * a3;
        v15len = sqrt(dotproc2(v15,v15));
        v53 = v13 - v15;
        v53lensq = v53' * v53;
        v53len = sqrt(v53lensq);
        v53unit = v53/v53len;

        % Get the altitude of cell 2 (v64) and its length.
        v4 = mesh.nodes(p4,1:3);
        v14 = v4 - v1;
        a4 = (v14' * v12) / v12lensq;
        v16 = v12 * a4;
        v16len = sqrt(dotproc2(v16,v16));
        v64 = v14 - v16;
        v64lensq = v64' * v64;
        v64len = sqrt(v64lensq);
        v64unit = v64/v64len;
        
        % Calculate angle between v53 and v64.
        cross5364 = crossproc2(v53unit,v64unit);
        sense = dotproc2(cross5364,v12);
        sintheta = sqrt(cross5364' * cross5364);
        if sense < 0
            sintheta = -sintheta;
        end
        costheta = dotproc2(v53unit,v64unit);
    %   theta = pi - atan2(sintheta, costheta);        
        theta = atan2(sintheta, -costheta);
        mesh.edgehinges(i,2) = theta;
        anglestrain = theta - mesh.edgehinges(i,1);
        totalhingestrain = totalhingestrain + abs(anglestrain);
        torque = mesh.edgehinges(i,3)*anglestrain;
        torque = torque * v12len;

        % Calculate the forces due to the hinge spring at p3 and p4.
        f3 = torque*crossproc2(v53,v12)/(v53lensq*v12len);
        f4 = -torque*crossproc2(v64,v12)/(v64lensq*v12len);
        
        % Calculate the reaction forces at p1 and p2, determined by the
        % conditions that the total force and total torque must be zero.
        a23 = v15len/v12len;
        a13 = 1 - a23;
        a24 = v16len/v12len;
        a14 = 1 - a24;
        f1 = -a13*f3 - a14*f4;
        f2 = -a23*f3 - a24*f4;
        
        % Check that the total torque is zero, to within arithmetic
        % precision.
    %    torque12 = crossproc2(f2,v12)
    %    torque13 = crossproc2(f3,v15)
    %    torque14 = crossproc2(f4,v16)
    %    totaltorque = torque12 + torque13 + torque14
    
        % Add the forces to the force vector.
        force(p1,:) = force(p1,:) + f1;
        force(p2,:) = force(p2,:) + f2;
        force(p3,:) = force(p3,:) + f3;
        force(p4,:) = force(p4,:) + f4;
    end
end

% Add damping forces, and move the points under the influence of the forces.
totalvel = 0;
%for i=1:size(mesh.nodes,1)
%    force(i,:) = force(i,:) - vels(i,:)*mesh.globalProps.damping*dt;
%    vels(i,:) = vels(i,:) + force(i,:)*dt;
%    mesh.nodes(i,1:3) = mesh.nodes(i,1:3) + vels(i,1:3)*dt;
%    totalvel = totalvel + dotproc2(vels(i,:),vels(i,:));
%end
% Untested de-for-ed code below.
force = force - vels*mesh.globalProps.damping*dt;
vels = vels + force*dt;
mesh.nodes = mesh.nodes + vels*dt;
totalvel = totalvel + sum(dotproc2(vels(:,:),vels(:,:),2));

%fprintf( 1, 'iterateadj: strain %f, total vel %f.%c', ...
%    totallinstrain, totalvel, 10 );
end

function v = findcelledge( celledges, edge )
%FINDCELLEDGE(CELLEDGES,EDGE)  Return the index into CELLEDGES corresponding to the EDGE.
    for i=1:3
        if celledges(i)==edge
            v = i;
            return;
        end
    end
    v = 0;
end



