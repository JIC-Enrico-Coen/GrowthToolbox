function ts = meshThickness( m, vis )
%ts = meshThickness( m, vis )
%   Compute the thickness of the mesh at each vertex in vis.  If vis is
%   omitted, the thickness at every vertex is returned, as a column vector.

    if nargin < 2
        vis = 1:size(m.nodes,1);
    end
    
    pvis2 = vis*2;
    pvis1 = pvis2-1;
    verticals = m.prismnodes(pvis2,:) - m.prismnodes(pvis1,:);
    ts = sqrt(sum(verticals.*verticals,2));
end
