function m = replaceNodes( m, newm, add )
%m = replaceNodes( m, newm )
%   Replace the vertexes and finite elements of M by those of NEWM.
%   Works for both foliate and volumetric meshes.
%
%   If ADD is true (the default is false), m is nonempty, and the finite
%   elements of m are of the same type as those of newm, the existing
%   elements of m will be retained and those of newm appended.

    global FE_P6 FE_T3
    
    if isempty(newm) || getNumberOfFEs( newm )==0
        return;
    end
    
    if (nargin < 3) || isempty(m) || getNumberOfFEs( m )==0
        add = false;
    end
    
    oldfull3d = usesNewFEs( m );
    newfull3d = usesNewFEs( newm );

    if ~isempty(m) && (oldfull3d ~= newfull3d)
        add = false;
    end

    if ~isempty(m) && oldfull3d && newfull3d
        if length(m.FEsets) ~= length(newm.FEsets)
            add = false;
        else
            for i=1:length(m.FEsets)
                if ~strcmp( m.FEsets.fe.name, newm.FEsets.fe.name )
                    add = false;
                    break;
                end
            end
        end
    end

    oldnumelements = getNumberOfFEs(m);
    newnumelements = getNumberOfFEs(newm);
    oldnumnodes = getNumberOfVertexes(m);
    newnumnodes = getNumberOfVertexes( newm );
    if add || (oldnumnodes == newnumnodes)
        renumber = [];
        prenumber = [];
        newtotalelements = oldnumelements + newnumelements;
        newtotalnodes = oldnumnodes + newnumnodes;
    else
        oldcentroids = elementCentres( m, [], 0 );
        newcentroids = elementCentres( newm, [], 0 );
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
    end
    if newfull3d
        if ~oldfull3d
            m = rmfield( m, { 'nodes', 'tricellvxs' } );
        end
        if add
            m.FEnodes = [m.FEnodes; newm.FEnodes];
            for i=1:length(m.FEsets)
                m.FEsets(i).fevxs = [ m.FEsets(i).fevxs; newm.FEsets(i).fevxs + oldnumnodes ];
            end
        else
            m.FEnodes = newm.FEnodes;
            m.FEsets = newm.FEsets;
        end
        m = calcFEvolumes( m );
        % connectivity?
    else
        if oldfull3d
            m.FEnodes = [];
            m.FEsets(1) = struct( 'fe', FE_P6, 'fevxs', [] );
            m.FEsets(2) = struct( 'fe', FE_T3, 'fevxs', [] );
%             m = rmfield( m, { 'FEnodes', 'FEsets' } );
        end
        if add
            m.nodes = [ m.nodes; newm.nodes ];
            m.tricellvxs = [ m.tricellvxs; newm.tricellvxs + oldnumnodes ];
        else
            m.nodes = newm.nodes;
            m.tricellvxs = newm.tricellvxs;
        end
        m.globalProps.trinodesvalid = true;
    end
    m.decorFEs = [];
    m.decorBCs = [];
    if isfield( newm, 'prismnodes' )
        if add
            m.prismnodes = [ m.prismnodes; newm.prismnodes ];
        else
            m.prismnodes = newm.prismnodes;
        end
        m.globalProps.prismnodesvalid = true;
    else
        m.prismnodes = [];
        m.globalProps.prismnodesvalid = false;
    end
    if add
        m.morphogens = [ m.morphogens; zeros( newnumnodes, size(m.morphogens,2) ) ];
        m.morphogenclamp = [ m.morphogenclamp; zeros( newnumnodes, size(m.morphogenclamp,2) ) ];
        m.mgen_production = [ m.mgen_production; zeros( newnumnodes, size(m.mgen_production,2) ) ];
        m.mgen_absorption = [ m.mgen_absorption; zeros( newnumnodes, size(m.mgen_absorption,2) ) ];
        if oldfull3d
            m.fixedDFmap = [ m.fixedDFmap; false( newnumnodes, size(m.fixedDFmap,2) ) ];
        else
            m.fixedDFmap = [ m.fixedDFmap; false( newnumnodes*2, size(m.fixedDFmap,2) ) ];
        end
        m.cellbulkmodulus = [ m.cellbulkmodulus; zeros( newnumelements, size(m.cellbulkmodulus,2) ) ];
        m.cellpoisson = [ m.cellpoisson; zeros( newnumelements, size(m.cellpoisson,2) ) ];
        m.cellstiffness( :, :, (oldnumelements+1):newtotalelements ) = repmat( mean( m.cellstiffness, 3 ), 1, 1, newnumelements );
        m.gradpolgrowth( (oldnumelements+1):newtotalelements, :, : ) = 0;
        if ~isempty(m.displacements)
            m.displacements( (oldnumnodes+1):newtotalnodes, : ) = 0;
        end
        if isfield( m, 'gradpolgrowth2' ) && ~isempty( m.gradpolgrowth2 )
            m.gradpolgrowth2( (oldnumelements+1):newtotalelements, :, : ) = 0;
        end
        m.polfreeze = [ m.polfreeze; zeros( newnumelements, size(m.polfreeze,2) ) ];
        m.polfrozen = [ m.polfrozen; zeros( newnumelements, size(m.polfrozen,2) ) ];
        if size(m.polsetfrozen,1) > 1
            m.polsetfrozen = [ m.polsetfrozen; zeros( newnumelements, size(m.polsetfrozen,2) ) ];
        end
        if ~newfull3d && ~oldfull3d
            m.polfreezebc = [ m.polfreezebc; zeros( newnumelements, size(m.polfreezebc,2) ) ];
        end
        for i=1:length(m.conductivity)
            if length( m.conductivity(i).Dpar )==oldnumelements
                meanConductivity = mean( m.conductivity(i).Dpar, 1 );
                m.conductivity(i).Dpar = [ m.conductivity(i).Dpar; meanConductivity + zeros( newnumelements, size( m.conductivity(i).Dpar, 2 ) ) ];
            end
            if length( m.conductivity(i).Dper )==oldnumelements
                meanConductivity = mean( m.conductivity(i).Dper, 1 );
                m.conductivity(i).Dper = [ m.conductivity(i).Dper; meanConductivity + zeros( newnumelements, size( m.conductivity(i).Dper, 2 ) ) ];
            end
        end
        if isfield( m, 'sharpvxs' )
            if isfield( newm, 'sharpvxs' )
                m.sharpvxs = [ m.sharpvxs; newm.sharpvxs ];
            else
                m.sharpvxs = [ m.sharpvxs; false( newnumnodes, 1 ) ];
            end
        end
    elseif ~isempty( renumber )
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
            if length( m.conductivity(i).Dpar )==oldnumelements
                m.conductivity(i).Dpar = m.conductivity(i).Dpar( renumberCells );
            end
            if length( m.conductivity(i).Dper )==oldnumelements
                m.conductivity(i).Dper = m.conductivity(i).Dper( renumberCells );
            end
        end
        if isfield( m, 'sharpvxs' )
            if isfield( newm, 'sharpvxs' )
                m.sharpvxs = newm.sharpvxs;
            else
                m.sharpvxs = false( newnumnodes, 1 );
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
    end
    m.effectiveGrowthTensor = zeros( getNumberOfFEs(m), 6 );
	m.directGrowthTensors = [];
    m = makeedgethreshsq( m );
    m = generateCellData( m );
    m = calculateOutputs( m );
  % [ok,m] = validmesh(m);
end
        
