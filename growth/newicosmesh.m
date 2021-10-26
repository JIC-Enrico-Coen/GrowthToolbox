function m = newicosmesh()
%m = newicosmesh()

    [m.nodes,m.tricellvxs] = icosahedronGeometry();
    m.globalProps.trinodesvalid = true;
    m.globalProps.prismnodesvalid = false;
end
