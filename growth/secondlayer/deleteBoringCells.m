function secondlayer = deleteBoringCells( secondlayer, t )
%secondlayer = deleteBoringCells( secondlayer )
%   Delete all second layer cells which are not either shocked or share an
%   edge with a shocked cell.

    numcells = length( secondlayer.cells );
    
    % Shocked cells are to be retained.
    boringCells = secondlayer.cloneindex == 0;
    
    % Every cell next to a shocked cell is to be retained.
    boringNeighbours = true(numcells,1);
    for i=1:size(secondlayer.edges,1)
        c2 = secondlayer.edges(i,4);
        if c2 <= 0, continue; end
        c1 = secondlayer.edges(i,3);
        if ~boringCells(c1)
            boringNeighbours(c2) = false;
        end
        if ~boringCells(c2)
            boringNeighbours(c1) = false;
        end
    end
    secondlayer = deleteSecondLayerCells( secondlayer, boringCells & boringNeighbours, t );
end

