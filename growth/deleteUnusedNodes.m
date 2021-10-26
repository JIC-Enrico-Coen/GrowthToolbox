function mesh = deleteUnusedNodes( mesh )
    nodes = findUnusedNodes( mesh );
    mesh = deletepoints( mesh, nodes );
end

