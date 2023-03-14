function bins = findMeshConnectedComponents( m )
    if isVolumetricMesh( m )
        graphedges = m.FEconnectivity.facefes;
    else
        graphedges = m.edgecells;
    end
    numFEs = getNumberOfFEs(m);
    graphedges( graphedges(:,2)==0, : ) = [];
    g = graph( [graphedges(:,1);numFEs], [graphedges(:,2);numFEs] );
    bins = conncomp( g, 'OutputForm', 'cell' );
end