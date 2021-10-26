function m = rotateXYZ( m, dir )
    if nargin==1
        dir = 1;
    end
    if dir
        p = [3 1 2];
    else
        p = [2 3 1];
    end
    m = rotateArrayField( m, 'nodes', p );
    m = rotateArrayField( m, 'prismnodes', p );
    m = rotateArrayField( m, 'unitcellnormals', p );
    m = rotateArrayField( m, 'gradpolgrowth', p );
    m.globalProps.G = m.globalProps.G(p);
    m = calcCloneVxCoords( m );
    m.secondlayer.cell3dcoords = m.secondlayer.cell3dcoords(:,p);
end

function m = rotateArrayField( m, f, p )
    if isfield( m, f )
        m.(f) = m.(f)(:,p);
    end
end
