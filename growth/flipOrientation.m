function m = flipOrientation( m )
    validityCheck = false;
    if isfield( m, 'tricellvxs' )
        m.tricellvxs(:,[2 3]) = m.tricellvxs(:,[3 2]);
    end
    if isfield( m, 'prismnodes' )
        numPN = size( m.prismnodes, 1 );
        prismrenumbering = reshape( (1:numPN)', 2, [] );
        prismrenumbering = prismrenumbering( [2 1], : );
        prismrenumbering = reshape(prismrenumbering,[],1);
        m.prismnodes = m.prismnodes(prismrenumbering,:);
    end
    if isfield( m, 'celledges' )
        m.celledges(:,[2 3]) = m.celledges(:,[3 2]);
        validityCheck = true;
    end
    if isfield( m, 'unitcellnormals' )
        m.unitcellnormals = -m.unitcellnormals;
        validityCheck = true;
    end
    if validityCheck
        validmesh(m);
    end
end
