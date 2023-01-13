function setGlobals()
%setGlobals()
%   This can be called any number of times, but only the first call in a
%   Matlab session does any work.  To force a reinitialisation of all of
%   these global variables, call resetGlobals().

    global gHaveGlobals;
    if ~isempty(gHaveGlobals)
        return;
    end
    gHaveGlobals = 1;
    
    global gMIN_MESHVERSION gMAX_MESHVERSION
    global gMIN_MGENVERSION gMAX_MGENVERSION

    global gLaminarMorphogenNames gVolumetricMorphogenNames
    global gLaminarRoleNameToMgenIndex gVolumetricRoleNameToMgenIndex
    
    global gCellFactorRoles
    global gCellRoleMenuDict
    
    global gDefaultPlotOptions
    global gPlotOptionNames
    global gPlotPriorities gABfields
    global gGlobalProps
    global gDEFAULTFIELDS
    global gPerNodeMgenDefaults gPerMgenDefaults gPerMgenDynamicDefaults
    global gAxisNames
    global gMISC_GLOBALS
    global gSecondLayerColorInfo gSecondLayerColorModeDictionary
    global gPlotHandles gStereoParams
    
    global gPerBioCellFields gPerBioEdgeFields gPerBioVertexFields
    
    global FE_P6 FE_T3 FE_Q4 FE_H8 FE_H8Q FE_T4 FE_T4Q
    global gUSENEWFES_ELAST
    global gUSENEWFES_DIFFUSE
    global gJacobianMethod

    global gMTProperties
    
    global gDYNAMICFIELDS gSTATICFIELDS gHYBRIDFIELDS gUNSAVEDFIELDS gTRANSIENTFIELDS
    global gRUNFIELDS gSecondlayerRunFieldDefaults gSecondlayerRunFields gSecondlayerStaticFields
    global gPerCellFactorDynamicDefaults
    
    global gFOLIATEONLYFIELDS gVOLUMETRICONLYFIELDS
    
    global gFIELDTYPES gPERVERTEX gPERFE gPERMGEN gPERCELLFACTOR
    
% gFIELDTYPES is an N*4 cell array of strings. In each row the four
% elements are:
% 1: A fieldname of m.
% 2: The types of the dimensions of that field of m.
% 3: The type of its values.
% 4: Whether it applies to volumetric meshes, foliate meshes, or both.
    gFIELDTYPES = {
        'FEnodes', { 'fevx', 'dim' }, '', 'vol';
        'FEsets', { '', '' }, '', 'vol';
        'FEsets.fevxs', { 'fe', 'vxperfe' }, 'fevx', 'vol';
        'nodes', { 'fevx', 'dim' }, '', 'fol';
        'prismnodes', { 'prismvx', 'dim' }, '', 'fol';
        ... % 'sharpedges', { 'feedge', 1 }, 'logical', 'vol'; % The sharpness of edges cannot be automatically updated,
        ... %       because FEconnectivity is celled after splitting, which can arbitrarily reorder the edges.
        'sharpvxs', { 'fevx', 1 }, 'logical', 'vol'; % This one is ok.
        ... % 'edgeends', { 'feedge', 2 }, 'fevx', 'fol', ...  % Why are these commented out? Why is celledges absent?
        ... % 'edgecells', { 'feedge', 2 }, 'fevx', 'fol', ... % What about edgecellindex and edgesense?
        ... % Perhaps the same reason that sharpedges is not listed here: edgeends and edgecells get recomputed from
        ... % scratch, not updated.
        'cellFrames', { '', '', 'fe' }, '', '';
        'cellFramesA', { '', '', 'fe' }, '', 'fol';
        'cellFramesB', { '', '', 'fe' }, '', 'fol';
        'growthanglepervertex', { 'fevx' }, '', 'fol';
        'growthangleperFE', { 'fe' }, '', 'fol';
        'visible.nodes', { 'fevx' }, '', '';
        'visible.edges', { '' }, '', '';
        'visible.faces', { '' }, '', '';
        'visible.elements', { 'fe' }, '', '';
        'visible.surfnodes', { 'fevx' }, '', '';
        'visible.surfedges', { '' }, '', '';
        'visible.surffaces', { '' }, '', '';
        'visible.surfelements', { 'fe' }, '', '';
        'mgenIndexToName', { 'mgen' }, '', '';
        'fixedDFmap', { 'prismvx', 'dim' }, '', '';
        'displacements', { 'fevx', 'dim' }, '', '';
        'effectiveGrowthTensor', { 'fe', 'rowtensor' }, '', '';
        'directGrowthTensors', { 'fe', 'rowtensor' }, '', '';
        'cellbulkmodulus', { 'fe' }, '', '';
        'cellpoisson', { 'fe' }, '', '';
        'cellstiffness', { '', '', 'fe' }, '', '';
        'morphogens', { 'fevx', 'mgen' }, '', '';
        'morphogenclamp', { 'fevx', 'mgen' }, '', '';
        'mgen_production', { 'fevx', 'mgen' }, '', '';
        'mgen_absorption', { 'fevx', 'mgen' }, '', '';
        'mutantlevel', { '', 'mgen' }, '', '';
        'mgenswitch', { '', 'mgen' }, '', '';
        'mgen_dilution', { '', 'mgen' }, '', '';
        'mgen_transportable', { '', 'mgen' }, '', '';
        'mgen_plotpriority', { '', 'mgen' }, '', '';
        'mgen_plotthreshold', { '', 'mgen' }, '', '';
        'conductivity', { '', 'mgen' }, '', '';
        'mgenposcolors', { 'col', 'mgen' }, '', '';
        'mgennegcolors', { 'col', 'mgen' }, '', '';
        'mgen_plottheshold', { '', 'mgen' }, '', '';
        'mgen_interptype', { '', 'mgen' }, '', '';
        'transportfield', { '', 'mgen' }, '', '';
        'gradpolgrowth', { 'fe', 'dim' }, '', '';
        'gradpolgrowth2', { 'fe', 'dim' }, '', 'vol';
        'unitcellnormals', { 'fe', 'dim' }, '', 'fol';
        'polfreeze', { 'fe', 'vxsperfe' }, '', '';
        'polfrozen', { 'fe' }, '', '';
        'polfreezebc', { 'fe', 'dim' }, '', '';
        'cellareas', { 'fe' }, '', 'fol';
        'currentbendangle', { 'feedge' }, '', 'fol';
        'initialbendangle', { 'feedge' }, '', 'fol';
        'celldata', { '', 'fe' }, '', '';
        'tricellvxs', { 'fe', 'dim' }, 'fevx', 'fol';
        'vertexnormals', { 'fevx', 'dim' }, '', 'fol';
        'globalProps.displayedVertexIndex', { '' }, 'fevx', '';
        'globalProps.displayedVertexMorphogen', { '' }, 'mgen', '';
        'globalDynamicProps.locatenode', { '' }, 'zfevx', '';
        'outputs.specifiedstrain.A', { 'fe', '' }, '', 'fol';
        'outputs.specifiedstrain.B', { 'fe', '' }, '', 'fol';
        'outputs.actualstrain.A', { 'fe', '' }, '', 'fol';
        'outputs.actualstrain.B', { 'fe', '' }, '', 'fol';
        'outputs.residualstrain.A', { 'fe', '' }, '', 'fol';
        'outputs.residualstrain.B', { 'fe', '' }, '', 'fol';
        'outputs.specifiedstrain', { 'fe', '' }, '', '';
        'outputs.actualstrain', { 'fe', '' }, '', '';
        'outputs.residualstrain', { 'fe', '' }, '', '';
        'outputs.rotations', { 'fe', '' }, '', '';
        'secondlayer.cells', { '', 'cell' }, '', '';  % Requires custom handling (already implemented).
        'secondlayer.cellcolor', { 'cell', 'col' }, '', '';
        'secondlayer.side', { 'cell' }, '', '';
        'secondlayer.cloneindex', { 'cell' }, '', '';
        'secondlayer.cellvalues', { 'cell', 'cellmgen' }, '', '';
        'secondlayer.cellpolarity', { 'cell' }, '', '';
        'secondlayer.areamultiple', { 'cell' }, '', '';
        'secondlayer.cellarea', { 'cell' }, '', '';
        'secondlayer.celltargetarea', { 'cell' }, '', '';
        'secondlayer.vxFEMcell', { 'cellvx' }, 'fe', '';
        'secondlayer.vxBaryCoords', { 'cellvx', 'dim' }, '', '';
        'secondlayer.cell3dcoords', { 'cellvx', 'dim' }, '', '';
        'secondlayer.cellid', { 'cell?' }, '', '';  % Requires custom handling.
        'secondlayer.cellparent', { 'cell?' }, '', '';  % Requires custom handling.
        'secondlayer.cellidtoindex', { 'cell?' }, '', '';  % Requires custom handling.
        'secondlayer.cellidtotime', { 'cell?' }, '', '';  % Requires custom handling.
        'secondlayer.edges', { 'celledge', 'two' }, 'cellvx&cell', '';  % Requires custom handling.
        'secondlayer.interiorborder', { 'celledge' }, '', '';  % Requires custom handling.
        'secondlayer.generation', { 'celledge' }, '', '';  % Requires custom handling.
        'secondlayer.edgepropertyindex', { 'celledge' }, '', '';  % Requires custom handling.
        'secondlayer.cellvalue_plotpriority', { 'cellmgen' }, '', '';
        'secondlayer.cellvalue_plotthreshold', { 'cellmgen' }, '', '';
        'secondlayer.celldata.genindex', { 'cell' }, '', '';
        'secondlayer.celldata.genmaxindex', { '' }, '', '';  % Requires custom handling.
        'secondlayer.celldata.parent', { 'cell' }, '', '';
        'secondlayer.celldata.values', { 'cell', 'any?' }, '', '';
        'secondlayer.edgedata.genindex', { 'celledge' }, '', '';
        'secondlayer.edgedata.genmaxindex', { '' }, '', '';  % Requires custom handling.
        'secondlayer.edgedata.parent', { 'celledge' }, '', '';
        'secondlayer.edgedata.values', { 'celledge', 'any?' }, '', '';
        'secondlayer.vxdata.genindex', { 'cellvx' }, '', '';
        'secondlayer.vxdata.genmaxindex', { '' }, '', '';  % Requires custom handling.
        'secondlayer.vxdata.parent', { 'cellvx' }, '', '';
        'secondlayer.vxdata.values', { 'cellvx', 'any?' }, '', '';
        'secondlayer.visible.cells', { 'cell' }, '', '';
        'volcells.vxs3d', { 'volvx', 'dim' }, 'float', 'vol';
        'volcells.facevxs', { '{' 'volface', '}', '' }, 'volvx', 'vol';
        'volcells.polyfaces', { '{' 'volsolid', '}', '' }, 'volface', 'vol';
        'volcells.polyfacesigns', { '{' 'volsolid', '}', '' }, 'logical', 'vol';
        'volcells.edgevxs', { 'voledge', '2' }, 'volvx', 'vol';
        'volcells.faceedges', { '{', 'volface', '}', '' }, 'voledge', 'vol';
        'volcells.vxfe', { 'volvx', '1' }, 'fe', 'vol';
        'volcells.vxbc', { 'volvx', '4' }, 'float', 'vol';
    };
% Fields that may need special handling:
% indexededgeproperties: [1x1 struct]
% plotdata  % Clear this? The mesh would need replotting anyway after deleting items.
% drivennodes  % Never used. Would this be a list of vertex indexes?
% drivenpositions  % Never used. Would this be indexed by indexed into drivennodes?
% mgenNameToIndex  % Need to update together with mgenIndexToName.
% decorFEs  % Probably not applicable.
% decorBCs  % Probably not applicable.

    foliateOnlyFields = gFIELDTYPES( strcmp( gFIELDTYPES(:,4), 'fol' ), 1 );
    
    gFOLIATEONLYFIELDS = {
        'nodes', ...
        'prismnodes', ...
        'tricellvxs', ...
        'vertexnormals', ...
        'edgeends', ...
        'edgecells', ...
        'celledges', ...
        'seams', ...
        'nodecelledges', ...
        'currentbendangle', ...
        'initialbendangle', ...
        'polfreezebc', ...
        'cellareas', ...
        'unitcellnormals', ...
    };

    gVOLUMETRICONLYFIELDS = {
        'FEnodes', ...
        'gradpolgrowth2', ...
    };


    gPERVERTEX = { ...
        'nodes' % But need to remember 'prismnodes' also, which is not quite per vertex.
        };
    
    gPERFE = { ...
        'tricellvxs'
        };
    
    gPERMGEN = { ...
        'morphogens'
        };
    
    gPERCELLFACTOR = { ...
        ... % Not used.
        };
    
    % For wizards only!  When gUSENEWFES_ELAST is true, enables a new
    % implementation of finite elements for elasticity.  When
    % gUSENEWFES_DIFFUSE is true, it does the same for diffusion.
    % If you declare these global on the command line and set them
    % to true, then setGlobals will not override it.  This allows the
    % new finite elements to be tested while making them invisible to
    % ordinary users.
    if isempty(gUSENEWFES_ELAST)
        gUSENEWFES_ELAST = false;
    end
    if isempty(gUSENEWFES_DIFFUSE)
        gUSENEWFES_DIFFUSE = false;
    end
    if isempty(gJacobianMethod)
        gJacobianMethod = false;
    end
    FE_P6 = FiniteElementType.MakeFEType( 'P6' );
    FE_T3 = FiniteElementType.MakeFEType( 'T3' );
    FE_Q4 = FiniteElementType.MakeFEType( 'Q4' );
    FE_H8 = FiniteElementType.MakeFEType( 'H8' );
    FE_H8Q = FiniteElementType.MakeFEType( 'H8Q' );
    FE_T4 = FiniteElementType.MakeFEType( 'T4' );
    FE_T4Q = FiniteElementType.MakeFEType( 'T4Q' );
    
    definePropertyLists();

    gPerBioCellFields = { ...
        'cells', ...
        'cellcolor', ...
        'side', ...
        'cloneindex', ...
        'cellvalues', ...
        'cellpolarity', ...
        'areamultiple', ...
        'cellarea', ...
        'celltargetarea' };
        
    gPerBioEdgeFields = { ...
        'edges', ...
        'interiorborder', ...
        'generation', ...
        'edgepropertyindex' };

    gPerBioVertexFields = { ...
        'vxFEMcell', ...
        'vxBaryCoords', ...
        'cell3dcoords', ...
        'vxedges' };
        
    gSecondLayerColorInfo = calcColorinfoMap( [], 'splitmono' );
    
    gSecondLayerColorModeDictionary = struct( ...
        'rainbow', 'Rainbow', ...
        'rainbowwhite', 'Split Rainbow', ...
        'maxmin', 'Monochrome', ...
        'posneg', 'Split Mono', ...
        'custom', 'Custom' );
    
    gStereoParams = struct( ...
            'enable', false, ...
            'vergence', 2.5, ...
            'spacing', 0, ...
            'direction', '-h' );

    gPlotHandles = struct( ...
            'HLedges', [], ...
            'HLvertexes', [], ...
            'patchA', [], ...
            'patchB', [], ...
            'patchM', [], ...
            'patchAM', [], ...
            'patchBM', [], ...
            'patchAB', [], ...
            'rimEdges', [], ...
            'throughEdges', [], ...
            'secondlayerhandle', [] );

    % Every field of a mesh structure should appear in exactly one of
    % gDYNAMICFIELDS, gSTATICFIELDS, gHYBRIDFIELDS, or gUNSAVEDFIELDS.
    gTRANSIENTFIELDS = { ...
            ... % These fields may or may not be present in a mesh.
            'strainhandles', ...
            'plothandles', ...
            'normalhandles', ...
            'visible', ...
            'timeForIter', ...
            'ticForIter', ...
            'componentinfo', ...
            'borders', ... % Really optional, not transient.
        };

    gUNSAVEDFIELDS = { ...
            ... % These fields should not be saved in mesh files.
%             'interactionMode', ...
%             'saved', ...
%             'stop', ...
%             'rewriteIFneeded', ...
%             'pictures', ...
%             'selection', ...
            'saved', ...
            'stop', ...
            'rewriteIFneeded', ...
            'pictures', ...
            'stopButton', ...
            'userdata_unsaved', ... % This is especially for figure handles,
                                ... % which will be either invalid on loading
                                ... % from a file, or if valid will cause the
                                ... % figure to be displayed in a new window,
                                ... % which is generally unwanted.
        };
    gHYBRIDFIELDS = { ...
            ... % These fields should be saved in both the static and dynamic mesh files.
            'mgenIndexToName', ...
            'mgenNameToIndex', ...
            'secondlayer', ...
        };
    gDYNAMICFIELDS = { ...
            ... % These fields should be saved in the dynamic mesh file only.
            'interactionMode', ...
            'selection', ...
            ...
            'globalDynamicProps', ...
            'FEsets', ...
            'FEnodes', ...
            'FEconnectivity', ...
            'nodes', ...
            'prismnodes', ...
            'tricellvxs', ...
            'vertexnormals', ...
            'edgeends', ...
            'edgecells', ...
            'celledges', ...
            'edgecellindex', ...
            'edgesense', ...
            'seams', ...
            'sharpedges', ...
            'sharpvxs', ...
            'nodecelledges', ...
            'currentbendangle', ...
            'initialbendangle', ...
            'displacements', ...
            'growthanglepervertex', ...
            'growthangleperFE', ...
            'morphogens', ...
            'morphogenclamp', ...
            'mgen_production', ...
            'mgen_absorption', ...
            'mutantLevel', ...
            'mgenswitch', ...
            'transportfield', ...
            'fixedDFmap', ...
            'gradpolgrowth', ...
            'gradpolgrowth2', ...
            'polfreeze', ...
            'polfreezebc', ...
            'polfrozen', ...
            'polsetfrozen', ...
            'effectiveGrowthTensor', ...
            'directGrowthTensors', ...
            'celldata', ...
            'cellFrames', ...
            'cellFramesA', ...
            'cellFramesB', ...
            'cellareas', ...
            'unitcellnormals', ...
            'versioninfo', ...
            'cellstiffness', ...
            'cellbulkmodulus', ...
            'cellpoisson', ...
            'decorFEs', ...
            'decorBCs', ...
            'drivennodes', ...
            'drivenpositions', ...
            'visible', ...
            'outputs', ...
            'plotdata', ...
            'userdata', ...
            'waypoints', ...
            'moviescripts', ...
            'movieselected', ...
            'tubules', ...
        };
    gSTATICFIELDS = { ...
            ... % These fields should be saved in the static mesh file.
            'globalProps', ...
            'globalInternalProps', ...
            'modeloptions', ...
            'stagetimes', ...
            'plotdefaults', ...
            'stereoparams', ...
            'mgen_interpType', ...
            'mgen_dilution', ...
            'mgen_transportable', ...
            'mgen_plotpriority', ...
            'mgen_plotthreshold', ...
            'mgenposcolors', ...
            'mgennegcolors', ...
            'roleNameToMgenIndex', ...
            'outputcolors', ...
            'conductivity', ...
            'allMutantEnabled', ...
            'meshparams', ...
            'secondlayerstatic', ...
            'userdatastatic', ...
            ... % 'FEtypes', ...
        };
    gRUNFIELDS = { ...
            ... % These fields should be saved in the run file, when it is implemented, but until then the static file.
        };
    gSecondlayerRunFieldDefaults = struct( ...
            ... % These fields of m.secondlayer should be saved in the run file, when it is implemented, but until then the static file.
            'cellparent', 0, ...
            ... % 'celldaughters', [0 0], ...
            'cellidtotime', NaN ...
        );
    gSecondlayerRunFields = fieldnames( gSecondlayerRunFieldDefaults )';
    gSecondlayerStaticFields = { ...
        'valuedict', ...
        'cellcolorinfo', ...
        'customcellcolorinfo', ...
        'cellvalue_plotpriority', ...
        'cellvalue_plotthreshold' };
    
    gPerCellFactorDynamicDefaults = struct( ...
        'cellvalues', 0 ...
    );

    global gFULLSTATICFIELDS
    % These are the fields that are saved in a project's static file.
    gFULLSTATICFIELDS = [ gSTATICFIELDS gHYBRIDFIELDS ];

    outputPlotQuantities = { 'resultantgrowth', ...
                             'resultantanisotropy', ...
                             'resultantrelativeanisotropy', ...
                             'resultantbend', ...
                             'residualgrowth', ...
                             'residualanisotropy', ...
                             'residualrelativeanisotropy', ...
                             'residualbend', ...
                             'specifiedgrowth', ...
                             'specifiedanisotropy', ...
                             'specifiedrelativeanisotropy', ...
                             'specifiedbend', ...
                             'rotation' };
    numOutputPlotQuantities = length(outputPlotQuantities);
    obsoletePlotQuantities = { 'currentgrowth', ...
                               'currentbend', ...
                               'strain', ...
                               'stress', ...
                               'polarisation' };
    for i=1:numOutputPlotQuantities
        gOutputColors.(outputPlotQuantities{i}) = ...
            HSVtoRGB( [ (i-1)/7, 1, 1 ] );
    end
    for i=1:length(obsoletePlotQuantities)
        gOutputColors.(obsoletePlotQuantities{i}) = ...
            HSVtoRGB( [ (i-1)/7, 1, 1 ] );
    end

    gLaminarMorphogenNames = { ...
        'KAPAR', 'KAPER', 'KBPAR', 'KBPER', ...
        'KNOR', 'POLARISER', 'STRAINRET', 'ARREST' };
    
    xx = [ gLaminarMorphogenNames; num2cell(1:length(gLaminarMorphogenNames)) ];
    gLaminarRoleNameToMgenIndex = struct( xx{:} );

    gVolumetricMorphogenNames = { ...
        'KPAR', 'KPAR2', 'KPER', 'POL', 'POL2' };
        % 'KPAR', 'KPER', 'KNOR', 'POLARISER', 'POLARISER2' };
    
    xx = [ gVolumetricMorphogenNames; num2cell(1:length(gVolumetricMorphogenNames)) ];
    gVolumetricRoleNameToMgenIndex = struct( xx{:} );
    
    gCellFactorRoles = { 'cell_area', 'div_comp', 'div_area', 'cell_age' };
    gCellRoleMenuDict = MakeNameIndex( ...
        gCellFactorRoles, ...
        { 'Area', 'Div. comp.', 'Div. area', 'Age' } );
    
    gMTProperties = { ...
        'plus_growthrate', ... % length/time
        'plus_shrinkrate', ... % length/time
        'minus_shrinkrate', ... % length/time  Normal shrink rate, somewhat smaller than plus_growthrate.
        'minus_catshrinkrate', ... % length/time  Catastrophizing shrink rate, likely the same as plus_shrinkrate.
        'prob_branch_time', ... % probability/time
        'prob_branch_tubule_time', ... % probability/(number of tubules)
        'prob_branch_length_time', ... % probability/(length*time)
        'prob_branch_length_curvature_time', ... % probability/(length*time) depending in some way on curvature.
        'prob_branch_forwards', ... % probability
        'prob_branch_parallel', ... % probability
        'prob_branch_antiparallel', ... % probability
        'branch_forwards_spread', ... % radians
        'branch_backwards_spread', ... % radians
        'branch_forwards_mean', ... % radians
        'branch_backwards_mean', ... % radians
        'branch_shrinktail_delay', ... % time
        'branch_interaction_delay', ... % time
        'edge_catastrophe_edges', ... % boolean map of edges
        'edge_catastrophe_amount', ... % probability
        'edge_pause_prob', ... % probability
        'edge_pause_time', ... % time
        'prob_plus_catastrophe', ... % probability/time
        'edge_plus_catastrophe', ... % probability/time
        'prob_plus_stop', ... % probability/time
        'prob_plus_rescue', ... % probability/time
        'prob_collide_zipcat', ... % probability per collision
        'prob_collide_catastrophe_shallow', ... % probability per collision
        'prob_collide_catastrophe_steep', ... % probability per collision
        'prob_collide_zipper_shallow', ... % probability per collision
        'prob_collide_zipper_steep', ... % probability per collision
        'prob_collide_branch', ... % probability per collision that the collider generates a new branch from the crossover point.
        'min_angle_crossover_branch', ... % When a crossover happens at below this angle, no new branch can be generated from the crossover point.
        'prob_collide_cut', ... % probability per collision that one of the mts involved is severed
        'prob_collide_cut_collider', ... % probability per severance that the colliding mt is severed.
        ... % 'prob_collide_cut_collided', ... % probability per severance that the mt collided with is severed
        ...                              % (Redundant with preceding: these must add to 1.)
        'prob_collide_cut_tailcat', ... % probability, given that a cut happens, that the tail of the leading half catastrophizes;
        'prob_collide_cut_headcat', ... % probability, given that a cut happens, that the head of the trailing half catastrophizes;
        'delay_cut', ... % The time after a crossover that cutting happens, in those cases where it does.
        'delay_branch', ... % The time after a crossover that branching happens, in those cases where it does.
        'min_cut_angle', ... % radians
        'min_collide_angle', ... % radians
        ... % 'prob_cleavage', ... % probability per crossover
        ... % 'prob_cleave_catastrophe', ... % probability that when a mt is cleaved, its rear part catastrophises
        ... % 'mintime_cleavage', ... % if a cleavage happens, the minimum time before cleavage
        ... % 'maxtime_cleavage', ... % if a cleavage happens, the maximum time before cleavage
        'creation_rate', ... % 1/(length^2 * time)
        'curvature', ... % 1/length
        'max_mt_per_area', ... % 1/length^2
        'radius' }; % length
    % The three collision probabilities relate to the first three of these
    % four possible outcomes of a collision:
    % 1. The collider stops growing and starts shrinking.
    % 2. The collider zippers to the other microtubule.
    % 3. The collider carries on, severing the other microtubule.
    % 4. The collider carries on, neither microtubule being affected.
    % Since they are exclusive and exhaustive events, the last does not
    % have a separate parameter, but is 1 minus the other three.
        
    gDEFAULTFIELDS = struct( ...
        'FEsets', [], ...
        'FEnodes', [], ...
        'FEconnectivity', [], ...
        'roleNameToMgenIndex', gLaminarRoleNameToMgenIndex, ...
        'stereoparams', gStereoParams, ...
        'modeloptions', [], ...
        'stagetimes', [], ...
        'secondlayer', newemptysecondlayer(), ...
        'secondlayerstatic', newemptysecondlayerstatic(), ...
        'meshparams', struct(), ...
        'cellFrames', [], ...
        'cellFramesA', [], ...
        'cellFramesB', [], ...
    	'allMutantEnabled', true, ...
        'growthanglepervertex', [], ...
        'growthangleperFE', [], ...
        'decorFEs', [], ...
        'decorBCs', [], ...
        'outputcolors', gOutputColors, ...
        'visible', [], ...
        'plotdata', [], ...
        'pictures', [], ...
        'userdata', struct(), ...
        'userdatastatic', struct(), ...
        'userdata_unsaved', struct(), ...
        'tubules', initTubules(), ...
        'waypoints', [], ...
        'moviescripts', [], ...
        'movieselected', [], ...
        'drivennodes', [], ...
        'drivenpositions', [], ...
        'saved', 0, ...
        'stop', false, ...
        'stopButton', [], ...
        'rewriteIFneeded', false, ...
        'plothandles', gPlotHandles );

    global gOBSOLETEFIELDS
    gOBSOLETEFIELDS = { ...
        'stagenames', ...
        'gradpolbend', ...
        'stepsSinceCheckpoint', ...
        'initialArea', ...
        'vertexcolors', ...
        'facecolors', ...
        'thirdlayer', ...
        'absKvector', ...
        'scripthistory' };

    global gXI gETA gZETA;
    onesixth = 1/6;
    twothirds = 2/3;
    sqrtthird = sqrt(1/3);
    gXI = [ onesixth, twothirds, onesixth, onesixth, twothirds, onesixth ];
    gETA = [ onesixth, onesixth, twothirds, onesixth, onesixth, twothirds ];
    gZETA = [ -sqrtthird, -sqrtthird, -sqrtthird, sqrtthird, sqrtthird, sqrtthird ];
    
    gMIN_MESHVERSION = 0;
    gMAX_MESHVERSION = 0;
    
    gMIN_MGENVERSION = 0;
    gMAX_MGENVERSION = 1;
    
    gMISC_GLOBALS = struct( ...
        'stagesuffixlength', 6, ...
        'stageprefix', '_s', ...
        'stageregexp', '[mM]?[0-9]+([dD][0-9]*)?' );

    gAxisNames = struct( 'total', [1 2 3], ...
                         'areal', [1 2], ...
                         'major', 1, ...
                         'minor', 2, ...
                         'parallel', 1, ...
                         'perpendicular', 2, ...
                         'normal', 3 );

    gPlotPriorities = { 'pervertex', 'perelement', 'tensor', 'morphogen', 'outputquantity', 'blank' };
    gABfields = [ gPlotPriorities, ...
        { 'outputaxes', 'perelementaxes', 'perelementcomponents', ...
          'axesquantity', 'axesdrawn', ... % These appear to be unused.
          'defaultmultiplottissue' } ];
    for i=1:length(gABfields)
        fn = gABfields{i};
        gDefaultPlotOptions.(fn) = [];
        gDefaultPlotOptions.([fn,'A']) = [];
        gDefaultPlotOptions.([fn,'B']) = [];
    end
    gDefaultPlotOptions.morphogen = gLaminarMorphogenNames{1};
    gPlotOptionNames = fieldnames( gDefaultPlotOptions );

    global gOBSOLETEPLOTOPTIONS
    gOBSOLETEPLOTOPTIONS = { ...
        'hfigure', ...
        'hpicture', ...
        'hpictureBackground', ...
        'hlegend', ...
        'hscalebar', ...
        'hcolorbar', ...
        'hcolortexthi', ...
        'hcolortextlo', ...
        'hmaxcolor', ...
        'hmincolor', ...
        'numbering', ...
        'showlabel', ...
        'plottensors', ...
        'plotmode', ...
        'plotquantity', ...
        'multicolor', ...
        'multimorphogen', ...
        'monochrome', ...
        'stuffPerVertex', ...
        'stuff', ...
        'vertexcolors', ...
        'tensordata', ...
        'facecolors', ...
        'rawcolors', ...
        'autoCentre', ...
        'showLeafSurface', ...
        'showMutant', ...
        'hiresdpi', ...
        'defaultmultiplot' ...
    };

    global gOBSOLETESTATICPROPS
    gOBSOLETESTATICPROPS = { ...
    	'legend', ...
    	'sparseK', ...
    	'jiggleProportion', ...
    	'cvtperiter', ...
    	'maxBioBcells' ...
        'dointernalrotation', ...
        'totalinternalrotation', ...
        'stepinternalrotation', ...
        'showinternalrotation', ...
        'performinternalrotation', ...
        'internallyrotated', ...
        'moviefile', ...
        'makemovie'
    };

    gPerNodeMgenDefaults = struct( 'morphogens', 0, ...
                                   'morphogenclamp', 0, ...
                                   'mgen_production', 0, ...
                                   'mgen_absorption', 0 );

    gPerMgenDynamicDefaults = struct( ...
        'morphogens', 0, ...
        'morphogenclamp', 0, ...
        'mgen_production', 0, ...
        'mgen_absorption', 0, ...
        'mutantLevel', 1, ...
        'mgenswitch', 1, ...
        'transportfield', [] ...
    );
    
    gPerMgenDefaults = struct( 'mutantLevel', 1, ...
                               'mgenswitch', 1, ...
                               'mgen_dilution', false, ...
                               'mgen_transportable', false, ...
                               'mgen_plotpriority', 0, ...
                               'mgen_plotthreshold', 0, ...
                               'conductivity', struct( 'Dpar', [], 'Dper', [] ), ...
                               'mgenposcolors', [1;0;0], ...
                               'mgennegcolors', [0;1;1] );
    gPerMgenDefaults.mgen_interpType = {gGlobalProps.defaultinterp};
    
    createMeshParamInfo();
    
    [~] = defaultVVplotoptions();
end


