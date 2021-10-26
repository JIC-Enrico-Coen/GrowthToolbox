function num = getNumQuadPointsPerFE( m )
    if isempty(m)
        num = 0;
    elseif usesNewFEs(m)
        num = size(m.FEsets(1).fe.quadraturePoints,1);  % Presumes only one type of FE is present.
    else
        num = 6;  % Quad points of a pentahedron.
    end
end
