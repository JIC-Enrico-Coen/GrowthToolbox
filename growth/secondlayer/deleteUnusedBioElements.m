function m = deleteUnusedBioElements( m )
%m = deleteUnusedBioElements( m )
%   Any vertexes or edges in the bio layer that are not part of any cell
%   are deleted, and the remainder renumbered.

    numcells = length(m.secondlayer.cells);
    numvxs = length(m.secondlayer.vxFEMcell);
    numedges = size(m.secondlayer.edges,1);
    
    usedvxs = false(1,numvxs);
    usededges = false(1,numedges);
    for i=1:numcells
        usedvxs( m.secondlayer.cells(i).vxs ) = true;
        usededges( m.secondlayer.cells(i).edges ) = true;
    end
    
    if all(usedvxs) && all(usededges)
        fprintf( 1, '%s: no unused vertexes or edges.\n', mfilename() );
        return;
    end
    
    fprintf( 1, '%s: %d unused vertexes, %d unused edges.\n', mfilename(), sum(~usedvxs), sum(~usededges) );

    
    [oldToNewVxs,~] = retainMapToPerms( usedvxs );
    [oldToNewEdges,~] = retainMapToPerms( usededges );
    
    for i=1:numcells
        m.secondlayer.cells(i).vxs = oldToNewVxs( m.secondlayer.cells(i).vxs );
        m.secondlayer.cells(i).edges = oldToNewEdges( m.secondlayer.cells(i).edges );
    end
    
    m.secondlayer = keepBioElements( m.secondlayer, 0, usededges, usedvxs );
    m.secondlayer.edges(:,[1 2]) = oldToNewVxs( m.secondlayer.edges(:,[1 2]) );
end

