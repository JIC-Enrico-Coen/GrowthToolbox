function gc = resultantDirectedGrowthPerCell( m, dir, type, cells )
%gfe = resultantDirectedGrowthPerCell( m, dir, type, fes )
%   Calculate the projections of various growth tensors of a mesh M onto a
%   specified direction.
%
%   DIR is a 3-element vector specifying a direction.  It must be non-zero
%   but need not be normalised.
%
%   TYPE is either 'actual', 'specified', or 'residual'.  Anything else
%   makes this procedure return an empty array.
%
%   CELLS specifies which finite element the growth is to be computed for.
%   By default it is all of them.
%
%   The result is a column vector of growth rates, one per finite element
%   asked for.
%
%   See also: projectTensorsToDirections.

    gfe = resultantDirectedGrowthPerFE( m, dir, type );
    if isempty(gfe)
        gc = [];
        return;
    end
    
    if (nargin < 4) || isempty(cells)
        cells = 1:length(m.secondlayer.cells);
    end
    numcells = length(cells);
    gc = zeros(numcells,1);
    gcvx = gfe( m.secondlayer.vxFEMcell );
    for i=1:numcells
        gcivx = gcvx( m.secondlayer.cells(i).vxs );
        gc(i) = sum(gcivx)/length(gcivx);
    end
end

