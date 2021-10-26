function s = makeEmptyPlotHandles( m )
    numnodes = size(m.nodes,1);
    numedges = size(m.edgeends,1);
    numcells = size(m.tricellvxs,1);
    numbioAcells = length(m.secondlayer.cells);

    s.nodes.blobs = -ones( 1, numnodes );
    s.nodes.Ablobs = -ones( 1, numnodes );
    s.nodes.Bblobs = -ones( 1, numnodes );

    s.edges.seams = -ones( 1, numedges );
    s.edges.Aseams = -ones( 1, numedges );
    s.edges.Bseams = -ones( 1, numedges );
    s.borderedges.patches = -ones( 1, numedges );

    s.cells.patches = -ones( 1, numcells );
    s.cells.Apatches = -ones( 1, numcells );
    s.cells.Bpatches = -ones( 1, numcells );

    s.bioAcells.patches = -ones( 1, numbioAcells );
end
