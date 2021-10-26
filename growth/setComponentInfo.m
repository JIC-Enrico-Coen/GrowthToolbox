function m = setComponentInfo( m )
    [nodeindexes,nodesets,edgeindexes,edgesets,cellindexes,cellsets] = connectedComponentsE(m);
    m.componentinfo = struct( ...
        'nodeindexes', nodeindexes, ...
        'edgeindexes', edgeindexes, ...
        'cellindexes', cellindexes );
    % The other results are cell arrays, and therefore cannot be used as
    % arguments to struct().
    m.componentinfo.nodesets = nodesets;
    m.componentinfo.edgesets = edgesets;
    m.componentinfo.cellsets = cellsets;
end
