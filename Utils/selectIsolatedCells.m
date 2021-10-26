function [selectedMap,selectedList] = selectIsolatedCells( cellvxs, celledges, edgecells )
%[selectedMap,selectedList] = selectIsolatedCells( cellvxs, celledges, edgecells )

    numcells = length( cellvxs );
    selectedMap = false( 1, numcells );
    candidateCellMap = true( 1, numcells );
    candidateCellList = 1:numcells;
    cellIndexToCellList = 1:numcells;
    numCandidates = numcells;
    
    maxiters = numcells;
    numiters = 0;
    while numCandidates > 0
        numiters = numiters+1;
        if numiters > maxiters
            xxxx = 1;
        end
        newCandidateIndex = floor( rand(1)*numCandidates ) + 1;
        chosenCell = candidateCellList( newCandidateIndex );
%         fprintf( 1, 'chosenCell %d\n', chosenCell );
        selectedMap(chosenCell) = true;
        nonCandidates = unique( [ chosenCell reshape( edgecells( celledges{chosenCell}, : ), 1, [] ) ] );
        nonCandidates(nonCandidates==0) = [];
        nonCandidates = nonCandidates( candidateCellMap(nonCandidates) );
        newNumCandidates = numCandidates - length(nonCandidates);
        
        nonCandidateCellIndexToCellList = sort( cellIndexToCellList(nonCandidates) );
        
        % Remove the non-candidates.
        candidateCellMap(nonCandidates) = false;
%         cellIndexToCellList(nonCandidates) = 0;
        k = 1;
        for cCLi = numCandidates:-1:(newNumCandidates + 1)
            ci = candidateCellList(cCLi);
            if candidateCellMap(ci)
                cCLk = nonCandidateCellIndexToCellList(k);
                candidateCellList(cCLk) = candidateCellList(cCLi);
                cellIndexToCellList(ci) = cCLk;
                k = k+1;
            else
                % Nothing.
            end
            candidateCellList(cCLi) = 0;
        end
        
        cellIndexToCellList(nonCandidates) = 0;
        
        numCandidates = newNumCandidates;
        
        n1 = sum( candidateCellMap );
        n2 = sum( candidateCellList ~= 0 );
        n3 = sum( cellIndexToCellList ~= 0 );
        if (n1 ~= n2) || (n1 ~= n3)
            xxxx = 1;
        end
        
        
        xxxx = 1;
    end
    
    if nargout >= 2
        selectedList = find( selectedMap );
    end
end
