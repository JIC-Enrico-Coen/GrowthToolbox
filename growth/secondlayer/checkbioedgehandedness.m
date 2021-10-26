function [ok,secondlayer] = checkbioedgehandedness( secondlayer, complainer )
    ok = true;
    for ei=1:size( secondlayer.edges, 1 )
        edgedata = secondlayer.edges( ei, : );
        v1 = edgedata(1);
        v2 = edgedata(2);
        cell1 = edgedata(3);
        cell2 = edgedata(4);
        if cell1 > 0
            cvxs = secondlayer.cells(cell1).vxs;
            v1i = find(cvxs==v1,1);
            v2i = mod(v1i,length(cvxs)) + 1;
            if cvxs(v2i) ~= v2
                ok = false;
                complainer( 'validmesh:badedgedata', ...
                    'edge %d has wrong handedness in cell %d: [ %d %d %d %d ]', ei, cell1, v1, v2, cell1, cell2 );
                fprintf( 1, 'cell %d has vertex list [', cell1 );
                fprintf( 1, ' %d', cvxs );
                fprintf( 1, ' ]\n' );
            end
        end
        if cell2 > 0
            cvxs = secondlayer.cells(cell2).vxs;
            v2i = find(cvxs==v2,1);
            v1i = mod(v2i,length(cvxs)) + 1;
            if cvxs(v1i) ~= v1
                ok = false;
                complainer( 'validmesh:badedgedata', ...
                    'edge %d has wrong handedness in cell %d: [ %d %d %d %d ]', ei, cell2, v1, v2, cell1, cell2 );
                fprintf( 1, 'cell %d has vertex list [', cell2 );
                fprintf( 1, ' %d', cvxs );
                fprintf( 1, ' ]\n' );
            end
        end
    end
    if ~ok
        % Remake the edge data with consistent orientations.
        secondlayer = fixBioOrientations( secondlayer );
    end
end

