function m = translatemesh( m, v )
    if isfield( m, 'nodes' )
        m.nodes = translatearray( m.nodes, v );
    end
    if isfield( m, 'prismnodes' )
        m.prismnodes = translatearray( m.prismnodes, v );
    end
end
