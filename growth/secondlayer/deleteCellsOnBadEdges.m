function m = deleteCellsOnBadEdges( m, badedges )
%m = deleteCellsOnBadEdges( m, badedges )
%   Delete every biological cell which crosses any edge of the finite
%   element mesh listed in badedges.  badedges can be a bitmap or an array
%   of indexes.
%
%   We use a conservative test: every biological cell that has vertexes
%   in two cells joined by a bad edge is deleted.  It is possible that a
%   cell is deleted unnecessarily.
%
%   WARNING: this test is not conservative enough.  It is possible for a
%   bio cell to contain vertexes straddling a seam edge, but without it
%   containing vertexes in both of the cells directly bordering the edge.
    
    badFEpairs = m.edgecells(badedges,:);
    badFEpairs( badFEpairs(:,2)==0, : ) = [];
    numbadedges = size(badFEpairs,1);
    badFEpairs = sort( badFEpairs, 2 );
    badFEpairs = sortrows( badFEpairs );
  % m.secondlayer.vxFEMcell( m.secondlayer.edges(:,[1 2]) )
    secondvxs = m.secondlayer.edges(:,[1 2]);
    secondcells = m.secondlayer.edges(:,[3 4]);
    bridgedFEs = [ m.secondlayer.vxFEMcell( secondvxs ), secondcells ];
    bridgedFEs(:,[1 2]) = sort( bridgedFEs(:,[1 2]), 2 );
    bridgedFEs = sortrows( bridgedFEs );
    curbadedge = 1;
    numbiocells = length( m.secondlayer.cells );
    cellstodelete = false( numbiocells, 1 );
    for i=1:size(bridgedFEs,1)
        if bridgedFEs(i,1) < badFEpairs(curbadedge,1)
            % skip
        elseif bridgedFEs(i,1) > badFEpairs(curbadedge,1)
            curbadedge = curbadedge+1;
            if curbadedge > numbadedges
                break;
            end
        elseif bridgedFEs(i,2) < badFEpairs(curbadedge,2)
            % skip
        elseif bridgedFEs(i,2) > badFEpairs(curbadedge,2)
            curbadedge = curbadedge+1;
            if curbadedge > numbadedges
                break;
            end
        else
            % Bad cells
            cellstodelete(bridgedFEs(i,3)) = true;
            if bridgedFEs(i,4) > 0
                cellstodelete(bridgedFEs(i,4)) = true;
            end
        end
    end
    m.secondlayer = deleteSecondLayerCells( m.secondlayer, cellstodelete, m.globalDynamicProps.currenttime );
end
