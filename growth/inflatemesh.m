function [m,ok] = inflatemesh( m )
%m = inflatemesh( m )
%   Reconstruct all the information that was removed from m by stripmesh.
%
%   See also: STRIPMESH.

    full3d = usesNewFEs( m );
    if full3d
        for i=1:length(m.FEsets)
            m.FEsets(i).fe = FiniteElementType.MakeFEType( m.FEsets(i).fe );
        end
        return;
    end
    numprismnodes = size(m.prismnodes,1);
    if ~isfield( m, 'nodes' )
        m.nodes = 0.5*(m.prismnodes( 2:2:numprismnodes, : ) + m.prismnodes( 1:2:numprismnodes, : ));
    end
    numnodes = getNumberOfVertexes( m );
    numedges = max(m.celledges(:));
    numcells = size(m.celledges,1);
    nummgens = size(m.morphogens,2);
    m.tricellvxs = int32(m.tricellvxs);
    if ~isfield( m, 'edgeends' )
        m.edgeends( m.celledges(:,1), : ) = m.tricellvxs( :, [2 3] );
        m.edgeends( m.celledges(:,2), : ) = m.tricellvxs( :, [3 1] );
        m.edgeends( m.celledges(:,3), : ) = m.tricellvxs( :, [1 2] );
    end
    if ~isfield( m, 'edgecells' )
        m.edgecells = zeros( numedges, 2, 'int32' );
        ec = sortrows( [ m.celledges(:), repmat( (1:numcells)', 3, 1 ) ] );
        for i=1:size(ec,1)
            ei = ec(i,1);
            ci = ec(i,2);
            if m.edgecells(ei,1)==0
                m.edgecells(ei,1) = ci;
            else
                m.edgecells(ei,2) = ci;
            end
        end
    end
    if ~isfield( m, 'nodecelledges' )
        m = makeVertexConnections( m );
    end
    if ~isfield( m, 'displacements' )
        m.displacements = [];
    end
    if ~isfield( m, 'currentbendangle' )
        m.currentbendangle = zeros( numedges, 1 );
    end
    if ~isfield( m, 'morphogenclamp' )
        m.morphogenclamp = zeros( numnodes, nummgens );
    end
    if ~isfield( m, 'mgen_production' )
        m.mgen_production = zeros( numnodes, nummgens );
    end
    if ~isfield( m, 'mgen_absorption' )
        m.mgen_absorption = zeros( numnodes, nummgens );
    end
    if ~isfield( m, 'fixedDFmap' )
        if usesNewFEs( m )
            m.fixedDFmap = false( numnodes, 3 );
        else
            m.fixedDFmap = false( numnodes*2, 3 );
        end
    end
    if ~isfield( m, 'seams' )
        m.seams = false( numedges, 1 );
    end
    if ~isfield( m, 'drivennodes' )
        m.drivennodes = [];
    end
    if ~isfield( m, 'drivenpositions' )
        m.drivenpositions = [];
    end
    if ~isfield( m, 'cellbulkmodulus' )
        m.cellbulkmodulus = m.globalProps.bulkmodulus * ones( numcells, 1 );
    elseif numel(m.cellbulkmodulus)==1
        m.cellbulkmodulus = m.cellbulkmodulus * ones( numcells, 1 );
    end
    if ~isfield( m, 'cellpoisson' )
        m.cellpoisson = m.globalProps.poissonsRatio * ones( numcells, 1 );
    elseif numel(m.cellpoisson)==1
        m.cellpoisson = m.cellpoisson * ones( numcells, 1 );
    end
    if ~isfield( m, 'cellstiffness' )
        m.cellstiffness = repmat( m.globalProps.D, [1,1,numcells] );
    end
    if ~isfield( m, 'decorFEs' )
        m.decorFEs = [];
    end
    if ~isfield( m, 'decorBCs' )
        m.decorBCs = [];
    end
    if isfield( m.globalProps, 'twosidedpolarisation' )
        numpol = m.globalProps.twosidedpolarisation + 1;
    else
        numpol = 1;
    end
    if ~isfield( m, 'polfrozen' )
        m.polfrozen = false( numcells, numpol );
    end
    if ~isfield( m, 'polsetfrozen' )
        m.polsetfrozen = false(1,numpol);
    end
    if ~isfield( m, 'polfreeze' )
        m.polfreeze = zeros( numcells, 3, numpol );
    end
    if ~isfield( m, 'polfreezebc' )
        m.polfreezebc = zeros( numcells, 3, numpol );
    end

    if any( ~isfield( m, ...
            { 'cellareas', ...
              'unitcellnormals', ...
              'gradpolgrowth', ...
              'currentbendangle' } ) ) ...
          || any( ~isfield( m.secondlayer, ...
                      { 'cell3dcoords', ...
                      'edges', ...
                      'cellarea' } ...
              ))
        m = recalc3d( m );
        % Restores:
        %   m.secondlayer.cell3dcoords
    end

    if ~isfield( m, 'celldata' )
        m = generateCellData( m );
        m = computeResiduals( m );
    else
        if ~isfield( m.celldata, 'gnGlobal' )
            m = computeGNGlobal( m );
        end
        newcell = fecell();
      % m.celldata(1) = defaultFromStruct( m.celldata(1), newcell );
        % This should be a call of defaultFromStruct but stupid Matlab
        % can't handle it.
        fn = fieldnames(newcell);
        for i = 1:length(fn)
            if ~isfield( m.celldata, fn{i} )
                for ci=1:length(m.celldata)
                    m.celldata(ci).(fn{i}) = newcell.(fn{i});
                end
            end
        end
        if ~isfield( m, 'cellFrames' )
            m = makeCellFrames( m );
        end
        m = computeResiduals( m );
        % m.celldata.fixed does not need to be restored.
    end

    m.effectiveGrowthTensor = zeros( numcells, 6 );
    
    if ~isfield( m.secondlayer, 'edges' ) || isempty( m.secondlayer.edges )
        m.secondlayer = makeSecondLayerEdgeData( m.secondlayer );
        % Restores:
        %   m.secondlayer.edges
        %   m.secondlayer.cells.edges
    end
    
    m.visible = [];
    
    % m.secondlayer.cellarea need not be rebuilt.
    % m.visible need not be rebuilt.
    % m.plothandles need not be rebuilt.
    % m.normalhandles need not be rebuilt.
    % m.strainhandles need not be rebuilt.
    
    ok = true;
  % ok = validmesh(m);
end

