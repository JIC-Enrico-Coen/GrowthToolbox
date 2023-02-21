function [m,numElided] = elideSmallFaces( m, threshold )
    [~,faces] = shortFaces( m, m.globalProps.maxFEratio );
    selfaces = maxdisjointfaces( m.FEconnectivity.faces(faces) );
    faces = faces(selfaces);
    edges = unique( m.FEconnectivity.faceedges(faces,:) );
    nedges = length(edges);
    edgeendtype = m.FEconnectivity.vertexloctype( m.FEconnectivity.edgeends(edges,:) );
    edges = edges( edgeendtype(:,1)==edgeendtype(:,2) );
    if nedges > length(edges)
        fprintf( 1, '%s: %d edges detected as connecting interior to surface.\n', mfilename(), nedges - length(edges) );
    end
    numElided = length(edges);
    if numElided > 0
        fprintf( 1, '%s: eliding %d faces, %d edges.\n', mfilename(), length(faces), numElided );
        m = collapseT4edges( m, edges );
    end
end
