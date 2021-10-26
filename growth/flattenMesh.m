function m = flattenMesh( m, uniformThickness )
%m = setzeroz( m )
%   Set thecoordinates of the mesh in its thinnest dimension to zero.

    if nargin < 2
        uniformThickness = false;
    end

    if isempty( m.globalInternalProps.flataxes )
        m.globalInternalProps.flataxes = getFlatAxes( m );
    end
    z = m.globalInternalProps.flataxes(3);
    
    vt = vertexThicknesses( m );
    if uniformThickness
        vt(:) = mean(vt);
    end
    m.nodes(:,z) = 0;
    m = setVertexThicknesses( m, vt );
    m = recalc3d( m );
    m.initialbendangle = m.currentbendangle;
end
