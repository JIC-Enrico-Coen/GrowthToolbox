function m = centremesh( m )
%m = centremesh( m )
%   Translate the mesh m so that the midpoint of the range of its node
%   positions is at the origin.

    mins = min(m.nodes,[],1);
    maxs = max(m.nodes,[],1);
    centre = (mins+maxs)/2;
    for i=1:size(m.nodes,1)
        m.nodes(i,:) = m.nodes(i,:) - centre;
    end
end
