function mesh = setlengths(mesh)
%MESH = SETLENGTHS(MESH)  Set the lengths of all the edges.
    mesh = makeTRIvalid( mesh );
    edgevecs = mesh.nodes(mesh.edgeends(:,1),1:3) ...
               - mesh.nodes(mesh.edgeends(:,2),1:3);
    mesh.edgelinsprings(:,1) = dotproc2(edgevecs,edgevecs,2);
    mesh.edgelinsprings(:,2) = sqrt(mesh.edgelinsprings(:,1));
end
