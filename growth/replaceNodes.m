function m = replaceNodes( m, newm )
%m = replaceNodes( m, newm )
%   Replace m.nodes and m.tricellvxs by newm.nodes and newm.tricellvxs.
%   If newm has prismnodes, replace that also.

    global FE_P6 FE_T3

    oldfull3d = usesNewFEs( m );
    newfull3d = usesNewFEs( newm );
    oldnumcells = getNumberOfFEs(m);
    oldnumnodes = getNumberOfVertexes(m);
    newnumnodes = getNumberOfVertexes( newm );
    if true || (oldnumnodes ~= newnumnodes)
        oldcentroids = cellcentres( m, [], 0 );
        newcentroids = cellcentres( newm, [], 0 );
        if oldfull3d
            oldnodes = m.FEnodes;
        else
            oldnodes = m.nodes;
        end
        if newfull3d
            newnodes = newm.FEnodes;
        else
            newnodes = newm.nodes;
        end
        renumber = nearestNeighbours( newnodes, oldnodes );
        if newfull3d
            prenumber = renumber;
        else
            prenumber = 2*renumber';
            prenumber = reshape( [ prenumber-1; prenumber ], [], 1 );
        end
        renumberCells = nearestNeighbours( newcentroids, oldcentroids );
    else
        renumber = [];
        prenumber = [];
    end
    if newfull3d
        if ~oldfull3d
            m = rmfield( m, { 'nodes', 'tricellvxs' } );
        end
        m.FEnodes = newm.FEnodes;
        m.FEsets = newm.FEsets;
        m = calcFEvolumes( m );
        % connectivity?
    else
        if oldfull3d
            m.FEnodes = [];
            m.FEsets(1) = struct( 'fe', FE_P6, 'fevxs', [] );
            m.FEsets(1) = struct( 'fe', FE_T3, 'fevxs', [] );
%             m = rmfield( m, { 'FEnodes', 'FEsets' } );
        end
        m.nodes = newm.nodes;
        m.tricellvxs = newm.tricellvxs;
        m.globalProps.trinodesvalid = true;
    end
    m.decorFEs = [];
    m.decorBCs = [];
    if isfield( newm, 'prismnodes' )
        m.prismnodes = newm.prismnodes;
        m.globalProps.prismnodesvalid = true;
    else
        m.prismnodes = [];
        m.globalProps.prismnodesvalid = false;
    end
    if ~isempty( renumber )
        m.morphogens = m.morphogens( renumber, : );
        m.morphogenclamp = m.morphogenclamp( renumber, : );
        m.mgen_production = m.mgen_production( renumber, : );
        m.mgen_absorption = m.mgen_absorption( renumber, : );
        if oldfull3d==newfull3d
            m.fixedDFmap = m.fixedDFmap( prenumber, : );
        else
            m.fixedDFmap = false( getNumberOfVertexes(m), 3 );
        end
        m.cellbulkmodulus = m.cellbulkmodulus( renumberCells );
        m.cellpoisson = m.cellpoisson( renumberCells );
        m.cellstiffness = m.cellstiffness( :, :, renumberCells );
        m.gradpolgrowth = m.gradpolgrowth( renumberCells, :, : );
        if ~isempty(m.displacements)
            m.displacements = m.displacements( renumber, : );
        end
        if isfield( m, 'gradpolgrowth2' ) && ~isempty( m.gradpolgrowth2 )
            m.gradpolgrowth2 = m.gradpolgrowth2( renumberCells, :, : );
        end
        m.polfreeze = m.polfreeze( renumberCells, : );
        m.polfrozen = m.polfrozen( renumberCells, : );
        if size(m.polsetfrozen,1) > 1
            m.polsetfrozen = m.polsetfrozen( renumberCells, : );
        end
        if ~newfull3d && ~oldfull3d
            m.polfreezebc = m.polfreezebc( renumberCells, : );
        end
        for i=1:length(m.conductivity)
            if length( m.conductivity(i).Dpar )==oldnumcells
                m.conductivity(i).Dpar = m.conductivity(i).Dpar( renumberCells );
            end
            if length( m.conductivity(i).Dper )==oldnumcells
                m.conductivity(i).Dper = m.conductivity(i).Dper( renumberCells );
            end
        end
    end
    m = safermfield( m, ...
        'unitcellnormals', ...
        'cellareas', ...
        'celledges', ...
        'edgeends', ...
        'edgecells', ...
        'celldata' ...
    );
    m.selection = emptySelection();
    m.cellFrames = [];
    m.cellFramesA = [];
    m.cellFramesB = [];
    m.growthanglepervertex = [];
    m.growthangleperFE = [];
    m.secondlayer = newemptysecondlayer();  % Should transfer old to new.
    if newfull3d
        % m = completeVolumetricMesh( m );
        m.FEconnectivity = connectivity3D( m );
    else
        m = setmeshgeomfromnodes( m );
    	m.effectiveGrowthTensor = zeros( size(m.tricellvxs,1), 6 );
    end
	m.directGrowthTensors = [];
    m = makeedgethreshsq( m );
    m = generateCellData( m );
    m = calculateOutputs( m );
  % [ok,m] = validmesh(m);
end
        
