function colorIndexes = randomColouring( numitems, adjacency, equivalence, initnumcolors )
%colorIndexes = randomColouring( numitems, adjacency, equivalence, initnumcolors )
%   
    if nargin < 3
        initnumcolors = 0;
    end
    if isempty( adjacency )
        adjacency = zeros(numitems,0);
    else
        adjacency = edgesToNbs( adjacency, numitems );
    end
    
    % Equivalence should be an N*1 array mapping each item to the index of
    % its equivalence class.
    if isempty( equivalence )
        equivalence = (1:numitems)';
        numclasses = numitems;
    else
        numclasses = max( equivalence(:) );
    end
    
    eqclasses = cell(numclasses,1);
    for i=1:numclasses
        eqclasses{i} = zeros(1,0,'int32');
    end
    for i=1:numitems
        eqclasses{equivalence(i)}(end+1) = i;
    end
    eqclassesarray = cellToRaggedArray( eqclasses );
    
    numcolors = initnumcolors;
    colorIndexes = zeros( numitems, 1, 'int32' );
    cis = randperm(numitems);
    for i=1:numitems
        if colorIndexes(i)==0
            % This item has not yet been assigned a colour.
            
            % Find all items equivalent to this one (including this one).
            eqnbs = eqclassesarray(equivalence(i),:);
            eqnbs = unique(eqnbs( eqnbs > 0 ));
            
            % Find all neighbours of all the equivalent items, excluding the equivalent items.
            neqnbs = adjacency( eqnbs, : );
            neqnbs = unique( neqnbs );
            neqnbs( neqnbs==0 ) = [];
            neqnbs = setdiff( neqnbs, eqnbs );
            
            % Find the colors already assigned to any of the neighbours.
            nbcolors = colorIndexes( neqnbs );
            nbcolors = unique( nbcolors );
            nbcolors(nbcolors==0) = [];
            
            % Choose a color not in that set.
            unusedcolormap = true( numcolors, 1 );
            unusedcolormap( nbcolors ) = false;
            unusedcolorindexes = find( unusedcolormap );
            if isempty(unusedcolorindexes)
                % If there is no unused color, make a new one.
                numcolors = numcolors+1;
                c = numcolors;
            else
                % Choose a random unused color.
                c = randelement( unusedcolorindexes );
            end
            
            % Assign that color to all the equivalent items.
            colorIndexes(eqnbs) = c;
        end
    end
    
    % Check that all cells have a colour, adjacent non-equivalent cells
    % have different colours, and adjacent equivalent cells have the same colour.
%     ok = all(colorIndexes > 0) && checkColouring( numitems, adjacency, equivalence, colorIndexes )
end

function ok = checkColouring( numitems, adjacency, equivalence, colorIndexes )
% Check that adjacent non-equivalent cells have different colours or are
% both uncoloured, and adjacent equivalent cells have the same colour.

    errors = 0;
    for i=1:numitems
        c1 = colorIndexes(i);
        for j=1:size(adjacency,2)
            i2 = adjacency(i,j);
            if i2 ~= 0
                c2 = colorIndexes(i2);
                if (c1==0) && (c2==0)
                    ok = true;
                elseif c1==c2
                    ok = equivalence(i)==equivalence(i2);
                else
                    ok = equivalence(i) ~= equivalence(i2);
                end
                if ~ok
                    errors = errors + 1;
                end
            end
        end
    end
end
