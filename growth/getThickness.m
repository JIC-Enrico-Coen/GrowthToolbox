function thicknesses = getThickness( m )
%t = getThickness( m )
%   Return the thickness of the mesh at every vertex.

    numpnodes = size( m.prismnodes, 1 );
    delta = m.prismnodes( 1:2:(numpnodes-1), : ) - ...
            m.prismnodes( 2:2:numpnodes, : );
    thicknesses = sqrt( sum( delta.^2, 2 ) );
end
