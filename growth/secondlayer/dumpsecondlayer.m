function dumpsecondlayer( secondlayer )
    vxFEMcells = secondlayer.vxFEMcell'
    fprintf( 1, 'Edge %d vxs %d %d cells %d %d\n', ...
        [ [1:size(secondlayer.edges,1)]', secondlayer.edges ]' );
    for ci=1:length( secondlayer.cells )
        fprintf( 1, 'Cell %d: vxs', ci );
        fprintf( 1, ' %d', secondlayer.cells(ci).vxs );
        fprintf( 1, '    edges' );
        fprintf( 1, ' %d', secondlayer.cells(ci).edges );
        fprintf( 1, '\n' );
    end
end

        