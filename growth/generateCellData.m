function m = generateCellData( m, cis )
%m = generateCellData( m, cis )
%   Create the per-cell data structures for the cells listed in cis.  The
%   mesh and its globalProps are assumed to have already been computed.
%   If cis is omitted it defaults to all the cells.

    full3d = usesNewFEs( m );
    if full3d
%         m = makeMultilayerCellFrames( m );
%         return;
        numnodes = size(m.FEnodes,1);
        numcells = size(m.FEsets(1).fevxs,1);
    else
        numnodes = size( m.nodes, 1 );
        numcells = size( m.tricellvxs, 1 );
    end

    if nargin < 2
        cis = 1:numcells;
    end
    if isempty(cis)
        return;
    end

    numGaussPoints = size(m.globalProps.gaussInfo.points,2);
    if full3d
        newcelldata(length(cis)) = emptyfecell();
    else
        newcelldata(length(cis)) = fecell();
    end
    m = makeCellFrames( m );
    for cii=1:length(cis)
        ci = cis(cii);
        if full3d
            cellvxCoords = m.FEnodes( m.FEsets(1).fevxs(ci,:), : )';
        else
            newcelldata(cii) = fecell();
            trivxs = m.tricellvxs(ci,:);
            prismvxs = [ trivxs*2-1, trivxs*2 ];
            cellvxCoords = m.prismnodes( prismvxs, : )';
        end
        if ~full3d % Is this code needed at all?
            for i=1:numGaussPoints
                J = PrismJacobian( cellvxCoords, m.globalProps.gaussInfo.points(:,i) );
                newcelldata(cii).gnGlobal(:,:,i) = ...
                    inv(J)' * m.globalProps.gaussInfo.gradN(:,:,i);
            end
        end
    end
    if isfield( m, 'celldata' )
        m.celldata(cis) = orderfields( newcelldata, m.celldata(1) );
    else
        m.celldata = newcelldata;
    end
  % m = recalc3d( m );  % WHY?
end
