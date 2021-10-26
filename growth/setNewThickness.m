function m = setNewThickness( m, th )
%m = setNewThickness( m, th )
%   th is a vector of real numbers, one per vertex of the mesh.
%   This routine sets the thickness of the mesh at each vertex to be the
%   corresponding value of th.  For this to be effective,
%   m.globalProps.physicalThickness should be set to true.

    numnodes = size(m.nodes,1);
    asidei = 1:2:(numnodes*2-1);
    bsidei = 2:2:(numnodes*2);
    verticals = m.prismnodes( bsidei, : ) - m.prismnodes( asidei, : );
    vlens = sqrt(sum( verticals.*verticals, 2 ));
    ratios = (th(:)./vlens)/2;
    verticals(:,1) = verticals(:,1) .* ratios;
    verticals(:,2) = verticals(:,2) .* ratios;
    verticals(:,3) = verticals(:,3) .* ratios;
    m.prismnodes( bsidei, : ) = m.nodes + verticals;
    m.prismnodes( asidei, : ) = m.nodes - verticals;
end