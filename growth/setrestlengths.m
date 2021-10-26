function mesh = setrestlengths(mesh)
%mesh = setrestlengths(mesh)    Set resting lengths to current values.
    mesh.edgelinsprings(:,3) = mesh.edgelinsprings(:,2);
    % mesh.edgehinges(:,1) = mesh.edgehinges(:,2);
end
