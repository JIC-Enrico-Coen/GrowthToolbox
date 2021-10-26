function cellColors = colorCells( cellvxs, celledges, edgecells )
%cellColors = colorCells( cellvxs, celledges, edgecells )

%     palette = [ 1 0 0;
%                 0 0 1;
%                 1 1 0;
%                 0 1 0;
%                 1 0.5 0;
%                 1 1 1;
%                 0 1 1;
%                 0 0 0 ];
    numcolors = 1; % size(palette,1);
    numcells = length( cellvxs );
    cellColors = zeros( numcells, 1 );
    
    cp = randperm(numcells);
    
    for ci=cp
        eci = celledges{ci};
        nbs = edgecells(eci,:);
        nbs( (nbs==0) | (nbs==ci) ) = [];
        excludedColors = cellColors( nbs(cellColors(nbs) > 0) );
        allowedColors = true(numcolors,1);
        allowedColors(excludedColors) = false;
        chosenColor = find(allowedColors,1);
        if isempty(chosenColor)
            numcolors = numcolors+1;
%             palette(numcolors,:) = rand(1,3);
            chosenColor = numcolors;
        end
        cellColors(ci) = chosenColor;
    end
    
    cp = randperm(numcells);
    for ci=cp
        eci = celledges{ci};
        nbs = edgecells(eci,:);
        nbs( (nbs==0) | (nbs==ci) ) = [];
        excludedColors = cellColors( nbs(cellColors(nbs) > 0) );
        allowedColors = true(numcolors,1);
        allowedColors(excludedColors) = false;
        allowedColorList = find(allowedColors);
        if ~isempty(allowedColorList)
            newColor = allowedColorList( randi( length(allowedColorList) ) );
            cellColors(ci) = newColor;
        end
    end
end



