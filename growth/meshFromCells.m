function [m,ok] = meshFromCells( vvxs, vcells, centroids, edgedivs )
%m = meshFromCells( vvxs, vcells )
%   Create a mesh from a set of biological cells.
%
%   vvxs is an N*3 array of N vertexes, and vcells is a C*1 cell array
%   listing the vertexes of each cell.  centroids, if supplied, is a C*3
%   array giving the position of a point within each cell.  If not
%   supplied, it defaults to the average of all the vertexes belonging to
%   that cell.

    m = [];
    numedgevxs = size(vvxs,1);
    numcells = length(vcells);
    if (nargin < 3) || isempty(centroids)
        centroids = zeros( numcells, size(vvxs,2) );
        for i=1:numcells
            centroids(i,:) = sum( vvxs( vcells{i}, : ), 1 )/length(vcells{i});
        end
    end
    numstaredges = 0;
    for i=1:numcells
        numstaredges = numstaredges + length(vcells{i});
    end
    m.nodes = [ vvxs; centroids ];
    
    m.tricellvxs = zeros( numstaredges, 3 );
    m.edgeends = zeros( numstaredges*2, 2 );
    numFEs = 0;
    cellnumsegments = zeros( numcells, 1 );
    for i=1:numcells
        vvi = vcells{i}(:);
        cellnumsegments(i) = length(vvi);
        cellFEs = [ repmat( numedgevxs+i, length(vvi), 1 ), vvi(:), vvi([2:end,1]') ];
        m.tricellvxs( (numFEs+1):(numFEs+length(vvi)), : ) = cellFEs;
        numFEs = numFEs+length(vvi);
    end
    [m,ok] = setmeshfromnodes( m, [] );
    numedges = size( m.edgeends, 1 );
    
    % Find the bio cell centres.
    m.vvlayer.iscellcentre = [ false( numedgevxs, 1 ); true( numcells, 1 ) ];
    m.vvlayer.cellcentres = find(m.vvlayer.iscellcentre);
    
    m.vvlayer.vxVVtoFE = 1:numedgevxs;
    m.vvlayer.vxFEtoVV = [ zeros(1,numedgevxs), 1:numcells ];
    m.vvlayer.cells(numcells) = struct( ...
        'vertexes', [], ...
        'edges', [], ...
        'intFEvxs', [], ...
        'centroidFE', [], ...
        'centroidBC', [] );
    
    % Make all edges between bio cell centres and cell walls go from the
    % former to the latter.
    edgesToFlip = m.vvlayer.iscellcentre( m.edgeends(:,2) );
    m.edgeends( edgesToFlip, : ) = m.edgeends( edgesToFlip, [2 1] );

    m.vvlayer.edgeVVtoFE = find( ~edgesToFlip );
    m.vvlayer.edgeFEtoVV = zeros( 1, size(m.edgeends,1) );
    m.vvlayer.edgeFEtoVV( ~edgesToFlip ) = 1:length(m.vvlayer.edgeVVtoFE);


    % Find the bio cell edges.
    m.vvlayer.iscellwall = ~any( m.vvlayer.iscellcentre( m.edgeends ), 2 );
    m.vvlayer.cellwallindexes = find(m.vvlayer.iscellwall);

    % Create empty arrays for cell and wall properties.
    numwalls = length(m.vvlayer.cellwallindexes);
    m.vvlayer.cellproperties = zeros( numcells, 0 );
    m.vvlayer.wallproperties = zeros( numwalls, 0 );
    
    % To build the edge vertex properties, we have to, for each edge,
    % divide it into segments of equal length (approximately the same
    % segment length for all edges), and represent the properties of each
    % segment as three values per segment-end, excluding the ends of the
    % whole edge.
    
    wallends = reshape( m.nodes( m.edgeends( m.vvlayer.cellwallindexes, : )', : ), ...,
                        2, [], 3 );
    walllengths = sqrt( sum( (wallends( 2, :, : ) - wallends( 1, :, : )).^2, 3 ) )';
%     maxwl = max( walllengths );
%     minwl = min( walllengths );
%     MAXWALLSEGMENTS = 10;
%     MINWALLSEGMENTS = 3;
    %r = max( min( maxwl/minwl, MAXWALLSEGMENTS ), MINWALLSEGMENTS );
    %m.vvlayer.targetwallseglength = maxwl/r;

    avwl = sum(walllengths)/length(walllengths);
    m.vvlayer.targetwallseglength = avwl/edgedivs;
    
    m.vvlayer.numedgesegments = zeros( numedges, 1 );
    for i=1:numwalls
        numsegvxs = max( 1, round( walllengths(i)/m.vvlayer.targetwallseglength ) );
        ei = m.vvlayer.cellwallindexes(i);
        m.vvlayer.numedgesegments(ei) = numsegvxs;
    end
    
    % m.vvlayer.vxCellToFE = 
    
    % For the bio vertexes around each cell wall intersection, if there are
    % N cells meeting at the vertex (where the outside counts as a notional
    % cell), then we need N bio vertexes, to be listed in the same order
    % as in m.nodecelledges.
    m.vvlayer.vertexcluster = cell( size(m.nodes,1), 1 );
    for vi = m.vvlayer.cellcentres'
        nce = m.nodecelledges{vi};
        eis = nce(1,:);
        end2 = m.edgeends(eis,2)~=vi;
        vis = m.edgeends(eis,1);
        vis(end2) = m.edgeends(eis(end2),2);
        vxs = m.nodes( vis, : );
        vx = m.nodes(vi,:);
        foo = 0.2;  % NOT FULLY IMPLEMENTED
        m.vvlayer.vertexcluster{vi} = (1-foo)*vxs + foo*repmat( vx, size(vxs,1), 1 );
    end
    
    % Compartments:
    %   1: cell interior
    %   2: cell membrane
    %   3: cell wall
    m.vvlayer.vertexToCompartment = [ ...
        ones(numcells,1); ...
        ones(numwallvxs*2,1):2; ...
        ones(numwallvxs,1):3 ];
    m.vvlayer.vertexToCell = [];
        % a cell index for each cell and membrane vertex.
        % zero for wall vertexes.
    m.vvlayer.vertexToEdge = [];
        % an edge index for each wall and membrane vertex.
        % zero for cell vertexes.
    m.vvlayer.vertexNbs = [];
        % list of vertex indedxes of all immediate neighbours of the vertex.
    m.vvlayer.vertexValues = [];
        % Values of all morphogens for all vertexes.
end
