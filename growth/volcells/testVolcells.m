function volcells1 = testVolcells()
    centre = [0 0 0];
    height = 1;
    edgelength = 1;
    staggerings = 1;
    convexity = 1/(2*sqrt(3));
    
    fprintf( 'Test 1.\n' );
    volcells1 = hexPrismVolCellForStaggering( centre, height, edgelength, staggerings, convexity );
    volcells1ok = validVolcells( volcells1 )
    
    fprintf( 'Test 2.\n' );
    volcells2 = volcells1;
    volcells2.vxs3d = volcells2.vxs3d + [0.75 sqrt(3)/4 1];
    volcells2ok = validVolcells( volcells2 )
    
    fprintf( 'Test 3.\n' );
    volcells3 = unionVolCells( volcells1, volcells2 );
    volcells3ok = validVolcells( volcells3 )
    
    fprintf( 'Test 4.\n' );
    volcells4 = unionVolCells( volcells1, volcells1 );
    volcells4ok = validVolcells( volcells4 )
    
    fprintf( 'Test 5.\n' );
    volcells5 = mergeVolCellsVxs2( volcells4, 0, false );
    volcells5ok = validVolcells( volcells5 )
    
    fprintf( 'Test 6.\n' );
    volcells6 = mergeVolCellsVxs2( volcells3, 1e-5, false );
    volcells6ok = validVolcells( volcells6 )
    
    fprintf( 'Test 7.\n' );
    edgevecs = volcells1.vxs3d( volcells1.edgevxs(:,1), : ) - volcells1.vxs3d( volcells1.edgevxs(:,2), : );
    edgesizes = max( abs(edgevecs), [], 2 );
    edgesizes = uniquetol( edgesizes );
    volcells7 = mergeVolCellsVxs2( volcells1, edgesizes(1)+1e-5, true );
    volcells7ok = validVolcells( volcells7 )

    fprintf( 'Test 8.\n' );
    volcells8 = volcells1;
    newv23v24 = mean( volcells8.vxs3d( [23 24], : ), 1 );
    volcells8.vxs3d(23,:) = newv23v24;
    volcells8.vxs3d(24,:) = newv23v24;
    volcells8 = mergeVolCellsVxs2( volcells8, 0, true );
    volcells8ok = validVolcells( volcells8 )

    fprintf( 'Test 9.\n' );
    volcells9 = volcells1;
    nodesToMerge = volcells9.vxs3d(:,3) >= 0.5-1e-5;
    volcells9.vxs3d( nodesToMerge, : ) = repmat( mean( volcells9.vxs3d( nodesToMerge, : ), 1 ), sum(nodesToMerge), 1 );
    volcells9 = mergeVolCellsVxs2( volcells9, 0, true );
    volcells9ok = validVolcells( volcells9 )

    fprintf( 'Test 10.\n' );
    volcells10 = mergeVolCellsVxs2( volcells1, 20, true );
    volcells10ok = validVolcells( volcells10 )

%     [fig,ax] = getFigure();
%     plotVolCells( ax, volcells3 );
%     view(0,30);
%     axis equal;
%     [fig,ax] = getFigure();
%     plotVolCells( ax, volcells4 );
%     view(0,30);
%     axis equal;
    [fig,ax] = getFigure();
    plotVolCells( ax, volcells7 );
    view(0,30);
    axis equal;
end
