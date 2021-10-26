function mesh = growmesh(mesh,dt)
%MESH = GROWMESH(MESH,DT)    Grow the mesh.
%  UNUSED
    gs = (mesh.morphogens(mesh.edgeends(:,1),mesh.globalProps.activeGrowth) + ...
          mesh.morphogens(mesh.edgeends(:,2),mesh.globalProps.activeGrowth))/2;
    mesh.edgelinsprings(:,3) = ...
            mesh.edgelinsprings(:,3) .* ((1 + gs*dt));
end

