function cells = allocateCells( numcells )
    cells = struct( 'vxs', cell(numcells,1), 'edges', cell(numcells,1) );
end
