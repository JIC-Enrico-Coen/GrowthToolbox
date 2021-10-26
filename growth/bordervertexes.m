function vxs = bordervertexes( m )
%vxs = bordervertexes( m )
%   Return a list of indexes of vertexes that lie on the border of the mesh
%   m.  The list is returned in sorted order. (This is not the order in
%   which the vertexes would be encountered by walking along the border.)

    % The border edges are those which have a finite element on only one
    %   side: mesh.edgecells(:,2)==0.
    % The border vertexes are the ends of the border edges:
    %   mesh.edgeends( ..., : ).
    % Each border vertex is an endpoint of at least two edges, so
    %   duplicates are removed: unique( ... ).
    
    if isVolumetricMesh( m )
        vxs = [];
    else
        vxs = unique(m.edgeends(m.edgecells(:,2)==0,:));
    end
end
