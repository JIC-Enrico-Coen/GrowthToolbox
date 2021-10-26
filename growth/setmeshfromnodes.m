function [m,ok] = setmeshfromnodes( newmesh, oldmesh, layers, thickness )
%m = setmeshfromnodes( newmesh, oldmesh, layers, thickness )
%    Complete a mesh structure which only has nodes and tricellvxs defined.
%    If oldmesh is provided, it is assumed to be a complete mesh structure,
%    and as much information as possible is reused from it.

    setGlobals();
    global gLaminarMorphogenNames
    global gDEFAULTFIELDS
    global FE_P6 FE_T3
    
    ok = true;

    if (nargin >= 2) && ~isempty( oldmesh )
        oldmesh.plotdata = struct([]);
        m = replaceNodes( oldmesh, newmesh );
        m = calculateOutputs( m );
        return;
    end
    if nargin < 3
        layers = 0;
    end
    if nargin < 4
        thickness = 0;
    end
    full3d = layers > 0;
    
    numMorphogens = length(gLaminarMorphogenNames);
    m = newmesh;

    m = setmeshgeomfromnodes( m, layers, thickness );
    
    m = defaultFromStruct( m, gDEFAULTFIELDS );

    if ~isfield( m, 'versioninfo' )
        m.versioninfo = newversioninfo( [], 1, version() );
    end
    
    if ~isfield( m, 'mgenposcolors' )
        m.mgenposcolors = defaultMgenColors( 1:numMorphogens );
        m.mgennegcolors = oppositeColor( m.mgenposcolors' )';
    end
    
    global gGlobalProps;
    if isfield( m, 'globalProps' )
        m.globalProps = defaultFromStruct( m.globalProps, gGlobalProps );
    else
        m.globalProps = gGlobalProps;
    end
    global gGlobalInternalProps;
    if isfield( m, 'gGlobalInternalProps' )
        m.globalInternalProps = defaultFromStruct( m.globalProps, gGlobalInternalProps );
    else
        m.globalInternalProps = gGlobalInternalProps;
    end
    global gGlobalDynamicProps;
    if isfield( m, 'globalDynamicProps' )
        m.globalDynamicProps = defaultFromStruct( m.globalDynamicProps, gGlobalDynamicProps );
    else
        m.globalDynamicProps = gGlobalDynamicProps;
    end
    


    % m = setmeshgeomfromnodes( m, layers, thickness );
    if isempty( m.FEsets )
        m.FEsets(1).fe = FE_P6;
        m.FEsets(1).fevxs = [];
        m.FEsets(2).fe = FE_T3;
        m.FEsets(2).fevxs = [];
    end
    
    numnodes = getNumberOfVertexes( m );
    numFEs = getNumberOfFEs( m );
    if usesNewFEs(m)
        numdfnodes = numnodes;
    else
        numdfnodes = numnodes*2;
    end
    
    m = buildMorphogenDict( m );
    m = updateElasticity( m );
    m = clearInteractionMode( m );
    global gDefaultPlotOptions;
    if isfield( m, 'plotdefaults' )
        m.plotdefaults = defaultFromStruct( m.plotdefaults, gDefaultPlotOptions );
    else
        m.plotdefaults = gDefaultPlotOptions;
    end
    m = applyMgenDefaults( m, 1:numMorphogens );
    for i=1:numMorphogens
        m.mgen_interpType{i} = 'mid';
    end
    
    numpol = 1 + m.globalProps.twosidedpolarisation;
    m.mgen_plotpriority = zeros( 1, numMorphogens );
    m.fixedDFmap = false( numdfnodes, 3 );
    m.gradpolgrowth = zeros( numFEs, 3, numpol );
    m.polfreeze = zeros( numFEs, 3, numpol );
    m.polfreezebc = zeros( numFEs, 3, numpol );
    m.polfrozen = false( numFEs, numpol );
    m.polsetfrozen = false( 1, numpol );
    m.cellbulkmodulus = repmat( m.globalProps.bulkmodulus, [numFEs, 1] );
    m.cellpoisson = repmat( m.globalProps.poissonsRatio, [numFEs, 1] );
    m.cellstiffness = repmat( m.globalProps.D, [1,1,numFEs] );
    m.transportfield = cell( 1, numMorphogens );
    if isVolumetricMesh( m )
        m.gradpolgrowth2 = zeros( numFEs, 3 );
    end

    m = makeedgethreshsq( m );
    m.effectiveGrowthTensor = zeros( numFEs, 6 );
    m.directGrowthTensors = []; % zeros( numFEs, 6 );

    m = generateCellData( m );
    m = calculateOutputs( m );  % Not valid for volumetric meshes. Needs
                                % updated to handle those.
    
    m = recalc3d(m);
    if full3d
        bboxlo = min( m.FEnodes, [], 1 );
        bboxhi = max( m.FEnodes, [], 1 );
    else
        bboxlo = min( m.nodes, [], 1 );
        bboxhi = max( m.nodes, [], 1 );
    end
    delta = max(bboxhi - bboxlo)/2;
    bboxcentre = (bboxhi + bboxlo)/2;
    bbox = reshape( [ bboxcentre-delta; bboxcentre+delta ], 1, [] );
    
    matlabViewParams = autozoomcentre( m.plotdefaults.matlabViewParams, bbox, true, true );
    m.plotdefaults.matlabViewParams = matlabViewParams;
    m.plotdefaults.ourViewParams = ourViewParamsFromCameraParams( m.plotdefaults.matlabViewParams );
    m.globalProps.defaultViewParams = m.plotdefaults.matlabViewParams;
    
    if full3d
        m.FEconnectivity = connectivity3D( m );
    end
    [ok,m] = validmesh(m);
end
