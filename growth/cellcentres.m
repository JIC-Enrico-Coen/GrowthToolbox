function cc = cellcentres( m, cells, side )
%cc = cellcentres( m, cells, side )
%   Find the centres of all the finite elements, on either the A side, the
%   B side, or the midplane.  side==-1 is the A side, 0 is the midplane,
%   and 1 is the B side.  If side is omitted, it is determined from the
%   plotting options.
%
%   For volumetric meshes, SIDE is ignored.

    full3d = usesNewFEs(m);
    if full3d
        haveCells = (nargin >= 1) && ~isempty(cells);
        rcellvxs = cell( length(m.FEsets), 1 );
        for i=1:length(m.FEsets)
            if haveCells
                cc = cells{i};
            else
                cc = 1 : size( m.FEsets(i).fevxs, 1 );
            end
            vxsPerFE = size( m.FEsets(i).fevxs, 2 );
            rcellvxs{i,1} = reshape( sum( reshape( m.FEnodes( m.FEsets(1).fevxs(cc,:)', : ), vxsPerFE, [], 3 ), 1 ), [], 3 ) / vxsPerFE;
        end
        cc = cell2mat( rcellvxs );
        return;
    end

    if (nargin < 2) || isempty(cells)
        cells = 1:getNumberOfFEs(m);
    end

    if side==0
        rcellvxs = reshape( m.nodes( m.tricellvxs(cells,:)', : ), 3, [], 3 );
    elseif side == -1
        rcellvxs = reshape( m.prismnodes( -1+2*m.tricellvxs(cells,:)', : ), 3, [], 3 );
    else
        rcellvxs = reshape( m.prismnodes( 2*m.tricellvxs(cells,:)', : ), 3, [], 3 );
    end
    cc = reshape( sum( rcellvxs, 1 ), [], 3 )/3;
end
