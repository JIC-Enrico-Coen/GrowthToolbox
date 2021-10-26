function secondlayer = calcEdgeData( secondlayer )
%secondlayer = calcEdgeData( secondlayer )
%   Calculate secondlayer.edges and secondlayer.cells(:).edges from the
%   other information in secondlayer.
%   This requires:
%       secondlayer.cells(:).vxs
%       secondlayer.vxFEMcell (only to get number of vertexes)
%   This produces:
%       secondlayer.cells(:).edges
%       secondlayer.edges

    numcells = length( secondlayer.cells );
    numvxs = length( secondlayer.vxFEMcell );

    % Record of edges we have already seen, so that we don't insert edges
    % twice, once for each of the two cells they bellong to.
    edgemx = zeros( numvxs, numvxs, 'int32' );
    
    % Estimate the number of edges.
    maxedges = 0;
    for ci=1:numcells
        maxedges = maxedges + length( secondlayer.cells(ci).vxs );
    end

    % Preallocate the edge data matrix.
    edgedata = zeros( maxedges, 4, 'int32' );

    numedges = 0;
    for ci=1:numcells
        numcellvxs = length( secondlayer.cells(ci).vxs );
        secondlayer.cells(ci).edges = zeros( 1, numcellvxs, 'int32' );
        for cvi=1:numcellvxs
            cvi1 = mod(cvi,numcellvxs) + 1;
            vi = secondlayer.cells(ci).vxs(cvi);
            vi1 = secondlayer.cells(ci).vxs(cvi1);
            if true % vi < vi1
                vlo = vi; vhi = vi1;
            else
                vlo = vi1; vhi = vi;
            end
            if edgemx( vlo, vhi )==0
                numedges = numedges+1;
                edgemx( vlo, vhi ) = numedges;
                edgedata( numedges, : ) = [ vi, vi1, ci, 0 ];
            else
                edgedata( edgemx( vlo, vhi ), 4 ) = ci;
            end
            secondlayer.cells(ci).edges(cvi) = edgemx( vlo, vhi );
        end
    end
    secondlayer.edges = edgedata( 1:numedges, : );
end
