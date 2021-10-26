function perCell = perFEToPerCell( m, perFE, whichCells )
%perCell = perFEToPerCell( m, perFE, whichCells )
%   Convert a per-FE quantity to a per-cell quantity.
%   whichCells is either a boolean map or a list of the indexes of the
%   cells for which values are requested, and defaults to all cells.
%   perFE must specify a value for all finite elements.  It may specify
%   several, by being an N*K array giving K values for each of the N cells.

    if nargin < 3
        whichCells = 1:length(m.secondlayer.cells);
    else
        if islogical(whichCells)
            whichCells = find(whichCells);
        end
        whichCells = reshape( whichCells, 1, [] );
    end
    numcells = length(whichCells);
    numvals = size(perFE,2);
    
    perCell = zeros( numcells, numvals );
    for i=1:length(whichCells)
        ci = whichCells(i);
        secondlayer_vxs = m.secondlayer.cells(ci).vxs;
        femCells = m.secondlayer.vxFEMcell( secondlayer_vxs );
        percellvertex = perFE( femCells, : );
        perCell(i,:) = sum( percellvertex, 1 ) / length( secondlayer_vxs );
    end
end
