function m = setVertexThicknesses( m, vt )
%setVertexThicknesses( m, vt )
%   Set the thickness of m at every vertex.  vt is an N*1 array, where N is
%   the number of vertexes of the finite element mesh.
%
%   SEE ALSO: vertexThicknesses

    if isVolumetricMesh( m )
        return;
    end
    if isempty( m.globalInternalProps.flataxes )
        m.globalInternalProps.flataxes = getFlatAxes( m );
    end
    x = m.globalInternalProps.flataxes(1);
    y = m.globalInternalProps.flataxes(2);
    z = m.globalInternalProps.flataxes(3);
    
    m.prismnodes(:,[x y]) = ...
        reshape( ...
            [ m.nodes(:,[x y])'; ...
              m.nodes(:,[x y])' ], ...
          2, size(m.nodes,1)*2 )';
    m.prismnodes(:,z) = ...
        reshape( ...
            [ m.nodes(:,z)' - vt'/2;
              m.nodes(:,z)' + vt'/2 ], ...
          1, size(m.nodes,1)*2 )';
    
    if any( m.nodes(:,z) ~= 0 )
        if m.globalProps.rectifyverticals
            m = rectifyVerticals(m);
        end
    end
end
