function definePropertyLists()
%definePropertyLists()
%   This defines some tables of mesh properties, mainly gGlobalProps (the
%   default value of m.globalProps), gGlobalDynamicProps (the default value
%   of m.globalDynamicProps), and gDefaultPlotOptions (the default value of
%   m.plotdefaults).  Documentation is interspersed with the definitions
%   which can be automatically extracted and used to populate a Help menu.

    global gGlobalProps gGlobalInternalProps gGlobalDynamicProps gDefaultPlotOptions
    global gOurViewParams gMatlabViewParams
    global gOurViewParamNames gMatlabViewParamNames
    global gGAUSS_INFO;

    gGAUSS_INFO = computeGaussInfo();

    secondlayercolors = [[0.1,1,0.1];[1,0.1,0.1]];
    secondlayercolorvariation = 0.05;

    gGlobalInternalProps = struct( ...
        'flataxes', [] ...
    );
    gGlobalProps = struct( ... % ITEM leaf_setproperties
        'trinodesvalid', false, ... % DYNAMIC, UNSAVED
        'prismnodesvalid', false, ... % DYNAMIC, UNSAVED
        'hybridMesh', false, ...
        'thicknessRelative', 0.1, ...
        'thicknessArea', 1, ...
        'thicknessMode', 'physical', ...
        'activeGrowth', 1, ...
        'displayedGrowth', 1, ...
        'displayedMulti', [], ...
        'allowNegativeGrowth', true, ...
        ... % If true, the growth morphogens KAPAR, KAPER, KBPAR, and KBPER
        ... % can be negative.  If false, any negative values arising in the
        ... % computation are replaced by zero.
        'usePrevDispAsEstimate', true, ...
        ... % If true, the computation of elastic deformation will use the
        ... % displacements computed on the previous timestep as the initial
        ... % estimate for the current timestep.  If false, the initial estimate
        ... % will be zero.
        'perturbInitGrowthEstimate', 0.00001, ...
        ... % This defines the amount of random perturbation added to the initial
        ... % estimate for the computation of elastic deformation, as an absolute amount.
        'perturbRelGrowthEstimate', 0.01, ...
        ... % This defines the amount of random perturbation added to the initial
        ... % estimate for the computation of elastic deformation, as a relative amount.
        'perturbDiffusionEstimate', 0.0001, ...
        ... % This defines the amount of random perturbation added to the initial
        ... % estimate for the computation of diffusion.
        'resetRand', false, ...
        ... % If true, the random number generator will be reset to a fixed initial
        ... % state before use is made of it.  This allows exact reproducibility
        ... % of a simulation.  If false, it is never reset.
        'mingradient', 0, ...
        'relativepolgrad', false, ...
        'usefrozengradient', true, ...
        'userpolarisation', false, ...
        'twosidedpolarisation', false, ...
        'thresholdsq', 0, ...
        'splitmargin', 1.4, ...
        ... % When splitting of long edges is enabled, an edge will be bisected
        ... % if its length is this amount times the threshold.  The default
        ... % value is approximately sqrt(2), so that after splitting the two new
        ... % edges are below the threshold by the same ratio.
        'splitmorphogen', '', ...
        ... % The value of this is the name of a morphogen to be used to influence
        ... % edge-splitting.  Every edge where this morphogen exceeds a specified
        ... % theshold at both ends will be split.  See also 'thresholdmgen'.
        'thresholdmgen', 0.5, ...
        ... % This is the threshold value for morphogen-specified edge-splitting.
        ... % See also 'splitmorphogen'.
        'surfacetension', 1/16, ...  % The tension parameter for the butterfly
        ... % method of edge-splitting, in the interior of a foliate mesh or on 
        ... % the surface of a volumetric mesh.  This must be between 0 and 1/8.
        ... % 0 gives flat subdivision.  1/8 makes the surface more pointy in the
        ... % middles of faces.  Negative values and values larger than 1/8 are
        ... % unstable, but are not excluded.
        'edgetension', 1/16, ...  % The tension parameter for the butterfly
        ... % method of edge-splitting, on the border of a foliate mesh. Does not
        ... % apply to volumetric meshes.  This must be between 0 and 1/8.
        ... % 0 gives straight subdivision.  1/8 makes the edge more pointy in the
        ... % middles of segments.  Negative values and values larger than 1/8 are
        ... % unstable, but are not excluded.
        'bulkmodulus', 1, ...
        ... % IGNORE
        'unitbulkmodulus', true, ...
        ... % IGNORE
        'poissonsRatio', 0.3, ...
        ... % This sets Poisson's ratio for the material, a constant value everywhere.
        'starttime', 0, ...
        ... % This defines the time at the start of the simulation.
        'timestep', 0.01, ...
        ... % This is the time step of the simulation.  It should be chosen small enough
        ... % that in a single time step, no part of the mesh grows by more than 10% in
        ... % any direction, and rotates by no more than 10 degrees.  For more accurate
        ... % runs, these criteriashould be reduced to 5% and 5 degrees.
        'timeunitname', '', ...
        ... % This is the name of the unit of time, and should be given in the singular.
        'distunitname', 'mm', ...
        ... % This is the name of the unit of length.
        'scalebarvalue', 0, ...
        ... % The number of physical units the scalebar should represent. If 0, a default
        ... % value will be chosen to make it of a tasteful size.  The default value will
        ... % always be either 1, 2, or 5 times a power of 10.
        'validateMesh', true, ...
        ... % This is for debugging only.  If true, a large set of validation checks
        ... % is run after each simulation step, to verify the integrity of the data
        ... % structures.
        'rectifyverticals', false, ...
        ... % If true, after each simulation step the pairs of vertexes on opposite
        ... % side of the mesh are moved as necessary to ensure that the line joinging
        ... % them is perpendicular to the mesh.  The midpoint of this line does not move.
        ... % This should be thought of as revising the decomposition of the material
        ... % into finite elements, not as a deformation of the material.
        ... % WARNING
        ... % BEFORE 2013 rectification of verticals was (erroneously) always performed,
        ... % even if this parameter was set to false. 
        ... % From 2013 onwards rectification of verticals is performed only if this
        ... % is set to true.  It is false by default.
        'allowSplitLongFEM', true, ...
        ... % This boolean flag specifies whether edges exceeding a certain length
        ... % threshold should be split after each simulation step.
        'allowSplitThinFEM', false, ...
        ... % This boolean flag specifies whether finite elements exceeding
        ... % a certain measure of thinness should be split after each
        ... % simulation step.
        'splitthinness', 10, ... % The measure of thinness for allowSplitThinFEM.
        'longSplitThresholdPower', 0, ...
        'allowSplitBentFEM', false, ...
        'allowSplitBio', true, ...
        'allowFlipEdges', false, ...
        'allowElideEdges', true, ...
        'mincellangle', 0.2, ...
        'mincellrelarea', 0.04, ...
        'maxFEratio', 10, ... % For volumetric meshes, a criterion for when to elide an
        ... % element because it is too long and thin.
        'alwaysFlat', false, ...
        'twoD', false, ...
        'flattenforceconvex', true, ...
        'flatten', false, ... % IGNORE.  Obsolete but harmless
        'flattenratio', 1, ... % IGNORE.  Obsolete but harmless
        'useGrowthTensors', false, ...
        'useMorphogens', true, ...
        'selfGrowth', false, ...
        'plasticGrowth', false, ...
        ... % If true, the material is modelled as a fluid flowing with Reynolds
        ... % number equal to zero, which is the limiting behaviour as Poisson's
        ... % ratio tends to 0.5.  The default is to model it as an elastic solid.
        'springyGrowth', false, ...
        ... % If true, the material is modelled as having finite Young's modulus and
        ... % infinite bulk modulus, with Poisson's ratio equal to 0.5. A substance of
        ... % this sort can be thought of as a mass of water-filled ballons glued together,
        ... % with no air spaces between them.
        ... % m.globalProps.bulkmodulus will be used as Young's modulus in this case, and
        ... % m.globalProps.poissonsRatio is ignored.
        ... % plasticGrowth takes precedence over springyGrowth.
        'maxFEcells', int32(0), ...
        ... % This specifies the maximum number of finite elements the mesh is
        ... % allowed to contain.  When it reaches this number, no more edge-splitting
        ... % will be done.  A value of zero means the number is unlimited.
        'inittotalcells', int32(0), ...
        'newcallbacks', true, ...
        'newoptionmethod', true, ...  % Introduced 2018 May 30.
        'IFsetsoptions', true, ...  % Introduced 2018 Jun 26.
        'enabletubules', true, ... % Introduced 2019 Aug 28. Enable or disable microtubule calculations.
        'bioApresplitproc', '', ...
        ... % This should be the name of a function which will be called immediately
        ... % before determining whether any biological cells should be split.  This
        ... % function can be used to override the default cell-splitting method.  The
        ... % method of writing this function is rather complex and not documented here.
        'bioApostsplitproc', '', ...
        ... % This should be the name of a function which will be called immediately
        ... % after having split some biological cells.  This
        ... % function can be used to override the default cell-splitting method.  The
        ... % method of writing this function is rather complex and not documented here.
        'maxBioAcells', int32(0), ...
        ... % This specifies the maximum number of biological cells the mesh is
        ... % allowed to contain.  When it reaches this number, no more cell-splitting
        ... % will be done.  A value of zero means the number is unlimited.
        'biosplitnoise', 0.25, ...
        ... % A parameter determining the amount of randomness in cell splitting.
        ... % The effect depends on the splitting method, and a user-specified splitting
        ... % method can use this parameter in whatever way is desired.
        'biosplitarea', 0, ...
        ... % If zero, this is ignored.  If positive, it is the area threshold below
        ... % which a bio cell will not be split.
        'biosplitarrestmgen', 'ARREST', ...
        ... % Biological cells will not be split wherever the named morphogen is above
        ... % biosplitarrestmgenthreshold.  If biosplitarrestmgen is empty, no morphogen
        ... % will be used for this purpose.
        'biosplitavoid4way', 0.05, ...
        ... % This determine the closest distance that two junctions on the same wall are allowed
        ... % to be, to avoid 4-way junctions. It is multiplied by an estimate of the cell radius.
        ... % This value must be positive.
        'biosplitarrestmgenthreshold', 0.99, ...
        'bioMinEdgeLength', 0, ... % A parameter relating to the growth of intercellular spaces.
        'bioSpacePullInRatio', 0.1, ... % A parameter relating to the growth of intercellular spaces.
        'colors', secondlayercolors, ...
        'colorvariation', secondlayercolorvariation, ...
        'colorparams', makesecondlayercolorparams( secondlayercolors, secondlayercolorvariation ), ...
        'biocolormode', 'auto', ...
        'userpostiterateproc', [], ...
        'canceldrift', false, ...
        ... % If true, after each simulation step, the mesh is repositioned if necessary
        ... % to force its centre (defined as the average of all of its vertexes) to
        ... % remain stationary.
        'mgen_interaction', '', ...
        ... % READ-ONLY.  This is a handle to the interaction function, and should not be
        ... % modified by the user.
        'mgen_interactionName', '', ...
        ... % READ-ONLY.  This is the name of the interaction function, and should not be
        ... % modified by the user.
        'allowInteraction', true, ...
        ... % This specifies whether the interaction function should be called during each
        ... % simulation step.
        'interactionValid', true, ... % UNSAVED
        ... % READ-ONLY.  If an error is detected in the interaction function, this
        ... % flag will be set to false.  It reverts to true of GFtbox detects that
        ... % the user has edited it, or when the Reset button in the GUI is clicked.
        'gaussInfo', gGAUSS_INFO, ... % IGNORE
        'D', zeros(6,6), ... % IGNORE
        'C', zeros(6,6), ... % IGNORE
        'G', zeros(6,1), ... % IGNORE
        'solver', 'cgs', ...
        ... % This specifies which solver to user when computing elastic deformation.
        'solverprecision', 'double', ...
        'solvertolerance', 0.001, ...
        'solvertolerancemethod', 'max', ...
        'diffusiontolerance', 0.00001, ...
        'allowsparse', true, ...
        'alwayssparse', false, ...
        ... % 'maxIters', int32(0), ...
        'maxsolvetime', 1000, ...
        'cgiters', int32(0), ...
        'simsteps', int32(0), ...
        'stepsperrender', int32(0), ...  % This is obsolete and never used.
        'growthEnabled', true, ...
        ... % This specifies whether elastic growth is to be computed during a
        ... % simulation step.
        'diffusionEnabled', true, ...
        ... % This specifies whether diffusion is to be computed during a
        ... % simulation step.
        'makemovie', false, ...
        ... % This specifies whether a frame is to be saved to a movie file
        ... % after each simulation step.
        'moviefile', '', ...
        ... % The name of the current movie file (empty when a movie is not being recorded).
        'codec', 'Motion JPEG AVI', ...
        ... % The codec to be used when recording a movie file.
        'autonamemovie', true, ...
        ... % If true, when a movie is started, a name will be automatically
        ... % generated for the movie file.  If false, the user will be presented
        ... % with a file dialog to choose the name.
        'overwritemovie', false, ...
        ... % When this is true, no check will be made to see if an automatically
        ... % generated movie file name already exists.  If false, the name will be
        ... % modified by appending a unique number in order to prevent any existing
        ... % file from being overwritten.
        'stepsperframe', int32(1), ...  % The number of simulation steps per movie frame.
        'framesize', [], ... % IGNORE UNSAVED
        'mov', [], ... % IGNORE UNSAVED
        'boingNeeded', false, ... % IGNORE 
        'initialArea', 0, ...
        'initialVolume', 0, ...
        'bendunitlength', 0, ...
        ... % 'targetRelArea', 1, ... % OBSOLETE
        ... % 'targetAbsArea', 1, ... % OBSOLETE
        'defaultinterp', 'min', ...
        'readonly', false, ...
        'projectdir', '', ...
        'modelname', '', ...
        'currentrun', '', ...
        'recordAllStages', true, ...
        'allowsave', true, ... % IGNORE UNSAVED
        'addedToPath', false, ... % IGNORE UNSAVED
        'bendsplit', 0.3, ...
        'usepolfreezebc', false, ...
        'dorsaltop', true, ...
        'defaultazimuth', -45, ...
        'defaultelevation', 33.75, ...
        'defaultroll', 0, ...
        'defaultViewParams', gMatlabViewParams, ...
        'comment', '', ...
        'legendTemplate', '%T: %q\n%m', ...
        ... % This is the format string used to define the legend appearing
        ... % at the top of the picture area.
        'bioAsplitcells', true, ...
        ... % Allow splitting of biological cells.
        'bioAsplitmethod', 'mindiam', ... % Method for splitting biological cells.
        'bioApullin', 4/28, ...
        'bioAfakepull', 0.7/(2*sqrt(3)), ...
        'bioAsublength', Inf, ... % The absolute length of the segments that new
        ...                           % cell walls should be subdivided into.
        'displayedVertexIndex', [], ...
        'displayedVertexMorphogen', [], ...
        'viewrotationstart', -45, ... % The initial azimuth angle, in degrees,
        ...                           % from which rotating movies start.
        'viewrotationperiod', 0, ... % If non-zero, specifies the view rotation
        ...                          % rate as the time to execute one revolution
        ...                          % about the Z axis.
        'validitytime', 0, ... % The final time of the last simulation step that
        ...                    % has been performed.
        'interactive', false, ...
        ... % READ-ONLY.  Says whether GFtbox is running interactively.  Obsolete?
        'coderevision', int32(0), ...
        ... % READ-ONLY.  The current revision number of GFtbox.
        'coderevisiondate', '', ...
        ... % READ-ONLY.  The current revision date of GFtbox.
        'modelrevision', int32(0), ...
        ... % READ-ONLY.  The latest revision of GFtbox that this model was
        ... % operated on with.  Backward compatibility is retained: old models
        ... % should always be loadable into new versions of GFtbox.  The reverse
        ... % is not necessarily the case.  This field will tell you if the model
        ... % has been edited with a newer version of GFtbox that you are currently
        ... % running.
        'modelrevisiondate', '', ...
        ... % READ-ONLY.  The date of the latest revision of GFtbox that this model was
        ... % operated on with.  See also 'modelrevision'.
        'savedrunname', '', ... % IGNORE
        'savedrundesc', '' ... % IGNORE
    );
    gGlobalProps.vxgrad(:,:,1) = gradN( [ 0; 0; 1 ] );
    gGlobalProps.vxgrad(:,:,2) = gradN( [ 1; 0; 1 ] );
    gGlobalProps.vxgrad(:,:,3) = gradN( [ 0; 1; 1 ] );
    gGlobalProps.vxgrad(:,:,4) = gradN( [ 0; 0; -1 ] );
    gGlobalProps.vxgrad(:,:,5) = gradN( [ 1; 0; -1 ] );
    gGlobalProps.vxgrad(:,:,6) = gradN( [ 0; 1; -1 ] );

    gGlobalDynamicProps = struct( ... % ITEM leaf_setproperties
        'currenttime', 0.0, ...
        'currentIter', 0, ...
        'laststagesuffix', '', ... % UNSAVED
        'currentArea', 0, ...
        'previousArea', 0, ...
        'currentVolume', 0, ...
        'previousVolume', 0, ...
        'thicknessAbsolute', 0, ... % DYNAMIC?
        'freezing', 0, ...
        'cellscale', 0, ...
        'locatenode', 0, ...
        'locateDFs', [], ...
        'staticreadonly', false, ...
        'commandok', true, ...
        'doinit', true, ...
        'stitchDFs', [], ...
        'stitchDFsets', [], ...
        'stepssinceframe', 0, ...
        'framesinmovie', 0 ...
    );

    gOurViewParams =  struct( ...
        'azimuth', -45, ...
        'elevation', 33.75, ...
        'roll', 0, ...
        'fov', 10, ...
        'pan', [0 0], ...
        'targetdistance', 0, ...
        'camdistance', 4*sqrt(3)/(2*tan(5*pi/180)), ...
        'projection', 'orthographic' );
    gMatlabViewParams = cameraParamsFromOurViewParams( gOurViewParams );
    gOurViewParamNames = fieldnames( gOurViewParams );
    gMatlabViewParamNames = fieldnames( gMatlabViewParams );

    gDefaultPlotOptions = struct( ... % ITEM leaf_plotoptions
        'visiblefigures', true, ...
        'drawtensoraxes', false, ...
        'drawtensorcircles', false, ...
        'rotcirclevaluescale', 1, ...
        'unitcrosses', true, ...
        ... % 'tensorquantity', 'resultantgrowthrate', ... % New 2009-11-11
        ... % 'tensorproperty', 'total', ...
        'outputquantity', 'resultantgrowthrate', ...
        'outputaxes', 'total', ...
        'morphogen', 1, ...
        ... % 'rawstuff', [], ...  % Obsolete.
        'drawleaf', 1, ...
        'drawedges', 1, ...
        'drawseams', 1, ...
        'edgesharpness', [], ...
        'fillleaf', 1, ...
        'drawstreamlines', 1, ...
        'streamlinecolor', 'b', ...
        'streamlinethick', 2, ...
        'streamlinemiddotsize', 1, ...
        'streamlineenddotsize', 20, ...
        'streamlineseverdotsize', 20, ...
        'streamlinexoversymbol', 'x', ...
        'streamlineoffset', 1.5, ...
        'drawstreamlinebranchpoints', false, ...
        'streamlinebranchsize', 20, ...
        'drawgradients', false, ...
        'drawgradients2', false, ...
        'drawgradients3', false, ...
        'scalegradients', false, ...
        'crossgradients', false, ...
        'unitgradients', false, ...
        'surfacedecor', true, ...  % For 3d meshes, whether decorations such as gradient arrows should be drawn on the surface.
        'surfacedecormaxangle', Inf, ...  % For 3d meshes, the maximum angle that decorations drawn on the surface are allowed to make with the surface.
        'volumedecor', true, ...  % For 3d meshes, whether decorations such as gradient arrows should be drawn throughout the volume.
        'multibrighten', 0.1, ...
        ... % 'monochrome', true, ...
        'drawcolorbar', true, ...
        'monocolors', [], ...
        'canvascolor', [1 1 1], ...
        'cmap', [], ...
        'crange', [], ...
        'zerowhite', true, ...
        'cmaptype', 'monochrome', ...
        'cmapsteps', 100, ...
        'sparsedistance', 0, ...
        'staticdecor', true, ...
        'axisRange', [], ...
        'axisVisible', 1, ...
        'alpha', 0.8, ...
        'ambientstrength', 0.8, ...
        'azimuth', -45, ...
        'elevation', 33.75, ...
        'roll', 0, ...
        'ourViewParams', gOurViewParams, ...
        'matlabViewParams', gMatlabViewParams, ...
        'autozoom', false, ...
        'autocentre', false, ...
        'autoScale', true, ...
        'autoColorRange', true, ...
        'falsecolorscaling', 1, ...
        'drawcontours', false, ...
        'contourdata', [], ...
        'contournumber', 20, ...
        'contourlevels', [], ...
        'contourcolor', [], ...
        'contourthickness', 2, ...
        'colorscale', [], ...
        'layeroffset', 0.0, ...
        'normaloffset', 0.0, ...
        'gradientoffset', 0.25, ...
        'tensoroffset', 0.25, ...
        'contouroffset', 1.2, ...
        'FEthicklinesize', 2, ...
        'FEthinlinesize', 1, ...
        'FElargevertexsize', 0, ...
        'FEsmallvertexsize', 0, ...
        'FElinecolor', [0 0 0], ...
        'seamlinesize', 5, ...
        'seamlinecolor', [1 0 0], ...
        'bioAlinesize', 1, ...
        'bioAnewlinesize', 1, ...
        'bioAlinecolor', [0.2 0.2 0.2], ...
        'bioAnewlinecolor', [0.2 0.2 0.2], ...
        'bioApointsize', 3, ...
        'bioApointcolor', [0.2 0.2 0.2], ...
        'bioAnewpointcolor', [0.2 0.2 0.2], ...
        'bioAalpha', 1, ...
        'bioAemptyalpha', [], ...
        'drawcellaniso', false, ...
        'cellanisothreshold', 0, ...
        'cellanisoratio', 0.8, ...
        'cellanisoproportional', false, ...
        'cellanisocolor', 'r', ...
        'cellanisowidth', 1, ...
        'cellspacecolor', [1 0 0], ...
        'axescolor', [0 0 0.3], ...
        'decorateAside', false, ... % Whether to draw FE edges more thickly on the A side or the B side.
        'sidetensor', 'AB', ... % Which side of the mesh to draw tensors on.
        'sidegrad', 'AB', ... % Which side of the mesh to draw the polariser gradient on.
        'sidebio', 'AB', ... % Which side of the mesh to draw bio cells on.
        'sidenormal', 'AB', ... % Which side of the mesh to draw vertex normals on.
        'drawnormals', false, ...
        'drawmutant', true, ...
        'drawdisplacements', false, ...
        'drawlegend', true, ...
        'drawscalebar', true, ...
        'thick', true, ...
        'nodenumbering', false, ...
        'nodenumbercolor', [1 0 0], ...
        'edgenumbering', false, ...
        'edgenumbercolor', [0 0.4 0.1], ...
        'FEnumbering', false, ...
        'FEnumbercolor', [0 0 0.4], ...
        'texture', 0, ...
        'bgcolor', [1 1 1], ...
        'emptycolor', [0.7, 0.8, 1], ...
        'clippingAzimuth', 0, ...
        'clippingElevation', 0, ...
        'clippingDistance', -0.01, ...
        'clippingThickness', Inf, ...
        'clipbymgen', false, ...
        'clipmgens', [], ...
        'clipmgenthreshold', 0, ...
        'clipmgenabove', true, ...
        'clipmgenall', true, ...
        'doclipbio', [], ...
        'doclip', false, ...
        'uicontrols', true, ...
        'light', false, ...
        'lightmode', 'gouraud', ...
        'invisibleplot', false, ...
        'decorscale', 1, ...
        'highlightthickness', 3, ...
        'arrowthickness', 2, ...
        'crossthickness', 1, ...
        'arrowheadsize', 0.5, ...
        'arrowheadratio', 0.3, ...
        'highgradcolor', [0 0 0.3], ...
        'lowgradcolor', [0 0 0.7], ...
        'highgradcolor2', [0.5 0 0], ...
        'lowgradcolor2', [1 0 0], ...
        'highgradcolor3', [0 0.5 0], ...
        'lowgradcolor3', [0 1 0], ...
        'drawrotations', false, ...
        'colorbarinimages', true, ...
        'stereoimages', false, ...
        'hiressnaps', false, ...
        'hiresstages', false, ...
        'hiresmovies', false, ...
        'hiresmagnification', 2, ...
        'hiresantialias', false, ...
        'mgenownsideonly', 'true', ...
        'taper', 'true', ...
        'anisotropythreshold', 0, ...
        'linesmoothing', 'on', ...
        'scalebarpos', [0 0], ...  % proportion of picture size
        'scalebarheight', 20, ...  % pixels
        'enableplot', true, ...
        'allowsnaps', true, ...
        'drawsecondlayer', true, ...
        'cellsonbothsides', true, ...
        'defaultmultiplotcells', [], ...
        'drawvvlayer', true, ...
        'cellbodyvalue', '', ...
        'celledgevalue', '', ...
        'cellvxvalue', '', ...
        'userpreplotproc', [], ...
        'userplotproc', [] );
end
