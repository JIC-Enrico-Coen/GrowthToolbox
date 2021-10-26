function m = setzeroz( m, uniformThickness )
%m = setzeroz( m )
%   Set z coordinates of the mesh to zero.

    if nargin < 2
        uniformThickness = false;
    end

    vt = vertexThicknesses( m );
    if uniformThickness
        vt(:) = mean(vt);
    end
    m.nodes(:,3) = 0;
    m = setVertexThicknesses( m, vt );
    m = recalc3d( m );
    m.initialbendangle = m.currentbendangle;
end
