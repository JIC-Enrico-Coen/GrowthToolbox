function cellColors = colorCells( cellvxs, celledges, edgecells, initNumColors )
%cellColors = colorCells( cellvxs, celledges, edgecells, initNumColors )

    if nargin < 4
        initNumColors = 6;
    end
    numcolors = initNumColors;
    numcells = length( cellvxs );
    cellColors = zeros( numcells, 1 );
    
    needConnectivity = (nargin==1) || isempty( celledges );
    
    if needConnectivity
        % Need to calculate the connectivity information.
        numedges = 0;
        for i=1:numcells
            numedges = numedges + length( cellvxs{i} );
        end
        edgeends = zeros( numedges, 2 );
        ec = zeros( numedges, 1 );
        ei = 0;
        for i=1:numcells
            vxs = cellvxs{i};
            vxs2 = vxs( [2:end 1] );
            edgeends( (ei+1):(ei+length(vxs)), : ) = [ vxs(:), vxs2(:) ];
            ec( (ei+1):(ei+length(vxs)) ) = i;
            ei = ei+length(vxs);
        end
        edgeends = [ sort( edgeends, 2 ), ec ];
        edgeends = sortrows( edgeends );
        [eec,ia,~] = unique( edgeends(:,1:2), 'rows', 'stable' );
        firstof2cellmap = ia(1:(end-1))+1 ~= ia(2:end);
        edgecells = zeros( length(ia), 2 );
        edgecells(:,1) = edgeends(ia,3);
        edgecells(firstof2cellmap,2) = edgeends(ia(firstof2cellmap)+1,3);
        
        celledgelist = [ edgecells(:), repmat( (1:size(edgecells,1))', 2, 1 ) ];
        celledgelist( celledgelist(:,1)==0, : ) = [];
        celledgelist = sortrows( celledgelist );
        [~,reps,first] = countreps( celledgelist(:,1) );
        celledges = cell( 1, length(first) );
        for i=1:length(first)
            celledges{i} = celledgelist( first(i):(first(i)+reps(i)-1), 2 )';
        end
        
%         edgeends = edgeends(:,1:2);
        xxxx = 1;
    end
    
    cp = randperm(numcells);
    
    % Go through the cells in random order.
    % For each cell, pick a color index randomly from those that do not
    % already occur among the neighbours of this cell. If all colours are
    % taken, make a new colour index.
    for ci=cp
        eci = celledges{ci};
        nbs = edgecells(eci,:);
        nbs( (nbs==0) | (nbs==ci) ) = [];
        excludedColors = cellColors( nbs(cellColors(nbs) > 0) );
        allowedColors = true(numcolors,1);
        allowedColors(excludedColors) = false;
        allowedColorIndexes = find(allowedColors);
        if isempty(allowedColorIndexes)
            numcolors = numcolors+1;
            chosenColor = numcolors;
        else
            chosenColor = allowedColorIndexes( 1 + floor( rand()*length(allowedColorIndexes) ) );
        end
        cellColors(ci) = chosenColor;
    end
    
%     cp = randperm(numcells);
%     for ci=cp
%         eci = celledges{ci};
%         nbs = edgecells(eci,:);
%         nbs( (nbs==0) | (nbs==ci) ) = [];
%         excludedColors = cellColors( nbs(cellColors(nbs) > 0) );
%         allowedColors = true(numcolors,1);
%         allowedColors(excludedColors) = false;
%         allowedColorList = find(allowedColors);
%         if ~isempty(allowedColorList)
%             newColor = allowedColorList( randi( length(allowedColorList) ) );
%             cellColors(ci) = newColor;
%         end
%     end
end



