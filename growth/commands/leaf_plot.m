function varargout = leaf_plot( m, varargin )
%m = leaf_plot( m, ... )
%   Plot the leaf.
%   There are many options.
%
%   leaf_plot stores all of the plotting options in the mesh, so that a
%   subsequent call to leaf_plot with only the mesh as an argument will
%   plot the same thing.
%
%   One option is not stored in the mesh: 'figure'.  The argument to this
%   is a figure handle or a positive integer (for which a figure will be
%   created).  The mesh will be plotted in that figure without affecting
%   its binding to any other figures.
%
%   Equivalent GUI operation: The leaf is plotted automatically, and a
%   replot can be forced by the Plot>Replot menu command.
%   Various options may be set in the "Plot options" panel, and the scroll
%   bars on the picture change the orientation.
%
%   See also: leaf_plotoptions.
%
%   Topics: Plotting.

    % Sanity check.
    if isempty(m)
        if nargout >= 1, varargout{1} = []; end
        return;
    end
    
    s = safemakestruct( mfilename(), varargin );
    
%     if isfield( s, 'enableplot' ) && ~s.enableplot
%         % Master switch for disabling all plotting.
%         if nargout >= 1
%             varargout{1} = m;
%         end
%         return;
%     end

    % Discard invalid handles.
    if isfield( m, 'pictures' ) && ~isempty( m.pictures )
        m.pictures = m.pictures( ishghandle( m.pictures ) );
    end
    hnames = fieldnames( m.plothandles );
    for i=1:length(hnames)
        m.plothandles.(hnames{i}) = gobjects(0);
    end
    
    externalFigure = false;
    if isfield( s, 'figure' ) && ~isempty( s.figure )
        % s specifies a figure.  We must use that figure.
        % If m.pictures is empty, install the figure's axes into m.
        goodFigure = ishghandle(s.figure) && strcmp( get( s.figure, 'Type' ), 'figure' );
        if ~goodFigure
            goodFigure = isnumeric(s.figure) && (numel(s.figure)==1) && (s.figure > 0) && (s.figure==round(s.figure));
        end
        if ~goodFigure
            fprintf( 1, '%s: Bad ''figure'' argument supplied. If supplied, it must be a figure handle or a positive integer.\n', mfilename() );
            if nargout >= 1, varargout{1} = m; end
            return;
        end
        if goodFigure && ~ishghandle(s.figure)
            theaxes = makeCanvasPicture( mfilename(), 'figure', s.figure );
        else
            theaxes = [];
        end
        externalFigure = true;
        theaxes = [];
        theFigure = s.figure;
        pichandles = guidata( theFigure );
        s = rmfield( s, 'figure' );
    elseif isfield( m, 'pictures') && ~isempty( m.pictures )
        % s does not specify a figure, and m does.
        theaxes = m.pictures(1);
        theFigure = ancestor( theaxes, 'figure' );
        pichandles = guidata( theFigure );
    else
        % Neither s nor m specifies a figure.
        theFigure = [];
        pichandles = [];
        theaxes = [];
    end
    
    [m,plotinfo,~] = leaf_plotoptions( m, s );
    if isfield( m.plotdefaults, 'enableplot' ) && ~m.plotdefaults.enableplot
        % Master switch for disabling all plotting.
        if ~isempty(theaxes)
            cla( theaxes );
        end
        if nargout >= 1, varargout{1} = m; end
        return;
    end
    s = m.plotdefaults;
    
    if isempty(theFigure)
        % If there is no picture handle, and plotting is enabled, make one.
        v = struct( 'Visible', boolchar( s.invisibleplot, 'off', 'on' ) );
        m = leaf_addpicture( m, ...
                'properties', v, ...
                'uicontrols', s.uicontrols );
        theaxes = m.pictures(1);
        theFigure = ancestor( theaxes, 'figure' );
        pichandles = guidata( theFigure );
        isNewFigure = true;
    else
        % figure(theFigure);
        isNewFigure = ~isfield( pichandles, 'picture' );
        if isNewFigure
            theaxes = makeCanvasPicture( '', 'figure', theFigure );
            pichandles = guidata( theFigure );
        else
            theaxes = pichandles.picture;
        end
        if isempty( m.pictures )
            m.pictures = theaxes;
        end
    end
    if isNewFigure
        if m.plotdefaults.autoScale % isempty( m.plotdefaults.axisRange )
            m.plotdefaults.axisRange = meshbbox( m, true, 0.05 );
        end
        setaxis( pichandles.picture, m.plotdefaults.axisRange );
        setViewFromMesh( m );
    end
    cla( theaxes );
    if hasNonemptySecondLayer(m)
        areafactor = FindCellRole( m, 'CELL_AREA' );
        if areafactor ~= 0
            m.secondlayer.cellvalues(:,areafactor) = m.secondlayer.cellarea;
        end
    end
    if m.globalProps.newcallbacks
        m = invokeIFcallback( m, 'Preplot', theaxes );
    elseif isa( s.userpreplotproc, 'function_handle' )
        fprintf( 1, 'Calling user pre-plotting procedure %s.\n', ...
            char( s.userpreplotproc ) );
        m = s.userpreplotproc( m, theaxes );
    end
    
    hold( theaxes, 'on' );
    if m.plotdefaults.light
        lightAxes( theaxes, true );
    end

    full3d = usesNewFEs(m);

    % We only have a colour bar when we are plotting a single quantity.
    % This is the case if all of the following hold:
    % (i) cmaptype is nonempty.
    % (ii) The colorbar object exists.
    % (iii) We are plotting exactly one scalar value -- that is, we are not
    % plotting different things on both sides or multiple morphogens, and
    % we are plotting something.
    % (iv) s.drawcolorbar is true.
    wantColorBar = true;
    % The colorbar has already been made visible or invisible according to
    % s.drawcolorbar.  The purpose of wantColorBar is to record whether the
    % colorbar, if visible, should have colours drawn in it or be blank.
    if isempty( s.cmaptype )
        % No colour map ==> blank colorbar.
        wantColorBar = false;
    end
    if plotinfo.haveAplot && plotinfo.haveBplot
        % Plotting something separately on each side ==> blank colorbar.
        wantColorBar = false;
    end
    havemultipleplot = iscell(s.morphogen) && (numel( s.morphogen ) > 1);
    havemultipleAplot = iscell(s.morphogenA) && (numel( s.morphogenA ) > 1);
    havemultipleBplot = iscell(s.morphogenB) && (numel( s.morphogenB ) > 1);
    if havemultipleplot || havemultipleAplot || havemultipleBplot
        % Plotting multiple morphogens ==> blank colorbar.
        wantColorBar = false;
    end

    % Calculate the data to be plotted as colours.
    m.plotdata = struct();
    m = calculatePlotData( m, '' );
    m = calculatePlotData( m, 'A' );
    m = calculatePlotData( m, 'B' );
    numscalars = 0;
    for fnc = { '', 'A', 'B' }
        fn_value = ['value' fnc{1}];
        fn_mgen = ['morphogen' fnc{1}];
        fn_output = ['outputquantity' fnc{1}];
        if isfield( m.plotdata, fn_value ) && ~isempty( m.plotdata.(fn_value) ) && (size( m.plotdata.(fn_value), 2 )==1)
            numscalars = numscalars+1;
            if s.autoColorRange || isempty( s.crange ) || (s.crange(1) >= s.crange(2))
                locolor = min(m.plotdata.(fn_value));
                hicolor = max(m.plotdata.(fn_value));
                crange = [ locolor, hicolor ];
            else
                crange = s.crange;
            end
            if s.autoColorRange && (s.falsecolorscaling ~= 1)
                crange = syntheticRange( crange, s.falsecolorscaling );
            end
            monocolors = []; % [1 0 0];
            if strcmp( s.cmaptype, 'monochrome' )
                if ~isempty( s.monocolors )
                    monocolors = s.monocolors;
                elseif ~isempty( s.(fn_mgen) )
                    mgens = FindMorphogenIndex( m, s.(fn_mgen) );
                    if length(mgens)==1
                        monocolors = [ m.mgennegcolors( :, mgens )'; ...
                                       m.mgenposcolors( :, mgens )' ];
                    end
                elseif ~isempty( s.(fn_output) )
                    o = regexprep( s.(fn_output), 'actual', 'resultant' );  % Hack.
                    o = regexprep( o, 'rate(A|B)?$', '' );
                    monocolors = m.outputcolors.(o);
                else
                    monocolors = [0 0 1; 1 0 0];
                end
                if size( monocolors, 1 )==3
                    monocolors = monocolors';
                end
                if size( monocolors, 1 )==1
                    monocolors = [ oppositeColor( monocolors ); monocolors ]; %#ok<AGROW>
                end
            end
            if strcmp( s.cmaptype, 'custom' )
                s.crange = crange;
            else
                [s.cmap,s.crange] = chooseColorMap( s.cmaptype, crange, monocolors, s.zerowhite, s.cmapsteps );
            end
            m.plotdefaults.cmap = s.cmap;
            m.plotdefaults.crange = s.crange;
            m.plotdata.(fn_value) = translateToColors( m.plotdata.(fn_value), s.crange, s.cmap );
        end
    end
    if numscalars ~= 1
        wantColorBar = false;
    end
    if wantColorBar
        if s.crange(1) >= s.crange(2)
            s.crange = extendToZero( s.crange );
        end
        colormap( pichandles.picture, s.cmap );
        caxis( pichandles.picture, s.crange([1 2]) );
    end

    commonpatchargs = { 'Parent', theaxes, ...
                        'FaceLighting', s.lightmode, ...
                        'AmbientStrength', s.ambientstrength, ...
                        'FaceAlpha', s.alpha, ...
                        'EdgeAlpha', s.alpha, ...
                        'EdgeColor', s.FElinecolor };
%                       'LineSmoothing', m.plotdefaults.linesmoothing };  % LineSmoothing is deprecated.
    m = findVisiblePart( m );
    
    % Draw the mesh
    if s.drawleaf
        if full3d
            if ~isfield( m.plotdata, 'pervertex' )
                [m,h,g] = plot3dmesh( m, theaxes );
            elseif m.plotdata.pervertex
                [m,h,g] = plot3dmesh( m, theaxes, m.plotdata.value );
            else
                [m,h,g] = plot3dmesh( m, theaxes, [], m.plotdata.value );
            end
            for hi=1:length(h)
                h(hi).Tag = sprintf( 'mesh%02d', hi );
            end
            m.plothandles.mesh = h;
            xxxx = 1;
        else
            visnodeindexes = find(m.visible.nodes);
            renumberNodes = zeros( size(m.nodes,1), 1 );
            renumberNodes(visnodeindexes) = (1:length(visnodeindexes))';

            vistriangles = m.tricellvxs( m.visible.cells, : );
            if size(vistriangles,1)==1
                vistriangles = renumberNodes(vistriangles)';
            else
                vistriangles = renumberNodes(vistriangles);
            end

            if ~isempty(vistriangles)
                viscellindexes = find(m.visible.cells);
                if ~s.thick
                    % Mid-plane
                    if s.drawedges < 2
                        thickness = 0;
                        pointsize = 0;
                    else
                        thickness = m.plotdefaults.FEthinlinesize;
                        pointsize = m.plotdefaults.FEsmallvertexsize;
                    end
                    suffix = '';
                    for fnc = { '', 'A', 'B' }
                        fn_value = ['value' fnc{1}];
                        if isfield( m.plotdata, fn_value ) && ~isempty( m.plotdata.(fn_value) )
                            suffix = fnc{1};
                            break;
                        end
                    end
                    vxs = m.nodes( m.visible.nodes, : );
                    m = makeCanvasColor( m, '' );
                    visdata = m.plotdata.(['value' suffix]);
                    if m.plotdata.(['pervertex' suffix])
                        visdata = visdata( m.visible.nodes==1, : );
                    else
                        visdata = visdata( m.visible.cells==1, : );
                    end
                    m.plothandles.patchM = plotmeshsurface( [], theaxes, s, vxs, vistriangles, ...
                            visdata, ... % m.plotdata.(['value' suffix]), ...
                            m.plotdata.(['pervertex' suffix]), ...
                            thickness, pointsize, commonpatchargs, ...
                            struct( 'faces', viscellindexes, 'type', 'patchM', 'ButtonDownFcn', @doMeshClick ) );
                    m.plothandles.patchM.Tag = 'patchM';
                    if s.drawedges==1
                        % Draw border edges.
                        m = plotedges( m, theaxes, '', ...
                            m.visible.borderedges, ...
                            m.plotdefaults.FEthinlinesize, ...
                            m.plotdefaults.FElinecolor, ...
                            'rimEdges' );
                    end
                    if s.drawseams
                        m = plotHighlightedEdges( m );
                    end
                else
                    if s.drawedges < 2
                        thicknessA = 0;
                        thicknessB = 0;
                        pointsizeA = 0;
                        pointsizeB = 0;
                    elseif s.decorateAside % m.globalProps.dorsaltop
                        thicknessA = m.plotdefaults.FEthicklinesize;
                        thicknessB = m.plotdefaults.FEthinlinesize;
                        pointsizeA = m.plotdefaults.FElargevertexsize;
                        pointsizeB = m.plotdefaults.FEsmallvertexsize;
                    else
                        thicknessA = m.plotdefaults.FEthinlinesize;
                        thicknessB = m.plotdefaults.FEthicklinesize;
                        pointsizeA = m.plotdefaults.FEsmallvertexsize;
                        pointsizeB = m.plotdefaults.FElargevertexsize;
                    end
                    if isfield( m.plotdata, 'valueA' ) && ~isempty( m.plotdata.valueA )
                        Asuffix = 'A';
                    else
                        Asuffix = '';
                    end
                    if isfield( m.plotdata, 'valueB' ) && ~isempty( m.plotdata.valueB )
                        Bsuffix = 'B';
                    else
                        Bsuffix = '';
                    end
                    if ~isfield( m.plotdata, ['value' Asuffix] )
                        m = makeCanvasColor( m, 'A' );
                        Asuffix = 'A';
                    end
                    if ~isfield( m.plotdata, ['value' Bsuffix] )
                        m = makeCanvasColor( m, 'B' );
                        Bsuffix = 'B';
                    end
                    visprismindexes = visnodeindexes*2;

                    % B side
                    % vxs = m.prismnodes( visprismindexes, : );
                    vxs = m.prismnodes( visprismindexes, : );
                    visdata = m.plotdata.(['value' Bsuffix]);
                    if m.plotdata.(['pervertex' Bsuffix])
                        visdata = visdata( m.visible.nodes==1, : );
                    else
                        visdata = visdata( m.visible.cells==1, : );
                    end
                    m.plothandles.patchB = plotmeshsurface( [], theaxes, s, vxs, vistriangles, ...
                            visdata, ... % m.plotdata.(['value' Bsuffix]), ...
                            m.plotdata.(['pervertex' Bsuffix]), ...
                            thicknessB, pointsizeB, commonpatchargs, ...
                            struct( 'faces', viscellindexes, 'type', 'patchB', 'ButtonDownFcn', @doMeshClick ) );
                    m.plothandles.patchB.Tag = 'patchB';
                    % A side
                    % vxs = m.prismnodes( visprismindexes-1, : );
                    vxs = m.prismnodes( visprismindexes-1, : );
                    visdata = m.plotdata.(['value' Asuffix]);
                    if m.plotdata.(['pervertex' Asuffix])
                        visdata = visdata( m.visible.nodes==1, : );
                    else
                        visdata = visdata( m.visible.cells==1, : );
                    end
                    m.plothandles.patchA = plotmeshsurface( [], theaxes, s, vxs, vistriangles, ...
                            visdata, ... % m.plotdata.(['value' Asuffix]), ...
                            m.plotdata.(['pervertex' Asuffix]), ...
                            thicknessA, pointsizeA, commonpatchargs, ...
                            struct( 'faces', viscellindexes, 'type', 'patchA', 'ButtonDownFcn', @doMeshClick ) );
                    m.plothandles.patchA.Tag = 'patchA';
                    % Borders
                    m = plotborder( m, theaxes, s );

                    % Seams
                    if s.drawseams
                        m = plotHighlightedEdges( m );
                    end
                end
                m = plotHighlightedVertexes( m, theaxes );
            end
        end
    end
    
    
    % 2015-02-15  UPDATING FOR 3D MESHES IN PROGRESS HERE.
    
    % Normal vectors.
    % Gradient vectors.
    % Tensor axes.
    sparsedistance = 0;
    if s.drawnormals || s.drawgradients || s.drawgradients2 || s.drawgradients3 || s.drawtensoraxes || s.drawtensorcircles || s.drawrotations || s.drawdisplacements
        if full3d
            diam = max( max(m.FEnodes,[],2) - min(m.FEnodes,[],2) );
        else
            diam = max( max(m.nodes,[],2) - min(m.nodes,[],2) );
        end
        sparsedistance = m.plotdefaults.sparsedistance*diam;
        if sparsedistance > 0
            decorscale = m.plotdefaults.decorscale * sparsedistance;
        else
            decorscale = m.plotdefaults.decorscale * m.globalDynamicProps.cellscale;
        end
    end
    if s.drawnormals || s.drawgradients || s.drawgradients2 || s.drawgradients3 || s.drawtensoraxes || s.drawtensorcircles || s.drawrotations
        if ~full3d
            semithicknessvectors = 0.5*(m.prismnodes(2:2:end,:) - m.prismnodes(1:2:end,:));
        end
        elcentres = elementCentres( m, [], 0 );
        cropped = false;
        if sparsedistance > 0
            if full3d
                if m.plotdefaults.volumedecor
                    [selcc,selbc,decorptsmid] = ...
                        randPointsInVolume( m.FEnodes, ...
                            m.FEsets.fevxs(m.visible.elements,:), abs(m.FEsets.fevolumes(m.visible.elements)), sparsedistance, ...
                            m.decorFEs(:), m.decorBCs );
                    viselementmap = find( m.visible.elements );
                    selcc = viselementmap( selcc );
                else
                    selcc = [];
                    selbc = [];
                    decorptsmid = [];
                end
                if m.plotdefaults.surfacedecor
                    [selccSurf,selbcSurf,decorptsmidSurf] = ...
                        randPointsOnSurface( m.FEnodes, ...
                            m.FEconnectivity.faces( m.visible.surffaces, : ), [], sparsedistance, ...
                            [], [], [], [] );
                    surfvisfacemap = find( m.visible.surffaces );
                    selFaces = surfvisfacemap( selccSurf );
                    selccSurf = m.FEconnectivity.facefes( selFaces, : )';
                    visSurfaceFEs = selccSurf > 0;
                    visSurfaceFEs( visSurfaceFEs ) = m.visible.elements( selccSurf( visSurfaceFEs ) );
                    selccSurf = selccSurf( visSurfaceFEs );
                else
                    selccSurf = [];
                    selFaces = [];
                    selbcSurf = [];
                    decorptsmidSurf = [];
                end
                cropped = true;
            else
                selFaces = [];
                bordernodeindexes = unique( m.edgeends( m.edgecells(:,2)==0, : ) );
                bordernodes = m.nodes(bordernodeindexes,:);
                borderdistance = decorscale/2.4; %sparsedistance/2;
                if ~m.plotdefaults.staticdecor
                    m.decorFEs = [];
                    m.decorBCs = [];
                end
                [selcc,selbc,decorptsmid] = ...
                    randPointsOnSurface( m.nodes, ...
                        m.tricellvxs, m.cellareas, sparsedistance, ...
                        m.decorFEs(:), m.decorBCs, bordernodes, borderdistance );
                if m.plotdefaults.staticdecor
                    m.decorFEs = selcc;
                    m.decorBCs = selbc;
                end
            end
        else
            numcells = getNumberOfFEs(m);
            if full3d
                vxsPerFE = getNumVxsPerFE( m );
            else
                vxsPerFE = 3;
            end
            selcc = (1:numcells)';
            selbc = ones( numcells, vxsPerFE ) / vxsPerFE;
            decorptsmid = elcentres;
            if full3d
                selFaces = find( m.visible.surffaces );
                selccSurf = m.FEconnectivity.facefes( m.visible.surffaces, : )';
                visSurfaceFEs = selccSurf > 0;
                visSurfaceFEs( visSurfaceFEs ) = m.visible.elements( selccSurf( visSurfaceFEs ) );
                selccSurf = selccSurf( visSurfaceFEs );
                selbcSurf = ones( length(selccSurf), 3 ) / 3;
                vxsPerFace = size( m.FEconnectivity.faces, 2 );
                dims = size( m.FEnodes, 2 );
                decorptsmidSurf = ...
                    permute( sum( reshape( m.FEnodes( m.FEconnectivity.faces( m.visible.surffaces, : )', : ), vxsPerFace, [], dims ), 1 ), [2,3,1] )/3;
                xxxx = 1;
            else
                selFaces = [];
                vxsPerFE = 3;
            end
        end
        if ~full3d
            decoroffset = baryToGlobalCoords( selcc, selbc, semithicknessvectors, m.tricellvxs );
            decoroffset = decoroffset( m.visible.cells(selcc), : );
        else
%             decorptsmid = [];
            decoroffset = 0;
        end
        if ~cropped
            if full3d
                selectedElements =  m.visible.elements(selcc);
            else
                selectedElements =  m.visible.cells(selcc);
            end
            decorptsmid = decorptsmid( selectedElements, : );
            selbc = selbc( selectedElements, : );
            selcc = selcc( selectedElements );
        end
    end
    
    if s.drawrotations
        rotationoffset = (s.thick + 2*s.gradientoffset)*decoroffset;
        if any( s.sidenormal=='A' )
            rotcentresA = decorptsmid - rotationoffset;
        else
            rotcentresA = [];
        end
        if any( s.sidenormal=='A' )
            rotcentresB = decorptsmid + rotationoffset;
        else
            rotcentresB = [];
        end
    end
    
    if s.drawnormals
        normaloffset = (s.thick + 2*s.normaloffset)*decoroffset;
        if any( s.sidenormal=='A' )
            normalptsA = decorptsmid - normaloffset;
        else
            normalptsA = [];
        end
        if any( s.sidenormal=='B' )
            normalptsB = decorptsmid + normaloffset;
        else
            normalptsB = [];
        end
        normalpts = [normalptsA; normalptsB];
        normaloffsets = decorscale * m.unitcellnormals(selcc,:);
        m.normalhandles = myquiver3( ...
            normalpts, ...
            [ -normaloffsets; normaloffsets ], ...
            [], m.plotdefaults.arrowheadsize, m.plotdefaults.arrowheadratio, 1, 0, ...
            'Color', 'k', ... % [0 0 0;1 0 0], ... % 
            'ColorIndex', ones(size(normalpts,1),1), ...
            'LineWidth', m.plotdefaults.arrowthickness, ...
            ... % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
            'Parent', theaxes );
    end
    
    if s.drawgradients || s.drawgradients2 || s.drawgradients3
        crosses = s.crossgradients;
        equalsize = true;
        m.strainhandles = [];
        gradoffset = (s.thick + 2*s.gradientoffset)*decoroffset;
        gradptsA = decorptsmid + gradoffset;
        if gradoffset==0
            gradptsB = [];
        else
            gradptsB = decorptsmid - gradoffset;
        end
        if ~full3d || m.plotdefaults.volumedecor
            m.plothandles.volumedecor = plotPolGrad( m, ...
                  selcc, selFaces, selbc, decorptsmid, gradptsA, gradptsB, ...
                  sparsedistance, crosses, equalsize, decorscale, s, full3d, m.plotdefaults.surfacedecormaxangle );
            for hi=1:length(m.plothandles.volumedecor)
                m.plothandles.volumedecor(hi).Tag = 'volumedecor';
            end
        end
        if full3d && m.plotdefaults.surfacedecor
            m.plothandles.surfacedecor = plotPolGrad( m, ...
                  selccSurf, selFaces, selbcSurf, decorptsmidSurf, decorptsmid, [], ...
                  sparsedistance, crosses, equalsize, decorscale, s, false, m.plotdefaults.surfacedecormaxangle );
            for hi=1:length(m.plothandles.surfacedecor)
                m.plothandles.surfacedecor(hi).Tag = 'surfacedecor';
            end
        end
    end
    
    if s.drawcontours && ~isempty( s.contourdata ) && (s.contournumber > 0)
        if ischar( s.contourdata ) || (length(s.contourdata)==1)
            cd = FindMorphogenIndex( m, s.contourdata );
            cd = getEffectiveMgenLevels( m, cd );
        else
            cd = s.contourdata;
        end
        if length(cd)==size(m.morphogens,1)
            m = plotContours( m, cd(:), s.contournumber, s.contourlevels, s.contourcolor, true, s.contouroffset*(1-s.decorateAside*2), s.contourthickness );
        end
    end
    
    if s.drawrotations && isfield( m.outputs, 'rotations' )
        if isempty( m.outputs.rotations )
            m.outputs.rotations = getRotations( m );
        end
        if size( m.outputs.rotations, 1 )==getNumberOfFEs(m)
            m = plotRotationCircles( m, ...
                  selcc, decorptsmid, rotcentresA, rotcentresB, ...
                  m.outputs.rotations(selcc,:), s.rotcirclevaluescale, decorscale, s );
        end
    end
    
    if s.drawstreamlines
        drawStreamlines( theaxes, m );
    end
    
    if (s.drawtensoraxes || s.drawtensorcircles) ... % && isfield( s, 'axesdrawn' ) && ~isempty(s.axesdrawn) ...
             && isfield( m.plotdata, 'frames' ) && ~isempty(m.plotdata.frames) ...
             && isfield( m.plotdata, 'selcpts' ) && ~isempty(m.plotdata.selcpts)
        numselcpts = size(m.plotdata.selcpts,2);
        axisordering = m.plotdata.selcpts;
        switch numselcpts
            case 1
                [other1,other2] = othersOf3( axisordering );
                axisordering = [ axisordering, other1, other2 ];
            case 2
                axisordering = [ axisordering, otherof3( axisordering(:,1), axisordering(:,2) ) ];
        end
        if size(m.plotdata.selcpts,1) == 1
            % The same components in the same order are plotted for every selected FE.
            cpts = m.plotdata.components( selcc, axisordering );
        else
            % Possibly different components or in different orders are plotted for every selected FE.
            cpts = zeros( length(selcc), 3 );
            for i=1:length(selcc)
                cpts(i,:) = m.plotdata.components(selcc(i),axisordering(selcc(i),:));
            end
        end
        maxperFE = max( abs(cpts), [], 2 );
        poscpts = maxperFE > 0;
        if any( poscpts )
            cpts = abs( cpts( poscpts, : ) );
            maxperFE = maxperFE( poscpts );
            frameselcc = selcc(poscpts);
            if size(m.plotdata.selcpts,1) == 1
                framevecs = m.plotdata.frames(:,axisordering,frameselcc);
            else
                posselcpts = axisordering(frameselcc,:);
                framevecs = zeros( 3, 3, length(frameselcc) );
                for i=1:length(frameselcc)
                    framevecs(:,:,i) = m.plotdata.frames(:,posselcpts(i,:),frameselcc(i));
                end
            end
            framevecs = reshape( permute( framevecs, [2,3,1] ), [], 3 );
            if s.unitcrosses
                cpts = cpts ./ repmat( maxperFE, 1, size(cpts,2) );
            else
                cpts = cpts / max(maxperFE);
            end
            framevecs = framevecs .* repmat( reshape( cpts', [], 1 ), 1, 3 );
            offsets = scalevecs( framevecs, decorscale );
            framevecs = permute( reshape( framevecs, 3, length(frameselcc), 3 ), [2 3 1] );
            offsets = permute( reshape( offsets, 3, length(frameselcc), 3 ), [2 3 1] );
%             offsets = resshape( ...
            tensorpts = decorptsmid(poscpts,:);
            if full3d
                origins = tensorpts;
            else
                haveA = any( s.sidetensor=='A' );
                haveB = any( s.sidetensor=='B' );
                tensoroffset = (s.thick + 2*s.tensoroffset)*decoroffset(poscpts,:);
                if haveA
                    origins = tensorpts + tensoroffset;
                    if haveB
                        origins(:,:,2) = tensorpts - tensoroffset;
                    end
                elseif haveB
                    origins = tensorpts - tensoroffset;
                end
            end
            if s.drawtensorcircles && (numselcpts > 1)
                hi = 0;
                numhandles = (numselcpts*(numselcpts+1))/2;
                hh = gobjects(1,numhandles);
                for i=1:(numselcpts-1)
                    for j=(i+1):numselcpts
                        k = otherof3( i, j );
                        hi = hi+1;
                        hh(hi) = plotcircles( ...
                            'centre', origins, ...
                            'radius', cpts(:,[i j]) * decorscale/2, ...
                            'normal', framevecs(:,:,k), ...
                            'startvec', framevecs(:,:,i), ...
                            'arrowsize', 0, ...
                            'Color', m.plotdefaults.axescolor, ...
                            'LineWidth', m.plotdefaults.arrowthickness, ...
                            'Parent', theaxes );
                        hh(hi).Tag = sprintf( 'tensorcircles%02d_%02d', i, j );
                    end
                end
                m.plothandles.tensorcircles = hh;
            end
            if s.drawtensoraxes
                m.plothandles.tensoraxes = myquiver3( ...
                    origins, ...
                    offsets(:,:,1:numselcpts), ...
                    [], ...
                    0, 0, 0.4, 0.4, ...
                    'Color', m.plotdefaults.axescolor, ...
                    'LineWidth', m.plotdefaults.arrowthickness, ...
                    ... % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
                    'Parent', theaxes );
                if length(m.plothandles.tensoraxes)==1
                    m.plothandles.tensoraxes.Tag = 'tensoraxes';
                else
                    for dhi=1:length(m.plothandles.tensoraxes)
                        m.plothandles.tensoraxes.Tag = sprintf( 'tensoraxess%03d', dhi );
                    end
                end
            end
        end
    end
    
    if s.drawdisplacements && ~isempty(m.displacements)
        if full3d
            selnodes = sparsifyPoints( m.FEnodes, sparsedistance );
            selnodes(~m.visible.nodes(selnodes)) = [];
            m.plothandles.displacementhandles = myquiver3( ...
                m.FEnodes(selnodes,:), ...
                scalevecs( m.displacements(selnodes,:), decorscale ), ...
                [], ...
                0.5, 0.6, 1, 0, ...
                'Color', [0.4 0.2 0.1], ...
                'LineWidth', m.plotdefaults.arrowthickness, ...
                ... % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
                'Parent', theaxes );
        else
            selnodes = sparsifyPoints( m.nodes, sparsedistance );
            selnodes(~m.visible.nodes(selnodes)) = [];
            selprismnodes = selnodes*2;
            selprismnodes = reshape([ selprismnodes-1, selprismnodes ]', [], 1 );
            m.plothandles.displacementhandles = myquiver3( ...
                m.prismnodes(selprismnodes,:), ...
                scalevecs( m.displacements(selprismnodes,:), decorscale ), ...
                [], ...
                0.5, 0.6, 1, 0, ...
                'Color', [0.4 0.2 0.1], ...
                'LineWidth', m.plotdefaults.arrowthickness, ...
                ... % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
                'Parent', theaxes );
        end
        if length(m.plothandles.displacementhandles)==1
            m.plothandles.displacementhandles.Tag = 'displacementhandles';
        else
            for dhi=1:length(m.plothandles.displacementhandles)
                m.plothandles.displacementhandles.Tag = sprintf( 'displacementhandless%03d', dhi );
            end
        end
    end

    % Plot the second layer.
    if s.drawsecondlayer && hasNonemptySecondLayer( m )
        m = plotSecondLayer( m, theaxes );
    else
        m.plothandles.secondlayerhandle = [];
    end
    
    if s.drawvvlayer && isfield( m.secondlayer, 'vvlayer')
       m.secondlayer.vvlayer = plotVVLayer2( theaxes, m.secondlayer.vvlayer );
    end
    
    drawAxisLabels( theaxes, s.bgcolor, s.axisVisible );

    hold( theaxes, 'on' );
    
    if isfield( pichandles, 'colorbar' )
        if wantColorBar
            drawColorbar( pichandles.colorbar, getColorBarLabels( s ), s.cmap, s.crange, s.cmaptype, get( pichandles.picture, 'Color' ), s.drawcolorbar );
        else
            drawColorbar( pichandles.colorbar, {'','',''}, [], [0 0], '', get( pichandles.picture, 'Color' ), s.drawcolorbar );
            % blankColorBar( pichandles.colorbar, get( pichandles.picture, 'Color' ) );
        end
    end
    
    if externalFigure
        plotWidgets( theaxes, s, false );
    else
        for i=1:length(m.pictures)
            plotWidgets( m.pictures(i), s, i >= 2 );
        end
    end
%     if isempty( m.plotdefaults.axisRange )
%         for i=1:length(m.pictures)
%             setaxis( m.pictures(i), visibleBbox( m.pictures(i) ) );
%         end
%     end
    
    if m.globalProps.newcallbacks
        m = invokeIFcallback( m, 'Postplot', theaxes );
    elseif isa( s.userplotproc, 'function_handle' )
        funcname = func2str( s.userplotproc );
        if isempty( regexp( funcname, '^UNKNOWN', 'once' ) )
            fprintf( 1, 'Calling user plotting procedure %s.\n', ...
                funcname );
            m = s.userplotproc( m, theaxes );
        end
    end

    hold( theaxes, 'off' );
    drawnow;
    if nargout >= 1, varargout{1} = m; end
end
    
    
function plotWidgets( axs, s, ismultiple )
    if ~ishandle( axs )
        return;
    end
    ph = guidata( axs );
    grid( axs, 'off' );
    if s.axisVisible
        axis( axs, 'on' );
    else
        axis( axs, 'off' );
    end
    if isfield( ph, 'legend' ) && ishandle( ph.legend )
        if s.drawlegend && ~isempty( get(ph.legend,'String') )
            set( ph.legend, 'Visible', 'on' );
        else
            set( ph.legend, 'Visible', 'off' );
        end
    end

    if ismultiple
        colormap( axs, s.cmap );
        caxis( axs, s.crange([1 2]) );
        cla(axs);
        copyobj( get( theaxes, 'Children' ), ph.picture ); % ?? theaxes is not defined.
    end
    if isfield( ph, 'pictureBackground' ) && ishandle( ph.pictureBackground )
        uistack( ph.pictureBackground, 'bottom' );
    end
end


    
function labels = getColorBarLabels( s )
    % For morphogens, no label.
    % For specified or actual growth, EXPANSION and CONTRACTION.  But
    % if either end of the scale is zero, put ZERO.  If the whole scale
    % is positive, HIGH EXPANSION and LOW EXPANSION.  Similarly, HIGH
    % CONTRACTION and LOW CONTRACTION.
    % For residuals, COMPRESSION and TENSION
    % Set labels to EXPANSION and CONTRACTION or COMPRESSION and
    % TENSION.
    if isempty( s.outputquantity )
        toplabel = '';
        bottomlabel = '';
    elseif regexp( s.outputquantity, 'anisotropy' )
        if regexp( s.outputquantity, '^residual' )
            toplabel = 'MORE';
            bottomlabel = 'LESS';
        else
            toplabel = 'G1 > G2';
            bottomlabel = 'G1 < G2';
        end
    elseif regexp( s.outputquantity, '^residual' )
        toplabel = 'TENSION';
        bottomlabel = 'COMPRESSION';
    else
        toplabel = 'EXPANSION';
        bottomlabel = 'CONTRACTION';
    end

    lo = s.crange(1);
    hi = s.crange(2);
    if lo==hi
        toplabel = '';
        bottomlabel = '';
    elseif lo==0
        bottomlabel = 'ZERO';
    elseif lo > 0
        bottomlabel = ['LOW ' toplabel];
        toplabel = ['HIGH ' toplabel];
    elseif hi==0
        toplabel = 'ZERO';
    elseif hi < 0
        toplabel = ['LOW ' bottomlabel];
        bottomlabel = ['HIGH ' bottomlabel];
    end
    labels = {'',toplabel,bottomlabel};
end

function m = plotedges( m, theaxes, side, edges, edgethickness, edgecolor, datatype )
    if ~any(edges)
        return;
    end
    [lw,ls] = basicLineStyle( edgethickness );
    switch side
        case ''
            coords = m.nodes;
        case 'A'
            coords = m.prismnodes( 1:2:end, : );
        case 'B'
            coords = m.prismnodes( 2:2:end, : );
    end
%     x = [ coords( m.edgeends(edges,1), 1 ), coords( m.edgeends(edges,2), 1 ) ]';
%     y = [ coords( m.edgeends(edges,1), 2 ), coords( m.edgeends(edges,2), 2 ) ]';
%     z = [ coords( m.edgeends(edges,1), 3 ), coords( m.edgeends(edges,2), 3 ) ]';
%     [x,y,z] = combineLines( x, y, z );
    edgelist = find(edges);
%     m.plothandles.(datatype) = line( ...
%         x, y, z, ...
%         'LineWidth', lw, ...
%         'LineStyle', ls, ...
%         'Color', edgecolor, ...
%         ... % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
%         'Parent', theaxes, ...
%         'ButtonDownFcn', @GFtboxGraphicClickHandler );
    m.plothandles.(datatype) = plotlines( ...
        m.edgeends(edges,:), ...
        coords, ...
        'LineWidth', lw, ...
        'LineStyle', ls, ...
        'Color', edgecolor, ...
        ... % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
        'Parent', theaxes, ...
        'ButtonDownFcn', @GFtboxGraphicClickHandler );
    m.plothandles.(datatype).Tag = datatype;
    setPlotHandleData( m, datatype, 'edges', edgelist, 'ButtonDownFcn', @doMeshClick );
end

function m = plotborder( m, theaxes, s )
    borderedgeends = m.edgeends(m.visible.borderedges,:)';
    bordernodelist = find(m.visible.bordernodes);
    bordernoderenumber = zeros(size(m.visible.bordernodes));
    bordernoderenumber( m.visible.bordernodes ) = (1:length(bordernodelist))';
    borderedgeendsreduced = bordernoderenumber(borderedgeends);
    bordernodepositions = m.nodes( m.visible.bordernodes, : );
    borderprismnodesB = bordernodelist*2;
    borderprismnodesA = borderprismnodesB-1;
    bordernodeApositions = m.prismnodes( borderprismnodesA, : );
    bordernodeBpositions = m.prismnodes( borderprismnodesB, : );
    edgeApositions = reshape( bordernodeApositions( borderedgeendsreduced, : )', 6, [] );
    edgeBpositions = reshape( bordernodeBpositions( borderedgeendsreduced, : )', 6, [] );
    borderedgeindexes = find( m.visible.borderedges );

    if isfield( m.plotdata, 'value' ) && ~isempty( m.plotdata.value )
        bordernodeABpositions = reshape( [ bordernodeApositions'; bordernodeBpositions' ], ...
                                         3, [] )';
        m = paintborder( m, theaxes, s, ...
            bordernodeABpositions, ...
            borderedgeendsreduced, ...
            m.plotdata.pervertex, ...
            false, ...
            m.plotdata.value, ...
            'patchAB', borderedgeindexes );
    else
        bordernodeAMpositions = reshape( [ bordernodeApositions'; bordernodepositions' ], ...
                                         3, [] )';
        bordernodeBMpositions = reshape( [ bordernodeBpositions'; bordernodepositions' ], ...
                                         3, [] )';
        m = paintborder( m, theaxes, s, ...
            bordernodeAMpositions, ...
            borderedgeendsreduced, ...
            m.plotdata.pervertexA, ...
            m.plotdefaults.taper, ...
            m.plotdata.valueA, ...
            'patchAM', borderedgeindexes );
        m = paintborder( m, theaxes, s, ...
            bordernodeBMpositions, ...
            borderedgeendsreduced, ...
            m.plotdata.pervertexB, ...
            m.plotdefaults.taper, ...
            m.plotdata.valueB, ...
            'patchBM', borderedgeindexes );
    end

    m.plothandles.throughEdges = [];
    m.plothandles.rimEdges = [];
    if m.plotdefaults.drawedges > 0
        % Draw border edges.
        
        % Through edges.
        [lw,ls] = basicLineStyle( m.plotdefaults.FEthinlinesize );
        m.plothandles.throughEdges = plotPtsToPts( ...
            bordernodeApositions, bordernodeBpositions, ...
            m.plothandles.throughEdges, ...
            'LineWidth', lw, ...
            'LineStyle', ls, ...
            'Color', m.plotdefaults.FElinecolor, ...
            ... % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
            'Parent', theaxes, ...
            'ButtonDownFcn', @GFtboxGraphicClickHandler );
        if ~isempty( m.plothandles.throughEdges )
            m.plothandles.throughEdges.Tag = 'throughEdges';
        end
        setPlotHandleData( m, 'throughEdges', 'vxs', bordernodelist, 'ButtonDownFcn', @doMeshClick );

        if m.plotdefaults.drawedges < 2
            m.plothandles.rimEdges = plotPtsToPts( ...
               [ edgeApositions(1:3,:)'; edgeBpositions(1:3,:)' ], ...
               [ edgeApositions(4:6,:)'; edgeBpositions(4:6,:)' ], ...
              'LineWidth', lw, ...
              'LineStyle', ls, ...
              'Color', m.plotdefaults.FElinecolor, ...
              ... % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
              'Parent', theaxes, ...
              'ButtonDownFcn', @GFtboxGraphicClickHandler );
            if ~isempty( m.plothandles.rimEdges )
                m.plothandles.rimEdges.Tag = 'rimEdges';
            end
            setPlotHandleData( m, 'rimEdges', 'edges', [borderedgeindexes;borderedgeindexes], 'ButtonDownFcn', @doMeshClick );
        end
    end
end

function m = paintborder( m, theaxes, s, bordernodepositions, borderedgeends, ...
                                      pervertex, taper, data, handlename, edges )
    quadVxIndexes = [ borderedgeends*2-1; ...
                      borderedgeends([2 1],:)*2 ];
    if ~isempty( data )
        if pervertex
            data = data( m.visible.bordernodes, : );
            data = reshape( [data'; data'], size(data,2), [] )';
        else
            data = data( m.visible.bordercells, : );
        end
        if size(data,2)==1
            data = translateToColors( data, s.crange, s.cmap );
        end
    end
    commonPlotArgs = { 'FaceLighting', m.plotdefaults.lightmode, ...
                       'AmbientStrength', m.plotdefaults.ambientstrength, ...
                       'FaceAlpha', m.plotdefaults.alpha, ...
                       'LineStyle', 'none', ...
                       'Marker', 'none', ...
                       ... % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
                       'Parent', theaxes };
    m.plothandles.(handlename) = plotmeshsurface( [], theaxes, s, bordernodepositions, quadVxIndexes', ...
        data, pervertex, 0, 0, commonPlotArgs, ...
        struct( 'type', handlename, 'edges', edges, 'ButtonDownFcn', @doMeshClick ) );
    m.plothandles.(handlename).Tag = handlename;
end

function m = calculatePlotData( m, side )
    full3d = usesNewFEs(m);
    fn_value = ['value' side];
    fn_pervertex = ['pervertex' side];
    fn_perelement = ['perelement' side];
    fn_tensors = ['tensor' side];
    fn_morphogen = ['morphogen' side];
    fn_outputquantity = ['outputquantity' side];
    fn_outputaxes = ['outputaxes' side];
    fn_perelementaxes = ['perelementaxes' side];
    fn_perelementcomponents = ['perelementcomponents' side];
%     fn_axesdrawn = ['axesdrawn' side];
%     fn_axesquantity = ['axesquantity' side];
    fn_components = ['components' side];
    fn_selcpts = ['selcpts' side];
    fn_frames = ['frames' side];
%     if ~isempty(m.plotdefaults.(fn_axesdrawn))
%         if ~isempty(m.plotdefaults.(fn_axesquantity))
%             m.plotdata.axes = foo;
%         elseif ~isempty(m.plotdefaults.(fn_tensors))
%         elseif ~isempty(m.plotdefaults.(fn_outputquantity))
%         end
%     end
    haveuserframes = ~isempty( m.plotdefaults.(fn_perelementaxes) );
    if haveuserframes
        m.plotdata.(fn_frames) = m.plotdefaults.(fn_perelementaxes);
        numaxes = size( m.plotdefaults.(fn_perelementaxes), 2 );
        m.plotdata.(fn_selcpts) = 1:numaxes;
        if isempty( m.plotdefaults.(fn_perelementcomponents) )
            m.plotdata.(fn_components) = ones( size( m.tricellvxs, 1 ), numaxes );
        else
            m.plotdata.(fn_components) = m.plotdefaults.(fn_perelementcomponents);
        end
    end
    if ~isempty(m.plotdefaults.(fn_pervertex))
        m.plotdata.(fn_pervertex) = true;
        m.plotdata.(fn_value) = m.plotdefaults.(fn_pervertex);
        m.plotdata.description = 'Value';
    elseif ~isempty(m.plotdefaults.(fn_perelement))
        m.plotdata.(fn_pervertex) = false;
        m.plotdata.(fn_value) = m.plotdefaults.(fn_perelement);
        m.plotdata.description = 'Value';
    elseif ~isempty( m.plotdefaults.(fn_morphogen) )
        mgenindexes = FindMorphogenIndex( m, m.plotdefaults.(fn_morphogen) );
        m.plotdata.(fn_pervertex) = true;
        if length( mgenindexes )==1
            m.plotdata.(fn_value) = getEffectiveMgenLevels( m, mgenindexes );
            m.plotdata.description = m.mgenIndexToName{mgenindexes};
        else
            m.plotdata.(fn_value) = multicolourmgens( ...
                    m, mgenindexes, m.plotdefaults.multibrighten, [] );
            m.plotdata.description = 'Multiple';
        end
    elseif ~isempty( m.plotdefaults.(fn_tensors) )
        m.plotdata.(fn_pervertex) = false;
        fn_cellFramesField = ['cellFrames', side];
        [m.plotdata.(fn_value), ...
         m.plotdata.(fn_components), ...
         theframes, ...
         m.plotdata.(fn_selcpts)] = getMeshTensorValues( ...
            m, ...
            m.plotdefaults.(fn_tensors), ...
            m.plotdefaults.(fn_outputaxes), ...
            m.(fn_cellFramesField) );
        if ~haveuserframes
            m.plotdata.(fn_frames) = theframes;
        end
        m.plotdata.description = 'Tensors';
    elseif ~isempty( m.plotdefaults.(fn_outputquantity) )
        m.plotdata.(fn_pervertex) = false;
        if regexp( m.plotdefaults.(fn_outputquantity), '^rotation' )
            % Set rotation data.  NOT IMPLEMENTED.
%             m.plotdata.(fn_value) = m.outputs.rotations;
            if isempty( m.outputs.rotations )
                inplane = zeros( getNumberOfFEs(m), 3 );
            elseif full3d
                inplane = sqrt(sum(m.outputs.rotations.^2,2));
            else
                [inplane,~] = splitVector( m.outputs.rotations, m.unitcellnormals );
            end
            m.plotdata.(fn_value) = inplane;
        else
            fn_cellFramesField = ['cellFrames', side];
            [m.plotdata.(fn_value), ...
             m.plotdata.(fn_components), ...
             m.plotdata.(fn_frames), ...
             m.plotdata.(fn_selcpts)] = getMeshTensorValues( ...
                m, ...
                m.plotdefaults.(fn_outputquantity), ...
                m.plotdefaults.(fn_outputaxes), ...
                m.(fn_cellFramesField) );
        end
        m.plotdata.description = m.plotdefaults.(fn_outputquantity);
    else
        % Nothing to be plotted.
        % m.plotdata.description = '';
    end
end

function m = makeCanvasColor( m, side )
    fn_value = ['value' side];
    fn_pervertex = ['pervertex' side];
    if ~isfield( m.plotdata, fn_value ) || isempty( m.plotdata.(fn_value) )
        if ~isfield( m.plotdata, fn_pervertex )
            m.plotdata.(fn_pervertex) = false;
        end
        if m.plotdata.(fn_pervertex)
            numdata = size( m.nodes, 1 );
        else
            numdata = size( m.tricellvxs, 1 );
        end
        m.plotdata.(fn_value) = repmat( m.plotdefaults.canvascolor, numdata, 1 );
    end
end

function drawAxisLabels( theaxes, bgcolor, visible )
    elementColor = contrastColor( bgcolor );
    axisVisString = boolchar( visible, 'on', 'off' );
    set( theaxes, ...
        'XColor', elementColor, ...
        'YColor', elementColor, ...
        'ZColor', elementColor );
    theaxesRange = axis(theaxes);
    if length(theaxesRange) < 6
        theaxesRange = [ theaxesRange, 0, 0 ];
    end
    labeloffset = 0.075;
    xaxislabel = get(theaxes,'XLabel');
    yaxislabel = get(theaxes,'YLabel');
    zaxislabel = get(theaxes,'ZLabel');
%     xloc = get( theaxes, 'XAxisLocation' );
%     yloc = get( theaxes, 'YAxisLocation' );
    set( theaxes, ...
        'XColor', elementColor, ...
        'YColor', elementColor, ...
        'ZColor', elementColor );
    set( xaxislabel, ...
        'String','X', ...
        'Position', [ (theaxesRange(1) + theaxesRange(2))/2, ...
                      theaxesRange(3)*(1+labeloffset) - theaxesRange(4)*labeloffset, ...
                      theaxesRange(5) ], ...
        'Rotation', 0, ...
        'Color', elementColor, ...
        'Visible', axisVisString );
    set( yaxislabel, ...
        'String','Y', ...
        'Position', [ theaxesRange(1)*(1+labeloffset) - theaxesRange(2)*labeloffset, ...
                      (theaxesRange(3) + theaxesRange(4))/2, ...
                      theaxesRange(5) ], ...
        'Rotation', 0, ...
        'Color', elementColor, ...
        'Visible', axisVisString );
%    if length(theaxesRange) == 6
        set( zaxislabel, ...
        'String','Z', ...
        'Position', [ theaxesRange(1)*(1+labeloffset) - theaxesRange(2)*labeloffset, ...
                      theaxesRange(4)*(1+labeloffset) - theaxesRange(3)*labeloffset, ...
                      (theaxesRange(5) + theaxesRange(6))/2 ], ...
        'Rotation', 0, ...
        'Color', elementColor, ...
        'Visible', axisVisString );
%    end
end

