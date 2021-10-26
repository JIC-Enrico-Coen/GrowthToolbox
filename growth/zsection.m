function [vxs,edgeends,polys,colors] = zsection( m, w, windex )
%[vxs,edgeends,colors] = zsection( m, w, windex )
%   Determine the intersection of m with a plane perpendicular to one of
%   the axes at value w.  windex specifies which axis (1=X, 2=Y, 3=Z), by
%   default 3.

    vxs = [];
    edgeends = [];
    polys = [];
    colors = [];
    if nargin < 3
        windex = 3;
    end
    otherindexes = mod( [windex, windex+1], 3 ) + 1
    
    % Determine which nodes lie below the section.
    [wsort,wperm] = sort( m.prismnodes(:,windex) );
    % wsort = m.prismnodes(wperm,windex)
    mbelow = m.prismnodes(:,windex) < w;
    mbelow = reshape( mbelow, 2, [] )';
    a_below = mbelow(:,1);
    b_below = mbelow(:,2);
    
    % Determine which edges and FEs intersect the section.
    % A-side edges.
    a_edgeendsbelow = a_below( m.edgeends );
    a_crossedgesmap = a_edgeendsbelow(:,1) ~= a_edgeendsbelow(:,2);
    a_crossnodes = m.edgeends( a_crossedgesmap, : );
    a_crossFEsmap = any( a_crossedgesmap(m.celledges), 2 );
    % B-side edges.
    b_edgeendsbelow = b_below( m.edgeends );
    b_crossedgesmap = b_edgeendsbelow(:,1) ~= b_edgeendsbelow(:,2);
    b_crossnodes = m.edgeends( b_crossedgesmap, : );
    b_crossFEsmap = any( b_crossedgesmap(m.celledges), 2 );
    % Through edges
    through_nodesmap = a_below ~= b_below;
    through_nodes = find(through_nodesmap);
    through_edgeends = through_nodes(:)*2;
    through_edgeends = [ through_edgeends-1, through_edgeends ];
    t_crossFEsmap = any( through_nodesmap(m.tricellvxs), 2 );
    all_crossFEsmap = a_crossFEsmap | b_crossFEsmap | t_crossFEsmap;
    
    all_crossedgeends = [ a_crossnodes*2-1; b_crossnodes*2; through_edgeends ];
    wpairs = reshape( m.prismnodes( all_crossedgeends', windex ), 2, [] )';
    node2pairs = permute( ...
        reshape( m.prismnodes( all_crossedgeends', otherindexes ), 2, [], 2 ), ...
        [ 2, 3, 1 ] );

    q = (w - wpairs(:,1)) ./ (wpairs(:,2) - wpairs(:,1));
    p = 1-q;
    
    vxs = [ p.*node2pairs(:,1,1) + q.*node2pairs(:,1,2), ...
            p.*node2pairs(:,2,1) + q.*node2pairs(:,2,2) ];
    
    % Find all pairs of A-side crossing edges that belong to the same FE.
    % Each such pair gives an edge of the intersection polygon.
    numedges1 = size(a_crossnodes,1);
    a_edgemapping = int16(a_crossedgesmap);
    a_edgemapping(a_crossedgesmap) = 1:numedges1;
    a_crossFEmap = sum( a_crossedgesmap(m.celledges), 2 ) > 1;
    a_edges2 = a_edgemapping(m.celledges( a_crossFEmap, : )');
    a_edges2 = reshape( a_edges2( a_edges2 > 0 ), 2, [] )'

    numedges2 = numedges1 + size(b_crossnodes,1);
    b_edgemapping = int16(b_crossedgesmap);
    b_edgemapping(b_crossedgesmap) = (numedges1+1):numedges2;
    b_crossFEmap = sum( b_crossedgesmap(m.celledges), 2 ) > 1;
    b_edges2 = b_edgemapping(m.celledges( b_crossFEmap, : )');
    b_edges2 = reshape( b_edges2( b_edges2 > 0 ), 2, [] )'

    numedges3 = numedges2 + size(through_nodes,1);
    t_nodemapping = int16( through_nodesmap );
    t_nodemapping( through_nodesmap ) = (numedges2+1):numedges3;
    t_crossFEmap = sum( through_nodesmap(m.tricellvxs), 2 ) > 1;
    t_edges2 = t_nodemapping(m.tricellvxs( t_crossFEmap, : )');
    t_edges2 = reshape( t_edges2( t_edges2 > 0 ), 2, [] )'
    
    % AT edges
    
    % BT edges
    
    % AB edges
end
