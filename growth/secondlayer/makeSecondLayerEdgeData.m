function secondlayer = makeSecondLayerEdgeData( secondlayer )
%secondlayer = makeSecondLayerEdgeData( secondlayer )
%   Construct secondlayer.edges and secondlayer.cells(:).edges from
%   secondlayer.cells(:).vxs.

    if ~isNonemptySecondLayer( secondlayer )
        return;
    end
    
    numBioVxs = length( secondlayer.vxFEMcell );
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
