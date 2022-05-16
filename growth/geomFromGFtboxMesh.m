function g = geomFromGFtboxMesh( m )

    g = Geometry3D( 'vxs', m.FEnodes, 'vxsets', m.FEsets(1).fevxs );
end