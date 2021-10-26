function m = setsaddlez(m,z,cycles)
%m = setsaddlez(m,z,cycles)
%   Apply saddle-shaped displacement of the vertexes of the mesh along
%   whatever axis the mesh is most perpendicular to.

    if z==0, return; end
    if nargin < 3, cycles = 2; end

    if isempty( m.globalInternalProps.flataxes )
        m.globalInternalProps.flataxes = getFlatAxes( m );
    end
    xaxis = m.globalInternalProps.flataxes(1);
    yaxis = m.globalInternalProps.flataxes(2);
    zaxis = m.globalInternalProps.flataxes(3);

    m = makeTRIvalid( m );
    centre = sum( m.nodes, 1 )/size(m.nodes,1);
    
    x = m.nodes(:,xaxis) - centre(xaxis);
    y = m.nodes(:,yaxis) - centre(yaxis);
    if cycles==2
        newz = (x.*x - y.*y);
    else
        newz = ...
            (x.*x + y.*y) .* cos(atan2(y,x)*double(cycles));
    end
    newz = scalevec( newz, -z/2, z/2 );
    m = addToZ( m, newz, zaxis );
    if m.globalProps.rectifyverticals
        m = rectifyVerticals( m );
    end
    m = recalc3d( m );
end
