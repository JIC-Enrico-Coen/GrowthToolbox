function m = wrapmesh( m, r )
%m = wrapmesh( m, r )
%   m should not contain any components except nodes, prismnodes,
%   globalProps.trinodesvalid, globalProps.prismnodesvalid, and borders.
%   None of these are required.
%   The resulting mesh will have the same components as m.

    if isfield( m, 'nodes' )
        m.nodes = wrappoints( m.nodes, r );
    end
    if isfield( m, 'prismnodes' )
        m.prismnodes = wrappoints( m.prismnodes, r );
    end
end
