function m = leaf_makemultilayer( m, numlayers )
%m = leaf_makemultilayer( m, numlayers )
%   Convert an old-style mesh to a multi-layer mesh.
%   m.FEnodes holds the new vertexes, and m.prismnodes and m.nodes are
%   deleted.
    if ~isempty( m.FEnodes )
        % m is already multilayer.
        return;
    end
    
    global FE_P6;
    
    % Multilayer meshes are incompatible with two-sided polarisation.
    m = leaf_setproperty( m, 'twosidedpolarisation', false );
    
    % Create the vertexes m.FEnodes, and delete m.nodes and m.prismnodes.
    dp = m.prismnodes(2:2:end,:) - m.prismnodes(1:2:end,:);
    m.FEnodes = repmat( m.nodes, numlayers+1, 1 );
    numcolumns = size(m.nodes,1);
    offsets = linspace( -0.5, 0.5, numlayers+1 );
    for i=0:numlayers
        m.FEnodes( (numcolumns*i+1):(numcolumns*(i+1)), : ) = ...
            m.nodes + dp*offsets(i+1);
    end
    
    % Make FEsets.fevxs from m.tricellvxs, then delete m.tricellvxs.
    numoldFEs = size(m.tricellvxs,1);
    m.FEsets = struct( 'fe', FE_P6, 'fevxs', zeros( numoldFEs*numlayers, 6 ) );
    for i=1:numlayers
        lowerbaseV = numcolumns*(i-1);
        upperbaseV = numcolumns*i;
        lowerbaseFE = numoldFEs*(i-1);
        upperbaseFE = numoldFEs*i;
        m.FEsets(1).fevxs( (lowerbaseFE+1):upperbaseFE, : ) = ...
            [ m.tricellvxs + lowerbaseV, m.tricellvxs + upperbaseV ];
    end
    
    m.cellFrames = repmat( m.cellFrames, [1,1,numlayers] );
    % What about cellFramesA and cellFramesB?
    if length(m.cellbulkmodulus) > 1
        m.cellbulkmodulus = repmat( m.cellbulkmodulus, numlayers, 1 );
    end
    if length(m.cellpoisson) > 1
        m.cellpoisson = repmat( m.cellpoisson, numlayers, 1 );
    end
    if size(m.cellstiffness,3) > 1
        m.cellstiffness = repmat( m.cellstiffness, [1,1,numlayers] );
    end
    
    m.morphogens = repmat( m.morphogens, numlayers+1, 1 );
    m.morphogenclamp = repmat( m.morphogenclamp, numlayers+1, 1 );
    m.mgen_production = repmat( m.mgen_production, numlayers+1, 1 );
    m.mgen_absorption = repmat( m.mgen_absorption, numlayers+1, 1 );
    fdfmap = m.fixedDFmap(1:2:end,:) | m.fixedDFmap(2:2:end,:);
    m.fixedDFmap = repmat( fdfmap, numlayers+1, 1 );
    m.gradpolgrowth = repmat( m.gradpolgrowth, numlayers, 1 );
    m.polfreeze = repmat( m.polfreeze, numlayers, 1 );
    m.polfreezebc = repmat( m.polfreezebc, numlayers, 1 );
    m.polfrozen = repmat( m.polfrozen, numlayers, 1 );
    if length(m.polsetfrozen) > 1
        m.polsetfrozen = repmat( m.polsetfrozen, numlayers, 1 );
    end
    m.effectiveGrowthTensor = repmat( m.effectiveGrowthTensor, numlayers, 1 );
    m.celldata = repmat( m.celldata, 1, numlayers );

    % Problematic fields:
%                  edgeends: [156x2 int32]
%                 celledges: [96x3 int32]
%                 edgecells: [156x2 int32]
%                     seams: [156x1 logical]
%             nodecelledges: {61x1 cell}
%                 cellareas: [96x1 double]
%           unitcellnormals: [96x3 double]
%          currentbendangle: [156x1 single]
%          initialbendangle: [156x1 single]
    m = rmfield( m, { 'nodes', ...
                    'prismnodes', ...
                    'tricellvxs', ...
                    'edgeends', ...
                    'celledges', ...
                    'edgecells', ...
                    'seams', ...
                    'nodecelledges', ...
                    'cellareas', ...
                    'unitcellnormals', ...
                    'currentbendangle', ...
                    'initialbendangle' } );
end
