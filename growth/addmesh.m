function m = addmesh( m, m1 )
%m = addmesh( m, m1 )
%   Combine two meshes which contain only nodes and tricellvxs.

    m.tricellvxs = [ m.tricellvxs; (m1.tricellvxs + size(m.nodes,1)) ];
    m.nodes = [ m.nodes; m1.nodes ];
end
