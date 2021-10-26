function m = derotate( m )
%m = derotate( m )

    if (m.globalProps.totalinternalrotation ~= 0) ...
            && m.globalProps.internallyrotated
        m = rotatemesh( m, -m.globalProps.totalinternalrotation, 'Z' );
        fprintf( 1, 'derotate, tot %.3f, v1 [ %.3f %.3f %.3f ]\n', ...
            m.globalProps.totalinternalrotation, ...
            m.nodes( 1, : ) );
    end
    m.globalProps.internallyrotated = false;
end
