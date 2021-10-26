 function [m,ok] = addRandomSecondLayerCell( m, ...
                        diameter, axisratio, numsides, cloneindex, ...
                        ci, allowoverlap, allowoveredge, cellcolor )
%m = addRandomSecondLayerCell( m, ...
%                       diameter, axisratio, numsides, cloneindex, ...
%                       ci, allowoverlap, cellcolor )
%   Add a second layer cell at a random position within the FEM cell ci. If
%   ci is omitted, a random FEM cell will be chosen.
%   The new cell will have NUMSIDES sides.  DIAMETER is the diameter of the cell,
%   in absolute units.
%   If allowoverlap is false, it will not create the new cell if it
%   overlaps any existing cell.
%   If allowoveredge is false, it will not create the new cell if it
%   overlaps the edge of the mesh.

    ok = true;
    if (nargin < 5) || isempty(cloneindex)
        cloneindex = 1;
    end
    if (nargin < 6) || isempty(ci)
        ci = randi( [1, getNumberOfFEs(m)] );
    end
    if (nargin < 7) || isempty(allowoverlap)
        allowoverlap = true;
    end
    if (nargin < 8) || isempty(allowoveredge)
        allowoveredge = true;
    end
    if nargin < 9
        cellcolor = [];
    end
    
    newci = numcellsBioA( m.secondlayer ) + 1;
    bccentre = randBaryCoords(1);  % [1 1 1]/3;
    femVxs = m.nodes( m.tricellvxs( ci, : ), : );
    cellcentre = bccentre * femVxs;
    cellradius = diameter/2; % sz * sqrt(m.globalDynamicProps.currentArea);
    % Test if cell center is within cellradius of any other vertex of the
    % bio layer.
    if ~allowoverlap
        cellradiussq = cellradius*cellradius;
        for i=1:size(m.secondlayer.cell3dcoords,1)
            if sum((m.secondlayer.cell3dcoords(i,:) - cellcentre).^2) < cellradiussq
                % Do not create new cell.
                ok = false;
                return;
            end
        end
    end
    havegradient = any( m.gradpolgrowth(ci,:) ~= 0 );
    if havegradient && (axisratio ~= 1)
        if ~isfield( m, 'cellFrames' ) || isempty( m.cellFrames )
            m = makeCellFrames( m );
        end
        J = m.cellFrames(:,[3,1,2],ci);
        adjustment = sqrt( axisratio );
        cellpts = circlepoints( cellradius, cellcentre, numsides, ...
            0, J(:,2)'*adjustment, J(:,3)'/adjustment );
    else
        n = m.unitcellnormals(ci,:);
        J = makebasis( n );
        cellpts = circlepoints( cellradius, cellcentre, numsides, ...
            rand(1), J(:,2)', J(:,3)' );
    end
    cis = zeros(size(cellpts,1),1);
    bcs = zeros(size(cellpts,1),3);
    bcerr = zeros(size(cellpts,1),1);
    abserr = zeros(size(cellpts,1),1);
    for i = 1:size(cellpts,1)
        [ cis(i), bcs(i,:), bcerr(i), abserr(i) ] = findFE( m, cellpts(i,:), 'hint', ci );
    end
    if ~allowoveredge
        badbcs = any( bcs==0, 2 ) & (bcerr < 0);
        if any( badbcs )
            % Cell overlaps edge of mesh -- do not create.
            ok = false;
            return;
        end
    end

    numvertexes = length( m.secondlayer.vxFEMcell );
    numedges = size( m.secondlayer.edges, 1 );

    newvi = numvertexes+1 : numvertexes+numsides;
    newei = numedges+1 : numedges+numsides;
    
    if cloneindex==1
        colorindex = 1;
    else
        colorindex = 2;
    end
    colorindex = trimnumber( 1, colorindex, size( m.globalProps.colorparams, 1 ) );
    if ~isempty(cellcolor)
        m.secondlayer.cellcolor(newci,:) = cellcolor(1,:);
    elseif isempty(m.secondlayer.cells) || ~isempty( m.secondlayer.cellcolor )
        m.secondlayer.cellcolor(newci,:) = ...
            secondlayercolor( 1, m.globalProps.colorparams(colorindex,:) );
    end
    m.secondlayer.cells(newci).vxs = newvi;
    m.secondlayer.cells(newci).edges = newei;
    m.secondlayer.cloneindex(newci,:) = cloneindex;
    m.secondlayer.side(newci,1) = rand(1) < 0.5;
    
    m.secondlayer.vxFEMcell(newvi,1) = cis;
    m.secondlayer.vxBaryCoords(newvi,:) = bcs;
    
    newedges = int32( [ newvi', ...
                        [ newvi(2:end)'; numvertexes+1], ...
                        ones(numsides,1)*newci, ...
                        zeros(numsides,1) ...
                      ] );
    m.secondlayer.edges( newei, : ) = newedges;
    m = calcCloneVxCoords( m, newvi );
    m = setSplitThreshold( m, 1.05, newci );
end
