function m = setlengthscale( m )
%m = setlengthscale( m )    Set m.globalProps.lengthscale to the
%largest diameter of the mesh along the x, y, or z dimensions.

    if usesNewFEs( m )
        mins = min( m.FEnodes, [], 1 );
        maxs = max( m.FEnodes, [], 1 );
    else
        mins = min( m.nodes, [], 1 );
        maxs = max( m.nodes, [], 1 );
    end
    m.globalProps.lengthscale = max( maxs-mins );
end
        