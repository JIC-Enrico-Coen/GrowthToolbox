function n = numcellsBioA( bioa )
%n = numcells( sl )
%   Find the number of cells in the bio-A layer.

    if (length( bioa.cells )==1) && isempty( bioa.cells.vxs )
        n = 0;
    else
        n = length( bioa.cells );
    end
end
