function m = upgrademesh( m, checkValidity )
%m = upgrademesh( m )
%   Ensure the mesh M is compatible with the current version of the software.

    if nargin < 2
        checkValidity = true;
    end
    if ~isfield( m, 'versioninfo' )
        m = upgradeVeryOldMesh( m );
        % m now has version number 0.
    end
    
    setGlobals();
    global gLaminarRoleNameToMgenIndex
    global gOBSOLETEFIELDS gOBSOLETESTATICPROPS gDEFAULTFIELDS gPerMgenDefaults
    global gGlobalProps gGlobalInternalProps gGlobalDynamicProps gDefaultVVPlotOptions gPlotHandles
    global gSecondLayerColorInfo gStereoParams
    global gCellFactorRoles
    global FE_P6 FE_T3
    % global gOurViewParams gDefaultPlotOptions;
    
    full3d = usesNewFEs( m );
    
    if ~full3d
        if ~isfield( m, 'FEnodes' )
            m.FEnodes = [];
        end
        if ~isfield( m, 'FESets' )
            m.FEsets = [ struct( 'fe', FE_P6, 'fevxs', [] ), ...
                         struct( 'fe', FE_T3, 'fevxs', [] ) ];
        end
    end
    
    if isfield( m.versioninfo, 'generalversion' )
        m.versioninfo = struct( 'meshversion', 0, ...
            'mgenversion', m.versioninfo.generalversion, 'matlabversion', version() );
    elseif ~isfield( m.versioninfo, 'mgenversion' )
        m.versioninfo.mgenversion = 1;
    end
    if ~isfield( m.versioninfo, 'matlabversion' )
        m.versioninfo.matlabversion = version();
    end
    m = convertKBENDtoAB( m );
    if ~isfield( m, 'roleNameToMgenIndex' )
        m.roleNameToMgenIndex = gLaminarRoleNameToMgenIndex;
    end
    pol_mgen = FindMorphogenRole( m, 'POLARISER' );
    
    numMorphogens = size(m.morphogens,2);

        
    % 2008 Jan 11  Default model name is now the empty string instead of 'untitled'.
    if strcmp( m.globalProps.modelname, 'untitled' )
        m.globalProps.modelname = '';
    end
    
    m.globalProps = replacefields( m.globalProps, ...
        'bioAsplitproc', 'bioApresplitproc', ...
        'bioAsplatproc', 'bioApostsplitproc' );
    if isfield( m.globalProps, 'stitchDFs' )
        m.globalDynamicProps.stitchDFs = m.globalProps.stitchDFs;
        m.globalProps = rmfield( m.globalProps, 'stitchDFs' );
    end

    if isfield( m.globalProps, 'freezing' )
        m.globalDynamicProps.freezing = m.globalProps.freezing;
        m.globalProps = rmfield( m.globalProps, 'freezing' );
    end
    
    if ~isfield( m, 'auxdata' )
        m.auxdata = struct();
    end
    
    % Sometimes a new feature is introduced for which there is no method of
    % automatically distinguishing meshes that support them from meshes
    % that do not, nor of automatically upgrading one that does not.  To
    % maintain backwards compatibility, for each such feature a boolean
    % flag is added.  The flag is true for meshes created since the feature
    % was added, but it defaults to false for meshes without the flag.
    if ~isfield( m.globalProps, 'newcallbacks' )
        m.globalProps.newcallbacks = false;
    end
    if ~isfield( m.globalProps, 'newoptionmethod' )
        m.globalProps.newoptionmethod = false;
    end
    
    if full3d
        if ~isfield( m.globalDynamicProps, 'currentVolume' ) || (m.globalDynamicProps.currentVolume==0) || any( m.FEsets(1).fevolumes <= 0 )
            m = calcFEvolumes( m, [], true );
        end
        if Steps(m)==0
            m.globalProps.initialVolume = m.globalDynamicProps.currentVolume;
            m.globalDynamicProps.previousVolume = m.globalDynamicProps.currentVolume;
        end
        if false && ~isfield( m.FEconnectivity, 'facefeparity' )
            m.FEconnectivity = connectivity3D( m );
        end
    end
    
    if isfield( m, 'FEtypes' )
        m = rmfield( m, 'FEtypes' );
    end
    
    if isfield( m, 'canvascolor' )
        m.plotdefaults.canvascolor = m.canvascolor;
        m = rmfield( m, 'canvascolor' );
    end
    
    m.plotdefaults = upgradePlotoptions( m.plotdefaults );

    if isfield( m.globalProps, 'defaultViewParams' ) && ~isempty( m.globalProps.defaultViewParams )
        m.globalProps.defaultViewParams = replacefields( ...
            m.globalProps.defaultViewParams, 'CameraUp', 'CameraUpVector' );
    else
        m.globalProps.defaultViewParams = m.plotdefaults.matlabViewParams;
    end

    if (~isfield( m, 'mgen_transportable' )) || (length(m.mgen_transportable) ~= numMorphogens)
        m.mgen_transportable = false( 1, numMorphogens );
    end
    
    if ~isfield( m, 'transportfield' )
        m.transportfield = cell( 1, numMorphogens );
    end

    if ~isfield( m, 'cellFrames' )
        if isfield( m, 'celldata') && isfield( m.celldata, 'cellFrame')
            m.cellFrames = reshape( [m.celldata.cellFrame], 3, 3, [] );
            m.celldata = rmfield( m.celldata, 'cellFrame' );
        else
            m.cellFrames = [];
        end
    end
    
    if ~isfield( m, 'selection' )
        m.selection = emptySelection();
    else
        if isfield( m.selection, 'highlightedCells' )
            if isempty( m.selection.highlightedCells )
                m.selection.highlightedCellList = [];
            elseif islogical(m.selection.highlightedCells)
                m.selection.highlightedCellList = find( m.selection.highlightedCells );
            else
                m.selection.highlightedCellList = m.selection.highlightedCells;
            end
            m.selection = rmfield( m.selection, 'highlightedCells' );
        end
        if isfield( m.selection, 'highlightedEdges' )
            if isempty( m.selection.highlightedEdges )
                m.selection.highlightedEdgeList = [];
            elseif islogical(m.selection.highlightedEdges)
                m.selection.highlightedEdgeList = find( m.selection.highlightedEdges );
            else
                m.selection.highlightedEdgeList = m.selection.highlightedEdges;
            end
            m.selection = rmfield( m.selection, 'highlightedEdges' );
        end
        if isfield( m.selection, 'highlightedVxs' )
            if isempty( m.selection.highlightedVxs )
                m.selection.highlightedVxList = [];
            elseif islogical(m.selection.highlightedVxs)
                m.selection.highlightedVxList = find( m.selection.highlightedVxs );
            else
                m.selection.highlightedVxList = m.selection.highlightedVxs;
            end
            m.selection = rmfield( m.selection, 'highlightedVxs' );
        end
    end
    
    if isfield( m, 'streamlines' ) && ~isempty( m.streamlines )
        if isfield( m.streamlines, 'vertexpos' )
            m.streamlines = rmfield( m.streamlines, 'vertexpos' );
        end
    end
    if ~isfield( m, 'tubules' )
        m.tubules = initTubules();
        if isfield( m, 'streamlines' )
            m.tubules.tracks = m.streamlines;
        end
        if isfield( m, 'defaultstreamline' )
            m.tubules.defaulttrack = m.defaultstreamline;
        end
    else
        m = upgradeTubules( m );
    end
    m = safermfield( m, 'streamlines', 'defaultstreamline' );
        
    ocfns = fieldnames( m.outputcolors );
    for i=1:length(ocfns)
        if ~isempty( regexp( ocfns{i}, '^actual' , 'once' ) )
            newocfn = regexprep( ocfns{i}, '^actual', 'resultant' );
            m.outputcolors.(newocfn) = m.outputcolors.(ocfns{i});
            m.outputcolors = rmfield( m.outputcolors, ocfns{i} );
        end
    end
    m.outputcolors = defaultFromStruct( m.outputcolors, gDEFAULTFIELDS.outputcolors );
    
    if ~isfield( m, 'conductivity' )
        m.conductivity = struct([]);
        haveAbsKvector = isfield( m, 'absKvector' );
        if haveAbsKvector
            for i=1:numMorphogens
                m.conductivity(i).Dpar = m.absKvector(1,i);
                if m.absKvector(1,i) == m.absKvector(1,i)
                    m.conductivity(i).Dper = [];
                else
                    m.conductivity(i).Dper = m.absKvector(2,i);
                end
            end
        else
            m.conductivity = repmat( gPerMgenDefaults.conductivity, 1, numMorphogens );
        end
    end
    if length(m.conductivity) < numMorphogens
        m.conductivity( (end+1):numMorphogens ) = ...
            gPerMgenDefaults.conductivity;
    elseif length(m.conductivity) > numMorphogens
        m.conductivity( (numMorphogens+1):end ) = [];
    end
    
    if ~isfield( m, 'plothandles' )
        m.plothandles = gPlotHandles;
    else
        m.plothandles = defaultFromStruct( m.plothandles, gPlotHandles );
        handlefields = fieldnames( m.plothandles );
        for i=1:length(handlefields)
            hf = handlefields{i};
            hh = m.plothandles.(hf);
            m.plothandles.(hf) = hh(ishandle(hh));
        end
    end
        
    if size( m.fixedDFmap, 2 )==6
        m.fixedDFmap = reshape( m.fixedDFmap', 3, [] )';
    end
    
    if isfield( m.globalProps, 'physicalThickness' )
        if m.globalProps.physicalThickness
            m.globalProps.thicknessMode = 'physical';
        else
            m.globalProps.thicknessMode = 'scaled';
        end
        m.globalProps = rmfield( m.globalProps, 'physicalThickness' );
    end
    
    if strcmp( m.globalProps.thicknessMode, 'anticurl' )
        m.globalProps.thicknessMode = 'direct';
    end
    
    if isfield( m.globalProps, 'legend' )
        m.globalProps.legendTemplate = gGlobalProps.legendTemplate;
        if ~isempty( m.globalProps.legend )
            m.globalProps.legendTemplate = [ m.globalProps.legendTemplate ...
                                             ' ' ...
                                             m.globalProps.legend ];
        end
        m.globalProps = rmfield( m.globalProps, 'legend' );
    end
    
    if isfield( m, 'invisible' )
        if ~isfield( m, 'visible' )
            m = findVisiblePart( m );
        end
        m = rmfield( m, 'invisible' );
    end

    % Remove obsolete fields.
    m = safermfield( m, gOBSOLETEFIELDS );
    m.globalProps = safermfield( m.globalProps, gOBSOLETESTATICPROPS );
    
    m = defaultFromStruct( m, gDEFAULTFIELDS );
    
    if iscell( m.stagetimes )
        m.stagetimes = [];
    end
    m.stagetimes = unique( myround( m.stagetimes, 6 ) );
    % 6 = same value as in addStages. Should perhaps be a property of the mesh.
    
    m.meshparams = defaultFromStruct( m.meshparams, ...
                                      struct( ...
                                        'type', 'unknown', ...
                                        'randomness', 0 ) );
    
    if isfield( m, 'mgencolors' )
        m.mgenposcolors = m.mgencolors;
        m = rmfield( m, 'mgencolors' );
    end
    if ~isfield( m, 'mgenposcolors' )
        m.mgenposcolors = HSVtoRGB( [ (0:1:(numMorphogens-1))'/12, ones( numMorphogens, 2 ) ] )';
    end
    if ~isfield( m, 'mgennegcolors' )
        m.mgennegcolors = oppositeColor( m.mgenposcolors' )';
    end
    
    if ~isfield( m, 'mgen_plotpriority' )
        m.mgen_plotpriority = zeros( 1, numMorphogens );
    end

    if ~isfield( m, 'mgen_plotthreshold' )
        m.mgen_plotthreshold = zeros( 1, numMorphogens );
    end

    if ~isfield( m, 'stereoparams' )
        m.stereoparams = gStereoParams;
    end
    
    if ~full3d
        if ~isfield( m, 'edgecellindex' ) || isempty( m.edgecellindex )
            m.edgecellindex = edgecellindex( m );
        end
    
        if ~isfield( m, 'edgesense' ) || isempty( m.edgesense )
            m.edgesense = edgesense( m );
        end

        if ~isfield( m, 'vertexnormals' ) || isempty( m.vertexnormals )
            m = setMeshVertexNormals( m );
        end
    end
    
    
    
    
    

    if ~hasSecondLayer( m )
        m.secondlayer = newemptysecondlayer();
    end
    if ~isfield( m, 'secondlayerstatic' )
        m.secondlayerstatic = newemptysecondlayerstatic();
    end
    numsecondlayercells = length( m.secondlayer.cells );
    m.secondlayer.cellarea = reshape( m.secondlayer.cellarea, numel(m.secondlayer.cellarea), 1 );
    m.secondlayer.celltargetarea = reshape( m.secondlayer.celltargetarea, numel(m.secondlayer.celltargetarea), 1 );
    m.secondlayer.areamultiple = reshape( m.secondlayer.areamultiple, numel(m.secondlayer.areamultiple), 1 );
    if ~isfield( m.secondlayer, 'cellid' )
        m = initialiseCellIDData( m );
    end
    if ~isfield( m.secondlayer, 'cellvalues' ) || isempty( m.secondlayer.cellvalues )
        m.secondlayer.cellvalues = zeros( numsecondlayercells, 0 );
    end

    if ~isfield( m.secondlayer, 'cellpolarity' )
        m.secondlayer.cellpolarity = zeros( numsecondlayercells, 3 );
    end

    if ~isfield( m.secondlayer, 'newedgeindex' )
        m.secondlayer.newedgeindex = 1;
    end

    if ~isfield( m.secondlayer, 'visible' )
        m.secondlayer.visible = struct( ...
            'cells', true( length(m.secondlayer.cells), 1 ) );
    end

    if isfield( m.secondlayer, 'wallthickness' )
        m.secondlayer = rmfield( m.secondlayer, 'wallthickness' );
    end
    if ~isfield( m.secondlayer, 'cellvalue_plotpriority' )
        m.secondlayer.cellvalue_plotpriority = zeros(1,size(m.secondlayer.cellvalues,2));
        m.secondlayer.cellvalue_plotthreshold = zeros(1,size(m.secondlayer.cellvalues,2));
    end
    if isnumeric( m.plotdefaults.cellbodyvalue )
        % m.plotdefaults.cellbodyvalue should contain only cell factor
        % names.
        m.plotdefaults.cellbodyvalue = FindCellFactorName( m, m.plotdefaults.cellbodyvalue );
    elseif ischar( m.plotdefaults.cellbodyvalue )
        % m.plotdefaults.cellbodyvalue should always be a cell array of
        % strings.
        m.plotdefaults.cellbodyvalue = { m.plotdefaults.cellbodyvalue };
    end
    
    if isfield( m.secondlayer, 'roleNameToCellValueIndex' )
        m.secondlayer = rmfield( m.secondlayer, 'roleNameToCellValueIndex' ); % Obsolete field.
    end
    
    if ~isfield( m.secondlayer, 'cellfactorroles' )
        m.secondlayer.cellfactorroles = MakeNameIndex( gCellFactorRoles, zeros(1,length(gCellFactorRoles)) );
    else
        % Force m.secondlayer.cellfactorroles to have the same roles as
        % gCellFactorRoles.
        oldroles = m.secondlayer.cellfactorroles.index2NameMap;
        obsoleteroles = setdiff( oldroles, gCellFactorRoles );
        newroles = setdiff( gCellFactorRoles, oldroles );
        m.secondlayer.cellfactorroles = deleteNamesFromIndex( m.secondlayer.cellfactorroles, obsoleteroles );
        m.secondlayer.cellfactorroles = addNames2Index( m.secondlayer.cellfactorroles, newroles, zeros(1,length(newroles)) );
    end
    
    if ~isfield( m.secondlayer, 'customcellcolorinfo' )
        m.secondlayer.customcellcolorinfo = gSecondLayerColorInfo;
    else
        m.secondlayer.customcellcolorinfo = defaultStructArrayFromStruct( m.secondlayer.customcellcolorinfo, gSecondLayerColorInfo );
    end
    if isfield( m.secondlayer, 'cellcolorinfo' )
        m.secondlayer.cellcolorinfo = renameStructFields( m.secondlayer.cellcolorinfo, 'startfromzero', 'issplit' );
        oldfns = fieldnames( m.secondlayer.cellcolorinfo );
        newfns = fieldnames( gSecondLayerColorInfo );
        deletedfns = setdiff( oldfns, newfns );
        addedfns = setdiff( newfns, oldfns );
        m.secondlayer.cellcolorinfo = rmfield( m.secondlayer.cellcolorinfo, deletedfns );
        m.secondlayer.cellcolorinfo = defaultStructArrayFromStruct( m.secondlayer.cellcolorinfo, gSecondLayerColorInfo, addedfns );
    else
        m.secondlayer.cellcolorinfo = gSecondLayerColorInfo;
        m.secondlayer.cellcolorinfo(1) = [];
    end
    if ~isempty(m.secondlayer.cellcolorinfo) && ~isfield( m.secondlayer.cellcolorinfo, 'range' )
        m.secondlayer.cellcolorinfo(1).range = [];
        m.secondlayer.cellcolorinfo(1).startfromzero = false;
    end
    
    if isfield( m.secondlayer, 'cellvalueposcolors' )
        n = size(m.secondlayer.cellvalueposcolors,2);
        m.secondlayer.cellcolorinfo = emptystructarray( n, fieldnames(gSecondLayerColorInfo) );
        for i=1:n
            m.secondlayer.cellcolorinfo(i) = calcColorInfoMap( [], 'monochrome', ...
                'pos', m.secondlayer.cellvalueposcolors(:,i)', ...
                'neg', m.secondlayer.cellvaluenegcolors(:,i)' );
        end
        m.secondlayer = rmfield( m.secondlayer, {'cellvalueposcolors', 'cellvaluenegcolors'} );
    end
    
    if ~isa( m.secondlayer.cellcolor, 'double' )
        m.secondlayer.cellcolor = double(m.secondlayer.cellcolor);
    end
    
    if isfield( m.secondlayer, 'cells' ) && (~isfield( m.secondlayer, 'side' ))
        m.secondlayer.side = true( numsecondlayercells, 1 );
        m.secondlayer.generation = int32( m.secondlayer.generation );
    end

    if ~isfield( m.secondlayer, 'edgepropertyindex' )
        m.secondlayer.edgepropertyindex = ones( size( m.secondlayer.edges, 1 ), 1 );
    end
    m.secondlayer.indexededgeproperties(1) = struct( 'LineWidth', m.plotdefaults.bioAlinesize, ...
                                                     'Color', m.plotdefaults.bioAlinecolor );

    if ~isfield( m.secondlayer, 'interiorborder' )
        m.secondlayer.interiorborder = false( size( m.secondlayer.edges, 1 ), 1 );
    end

    m.secondlayer = newemptybiodata( m.secondlayer );

    if ~isfield( m.secondlayer, 'valuedict' )
        m.secondlayer.valuedict = MakeNameIndex();
    end

    if ~isfield( m.secondlayer, 'colorscale' )
        m.secondlayer.colorscale = [];
    end

    % Construct secondlayer.vxedges, first implemented 2022-01-25.
    % Not done yet.
    if false && (~isfield( m.secondlayer, 'vxedges' ) || isempty( m.secondlayer.vxedges ))
        % Construct secondlayer.vxedges
        ve = sort( [ m.secondlayer.edges(:,[1 2]), repmat( (1:getNumberOfCellEdges(m))', 2, i ) ], 'rows' );
        vxedges = zeros( getNumberOfCellVertexes(m), 3, 'int32' );
        for i=1:size(ve,1)
            % ...
        end
    end

    if all(m.displacements==0)
        m.displacements = [];
    end
    
    gdpfn = fieldnames( gGlobalDynamicProps );
    if ~isfield( m, 'globalDynamicProps' )
        gdp = gGlobalDynamicProps;
        for i=1:length(gdpfn)
            fn = gdpfn{i};
            if isfield( m.globalProps, fn )
                gdp.(fn) = m.globalProps.(fn);
            end
        end
        m.globalProps = safermfield( m.globalProps, gdpfn );
        m.globalDynamicProps = gdp;
    else
        for i=1:length(gdpfn)
            if isfield( m.globalProps, gdpfn{i} )
                m.globalDynamicProps.(gdpfn{i}) = m.globalProps.(gdpfn{i});
                m.globalProps = rmfield( m.globalProps, gdpfn{i} );
            end
        end
    end
    if ~isfield( m.globalDynamicProps, 'staticreadonly' )
        m.globalDynamicProps.staticreadonly = false;
    end

    m.globalProps.flatten = false;  % Obsolete, to be deleted in a future version.
    m.globalProps.flattenratio = 1; % Obsolete, to be deleted in a future version.
    if ~isfield( m.globalProps, 'relativepolgrad' )
         m.globalProps.relativepolgrad = gGlobalProps.relativepolgrad;
    end
    if ~isfield( m.globalProps, 'mingradient' )
         m.globalProps.mingradient = gGlobalProps.mingradient;
    end
    if ~isfield( m.globalProps, 'userpolarisation' )
         m.globalProps.userpolarisation = gGlobalProps.userpolarisation;
    end
    if ~isfield( m.globalProps, 'usepolfreezebc' )
         m.globalProps.usepolfreezebc = gGlobalProps.usepolfreezebc;
    elseif ischar( m.globalProps.usepolfreezebc )
        m.globalProps.usepolfreezebc = gGlobalProps.usepolfreezebc;
    end
    if ~isfield( m.globalProps, 'usefrozengradient' )
         m.globalProps.usefrozengradient = gGlobalProps.usefrozengradient;
    end
    
    m = inflatemesh( m );
    
    % Use integers, where integers are what is wanted.
    % The field-testing here is because we want to be able to handle stripped
    % meshes as well.
    
    if isfield( m, 'tricellvxs' )
        m.tricellvxs = forcetype( m.tricellvxs, 'int32' );
    end
    if isfield( m, 'edgecells' )
        m.edgecells = forcetype( m.edgecells, 'int32' );
    end
    if isfield( m, 'celledges' )
        m.celledges = forcetype( m.celledges, 'int32' );
    end
    if isfield( m.secondlayer, 'edges' )
        m.secondlayer.edges = forcetype( m.secondlayer.edges, 'int32' );
    end
    m.secondlayer.cloneindex = forcetype( m.secondlayer.cloneindex(:), 'int32' );
    if isfield( m.secondlayer.cells, 'edges' )
        for i=1:numsecondlayercells
            m.secondlayer.cells(i).edges = forcetype( m.secondlayer.cells(i).edges, 'int32' );
        end
    end
    if isfield( m, 'nodecelledges' )
        for i=1:length(m.nodecelledges)
            m.nodecelledges{i} = int32( m.nodecelledges{i} );
        end
%         if isfield( m, 'nodecelledges' )
%             [m.nodeFEs,m.nodeedges] = convertNodeCellEdges( m.nodecelledges );
%         end
    end
    fns = fieldnames( m.mgenNameToIndex );
    for i=1:length(fns)
        m.mgenNameToIndex.(fns{i}) = int32( m.mgenNameToIndex.(fns{i}) );
    end
    
    
    if ~isfield( m.globalProps, 'starttime' )
        m.globalProps.starttime = ...
            m.globalDynamicProps.currenttime ...
            - m.globalProps.timestep * m.globalDynamicProps.currentIter;
    end
    if ~isfield( m.globalProps, 'validitytime' )
        m.globalProps.validitytime = m.globalProps.starttime;
    end
    if ~isfield( m.globalProps, 'unitbulkmodulus' )
        if m.globalProps.bulkmodulus ~= 1
            m = leaf_setproperty( m, 'bulkmodulus', 1 );
        end
    end
    m.globalProps = defaultFromStruct( m.globalProps, gGlobalProps );
    m.globalProps = safermfield( m.globalProps, 'MESHVERSION' );
    m.globalProps.IFsetsoptions = true;
    if isnumeric(m.globalProps.defaultinterp)
        switch m.globalProps.defaultinterp
            case 1
                m.globalProps.defaultinterp = 'mid';
            case 2
                m.globalProps.defaultinterp = 'min';
            case 3
                m.globalProps.defaultinterp = 'max';
            otherwise
        end
    end
    m.globalProps.coderevision = int32(m.globalProps.coderevision);
    m.globalProps.maxFEcells = int32(m.globalProps.maxFEcells);
    m.globalProps.inittotalcells = int32(m.globalProps.inittotalcells);
    m.globalProps.maxBioAcells = int32(m.globalProps.maxBioAcells);
    m.globalProps.canceldrift = logical(m.globalProps.canceldrift);
    m.globalProps.allowInteraction = logical(m.globalProps.allowInteraction);
    if ~isfield( m, 'mgen_interpType' )
        numStdMgens = length(m.roleNameToMgenIndex);
        for i=1:numStdMgens
            m.mgen_interpType{i} = 'mid';
        end
        for i=numStdMgens+1:numMorphogens
            m.mgen_interpType{i} = m.globalProps.defaultinterp;
        end
    elseif ~iscell( m.mgen_interpType )
        numMorphogens = length(m.mgen_interpType);
        newInterpType = cell(1,numMorphogens);
        for i=1:numMorphogens
            switch m.mgen_interpType(i)
                case 2
                    newInterpType{i} = 'min';
                case 3
                    newInterpType{i} = 'max';
                otherwise
                    newInterpType{i} = 'mid';
            end
        end
        m.mgen_interpType = newInterpType;
    end
    
    if ~isfield( m, 'mgenswitch' )
        m.mgenswitch = ones( 1, size(m.mutantLevel,2) );
    end
    
    if isfield( m.globalProps, 'laststage' )
        m.globalDynamicProps.laststagesuffix = '';
        m.globalProps = rmfield( m.globalProps, 'laststage' );
    end
    
    m = updateElasticity( m );
    
    if isfield( m.secondlayer, 'colors' )
        m = setSecondLayerColorInfo( m, m.secondlayer.colors, m.secondlayer.colorvariation );
        m.secondlayer = rmfield( m.secondlayer, { 'colors', 'colorvariation', 'colorparams' } );
    end
    if size(m.globalProps.colors,1)==1
        m.globalProps.colors = [ m.globalProps.colors; 1-m.globalProps.colors ];
    end

    if ~isfield( m, 'mgen_production' )
        m.mgen_production = zeros(size(m.morphogens));
    end
    
    if size(m.mgen_absorption,1)==1
        m.mgen_absorption = repmat( m.mgen_absorption, getNumberOfVertexes(m), 1 );
    end
    
    % Remove obsolete fields of m.celldata.
    m.celldata = safermfield( m.celldata, ...
        'cellThermDiffLocalTensor', ...
        'cellThermDiffDir', ...
        'cellThermDiffGlobalTensor', ...
        'cellThermExpLocalTensor', ...
        'cellThermExpDir', ...
        'majorThermExp', ...
        'minorThermExp', ...
        'avResidStrain', ...
        'residualStress', ...
        'normResidStrain', ...
        'normResidStress', ...
        'actualGrowthParams' );
    if isfield(m.celldata, 'residualStrain') && (size(m.celldata(1).residualStrain,2)==1)
        for i=1:length(m.celldata)
            m.celldata(i).residualStrain = repmat( m.celldata(i).residualStrain, 1, 6 );
        end
    end
    if ~isfield( m.celldata, 'vorticity' )
        for i=1:length(m.celldata)
            m.celldata(i).vorticity = repmat( eye(3), [1,1,6] );
        end
    end
    
    if ~isfield( m, 'directGrowthTensors' )
        m.directGrowthTensors = [];
    end
        
    % Older versions of GFtbox could leave m.outputs in an inconsistent
    % state (e.g. if leaf_load were used to replace the mesh by another).
    % Here we test to see if every component of m.outputs is the size it
    % should be, and if not, discard and recompute it.
    numcells = getNumberOfFEs( m );
    if full3d
        goodOutputs = isfield( m, 'outputs' ) ...
            && (size( m.outputs.specifiedstrain, 1 ) == numcells) ...
            && (size( m.outputs.actualstrain, 1 ) == numcells) ...
            && (size( m.outputs.residualstrain, 1 ) == numcells) ...
            && (size( m.outputs.rotations, 3 ) == numcells);
    else
        goodOutputs = isfield( m, 'outputs' ) ...
            && (size( m.outputs.specifiedstrain.A, 1 ) == numcells) ...
            && (size( m.outputs.specifiedstrain.B, 1 ) == numcells) ...
            && (size( m.outputs.actualstrain.A, 1 ) == numcells) ...
            && (size( m.outputs.actualstrain.B, 1 ) == numcells) ...
            && (size( m.outputs.residualstrain.A, 1 ) == numcells) ...
            && (size( m.outputs.residualstrain.B, 1 ) == numcells) ...
            && (size( m.outputs.rotations, 3 ) == numcells);
    end
    if ~goodOutputs
        m = calculateOutputs( m );
    end
    
    if isfield( m, 'cellareas' )
        m.cellareas = reshape( m.cellareas, numel(m.cellareas), 1 );
    end
    
    numFEs = getNumberOfFEs( m );
    PERCELL_ELASTICITY_IS_UNIMPLEMENTED = false;
    if PERCELL_ELASTICITY_IS_UNIMPLEMENTED || ~isfield( m, 'cellstiffness' )
        m.cellbulkmodulus = repmat( m.globalProps.bulkmodulus, [numFEs, 1] );
        m.cellpoisson = repmat( m.globalProps.poissonsRatio, [numFEs, 1] );
        m.cellstiffness = repmat( m.globalProps.D, [1,1,numFEs] );
    end

    if ~isfield( m, 'polfreeze' )
        m.polfreeze = reshape( m.morphogens( m.tricellvxs, pol_mgen ), size(m.tricellvxs) );
    end
    
    if ~full3d && ~isfield( m, 'polfreezebc' )
        if m.globalProps.twosidedpolarisation
            trivxs = m.tricellvxs*2;
            for ci=1:size(m.polfreeze,1)
                m.polfreezebc(ci,:,1) = vec2bc( m.gradpolgrowth(ci,:,1), ...
                                                m.prismnodes( trivxs(ci,:)-1, : ) );
                m.polfreezebc(ci,:,2) = vec2bc( m.gradpolgrowth(ci,:,2), ...
                                                m.prismnodes( trivxs(ci,:), : ) );
            end
        else
            for ci=1:size(m.polfreeze,1)
                m.polfreezebc(ci,:) = vec2bc( m.gradpolgrowth(ci,:), ...
                                              m.nodes( m.tricellvxs(ci,:), : ) );
            end
        end
    end
    
    if isfield( m, 'polfreezebc' ) && (numel( m.polfreezebc )==1)
        m = rmfield( m, 'polfreezebc' );
    end
    
    if ~isfield( m, 'polfrozen' )
        m.polfrozen = false( numFEs, 1, size(m.gradpolgrowth,3) );
    elseif size( m.polfrozen, 1 )==1
        m.polfrozen = m.polfrozen(:);
    end
    
    if ~isfield( m, 'polsetfrozen' )
        m.polsetfrozen = false;
    end
    
    if (size( m.polsetfrozen, 1 ) ~= numFEs) && (size( m.polsetfrozen, 1 ) == getNumberOfVertexes( m ))
        % Convert from per-vertex to per-FE.
        m.polsetfrozen = sum( m.polsetfrozen( m.tricellvxs ), 2 ) > 1.5;
    end
    
    if (isfield( m, 'growthangleperFEB' ) && ~isempty( m.growthangleperFEB )) ...
            || (isfield( m, 'growthanglepervertexB' ) && ~isempty( m.growthanglepervertexB ))
        % Force two-sided polarisation and store both growth angles in
        % m.growthangleperFE and m.growthangleperFE.
        m = setTwoSidedPolarisation( m, true );
        if ~isempty( m.growthangleperFEB )
            m.growthangleperFE = [ m.growthangleperFE, m.growthangleperFEB ];
        end
        if ~isempty( m.growthanglepervertexB )
            m.growthanglepervertex = [ m.growthanglepervertex, m.growthanglepervertexB ];
        end
    else
        m = setTwoSidedPolarisation( m, m.globalProps.twosidedpolarisation );
    end
    m = safermfield( m, 'growthangleperFEB', 'growthanglepervertexB' );
    
    % Force consistency of all the fields affected by one/two-sided
    % polarisation.
    
    m.globalDynamicProps = defaultFromStruct( m.globalDynamicProps, gGlobalDynamicProps  );
    if ~isfield( m, 'globalInternalProps' )
        m.globalInternalProps = gGlobalInternalProps;
    end
    m.globalInternalProps = defaultFromStruct( m.globalInternalProps, gGlobalInternalProps  );
    if isempty( m.globalInternalProps.flataxes )
        m.globalInternalProps.flataxes = getFlatAxes( m );
    end
    
    if isfield( m.secondlayer, 'vvlayer' )
        m.secondlayer.vvlayer.plotoptions = defaultFromStruct( m.secondlayer.vvlayer.plotoptions, gDefaultVVPlotOptions  );
    end
    
    m.secondlayer = fixBioOrientations( m.secondlayer );
    
    [m,~] = upgradeModelOptions( m );
    
    if isVolumetricMesh( m )
        m = upgradeVolumetricMesh( m );
    end
    
% 2007 Jun 12
    if checkValidity
        [ok,m] = validmesh( m );
        if ~ok
            % Nothing -- validmesh will already have written error messages.
        end
    end
end

function x = forcetype( x, fieldtype )
    if ~strcmp( class( x ), fieldtype )
        fieldtypehandle = str2func(fieldtype);
        x = fieldtypehandle(x);
    end
end

% function [nc,ne] = convertNodeCellEdges( nce )
%     nc = cell(size(nce));
%     ne = cell(size(nce));
%     for i=1:length(nce)
%         ne{i} = nce{i}(1,:);
%         nc{i} = nce{i}(2,:);
%     end
% end

function m = upgradeTubules( m )
    global gMTProperties

    emptyTubules = initTubules();
    for i=1:length(m.tubules.tracks)
        m.tubules.tracks(i) = defaultFromStructRecursive( m.tubules.tracks(i), emptyTubules.defaulttrack );
    end
    m.tubules = defaultFromStructRecursive( m.tubules, emptyTubules );
    m.tubules = safermfield( m.tubules, setdiff( fieldnames( m.tubules ), fieldnames( emptyTubules ) ) );
    if isfield( m.tubules.tubuleparams, 'prob_collide_catastrophe' ) && ~isfield( m.tubules.tubuleparams, 'prob_collide_catastrophe_shallow' )
        m.tubules.tubuleparams.prob_collide_catastrophe_shallow = m.tubules.tubuleparams.prob_collide_catastrophe;
        m.tubules.tubuleparams.prob_collide_catastrophe_steep = m.tubules.tubuleparams.prob_collide_catastrophe;
    end
%     if isfield( m.tubules.tubuleparams, 'prob_collide_catastrophe_steep' )
%         m.tubules.tubuleparams.prob_collide_catastrophe = m.tubules.tubuleparams.prob_collide_catastrophe_steep;
%     end
    m.tubules.tubuleparams = safermfield( m.tubules.tubuleparams, setdiff( fieldnames( m.tubules.tubuleparams ), fieldnames( emptyTubules.tubuleparams ) ) );

    m.tubules.defaulttrack = upgradeTubule( m.tubules.defaulttrack );
    if ~isempty( m.tubules.tracks )
        if isfield( m.tubules.tracks(1).status, 'growhead' )
            for i=1:length(m.tubules.tracks)
                m.tubules.tracks(i) = upgradeTubule( m.tubules.tracks(i) );
            end
        end
        if isfield( m.tubules.tracks(1).status, 'lastcat_bc' )
            for i=1:length(m.tubules.tracks)
                m.tubules.tracks(i).status = safermfield( m.tubules.tracks(i).status, { 'lastcat_bc', 'lastcat_element' } );
            end
        end
    end
    if ~isfield( m.tubules, 'tubuleparams' )
        m.tubules.tubuleparams = m.tubules.defaulttrack.params;
        m.tubules.defaulttrack = rmfield( m.tubules.defaulttrack, 'params' );
    end
end

function tubule = upgradeTubule( tubule )
    if isfield( tubule.status, 'growhead' )
        tubule.status.head = tubule.status.growhead*2 - 1;
        tubule.status = rmfield( tubule.status, 'growhead' );
    end
end






