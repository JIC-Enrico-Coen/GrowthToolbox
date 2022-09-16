function volcells = fillWithHexVolcells( bbox, initpoint, height, edgelength )

% Calculate the lattice of centres. CENTRE is the location of one of them.
% The others are to be spaced from there.

    latticevectors = [ edgelength*3/2, edgelength*sqrt(3)/2, 0; ...
                       0, edgelength*sqrt(3), 0; ...
                       edgelength*0.75 edgelength*sqrt(3)/4  height ];
    latticepts = fillBoxWithLattice( bbox, initpoint, latticevectors );

    staggerings = 1;
    convexity = 1;
    volcells00 = hexPrismVolCellForStaggering( [0 0 0], height, edgelength, staggerings, [0 1] );
    volcells0 = delVolcells( volcells00, 'vxdellist', [] );
    volcells1 = hexPrismVolCellForStaggering( [0 0 0], height, edgelength, staggerings, convexity );
    
    toplatticepoints = latticepts(:,3) >= max( latticepts(:,3) ) - 1e-5;
    
    % Replicate volcells0 and volcells1 over latticepts.
    allvolcells = emptystructarray( [size(latticepts,1),1], volcells1 );
    for i=1:size(latticepts,1)
        if toplatticepoints(i)
            allvolcells(i) = volcells0;
        else
            allvolcells(i) = volcells1;
        end
        allvolcells(i).vxs3d = allvolcells(i).vxs3d + latticepts(i,:);
    end
    
    volcells = unionVolCells( allvolcells );
    
    volcells = mergeVolCellsVxs2( volcells, 1e-5 * min( height, edgelength ), true );
    [fig,ax] = getFigure();
    plotVolCells( ax, volcells )
    axis equal;
end

