function updateGUIFromMesh( h )
%h = updateGUIFromMesh( h )
%   Updates every GUI element that displays a property of the mesh, to be
%   consistent with h.mesh.  When h.mesh is empty, it clears all settings
%   to their defaults.
%
%   If h is a mesh then h will be set to guidata(m.pictures(1)).
%   m.pictures(1) is assumed to be a GFtbox window.
%
%   If it does not recognise what h is, it will do nothing.

    setGlobals();
    global gGlobalProps gGlobalDynamicProps gDefaultPlotOptions
    
    if ishandle(h)
        try
            h = guidata(h);
        catch e %#ok<NASGU>
            return;
        end
    end
    if ~isstruct(h)
        return;
    end
    if hasPicture( h )
        % h is a mesh structure.  Find the figure handle and get its
        % guidata.
        if isempty( h.pictures )
            return;
        end
        m = h;
        f = m.pictures(1);
        if ~ishandle( f )
            return;
        end
        h = guidata(f);
    elseif isfield( h, 'mesh' ) && isfield( h, 'displayedGrowthMenu' );
        % The existence of these two fields is our test for whether h is
        % the guidata of a GFtbox window.
        m = h.mesh;
    else
        return;
    end
    if ~isfield( h, 'mesh' )
        % Not called from within GFtbox.  GUI assumed not present.
        % Check for a legend.
        if hashandle( h, 'legend' )
            setMyLegend( m );
        end
        return;
    end
    if isempty( m )
        gprops = gGlobalProps;
        gdprops = gGlobalDynamicProps;
        plotdefaults = gDefaultPlotOptions;
    else
        gprops = m.globalProps;
        gdprops = m.globalDynamicProps;
        plotdefaults = m.plotdefaults;
        h.mesh = m;
    end
    
    if isfield( h, 'bioAsplitTypeSelect' )
        if gprops.bioAsplitcells
            set( h.bioAsplitTypeSelect, 'SelectedObject', h.bioAsplitCellsButton );
        else
            set( h.bioAsplitTypeSelect, 'SelectedObject', h.bioAsplitEdgesButton );
        end
    end

    setDisplayedGrowthMenuStrings( h );
    setMeshFigureTitle( h.output, m );
    selectedMgen = FindMorphogenIndex( m, gprops.displayedGrowth );
    if isempty(selectedMgen)
        selectedMgen = 1;
    else
        selectedMgen = selectedMgen(1);
    end
    selectMgenInMenu( h, selectedMgen );
    
    setCellMgenMenuFromMesh( h );
    
    if isempty(m)
        set( h.inputSelectButton, 'Value', 1 );
        set( h.outputSelectButton, 'Value', 0 );
        set( h.showTensorAxes, 'Value', 0 );
    else
        if ~isempty( m.plotdefaults.morphogen )
            set( h.inputSelectButton, 'Value', 1 );
            set( h.outputSelectButton, 'Value', 0 );
        elseif ~isempty( m.plotdefaults.outputquantity )
            set( h.inputSelectButton, 'Value', 0 );
            set( h.outputSelectButton, 'Value', 1 );
        else
            set( h.inputSelectButton, 'Value', 0 );
            set( h.outputSelectButton, 'Value', 0 );
        end
        set( h.showTensorAxes, 'Value', m.plotdefaults.drawtensoraxes );
    end

    setGUIMgenInfo( h, m );
    
    if isempty( m )
        set( h.allowDilution, 'Value', false );
    else
        set( h.allowDilution, 'Value', m.mgen_dilution(selectedMgen) );
    end

    setCheckboxesFromMesh( h, { ...
        'alwaysFlat', ...
        'twoD', ...
        'useGrowthTensors', ...
        'allowNegativeGrowth', ...
        'usefrozengradient', ...
        'allowFlipEdges', ...
        'diffusionEnabled', ...
        'allowSplitLongFEM', ...
        'allowSplitBentFEM', ...
        'allowSplitBio', ...
        'useGrowthTensors' } );
    normTolMethod = strcmp( gGlobalProps.solvertolerancemethod, 'norm' ); % WHY gGlobalProps AND NOT gprops?
    
    checkMenuItem( h.autonameItem, gprops.autonamemovie );
    checkMenuItem( h.normErrorItem, normTolMethod );
    checkMenuItem( h.maxabsErrorItem, ~normTolMethod );
    checkMenuItem( h.enabledisableIFitem, gprops.allowInteraction );
    setVisibility( h.enableIFtext, ~gprops.allowInteraction );
    checkMenuItem( h.useprevdispItem, gprops.usePrevDispAsEstimate );
    checkMenuItem( h.allowSparseItem, gprops.allowsparse );
    checkMenuItem( h.alwaysRectifyVerticalsItem, gprops.rectifyverticals );
    checkMenuItem( h.recordAllStagesItem, gprops.recordAllStages );

    checkMenuItem( h.staticReadOnlyItem, gdprops.staticreadonly );
    
    if strcmp( gprops.solverprecision, 'single' )
        selectMenuChoice( h.singlePrecisionItem );
    else
        selectMenuChoice( h.doublePrecisionItem );
    end
    switch gprops.solver
        case 'cgs'
            selectMenuChoice( h.cgsSolverItem );
        case 'lsqr'
            selectMenuChoice( h.lsqrSolverItem );
        case 'culaSgesv'
            selectMenuChoice( h.culaSgesvSolverItem );
        otherwise
            fprintf( 1, 'Warning: unrecognised solver "%s".\n', gprops.solver );
            selectMenuChoice( h.cgsSolverItem );
    end
    set( h.allowRetriangulate, 'Value', gprops.allowElideEdges );
    set( h.growthEnabled, 'Value', gprops.growthEnabled && ~gprops.plasticGrowth && ~gprops.springyGrowth );
    set( h.plasticGrowthEnabled, 'Value', gprops.growthEnabled && gprops.plasticGrowth );
    set( h.springyGrowthEnabled, 'Value', gprops.growthEnabled && gprops.springyGrowth );
    setTextAndSlider( h.freezetext, gdprops.freezing );
    switch gprops.thicknessMode
        case 'physical'
            set( h.physicalRadioButton, 'Value', 1 );
        case 'direct'
            set( h.directRadioButton, 'Value', 1 );
    end
    setDoubleInTextItem( h.poissonsRatio, gprops.poissonsRatio );
    setDoubleInTextItem( h.maxFEtext, gprops.maxFEcells );
    setDoubleInTextItem( h.maxBendtext, gprops.bendsplit );
    setDoubleInTextItem( h.edgesplitscaletext, gprops.longSplitThresholdPower );
    setDoubleInTextItem( h.splitmargintext, gprops.splitmargin );
    setDoubleInTextItem( h.minpolgradText, gprops.mingradient );
    set( h.relativepolgrad, 'Value', gprops.relativepolgrad );
    setDoubleInTextItem( h.solvertolerance, gprops.solvertolerance );
    setDoubleInTextItem( h.diffusionToleranceText, gprops.diffusiontolerance );
    setDoubleInTextItem( h.maxsolvetime, gprops.maxsolvetime );
    setDoubleInTextItem( h.maxBioAtext, gprops.maxBioAcells );
    setDoubleInTextItem( h.timestep, gprops.timestep );
    setDoubleInTextItem( h.totalCellsText, gprops.inittotalcells );
    
    set( h.azimuth, 'Value', ...
        normaliseAngle( -plotdefaults.ourViewParams.azimuth, -180, true ) );
    set( h.elevation, 'Value', ...
        normaliseAngle( -plotdefaults.ourViewParams.elevation, -180, true ) );
    set( h.roll, 'Value', ...
        normaliseAngle( -plotdefaults.ourViewParams.roll, -180, true ) );

    checkMenuItem( h.lineSmoothingItem, strcmp( plotdefaults.linesmoothing, 'on' ) );
    checkMenuItem( h.autozoomItem, plotdefaults.autozoom );
    checkMenuItem( h.autocentreItem, plotdefaults.autocentre );
    checkMenuItem( h.autozoomcentreItem, plotdefaults.autozoom & plotdefaults.autocentre );
    checkMenuItem( h.cellsonbothsidesItem, plotdefaults.cellsonbothsides );
    checkMenuItem( h.staticDecorItem, plotdefaults.staticdecor );
    set( h.opacityItem, 'UserData', struct( 'currentvalue', plotdefaults.alpha )  );
    set( h.ambientItem, 'UserData', struct( 'currentvalue', plotdefaults.ambientstrength )  );
    
    set( h.enablePlotCheckbox, 'Value', plotdefaults.enableplot );
    set( h.showNoEdgesRadioButton, 'Value', plotdefaults.drawedges==0 );
    set( h.showSomeEdgesRadioButton, 'Value', plotdefaults.drawedges==1 );
    set( h.showAllEdgesRadioButton, 'Value', plotdefaults.drawedges==2 );
    set( h.showPolariser, 'Value', plotdefaults.drawgradients );
    set( h.showPolariser2, 'Value', plotdefaults.drawgradients2 );
    set( h.showPolariser3, 'Value', plotdefaults.drawgradients3 );
    set( h.showSecondLayer, 'Value', plotdefaults.drawsecondlayer );
    set( h.asideRButton, 'Value', plotdefaults.decorateAside );
    set( h.bsideRButton, 'Value', 1 - plotdefaults.decorateAside );
    setDoubleInTextItem( h.sparsityText, plotdefaults.sparsedistance );
    setDoubleInTextItem( h.multiBrightenText, plotdefaults.multibrighten );
    set( h.drawmulticolor, 'Value', false );
    if isempty( plotdefaults.autoScale )
        plotdefaults.autoScale = true;
    end
    set( h.autoScale, 'Value', plotdefaults.autoScale );
    set( h.autoColorRange, 'Value', plotdefaults.autoColorRange );
    switch plotdefaults.cmaptype
        case 'monochrome'
            if plotdefaults.zerowhite
                setMenuSelectedLabel( h.colorScalePopupMenu, 'Split Mono' );
            else
                setMenuSelectedLabel( h.colorScalePopupMenu, 'Monochrome' );
            end
        case 'rainbow'
            if plotdefaults.zerowhite
                setMenuSelectedLabel( h.colorScalePopupMenu, 'Split Rainbow' );
            else
                setMenuSelectedLabel( h.colorScalePopupMenu, 'Rainbow' );
            end
        otherwise
    end
    set( h.clipCheckbox, 'Value', plotdefaults.doclip );
    set( h.clipbymgenCheckbox, 'Value', plotdefaults.clipbymgen );
    setDoubleInTextItem( h.azclipText, plotdefaults.clippingAzimuth );
    setDoubleInTextItem( h.elclipText, plotdefaults.clippingElevation );
    setDoubleInTextItem( h.dclipText, plotdefaults.clippingDistance );
    setDoubleInTextItem( h.tclipText, plotdefaults.clippingThickness );
    setShowHideMenuItem( h.axesMenuItem, plotdefaults.axisVisible );
    setShowHideMenuItem( h.displacementsMenuItem, plotdefaults.drawdisplacements );
    
    isblack = sum(plotdefaults.bgcolor)/3 < 0.5;
    if isblack
        setGUIPlotBackground( h, [0 0 0] );
    else
        setGUIPlotBackground( h, [1 1 1] );
    end
    checkMenuItem( h.blackMenuItem, isblack );
    checkMenuItem( h.whiteMenuItem, ~isblack );
    
    set( h.cellColorIndicator1, 'BackgroundColor', gprops.colors(1,:) );
    if size(gprops.colors,1)<2
        set( h.cellColorIndicator2, 'BackgroundColor', gprops.colors(1,:) );
    else
        set( h.cellColorIndicator2, 'BackgroundColor', gprops.colors(2,:) );
    end
    setDoubleInTextItem( h.colorVariationText, gprops.colorvariation );
    
    if isempty( m )
        set( h.allWildcheckbox, 'Value', false );
    else
        set( h.allWildcheckbox, 'Value', ~m.allMutantEnabled );
    end
    manageMutantControls( h );

    setShowHideMenuItem( h.normalsMenuItem, plotdefaults.drawnormals );
    setShowHideMenuItem( h.showmeshMenuItem, plotdefaults.drawleaf );
    setShowHideMenuItem( h.vvMenuItem, plotdefaults.drawvvlayer );
    setShowHideMenuItem( h.thicknessMenuItem, plotdefaults.thick );
    setShowHideMenuItem( h.seamsMenuItem, plotdefaults.drawseams );
    setShowHideMenuItem( h.nodeNumbersItem, plotdefaults.nodenumbering );
    setShowHideMenuItem( h.edgeNumbersItem, plotdefaults.edgenumbering );
    setShowHideMenuItem( h.FENumbersItem, plotdefaults.FEnumbering );
    setShowHideMenuItem( h.colorbarMenuItem, plotdefaults.drawcolorbar );
    if plotdefaults.light
        set( h.lightMenuItem, 'Label', 'Turn Light Off' );
    else
        set( h.lightMenuItem, 'Label', 'Turn Light On' );
    end
    % Light mode does not work.
    %{
    c = get( h.lightmodeMenu, 'Children' );
    for i=1:length(c)
        checkMenuItem( c(i), strcmpi( plotdefaults.lightmode, get( c(i), 'Label' ) ) );
    end
    %}

    if length(plotdefaults.crange) >= 2
        setDoubleInTextItem( h.autoColorRangeMintext, plotdefaults.crange(1) );
        setDoubleInTextItem( h.autoColorRangeMaxtext, plotdefaults.crange(2) );
        if length(plotdefaults.crange) >= 3
            setDoubleInTextItem( h.autoColorRangeMidtext, plotdefaults.crange(3) );
        else
            set( h.autoColorRangeMidtext, 'String', '' );
        end
    else
        setDoubleInTextItem( h.autoColorRangeMintext, 0 );
        setDoubleInTextItem( h.autoColorRangeMaxtext, 0 );
        set( h.autoColorRangeMidtext, 'String', '' );
    end
    announceSimStatus( h, m );
    
    % Set interaction name.
    if gprops.mgen_interactionName
        set( h.mgenInteractionName, 'String', gprops.mgen_interactionName );
    else
        set( h.mgenInteractionName, 'String', '(none)' );
    end
    
    % Set mesh parameters.
    if ~isempty( m )
        setMeshParams( h, m.meshparams );
    end
    guidata( h.GFTwindow, h );
    
    cellfactorUpdater( h.GFTwindow );
end
