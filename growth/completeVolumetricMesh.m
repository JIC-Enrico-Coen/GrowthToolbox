function m = completeVolumetricMesh( m )
%m = completeVolumetricMesh( m )
%   Given a mesh containing only FEnodes and FEsets, fill in the complete
%   structure.

    global gDEFAULTFIELDS
    global gGlobalProps gGlobalDynamicProps
    global gVolumetricRoleNameToMgenIndex
    
    setGlobals();

    m = calcFEvolumes( m, [], true );
    m.globalProps.initialVolume = m.globalDynamicProps.currentVolume;
    m.globalDynamicProps.previousVolume = m.globalDynamicProps.currentVolume;
    m.FEconnectivity = connectivity3D( m );
    m.versioninfo = newversioninfo( [], 2, version() );
    m = defaultFromStruct( m, gDEFAULTFIELDS );
    m.globalProps = gGlobalProps;
    m.globalDynamicProps = gGlobalDynamicProps;
    m.globalProps.hybridMesh = false;
    m = buildMorphogenDict( m );
    m.roleNameToMgenIndex = gVolumetricRoleNameToMgenIndex;
    
    numnodes = getNumberOfVertexes(m);
    numFEs = getNumberOfFEs(m);
    numVxsPerFE = getNumVxsPerFE(m);
    if ~isfield( m, 'fixedDFmap' )
        m.fixedDFmap = false( numnodes, 3 );
    end
    m = setlengthscale( m );
    m.displacements = [];
    m.effectiveGrowthTensor = zeros( numFEs, 6 );
    m.directGrowthTensors = [];
    m = updateElasticity( m );
    m = clearInteractionMode( m );
    global gDefaultPlotOptions;
    if isfield( m, 'plotdefaults' )
        m.plotdefaults = defaultFromStruct( m.plotdefaults, gDefaultPlotOptions );
    else
        m.plotdefaults = gDefaultPlotOptions;
    end
    m.plotdefaults.morphogen = FindMorphogenName( m, FindMorphogenRole(m,'KPAR') );
    numMorphogens = length( m.mgenIndexToName );
    m = applyMgenDefaults( m, 1:numMorphogens );
    for i=1:numMorphogens
        m.mgen_interpType{i} = 'mid';
    end
    m.gradpolgrowth = zeros( numFEs, 3 );
    m.gradpolgrowth2 = zeros( numFEs, 3 );
    m.unitcellnormals = repmat( [0 0 1], numFEs, 1 );  % A hack to get plotting gradient arrows to work.
    
    m.polfreeze = zeros( numFEs, numVxsPerFE );
    % m.polfreezebc = zeros( numFEs, 3 ); % Not meaningful for volumetric FEs.
    m.polfrozen = false( numFEs, 1 );
    m.polsetfrozen = false;
    if numel( m.globalProps.bulkmodulus, 3 )==1
        m.cellbulkmodulus = repmat( m.globalProps.bulkmodulus, [numFEs, 1] );
    else
        m.cellbulkmodulus = m.globalProps.bulkmodulus;
    end
    if numel( m.globalProps.bulkmodulus, 3 )==1
        m.cellpoisson = repmat( m.globalProps.poissonsRatio, [numFEs, 1] );
    else
        m.cellpoisson = m.globalProps.poissonsRatio;
    end
    if size( m.globalProps.D, 3 )==1
        m.cellstiffness = repmat( m.globalProps.D, [1,1,numFEs] );
    else
        m.cellstiffness = m.globalProps.D;
    end
    m.transportfield = cell( 1, numMorphogens );
    m = makeedgethreshsq( m );
    m = generateCellData( m );
    m = calculateOutputs( m );
    m = calcFEvolumes( m );
    m.globalProps.initialVolume = m.globalDynamicProps.currentVolume;
    m.globalDynamicProps.cellscale = mean(m.FEsets(1).fevolumes)^(1/3);  %sqrt( m.globalDynamicProps.currentArea / length(m.cellareas) );
    m.sharpedges = zeros(0,1);
    m.sharpvxs = zeros(0,1);
end
