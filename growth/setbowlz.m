function m = setbowlz(m, amount, centre)
%m = setbowlz(m, amount, centre)
%   Apply bowl-shaped displacement of the vertexes of the mesh along
%   whatever axis the mesh is most perpendicular to.

    if amount==0, return; end

    if isempty( m.globalInternalProps.flataxes )
        m.globalInternalProps.flataxes = getFlatAxes( m );
    end
    x = m.globalInternalProps.flataxes(1);
    y = m.globalInternalProps.flataxes(2);
    z = m.globalInternalProps.flataxes(3);

    newz = (m.nodes(:,x)-centre(x)).^2 + (m.nodes(:,y)-centre(y)).^2;
    newz = scalevec( newz, -amount/2, amount/2 );
    m = addToZ( m, newz, z );
    if m.globalProps.rectifyverticals
        m = rectifyVerticals( m );
    end
    m = recalc3d( m );
    m.initialbendangle = m.currentbendangle;
end
