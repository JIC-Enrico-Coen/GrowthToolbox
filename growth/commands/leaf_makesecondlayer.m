function [m,ok] = leaf_makesecondlayer( m, varargin )
%[m,ok] = leaf_makesecondlayer( m, ... )
%   Make a new cellular layer, either adding to or discarding any existing one.
%
%   Options:
%       mode:   One of the following strings:
%           'universal': cover the entire surface with a continuous sheet of
%               cells.  The 'numcells' option specifies how many.  This is
%               only valid for flat or nearly flat meshes.
%           'voronoi': cover the entire surface with a continuous sheet of
%               cells.  The 'numcells' option specifies how many.  This is
%               only valid for flat or nearly flat meshes.  This is
%               obsolete and 'universal' should be used instead.
%           'full': cover the entire surface with a continuous sheet of
%               cells.  There will be one cell per FE cell plus one cell
%               per FE vertex.  This is little used and should be
%               considered obsolete.
%           'grid': cover the entire surface with a continuous sheet of
%               square cells.  Suitable only for meshes that are close to
%               flat in the XY plane.
%           'cylindergrid': Like 'grid', but applies to meshes that are
%               close to cylindrical aong the Z axis.
%           'single': make a single second layer cell in a random position.
%           'few': make a specified number of second layer cells, randomly
%               scattered over the mesh. Some attempt is made to avoid
%               clumping.
%           'each': make one second layer cell within each FEM cell.
%           'empty': do not make any cells, just create the structure for
%               storing a cellular layer.
%           The following values for mode use a new system (as of Jan 2018)
%           for generating certain grid-like cellular layers, and for these
%           modes there is a correspondingly new set of options, the other
%           options being ignored.
%           'radial': Makes a circular grid of cells, where the edges are
%               radial or circumferential.
%           'latlong': For spherical meshes only (foliate or volumetric).
%               This will generate a layer of cells dividing the sphere
%               into a latitude and longitude grid.
%           'rectgrid': For rectangular meshes only (foliate or
%               volumetric). This will generate a rectangular grid of
%               cells.
%           'circlegrid': A grid of cells, truncated to circular form.
%           'box': For 3D box-like meshes only.  A layer of cells forming a
%               three-dimensional box.
%           'spherebox': As 'box', but the box is projected to a sphere.
%
%   Options relevant to the new values of mode (see above):
%       divisions: This is
%           either 1, 2, or 3 numbers, here called d1, d2, and d3. Where
%           more numbers are required than are given, defaults are applied.
%           For mode 'latlong', d1 is the number of cells around the
%           equator and d2 is the number of cells from pole to pole (by
%           default ceil(d1/2).
%           For mode 'radial', d1 is the number of cells around the
%           circumference and d2 is the number of rings of cells (default
%           max(1,ceil(d1/3)).
%           For mode 'rectgrid', d1 and d2 (default d1) are the number of
%           cells each way.
%       plane: This is one of the
%           strings 'XY', 'YX', 'XZ', 'ZX', 'YZ', or 'ZY' (case is ignored).
%           This specifies the plane that the cells lie in for modes
%           'radial' and 'rectgrid', and the equatorial plane for mode
%           'latlong'. For modes that require the mesh to be nearly flat,
%           the default is whatever plane it is flattest in, otherwise 'XY'.
%       centre: Specifies the centre of the bounding box of the cellular
%           layer. Defaults to the centre of the bounding box of the mesh.
%       magnitude: Specifies the diameter of the cellular layer in two or
%           three dimensions. Defaults to the magnitude of the bounding box
%           of the mesh in those dimensions.
%       hemisphere: Applies to latlong grids only.  A value of 'n'
%           specifies that only the north hemisphere is to be made, 's'
%           that only the south hemisphere is to be made, and anything else
%           that the whole sphere is to be made. Case is ignored.
%       range: Defines a subset of the grid to be made. (FURTHER DETAILS TO
%           BE DOCUMENTED.)
%
%   Options relevant to old modes:
%       positions:  Only valid for mode=few or mode=single.  If this is present
%               and nonempty, it specifies the centres of the new cells.
%       absdiam:   Not valid for mode=full.  In all other cases, this is a real
%               number, being the diameter of a single cell.
%       absarea:   Not valid for mode=full.  In all other cases, this is a real
%               number, being the area of a single cell.
%       reldiam:   Not valid for mode=full.  In all other cases, this is a real
%               number, being the diameter of a single cell as a proportion
%               of the diameter of the current mesh (estimated as the
%               square root of the mesh area).
%       relarea:   Not valid for mode=full.  In all other cases, this is a real
%               number, being the area of a single cell as a proportion
%               of the area of the current mesh.
%       abssize:   OBSOLETE, REMOVED.  Use 'absdiam' instead.
%       relsize:   OBSOLETE, REMOVED.  Use 'reldiam' instead.
%       relinitarea:   OBSOLETE, REMOVED.
%       relFEsize:   OBSOLETE, REMOVED.
%       axisratio:   The ratio of major to minor axis of the cells.  If
%                    this is not 1, the major axis will be parallel to the
%                    polariser gradient, if any; if there is no polariser
%                    gradient, or at the cell location it is beneath the
%                    threshold for it to be  effective, the cell will be
%                    created circular.  The default value is 1.
%       numcells:    Valid only for mode='voronoi', mode='each', or
%               mode='few'.  An integer specifying the number of cells to
%               create.
%       sides:  Each cell is created as a regular polygon having this many
%               sides.  The default is 12, but if you are using a very
%               large number of cells, rendering will be significantly
%               faster if you use fewer sides.
%       refinement:  An integer.  Once the cells have been created
%               according to the other options, if this option is given and
%               has a value of at least 2, then every wall segment will be
%               divided into a series of that number of smaller segments.
%       add:    Boolean.  If true, existing cells are retained and new
%               cells are added to them.  If false, any existing biological
%               layer is discarded.  If 'mode' is 'universal', 'full', or
%               'voronoi', the old layer is always discarded, ignoring the
%               'add' argument.
%       allowoverlap:  Boolean.  If true, cells are allowed to overlap each
%               other.  If false, cells will not overlap each other.  You
%               may as a result end up with fewer cells than you asked for.
%       allowoveredge:  Boolean.  If true, cells are allowed to overlap the
%               edge of the mesh (and will be trimmed back to fit).  If
%               false, the whole of the cell must lie within the mesh
%               without trimming.  You may as a result end up with fewer
%               cells than you asked for.
%       colors:  The colour of the new cells, as an RGB value.
%       colorvariation:  The amount of variation in the colour of the new
%               cells. Each component of the colour value will be randomly
%               chosen within this ratio of the value set by the 'color'
%               argument.  That is, a value of 0.1 will set each component
%               to between 0.9 and 1.1 times the corresponding component of
%               the specified colour.  (The variation is actually done in
%               HSV rather than RGB space, but the difference is slight.)
%       probperFE:  For 'each' mode, this specifies for each FE the
%               probability per unit area for creating a cell there.
%               Any value less than 0 is equivalent
%               to 0.  The values will be scaled so as to add to 1.
%       probpervx:  Like probperFE, but the values are given per vertex.
%               Alternatively, the value can be a morphogen name or index,
%               in which case the values of that morphogen at each vertex
%               will be used.
%       The options 'probperFE', and 'probpervx' are mutually exclusive.
%       vertexdata:  Instead of generating the cells according to one of
%               the methods described above, take this N*3 array to be the
%               positions of all of the cell vertexes.
%       celldata:  To be used with vertexdata.  This is a cell array of
%               integer arrays, each integer array specifying the vertexes
%               of one cell in order around the cell.
%       vertexindexing: This is either 1 or 0.  If celldata is provided, then
%               this specifies whether the indexes in celldata are 1-based
%               or 0-based.  1-based is the default, since that is Matlab's
%               convention for all indexing of arrays, but external data
%               may often be zero-based.  If vertexindexing is not supplied
%               or is empty, then if zero occurs anywhere in celldata, it
%               will be assumed to be zero-based, otherwise 1-based.
%       If either 'vertexdata' or 'celldata' is supplied, the other must
%       also be, and all other options that specify the manner of creating
%       cells will be ignored.
%
%   At most one of ABSDIAM, ABSAREA, RELDIAM, and RELAREA should be given.
%
%   Equivalent GUI operation: clicking the "Make cells" button on the Bio-A
%   panel.  This is equivalent to m = leaf_makesecondlayer(m,'mode','full').
%
%   Topics: Bio layer.

%       relinitarea:   Not valid for mode=full.  In all other cases, this is a real
%               number, being the area of a single cell as a proportion
%               of the area of the initial mesh.

% The second layer contains the following information:
% For each cell ci:
%*       cells(ci).vxs(:)       A list of all its vertexes, in clockwise order.
%*       cells(ci).edges(:)     A list of all its edges, in clockwise order.
%           These cannot be 2D arrays, since different cells may have
%           different numbers of vertexes or edges.
%*       cellcolor(ci,1:3):     Its colour.
%       celllabel(ci,1):       Its label (an arbitrary integer). (OBSOLETE.)
%       celltargetarea(ci)     The cells' target areas.  Initially equal to
%                              their current areas.
%       cellarea(ci)           The cells' current areas.
%       areamultiple(ci)       A morphogen, initially 1.  The effective
%                              target area is areamultiple*celltargetarea.
%       cloneindex(ci)         An integer, used to distinguish clones.
%                              Inherited by descendants.
%
% For each clone vertex vi:
%*       vxFEMcell(vi)          Its FEM cell index.
%*       vxBaryCoords(vi,1:3)   Its FEM cell barycentric coordinates.
%*       cell3dcoords(vi,1:3)   Its 3D coordinates (which can be calculated
%                               from the other data).
% For each clone edge ei:
%*       edges(ei,1:4)          The indexes of the clone vertexes at its ends
%           and the clone cells on either side (the second one is 0 if absent).
%           This can be computed from the other data.
%        generation(ei)         An integer recording the generation at which
%                               this edge was created.
%        edgepropertyindex(ei)   Index to properties (primarly plotting options).
%
% Other parameters:
%        colorSaturation        ...
%        splitThreshold         ...
%        colorparams            ...
%        jiggleAmount           ...
%        averagetargetarea      ...
%   uniformhue: the hue of cells having cloneindex 0.
%   uniformhuerange: the random range of hue for cells having cloneindex 0.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
        'mode', 'full', ...
        'centre', [], ...
        'magnitude', [], ...
        'divisions', [], ...
        'range', [], ...
        'hemisphere', '', ...
        'subdivisions', [1 1 1], ...
        'plane', 'XY', ...
        'positions', [], ...
        'absdiam', -1, 'absarea', -1, ...
        'reldiam', -1, 'relarea', -1, ...
        'relinitarea', -1, ...
        'numcells', -1, 'sides', 12, ...
        'refinement', 1, ...
        'add', true, ...
        'probperFE', [], ...
        'probpervx', [], ...
        'axisratio', 1, ...
        'allowoverlap', true, ...
        'allowoveredge', true, ...
        'cellcolors', [], ...
        'colors', [], ...
        'colorvariation', [], ...
        'vertexdata', [], ...
        'celldata', [], ...
        'vertexindexing', [], ...
        'hexrows', 6, ...
        'hexperrow', 12 );
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'mode', ...
        'centre', ...
        'magnitude', ...
        'divisions', ...
        'range', ...
        'hemisphere', ...
        'subdivisions', ...
        'plane', ...
        'positions', ...
        'absdiam', 'absarea', ...
        'reldiam', 'relarea', ...
        'relinitarea', ...
        'numcells', 'sides', ...
        'refinement', 'add', 'probperFE', 'probpervx', ...
        'axisratio', ...
        'allowoverlap', ...
        'allowoveredge', ...
        'cellcolors', ...
        'colors', 'colorvariation', ...
        'vertexdata', 'celldata', 'vertexindexing', ...
        'hexrows', 'hexperrow' );
    if ~ok, return; end
    s.numcells = double(s.numcells);
    
    switch s.mode
        case { 'each', 'few' }
            s.mode = 'scatter';
        case 'single'
            s.mode = 'scatter';
            s.numcells = 1;
    end
    
    haveexternaldata = (~isempty( s.vertexdata )) || (~isempty( s.celldata ));
    if haveexternaldata
        if isempty( s.vertexdata )
            complain( '%s: celldata was supplied without vertexdata.', ...
                mfilename() );
            ok = false;
            return;
        elseif isempty( s.celldata )
            complain( '%s: vertexdata was supplied without celldata.', ...
                mfilename() );
            ok = false;
            return;
        end
        s = rmfield( s, { ...
                'absdiam', 'absarea', 'reldiam', 'relarea', ...
                'relinitarea', 'numcells', 'sides', ...
                'probperFE', 'probpervx', 'axisratio', 'allowoverlap' ...
                'allowoveredge' ...
            } );
        s.mode = 'external';
        if isempty( s.vertexindexing )
            for i=1:length(s.celldata)
                if any( s.celldata{i}==0 )
                    s.vertexindexing = 0;
                    break;
                end
            end
        end
        if s.vertexindexing==0
            for i=1:length(s.celldata)
                s.celldata{i} = s.celldata{i}+1;
            end
        end
    end
    
    fprintf( 1, 'Making cellular layer of type "%s"\n', s.mode );
    
    useMakeCellGrid = ~isempty( find( strcmp( s.mode, ...
        { 'radial', 'rectgrid', 'circlegrid', 'latlong', 'box', ...
          'spherebox', 'hemisphere', 'MakePrim3DGrid', 'MakePrim3DVoronoi', 'Block3DVoronoi', ...
          'EquatorialYZVoronoi', 'SolidHemisphere3D', 'test', 'test1', 'testXY', ...
          'testXZ', 'testYZ' } ), 1 ) );
    isFull3D = isVolumetricMesh( m );
    if isFull3D
        % This is a rough approximation to the surface area of the mesh.
        mesharea = (pi/4)*prod(max(m.FEnodes,[],1) - min(m.FEnodes,[],1))^(2/3);
    else
        mesharea = m.globalDynamicProps.currentArea;
    end
    
    defaultNumCells = 20;
    
    % For all modes that create a continuous sheet of cells over the whole mesh,
    % numcells, absdiam, reldiam, absarea, and relarea are dependent on
    % each other, and only one should be specified.
    fullcover = any( strcmp( s.mode, {'universal', 'voronoi', 'grid'} ) );
    if fullcover
        s.add = false;
        % Exactly one of numcells, absdiam, reldiam, absarea, and relarea
        % should be specified.
        numargs = (s.numcells > 0) + (s.absdiam > 0) + (s.reldiam > 0) + (s.absarea > 0) + (s.relarea > 0);
        if numargs == 0
            fprintf( 1, [ '%s: for mode ''%s'', exactly one of ''numcells'', ''absdiam'', ' ...
                          '''reldiam'', ''absarea'', and ''relarea''\nmust be supplied. ' ...
                          'Defaulting to numcells=20.\n' ], ...
                mfilename(), s.mode );
            s.numcells = defaultNumCells;
        elseif numargs > 1
            fprintf( 1, [ '%s: for mode ''%s'', exactly one of ''numcells'', ''absdiam'', ' ...
                          '''reldiam'', ''absarea'', and ''relarea''\nshould be supplied. ' ...
                          'The first of those supplied will override the remainder.\n' ], ...
                mfilename(), s.mode );
        end
        meshdiam = sqrt(mesharea*4/pi);
        if s.numcells > 0
            s.reldiam = 1/sqrt(s.numcells);
            s.absdiam = meshdiam*s.reldiam;
            s.relarea = 1/s.numcells;
            s.absarea = s.relarea*mesharea;
        elseif s.relarea > 0
            s.numcells = round( 1/s.relarea );
            s.absarea = s.relarea*mesharea;
            s.reldiam = 1/sqrt(s.numcells);
            s.absdiam = meshdiam*s.reldiam;
        elseif s.absarea > 0
            s.relarea = s.absarea/mesharea;
            s.numcells = round( 1/s.relarea );
            s.reldiam = 1/sqrt(s.numcells);
            s.absdiam = meshdiam*s.reldiam;
        elseif s.reldiam > 0
            s.absdiam = meshdiam*s.reldiam;
            s.numcells = round( 1/(s.reldiam^2) );
            s.relarea = 1/s.numcells;
            s.absarea = s.relarea*mesharea;
        else % s.absdiam > 0
            s.reldiam = s.absdiam/meshdiam;
            s.numcells = round( s.reldiam^2 );
            s.relarea = 1/s.numcells;
            s.absarea = s.relarea*mesharea;
        end
    end
    
    if isfield( s, 'numcells' ) && (s.numcells < 0)
        s.numcells = defaultNumCells;
    end
    
    fprintf( 1, 'Making %d cells.\n', s.numcells );
    
    if ~s.add
        m.secondlayer = deleteSecondLayerCells( m.secondlayer );
    end

    olddata = struct( 'numcells', length(m.secondlayer.cells), ...
                      'numedges', size(m.secondlayer.edges,1), ...
                      'numvxs', length(m.secondlayer.vxFEMcell) );
    
    if ~haveexternaldata
        if s.sides < 3
            s.sides = 3;
        end
        
        if s.absdiam > 0
            celldiameter = s.absdiam;
        elseif s.absarea > 0
            celldiameter = sqrt(4*s.absarea/pi);
        elseif s.reldiam > 0
            celldiameter = s.reldiam * sqrt(mesharea);
        elseif s.relarea > 0
            cellarea = s.relarea * mesharea;
            celldiameter = sqrt(cellarea*4/pi);
        elseif s.relinitarea > 0
            cellarea = s.relinitarea * m.globalProps.initialArea;
            celldiameter = sqrt(cellarea*4/pi);
        elseif ~useMakeCellGrid && (~strcmp( s.mode, 'full' )) && (~strcmp( s.mode, 'voronoi' )) && (~strcmp( s.mode, 'hex' )) && (~strcmp( s.mode, 'empty' ))
            complain( '%s: no cell size found for mode "%s": use one of absdiam, absarea, reldiam, or relarea.', ...
                mfilename(), s.mode );
            ok = false;
            return;
        end
        
        if ~isempty(s.probpervx)
            if ischar(s.probpervx) || (numel(s.probpervx)==1)
                mgenIndex = FindMorphogenIndex( m, s.probpervx );
                if isempty(mgenIndex)
                    if ischar(s.probpervx)
                        fprintf( 1, '%s: morphogen %s not found.\n', s.probpervx );
                    else
                        fprintf( 1, '%s: morphogen %d not found.\n', s.probpervx );
                    end
                    s.probpervx = [];
                    return;
                else
                    s.probpervx = m.morphogens(:,mgenIndex(1));
                end
            end
        end
    end
    
    if ~useMakeCellGrid && (~haveexternaldata) && (celldiameter <= 0)
        fprintf( 1, '%s: Cannot fill the mesh with cells of requested diameter zero.\n', mfilename() );
        ok = false;
        return;
    end

    if isempty( s.colors )
        s.colors = m.globalProps.colors;
    end
    if isempty( s.colorvariation )
        s.colorvariation = m.globalProps.colorvariation;
    end
    if (~isempty( s.colors )) || (~isempty( s.colorvariation ))
        if ~isempty( s.colors )
            m.globalProps.colors = s.colors;
        end
        if ~isempty( s.colorvariation )
            m.globalProps.colorvariation = s.colorvariation;
        end
        m.globalProps.colorparams = ...
            makesecondlayercolorparams( m.globalProps.colors, ...
                                        m.globalProps.colorvariation );
    end

%     if strcmp( s.mode, 'few' ) && (s.numcells >= size( m.tricellvxs, 1 ))
%         s.mode = 'each';
%     end

    numoldcells = length(m.secondlayer.cells);
    switch s.mode
            
        case { 'radial', 'rectgrid', 'circlegrid', 'latlong', 'box', ...
               'spherebox', 'MakePrim3DGrid', 'MakePrim3DVoronoi', 'Block3DVoronoi', 'EquatorialYZVoronoi', ...
               'SolidHemisphere3D', 'test', 'test1', 'testXZ', 'testYZ', ...
               'testXY' }
            % These types are all constructed by makeCellGrid().
            if isempty( s.divisions )
                fprintf( 1, '%s: for mode ''%s'', the ''divisions'' option must be supplied. No cells created\n', ...
                    mfilename(), s.mode );
                return;
            end
            bbox = meshbbox( m, false, 0 );
            if isempty(s.magnitude)
                s.magnitude = bbox(2,:)-bbox(1,:);
            end
            if isempty( s.centre )
                s.centre = sum(bbox,1)/2;
            end
            [sl,m,ok] = makeCellGrid( s.mode, s.magnitude, s.centre, s.divisions, s.subdivisions, s.plane, s.add, s.hemisphere, s.range, m, s.numcells );
            if ~ok
                fprintf( 1, '%s: interrupted, cellular layer not made.\n', mfilename() );
                clearstopbutton( m );
                return;
            end
            xxxx = 1;
        case 'hex'
            numoldcells = 0;
            m = makeSecondlayerHexgrid( m, s.hexrows, s.hexperrow );
        case 'universal'
            totalCells = sum( m.cellareas )/(celldiameter*pi/4);
            fprintf( 1, 'About to make "%s" layer of about %d cells.\n', s.mode, totalCells );
            numoldcells = 0;
            if isFull3D
                m = makesecondlayeruniversal3D( m, celldiameter );
            else
                m = makesecondlayeruniversal( m, celldiameter );
            end
        case 'external'
            fprintf( 1, 'About to make "%s" layer of %d cells.\n', s.mode, length( s.celldata ) );
            m = makeExternCells( m, s.vertexdata, s.celldata );
            m = setSecondLayerColorInfo( m, s.colors, s.colorvariation );
            if ~isfield( m.secondlayer, 'cellcolor' )
                m.secondlayer.cellcolor = [];
            end
            if (size(s.cellcolors,1)==length(s.celldata)) && (size(s.cellcolors,2)==3)
                m.secondlayer.cellcolor = [ m.secondlayer.cellcolor; s.cellcolors ];
            else
                m.secondlayer.cellcolor = [ m.secondlayer.cellcolor; ...
                    randcolor( length(s.celldata), ...
                         m.globalProps.colorparams(1,[1 2 3]), ...
                         m.globalProps.colorparams(1,[4 5 6]) ) ];
            end
            m.secondlayer.cloneindex = [ m.secondlayer.cloneindex; ...
                                         zeros( length(s.celldata), 1 ) ];
            m.secondlayer.side = [ m.secondlayer.side;
                                   true( length(s.celldata), 1 ) ];
        case 'grid'
            numoldcells = 0;
            m = makeSquareCellGrid( m, celldiameter, s.allowoveredge );
        case 'cylindergrid'
            numoldcells = 0;
            m = makeCellCylinderGrid( m, celldiameter, s.allowoveredge );
        case 'voronoi'
            numoldcells = 0;
            fprintf( 1, 'About to make "%s" layer of %d cells.\n', s.mode, s.numcells );
            m = makeVoronoiBioA( m, s.numcells, 8, [], s.colors, s.colorvariation, s.cellcolors );
        case 'full'
            numoldcells = 0;
            totalCells = getNumberOfFEs(m) * (s.refinement*(s.refinement-1)*3/2 + 1);
            fprintf( 1, 'About to make "%s" layer of %d cells.\n', s.mode, totalCells );
            m = makeFullSecondlayer2( m, s.refinement );
        case 'singleOBSOLETE'
            if s.axisratio ~= 1
                m = calcPolGrad( m );
            end
            [m,ok1] = addRandomSecondLayerCell( m, ...
                        celldiameter, s.axisratio, s.sides, 2, [], ...
                        s.allowoverlap, s.allowoveredge, s.cellcolors );
            m = addNewCellIDData( m, length(m.secondlayer.cells) - numoldcells );
            if ~ok1
                fprintf( 1, '%s: new cell overlapped old cells, not created.\n', mfilename() );
            end
        case 'fewOBSOLETE'
            if s.axisratio ~= 1
                m = calcPolGrad( m );
            end
            if s.numcells > 1
                numFEs = size( m.tricellvxs, 1 );
                maxtries = 10; % ceil(s.numcells * 1.5);
                tries = 1;
                numremaining = s.numcells;
                while (tries <= maxtries) && (numremaining >0)
                    fprintf( 1, 'Pass %d: trying to make %d cells.\n', tries, numremaining );
                    cells = randchoiceseq( numFEs, numremaining, numFEs*0.75, numFEs*2 );
                    for i=1:numremaining
                        cellcolor = randcolor( 1, ...
                                        m.globalProps.colorparams(1,[1 2 3]), ...
                                        m.globalProps.colorparams(1,[4 5 6]) );
                        [m,ok1] = addRandomSecondLayerCell( m, ...
                                    celldiameter, s.axisratio, s.sides, 2, cells(i), ...
                                    s.allowoverlap, s.allowoveredge, cellcolor );
                        if ok1
                            numremaining = numremaining-1;
                        end
                    end
                    tries = tries+1;
                end
                if numremaining > 0
                    fprintf( 1, '%s: %d cells requested, only %d created due to overlaps.\n', ...
                        mfilename(), s.numcells, s.numcells-numremaining );
                end
            else
                [m,ok1] = addRandomSecondLayerCell( m, ...
                            celldiameter, s.axisratio, s.sides, 2, [], ...
                            s.allowoverlap, s.allowoveredge, s.cellcolors );
                if ~ok1
                    fprintf( 1, '%s: new cell overlapped old cells, not created.\n', mfilename() );
                end
            end
            m = addNewCellIDData( m, length(m.secondlayer.cells) - numoldcells );
        case 'scatter'  % Formerly called 'each'.
            s.probpervx = max( 0, s.probpervx );
            s.probperFE = max( 0, s.probperFE );
            if ~isempty(s.probpervx)
                s.probperFE = sum( s.probpervx(m.tricellvxs), 2 )/size(m.tricellvxs,2);
            end
            if isempty(s.probperFE) || all( s.probperFE==0 )
                probperFE = m.cellareas;
            else
                probperFE = s.probperFE .* m.cellareas;
            end
            cumprobperFE = cumsum( probperFE );
            cumprobperFE = cumprobperFE/cumprobperFE(end);
            cis = genrand( cumprobperFE, s.numcells );
            if s.axisratio ~= 1
                m = calcPolGrad( m );
            end
            numcreated = 0;
            for i=1:length(cis)
                if i > size(s.cellcolors,1)
                    cellcolor = [];
                else
                    cellcolor = s.cellcolors(i,:);
                end
                [m,ok1] = addRandomSecondLayerCell( m, ...
                            celldiameter, s.axisratio, s.sides, 1, cis(i), ...
                            s.allowoverlap, s.allowoveredge, cellcolor );
                if ok1
                    numcreated = numcreated+1;
                end
            end
            m = addNewCellIDData( m, length(m.secondlayer.cells) - numoldcells );
            if numcreated < s.numcells
                fprintf( 1, '%s: %d cells requested, only %d created due to overlaps.\n', ...
                    mfilename(), s.numcells, numcreated );
            end
        case 'empty'
            % Nothing.
        otherwise
            fprintf( 1, '%s: unknown mode "%s".\n', mfilename(), s.mode );
            return;
    end
    
    m = completesecondlayer( m );
    
    if (s.refinement > 1) && (length(m.secondlayer.cells) > numoldcells)
        m = leaf_refinebioedges( m, 'refinement', s.refinement, 'cells', (numoldcells+1):length(m.secondlayer.cells) );
    end
    
    [ok,m.secondlayer] = checkclonesvalid( m.secondlayer );
end

    
