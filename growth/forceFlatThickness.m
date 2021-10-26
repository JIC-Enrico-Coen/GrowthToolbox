function m = forceFlatThickness( m )
%m = forceFlatThickness( m )
%   Set m.prismnodes from m.nodes, assuming a thickness of
%   m.globalDynamicProps.thicknessAbsolute and that the mesh is flat in the XY
%   plane.

    numnodes = size(m.nodes,1);
    delta = m.globalDynamicProps.thicknessAbsolute/2;
    offset = repmat( [0,0,delta], numnodes, 1 );
    m.prismnodes(2:2:(numnodes*2),:) = m.nodes + offset;
    m.prismnodes(1:2:(numnodes*2-1),:) = m.nodes - offset;
    m = recalc3d(m);
end
