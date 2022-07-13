function secondlayer = makeSecondLayerEdgeData( secondlayer )
%secondlayer = makeSecondLayerEdgeData( secondlayer )
%   Construct secondlayer.edges and secondlayer.cells(:).edges from
%   secondlayer.cells(:).vxs.
%
%   secondlayer.edges is an E*4 array, where E is the number of edges.
%   secondlayer.edges(:,[1 2]) lists the vertexes that the edge joins.
%   secondlayer.edges(:,[3 4]) lists the cells the edge belongs to.
%
%   There are consistency rules relating these:
%
%   1. If an edge ei has a cell on only one side, then the non-existent
%   cell on the other side is represented as zero. This entry always occurs
%   as the second cell, i.e. secondlayer.edges(ei,4).
%
%   2. If secondlayer.edges(ei,:) is [v1,v2,c1,c2], then vertexes v1 and v2
%   occur in that order in secondlayer.cells(c1).vxs, and if c2 is not 0,
%   in the opposite order in secondlayer.cells(c2).vxs.

    if ~isNonemptySecondLayer( secondlayer )
        return;
    end
    
    if isfield( secondlayer, 'vxFEMcell' )
        numBioVxs = length( secondlayer.vxFEMcell );
    else
        allvxs = cell2mat( { secondlayer.cells.vxs } );
        numBioVxs = max( allvxs );
    end
    numBioEdges = 0;
    numBioCells = length( secondlayer.cells );
    
    % Estimate the number of edges.
    maxedges = 0;
    for ci=1:numBioCells
        maxedges = maxedges + length( secondlayer.cells(ci).vxs );
    end
    
    % Preallocate the edge data matrix.
    bioEdges = zeros( maxedges, 4, 'int32' );
    
    es = zeros( numBioVxs, numBioVxs );
    for ci=1:numBioCells
        cvs = secondlayer.cells(ci).vxs;
        nv = length(cvs);
        celledges = zeros( 1, nv, 'int32' );
        for i=1:nv
            j = mod(i,nv)+1;
            v1 = cvs(i);
            v2 = cvs(j);
            ei = es(v2,v1);
            if ei==0
                numBioEdges = numBioEdges+1;
                ei = numBioEdges;
                es(v1,v2) = ei;
                es(v2,v1) = ei;
                bioEdges( ei, : ) = [ v1, v2, ci, 0 ];
            else
                bioEdges( ei, 4 ) = ci;
            end
            celledges(i) = ei;
        end
        secondlayer.cells(ci).edges = celledges;
    end
    secondlayer.edges = bioEdges( 1:numBioEdges, : );
end
