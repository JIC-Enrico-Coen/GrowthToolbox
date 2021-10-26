function [m,ok] = makeVoronoiBioA( m, numBioCells, numiters, amount, color, colorvariation, cellcolors )
%m = makeVoronoiBioA( m, numpoints )
%   Generate a bio-A layer by the Voronoi method.  This only applies if
%   the mesh is flat in the XY plane or nearly so.  The layer will contain
%   numBioCells cells.

    ok = true;
    if (nargin < 3) || isempty(numiters)
        numiters = 8;
    end
    if (nargin < 4) || isempty(amount)
        amount = 1;
    end
    if (nargin < 5) || isempty(color)
        color = [];
    end
    if (nargin < 6) || isempty(colorvariation)
        colorvariation = [];
    end
    if (nargin < 7) || isempty(cellcolors)
        cellcolors = [];
    end
    numBioCells = double(numBioCells);
    
    % Select n points at random over the mesh.
    [cells,vxBaryCoords] = randInTriangles( m.cellareas, numBioCells );
    vxGlobalCoords = meshBaryToGlobalCoords( m, cells, vxBaryCoords )';
    xyCoords = vxGlobalCoords([1 2],:);
    
    % Use CVT to arrange them into a centroidal Voronoi tesselation.
    for i=1:numiters
        xyCoords = ...
                cvt_iterate( ...
                    2, ...
                    numBioCells, ...
                    1000, ...
                    3, ... % METHOD
                    0, ... % INITIALIZE
                    40, ... % 10000, ... % SAMPLE_NUM
                    0, ... % SEED
                    xyCoords, ... % 
                    amount, ... % 
                    'meshcells', ... % 
                    m, ... % 
                    [] );

        if 0
            figure(1);
            clf;
            voronoi(vxGlobalCoords(1,:),vxGlobalCoords(2,:));
            hold on;
          %  tri = delaunay(gc(:,1),gc(:,2);
          %  fill( reshape( r(1,tri'), 3, [] ), reshape( r(2,tri'), 3, [] ), 'w', 'FaceColor', 'none' );
            axis equal;
            hold off;
            drawnow;
          % pause;
        end
    end
    vxGlobalCoords = [xyCoords; vxGlobalCoords(3,:)]';
    savedCellNormals = m.unitcellnormals;
    numElements = size(m.tricellvxs,1);
    m.unitcellnormals = [ zeros(numElements,2), ones(numElements,1) ];
    
    
    
    

    % Generate the cell and edge information required by the bio-A layer.
    vmin = min( vxGlobalCoords(:,1:2) );
    vmax = max( vxGlobalCoords(:,1:2) );
    vcentre = (vmin + vmax)/2;
    semidiam = (vmax - vmin)/2;
    a = semidiam(1);
    b = semidiam(2);
    c = a+a+b;
    e = b*1.2;
    d = (e+c)*0.6;
    vprotect = [ (vcentre(1) + [0; d; -d]), (vcentre(2) + [-c; e; e]) ];
    [bioa_vg,bioa_c] = voronoin( [ vxGlobalCoords(:,1:2); vprotect ] );
    % Remove the cells containing the protection points.
    bioa_c = bioa_c(1:(length(bioa_c)-3));
    % Ensure that all polygons are listed in anticlockwise order.
    ac = isAnticlockwisePoly2D( bioa_vg, bioa_c );
    for i=find(~ac')
        xx = bioa_c{i};
        bioa_c{i} = xx( end:(-1):1 );
    end
    % iscyclic = cyclicAngles( angles )
    
    if 0
        figure(2);
        clf;
        hold on;
        for i=1:length(bioa_c)
            cvs = bioa_c{i};
            cvs = [ cvs, cvs(1) ];
            plot( bioa_vg(cvs,1), bioa_vg(cvs,2), '-' );
          % pause;
        end
        hold off;
    end

    [bioa_vg,bioa_c] = truncateCells( m, bioa_vg, bioa_c, ...
        1:numElements, true( 1, numElements ) );
    if isempty(bioa_vg)
        % Cannot complete layer.
        fprintf( 1, '**** Cannot construct Voronoi tessellation of cells.  Try "universal" method instead.\n' );
        ok = false;
        return;
    end
    
    ac = isAnticlockwisePoly2D( bioa_vg, bioa_c );
    if ~all(ac)
        xxxx = 1;
    end
    if 0
        figure(3);
        clf;
        hold on;
        for i=1:length(bioa_c)
            cvs = bioa_c{i};
            cvs = [ cvs, cvs(1) ];
            plot( bioa_vg(cvs,1), bioa_vg(cvs,2), '-' );
          % pause;
        end
        hold off;
    end
    [bioa_fc,bioa_vb] = meshGlobalToBaryCoords( m, [bioa_vg,ones(size(bioa_vg,1),1)] );
    m.unitcellnormals = savedCellNormals;
    bioa_vg = meshBaryToGlobalCoords( m, bioa_fc, bioa_vb );

    if 0
        figure(4);
        clf;
        hold on;
        for i=1:length(bioa_c)
            cvs = bioa_c{i};
            cvs = [ cvs, cvs(1) ];
            plot( bioa_vg(cvs,1), bioa_vg(cvs,2), '-' );
          % pause;
        end
        hold off;
    end

% For each cell ci:
%DONE    cells(ci).vxs(:)       A list of all its vertexes, in clockwise order.
%DONE    cells(ci).edges(:)     A list of all its edges, in clockwise order.
%           These cannot be 2D arrays, since different cells may have
%           different numbers of vertexes or edges.
%DONE    cellcolor(ci,1:3):     Its colour.
%XXXX   celllabel(ci,1):       Its label (an arbitrary integer). (OBSOLETE.)
%DONE   celltargetarea(ci)     The cells' target areas.  Initially equal to
%                              their current areas.
%DONE   cellarea(ci)           The cells' current areas.
%DONE   areamultiple(ci)       A morphogen, initially 1.  The effective
%                              target area is areamultiple*celltargetarea.
%DONE   cloneindex(ci)         An integer, used to distinguish clones.
%                              Inherited by descendants.
%
% For each clone vertex vi:
%DONE    vxFEMcell(vi)          Its FEM cell index.
%DONE    vxBaryCoords(vi,1:3)   Its FEM cell barycentric coordinates.
%DONE    cell3dcoords(vi,1:3)   Its 3D coordinates (which can be calculated
%                              from the other data).
% For each clone edge ei:
%DONE    edges(ei,1:4)          The indexes of the clone vertexes at its ends
%           and the clone cells on either side (the second one is 0 if absent).
%           This can be computed from the other data.
%DONE   generation(ei)         An integer recording the generation at which
%                              this edge was created.
%
% Other parameters:
%DONE    splitThreshold         ...
%DONE    colorparams            ...
%DONE    jiggleAmount           ...
%DONE    averagetargetarea      ...

    m = setSecondLayerColorInfo( m, color, colorvariation );
    m.secondlayer = deleteSecondLayerCells( m.secondlayer );
    m.secondlayer.vxFEMcell = bioa_fc;
    m.secondlayer.vxBaryCoords = bioa_vb;
    m.secondlayer.cell3dcoords = bioa_vg;
    

    m.secondlayer.cells = struct([]);
    for ci=1:numBioCells
        m.secondlayer.cells(ci).vxs = bioa_c{ci};
    end
    
    numBioVxs = size( bioa_vb, 1 );
    numBioEdges = 0;
    bioEdges = zeros( 0, 4 );
    es = zeros( numBioVxs, numBioVxs );
    for ci=1:numBioCells
        cvs = bioa_c{ci};
        nv = length(cvs);
        celledges = zeros( 1, nv );
        for i=1:nv
            j = mod(i,nv)+1;
            if true % cvs(i) < cvs(j)
                v1 = cvs(i);
                v2 = cvs(j);
            else
                v1 = cvs(j);
                v2 = cvs(i);
            end
            ei = es(v2,v1);
            if ei==0
                numBioEdges = numBioEdges+1;
                ei = numBioEdges;
                es(v1,v2) = ei;
                bioEdges( ei, : ) = [ v1, v2, ci, 0 ];
            else
                bioEdges( ei, 4 ) = ci;
            end
            celledges(i) = ei;
        end
        m.secondlayer.cells(ci).edges = celledges;
    end
    m.secondlayer.edges = bioEdges;
    m.secondlayer = purgeOldVxs( m.secondlayer );

%     m.secondlayer.side = true(numBioCells,1);
%     m = calcBioACellAreas( m );
%     m.secondlayer.areamultiple = ones( numBioCells, 1 );
%     m.secondlayer.celltargetarea = m.secondlayer.areamultiple * ...
%         (sum(m.secondlayer.cellarea)/numBioCells);
%     m.secondlayer.averagetargetarea = ...
%         sum(m.secondlayer.celltargetarea)/numBioCells;

    if (size(cellcolors,1)==numBioCells) && (size(cellcolors,2)==3)
        m.secondlayer.cellcolor = cellcolors;
    else
        m.secondlayer.cellcolor = randcolor( numBioCells, ...
                                             m.globalProps.colorparams(1,[1 2 3]), ...
                                             m.globalProps.colorparams(1,[4 5 6]) ); % ones( numBioCells, 3 );
    end
    m.secondlayer.cloneindex = zeros( numBioCells, 1 );
    m.secondlayer.generation = zeros( numBioEdges, 1 );
    m.secondlayer.edgepropertyindex = ones( numBioEdges, 1 );
    m.secondlayer.interiorborder = false( numBioEdges, 1 );
    
%     m.secondlayer.jiggleAmount = 0;
    m = setSplitThreshold( m, 1.05 );
    
    if size(m.secondlayer.cellvalues,1) < numBioCells
        m.secondlayer.cellvalues = ...
            [ m.secondlayer.cellvalues; ...
              zeros(numBioCells-size(m.secondlayer.cellvalues,1), size(m.secondlayer.cellvalues,2) ) ];
    end
    
    m = initialiseCellIDData( m );
    [ok,m.secondlayer] = checkclonesvalid( m.secondlayer );
    if ~ok
        complain( 'makeVoronoiBioA made an invalid layer.\n' );
    end
end

function secondlayer = purgeOldVxs( secondlayer )
    numcells = length( secondlayer.cells );
    numedges = size( secondlayer.edges, 1 );
    numvxs = length( secondlayer.vxFEMcell );
    foundVxs = false(1,numvxs);
    for ci=1:numcells
        foundVxs( secondlayer.cells(ci).vxs ) = true;
    end
    if ~all(foundVxs)
      % fprintf( 1, 'makeVoronoiBioA: purging vertexes:\n' );
      % lostVxs = find(~foundVxs)
        remainingVxs = find( foundVxs );
        renumberVxs = zeros(1,numvxs);
        renumberVxs( remainingVxs ) = 1:length(remainingVxs);
        for ci=1:numcells
            secondlayer.cells(ci).vxs = renumberVxs( secondlayer.cells(ci).vxs );
        end
        for ei=1:numedges
            secondlayer.edges(ei,[1 2]) = renumberVxs( secondlayer.edges(ei,[1 2]) );
        end
        secondlayer.vxFEMcell = secondlayer.vxFEMcell(remainingVxs);
        secondlayer.vxBaryCoords = secondlayer.vxBaryCoords(remainingVxs,:);
        secondlayer.cell3dcoords = secondlayer.cell3dcoords(remainingVxs,:);
    end
end
